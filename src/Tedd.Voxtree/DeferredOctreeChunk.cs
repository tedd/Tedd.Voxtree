using System.Buffers;

namespace Tedd.Voxtree;

/// <summary>An exclusively owned chunk with pooled sparse edits and optional dense storage.</summary>
/// <remarks>
/// Not thread-safe. Point writes are immediately visible through this owner; previously
/// returned immutable snapshots retain their original values. Dispose returns sparse buffers.
/// Do not access this owner while modifying storage borrowed from MakeHot.
/// </remarks>
public sealed class DeferredOctreeChunk : IDisposable
{
    private OctreeChunk _snapshot;
    private HotOctreeChunk? _hot;
    private SparseVoxelEdits<uint>? _edits;
    private readonly bool _deferredWritesEnabled;
    private bool _disposed;

    /// <summary>Retains an immutable source; capacity counts distinct edited positions across all channels.</summary>
    /// <param name="source">The immutable source snapshot.</param>
    /// <param name="capacity">Maximum sparse positions, 1..1,048,576. Overflow promotes to dense storage.</param>
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
    /// <summary>The number of distinct sparse positions; zero after dense promotion or repackaging.</summary>
    public int PendingPositionCount => _edits?.Count ?? 0;
    /// <summary>Whether this owner retains dense editing storage.</summary>
    public bool IsHot => _hot is not null;
    /// <summary>Whether edits or borrowed dense storage require repackaging.</summary>
    public bool IsDirty => _hot is not null || PendingPositionCount != 0;

    /// <summary>Reads or overwrites a channel value, consulting sparse edits before the compressed source.</summary>
    public uint this[int channel, int x, int y, int z]
    {
        get
        {
            var key = Validate(channel, x, y, z);
            if (_hot is not null) return _hot[channel, x, y, z];
            if (_edits is not null && _edits.TryGet(channel, key, out var value)) return value;
            return _snapshot.GetChannel(channel).Get(x, y, z);
        }
        set
        {
            var key = Validate(channel, x, y, z);
            if (_hot is not null) { _hot[channel, x, y, z] = value; return; }
            var edits = _edits;
            if (edits is null)
            {
                if (!_deferredWritesEnabled)
                {
                    MakeHot()[channel, x, y, z] = value;
                    return;
                }
                _edits = edits = new SparseVoxelEdits<uint>(Levels, ChannelCount, Capacity);
            }
            if (!edits.TrySet(channel, key, value)) MakeHot()[channel, x, y, z] = value;
        }
    }

    /// <summary>Expands once, applies sparse edits, and returns their pooled buffers.</summary>
    /// <remarks>
    /// The returned editor is borrowed exclusively until Repackage or Dispose. Do not commit
    /// it separately; use Repackage on this owner. Borrowed spans must not outlive that call.
    /// </remarks>
    public HotOctreeChunk MakeHot()
    {
        ThrowIfDisposed();
        if (_hot is not null) return _hot;
        var hot = _snapshot.MarkHot();
        if (_edits is not null)
        {
            for (var channel = 0; channel < ChannelCount; channel++)
            {
                if (!_edits.HasChannel(channel)) continue;
                var values = hot.GetChannelSpan(channel);
                for (var i = 0; i < _edits.Count; i++)
                {
                    if (!_edits.HasValue(channel, i)) continue;
                    var key = _edits.Key(i);
                    var mask = SideLength - 1;
                    var x = key >> (Levels * 2);
                    var y = (key >> Levels) & mask;
                    var z = key & mask;
                    values[DenseVoxel.Index(x, y, z, SideLength, DenseVoxelLayout.Morton)] = _edits.Value(channel, i);
                }
            }
        }
        _hot = hot;
        ReleaseEdits();
        return hot;
    }

    /// <summary>Returns a current immutable snapshot and clears pending edits; further writes are allowed.</summary>
    /// <remarks>With sparse edits, only changed channels are decoded and re-encoded. Failed encoding retains pending edits.</remarks>
    public OctreeChunk Repackage()
    {
        ThrowIfDisposed();
        if (_hot is not null)
        {
            var snapshot = _hot.Commit();
            _snapshot = snapshot;
            _hot = null;
        }
        else if (_edits is not null)
        {
            var snapshot = _snapshot;
            var count = OctreeCodec.GetVoxelCount(Levels);
            var buffer = ArrayPool<uint>.Shared.Rent(count);
            try
            {
                var dense = buffer.AsSpan(0, count);
                for (var channel = 0; channel < ChannelCount; channel++)
                {
                    if (!_edits.HasChannel(channel)) continue;
                    _snapshot.GetChannel(channel).CopyBlockTo(0, 0, 0, Levels, dense, DenseVoxelLayout.Morton);
                    for (var i = 0; i < _edits.Count; i++)
                    {
                        if (!_edits.HasValue(channel, i)) continue;
                        var key = _edits.Key(i);
                        var mask = SideLength - 1;
                        var x = key >> (Levels * 2);
                        var y = (key >> Levels) & mask;
                        var z = key & mask;
                        dense[DenseVoxel.Index(x, y, z, SideLength, DenseVoxelLayout.Morton)] = _edits.Value(channel, i);
                    }
                    snapshot = snapshot.WithDenseChannel(channel, dense, DenseVoxelLayout.Morton);
                }
                _snapshot = snapshot;
                ReleaseEdits();
            }
            finally { ArrayPool<uint>.Shared.Return(buffer); }
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

    private void ThrowIfDisposed()
    {
        if (_disposed) throw new ObjectDisposedException(nameof(DeferredOctreeChunk));
    }

    private void ReleaseEdits() { _edits?.Dispose(); _edits = null; }

    /// <summary>Discards pending edits and returns pooled buffers. Previously returned snapshots remain valid.</summary>
    public void Dispose()
    {
        if (_disposed) return;
        ReleaseEdits();
        _hot = null;
        _disposed = true;
    }
}
