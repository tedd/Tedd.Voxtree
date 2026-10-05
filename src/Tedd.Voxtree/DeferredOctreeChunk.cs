using System.Buffers;
using System.Runtime.CompilerServices;

namespace Tedd.Voxtree;

/// <summary>An exclusively owned chunk with pooled sparse edits and optional dense storage.</summary>
/// <remarks>
/// Not thread-safe. Point writes are immediately visible through this owner; previously
/// returned immutable snapshots retain their original values. Dispose returns pooled edit buffers.
/// Do not access this owner while modifying storage borrowed from MakeHot.
/// </remarks>
public sealed class DeferredOctreeChunk : IDisposable
{
    private OctreeChunk _snapshot;
    private HotOctreeChunk? _hot;
    private SparseVoxelEdits<uint>? _edits;
    private PartialVoxelEdits<uint>? _partial;
    private byte[]?[]? _directChannels;
    private readonly bool _deferredWritesEnabled;
    private bool _disposed;

    /// <summary>Retains an immutable source; capacity counts distinct edited positions across all channels.</summary>
    /// <param name="source">The immutable source snapshot.</param>
    /// <param name="capacity">Maximum sparse positions, 1..1,048,576. Overflow materializes affected channels.</param>
    /// <param name="deferredWritesEnabled">Whether point writes use sparse storage before dense promotion.</param>
    public DeferredOctreeChunk(OctreeChunk source, int capacity = 256, bool deferredWritesEnabled = true)
    {
        _snapshot = source ?? throw new ArgumentNullException(nameof(source));
        if (capacity < 1 || capacity > 1_048_576) throw new ArgumentOutOfRangeException(nameof(capacity));
        Capacity = Math.Min(capacity, OctreeCodec.GetVoxelCount(source.Levels));
        _deferredWritesEnabled = deferredWritesEnabled;
    }

    /// <summary>The chunk depth.</summary>
    public int Levels => _snapshot.Levels;
    /// <summary>The chunk side length.</summary>
    public int SideLength => _snapshot.SideLength;
    /// <summary>The independent channel count.</summary>
    public int ChannelCount => _snapshot.ChannelCount;
    /// <summary>The maximum number of distinct sparse positions before dense promotion.</summary>
    public int Capacity { get; }
    /// <summary>Whether point writes use sparse storage before dense promotion.</summary>
    public bool DeferredWritesEnabled => _deferredWritesEnabled;
    /// <summary>The number of distinct positions remaining in sparse storage.</summary>
    public int PendingPositionCount => _edits?.Count ?? _partial?.Edits?.Count ?? 0;
    /// <summary>Whether this owner retains any dense editing storage.</summary>
    public bool IsHot => _hot is not null || _partial is not null;
    /// <summary>Whether edits or borrowed dense storage require repackaging.</summary>
    public bool IsDirty => IsHot || PendingPositionCount != 0 || _directChannels is not null;

    /// <summary>Reads or overwrites a channel value, consulting sparse edits before the compressed source.</summary>
    public uint this[int channel, int x, int y, int z]
    {
        get
        {
            var key = Validate(channel, x, y, z);
            if (_hot is not null) return _hot[channel, x, y, z];
            if (_directChannels?[channel] is { } direct &&
                OctreeCodec.TryGetUnchecked(direct, Levels, StorageKind.Tree, x, y, z, out var directValue))
                return directValue;
            if (_edits is { } edits)
                return edits.TryGet(channel, key, out var sparseValue)
                    ? sparseValue
                    : _snapshot.GetChannel(channel).Get(x, y, z);
            if (_partial is { } partial)
            {
                if (partial.DenseChannels[channel] is { } dense)
                    return dense[DenseVoxel.Index(x, y, z, SideLength, DenseVoxelLayout.Morton)];
                if (partial.Edits is not null && partial.Edits.TryGet(channel, key, out var partialValue))
                    return partialValue;
            }
            return _snapshot.GetChannel(channel).Get(x, y, z);
        }
        set
        {
            var key = Validate(channel, x, y, z);
            if (_hot is not null) { _hot[channel, x, y, z] = value; return; }
            if (_edits is null && _partial is null)
            {
                if (TryDirectSet(channel, x, y, z, value)) return;
                PublishDirect();
            }
            var edits = _edits;
            if (edits is not null)
            {
                if (!edits.TrySet(channel, key, value))
                    SetAfterSparseOverflow(channel, key, x, y, z, value, edits);
                return;
            }
            if (_partial is { } partial)
            {
                SetPartial(partial, channel, key, x, y, z, value);
                return;
            }
            if (!_deferredWritesEnabled)
            {
                MakeHot()[channel, x, y, z] = value;
                return;
            }
            _edits = edits = new SparseVoxelEdits<uint>(Levels, ChannelCount, Capacity);
            edits.TrySet(channel, key, value);
        }
    }

    /// <summary>Expands every channel, applies pending edits, and returns intermediate pooled buffers.</summary>
    /// <remarks>
    /// The returned editor is borrowed exclusively until Repackage or Dispose. Do not commit
    /// it separately; use Repackage on this owner. Borrowed spans must not outlive that call.
    /// </remarks>
    public HotOctreeChunk MakeHot()
    {
        ThrowIfDisposed();
        if (_hot is not null) return _hot;
        PublishDirect();
        var hot = _partial is null
            ? _snapshot.MarkHot()
            : HotOctreeChunk.FromChunkReplacingChannels(_snapshot, _partial.DenseChannels);
        var edits = _edits ?? _partial?.Edits;
        if (edits is not null)
        {
            for (var channel = 0; channel < ChannelCount; channel++)
            {
                if (!edits.HasChannel(channel)) continue;
                ApplyEdits(edits, channel, hot.GetChannelSpan(channel));
            }
        }
        _hot = hot;
        ReleasePendingState();
        return hot;
    }

    /// <summary>Returns a current immutable snapshot and clears pending edits; further writes are allowed.</summary>
    /// <remarks>
    /// Sparse and partially dense state encodes only changed channels. Explicit full-hot state
    /// encodes every channel. Failed encoding retains pending edits.
    /// </remarks>
    public OctreeChunk Repackage()
    {
        ThrowIfDisposed();
        PublishDirect();
        if (_hot is not null)
        {
            var snapshot = _hot.Commit();
            _snapshot = snapshot;
            _hot = null;
        }
        else if (_edits is not null || _partial is not null)
        {
            var snapshot = _snapshot;
            var count = OctreeCodec.GetVoxelCount(Levels);
            uint[]? buffer = null;
            try
            {
                for (var channel = 0; channel < ChannelCount; channel++)
                {
                    if (_partial?.DenseChannels[channel] is { } materialized)
                    {
                        snapshot = snapshot.WithDenseChannel(channel,
                            materialized.AsSpan(0, count), DenseVoxelLayout.Morton);
                        continue;
                    }
                    var edits = _edits ?? _partial?.Edits;
                    if (edits is null || !edits.HasChannel(channel)) continue;
                    buffer ??= ArrayPool<uint>.Shared.Rent(count);
                    var dense = buffer.AsSpan(0, count);
                    _snapshot.GetChannel(channel).CopyBlockTo(0, 0, 0, Levels, dense, DenseVoxelLayout.Morton);
                    ApplyEdits(edits, channel, dense);
                    snapshot = snapshot.WithDenseChannel(channel, dense, DenseVoxelLayout.Morton);
                }
                _snapshot = snapshot;
                ReleasePendingState();
            }
            finally
            {
                if (buffer is not null) ArrayPool<uint>.Shared.Return(buffer);
            }
        }
        return _snapshot;
    }

    /// <summary>Obtains the current immutable chunk, applying and clearing pending edits.</summary>
    public OctreeChunk GetChunk() => Repackage();

    /// <summary>Obtains the current serialized length, applying and clearing pending edits.</summary>
    public int SerializedLength => Repackage().SerializedLength;

    /// <summary>Serializes a current snapshot after applying pending edits.</summary>
    public int CopyEncodedTo(Span<byte> destination) => Repackage().CopyEncodedTo(destination);

    /// <summary>Copies a current block after applying pending edits.</summary>
    public void CopyBlockTo(int x, int y, int z, int levels, Span<uint> destination,
        DenseVoxelLayout layout = DenseVoxelLayout.Linear) =>
        Repackage().CopyBlockTo(x, y, z, levels, destination, layout);

    private int Validate(int channel, int x, int y, int z)
    {
        ThrowIfDisposed();
        if ((uint)channel >= (uint)ChannelCount) throw new ArgumentOutOfRangeException(nameof(channel));
        if ((uint)x >= (uint)SideLength || (uint)y >= (uint)SideLength || (uint)z >= (uint)SideLength)
            throw new ArgumentOutOfRangeException(nameof(x));
        return (x << (Levels * 2)) | (y << Levels) | z;
    }

    private bool TryDirectSet(int channel, int x, int y, int z, uint value)
    {
        if (_directChannels?[channel] is { } direct)
            return OctreeCodec.TryPatchSingleLeaf(direct, direct, Levels, x, y, z, value);
        var source = _snapshot.GetChannelData(channel).Span;
        if (OctreeCodec.GetStorageKindUnchecked(source) != StorageKind.Tree) return false;
        if (!OctreeCodec.TryPatchSingleLeaf(source, Span<byte>.Empty, Levels, x, y, z, value)) return false;
        var copy = source.ToArray();
        OctreeCodec.TryPatchSingleLeaf(copy, copy, Levels, x, y, z, value);
        (_directChannels ??= new byte[]?[ChannelCount])[channel] = copy;
        return true;
    }

    private void PublishDirect()
    {
        if (_directChannels is not { } patches) return;
        _snapshot = _snapshot.WithPatchedChannels(patches);
        _directChannels = null;
    }

    private void ThrowIfDisposed()
    {
        if (_disposed) throw new ObjectDisposedException(nameof(DeferredOctreeChunk));
    }

    private void MaterializeChannel(PartialVoxelEdits<uint> partial, int channel)
    {
        var edits = partial.Edits!;
        var count = OctreeCodec.GetVoxelCount(Levels);
        var buffer = ArrayPool<uint>.Shared.Rent(count);
        var published = false;
        try
        {
            var dense = buffer.AsSpan(0, count);
            _snapshot.GetChannel(channel).CopyBlockTo(0, 0, 0, Levels, dense, DenseVoxelLayout.Morton);
            ApplyEdits(edits, channel, dense);
            edits.RemoveChannel(channel);
            partial.DenseChannels[channel] = buffer;
            published = true;
            if (edits.Count == 0)
            {
                edits.Dispose();
                partial.Edits = null;
            }
        }
        finally
        {
            if (!published) ArrayPool<uint>.Shared.Return(buffer);
        }
    }

    private void ApplyEdits(SparseVoxelEdits<uint> edits, int channel, Span<uint> dense)
    {
        var mask = SideLength - 1;
        for (var index = 0; index < edits.Count; index++)
        {
            if (!edits.HasValue(channel, index)) continue;
            var key = edits.Key(index);
            var x = key >> (Levels * 2);
            var y = (key >> Levels) & mask;
            var z = key & mask;
            dense[DenseVoxel.Index(x, y, z, SideLength, DenseVoxelLayout.Morton)] = edits.Value(channel, index);
        }
    }

    private void ReleasePendingState()
    {
        _edits?.Dispose();
        _edits = null;
        var partial = _partial;
        if (partial is null) return;
        partial.Edits?.Dispose();
        partial.Edits = null;
        for (var channel = 0; channel < partial.DenseChannels.Length; channel++)
        {
            if (partial.DenseChannels[channel] is { } dense) ArrayPool<uint>.Shared.Return(dense);
            partial.DenseChannels[channel] = null;
        }
        _partial = null;
    }

    [MethodImpl(MethodImplOptions.NoInlining)]
    private void SetAfterSparseOverflow(int channel, int key, int x, int y, int z, uint value,
        SparseVoxelEdits<uint> edits)
    {
        var partial = new PartialVoxelEdits<uint>(ChannelCount, edits);
        _partial = partial;
        _edits = null;
        SetPartial(partial, channel, key, x, y, z, value);
    }

    [MethodImpl(MethodImplOptions.NoInlining)]
    private void SetPartial(PartialVoxelEdits<uint> partial, int channel, int key,
        int x, int y, int z, uint value)
    {
        if (partial.DenseChannels[channel] is { } dense)
        {
            dense[DenseVoxel.Index(x, y, z, SideLength, DenseVoxelLayout.Morton)] = value;
            return;
        }
        var edits = partial.Edits ??= new SparseVoxelEdits<uint>(Levels, ChannelCount, Capacity);
        if (edits.TrySet(channel, key, value)) return;
        while (true)
        {
            var selected = edits.SelectChannelToMaterialize();
            if (selected < 0) throw new InvalidOperationException("The sparse edit cache is full without a materializable channel.");
            MaterializeChannel(partial, selected);
            if (partial.DenseChannels[channel] is { } promoted)
            {
                promoted[DenseVoxel.Index(x, y, z, SideLength, DenseVoxelLayout.Morton)] = value;
                return;
            }
            edits = partial.Edits ??= new SparseVoxelEdits<uint>(Levels, ChannelCount, Capacity);
            if (edits.TrySet(channel, key, value)) return;
        }
    }

    /// <summary>Discards pending edits and returns pooled buffers. Previously returned snapshots remain valid.</summary>
    public void Dispose()
    {
        if (_disposed) return;
        ReleasePendingState();
        _hot = null;
        _disposed = true;
    }
}
