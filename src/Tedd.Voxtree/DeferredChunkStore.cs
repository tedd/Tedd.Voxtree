namespace Tedd.Voxtree;

/// <summary>Owns deferred chunk edits and tracks chunks awaiting repackaging.</summary>
/// <remarks>
/// All operations are synchronized. Point reads include pending edits. Snapshot reads apply
/// pending edits and return immutable chunks suitable for serialization or publication into a world.
/// Repackaging holds the store lock; schedule bounded batches to limit reader and writer stalls.
/// Existing worlds retain their published snapshots until the caller replaces them explicitly.
/// </remarks>
public sealed class DeferredChunkStore : IDisposable
{
    private readonly object _gate = new();
    private readonly Dictionary<ChunkAddress, DeferredOctreeChunk> _chunks = new();
    private readonly HashSet<ChunkAddress> _pending = new();
    private bool _disposed;

    /// <summary>Creates a store with a maximum number of sparse positions per chunk before dense promotion.</summary>
    /// <param name="capacity">Maximum sparse positions, 1..1,048,576, capped at each chunk's voxel count.</param>
    public DeferredChunkStore(int capacity = 256)
    {
        if (capacity < 1 || capacity > 1_048_576) throw new ArgumentOutOfRangeException(nameof(capacity));
        Capacity = capacity;
    }

    /// <summary>The sparse position capacity used by newly installed chunks.</summary>
    public int Capacity { get; }

    /// <summary>The number of chunks with edits or dense storage awaiting repackaging.</summary>
    public int PendingRepackageCount
    {
        get { lock (_gate) { ThrowIfDisposed(); return _pending.Count; } }
    }

    /// <summary>Installs a snapshot, discarding pending edits at the same address.</summary>
    public void SetChunk(ChunkAddress address, OctreeChunk chunk)
    {
        if (chunk is null) throw new ArgumentNullException(nameof(chunk));
        lock (_gate)
        {
            ThrowIfDisposed();
            var replacement = new DeferredOctreeChunk(chunk, Capacity);
            if (_chunks.TryGetValue(address, out var previous)) previous.Dispose();
            _chunks[address] = replacement;
            _pending.Remove(address);
        }
    }

    /// <summary>Reads a channel value using chunk-local coordinates, including pending edits.</summary>
    public uint Get(ChunkAddress address, int channel, int x, int y, int z)
    {
        lock (_gate) { return Find(address)[channel, x, y, z]; }
    }

    /// <summary>Writes a channel value using chunk-local coordinates and schedules its chunk for repackaging.</summary>
    public void Set(ChunkAddress address, int channel, int x, int y, int z, uint value)
    {
        lock (_gate)
        {
            var chunk = Find(address);
            // Reserve queue membership before mutating, so allocation failure cannot lose work.
            _pending.Add(address);
            try { chunk[channel, x, y, z] = value; }
            finally { if (!chunk.IsDirty) _pending.Remove(address); }
        }
    }

    /// <summary>Promotes a chunk to private dense storage for subsequent point writes.</summary>
    public void MakeHot(ChunkAddress address)
    {
        lock (_gate)
        {
            var chunk = Find(address);
            _pending.Add(address);
            try { chunk.MakeHot(); }
            finally { if (!chunk.IsDirty) _pending.Remove(address); }
        }
    }

    /// <summary>Applies pending edits and returns the current immutable snapshot.</summary>
    public OctreeChunk GetChunk(ChunkAddress address)
    {
        lock (_gate)
        {
            var snapshot = Find(address).Repackage();
            _pending.Remove(address);
            return snapshot;
        }
    }

    /// <summary>Copies the current chunk packet after applying pending edits.</summary>
    public int CopyEncodedTo(ChunkAddress address, Span<byte> destination) =>
        GetChunk(address).CopyEncodedTo(destination);

    /// <summary>Copies a dense block from the current snapshot after applying pending edits.</summary>
    public void CopyBlockTo(ChunkAddress address, int x, int y, int z, int levels,
        Span<uint> destination, DenseVoxelLayout layout = DenseVoxelLayout.Linear) =>
        GetChunk(address).CopyBlockTo(x, y, z, levels, destination, layout);

    /// <summary>Returns a stable copy of addresses awaiting repackaging, in unspecified order.</summary>
    /// <remarks>The copy is advisory: chunks may be changed, repackaged, replaced, or removed afterward.</remarks>
    public ChunkAddress[] GetPendingRepackageChunks()
    {
        lock (_gate)
        {
            ThrowIfDisposed();
            var result = new ChunkAddress[_pending.Count];
            _pending.CopyTo(result);
            return result;
        }
    }

    /// <summary>Repackages up to the specified number of pending chunks and returns the number processed.</summary>
    public int Repackage(int maxChunks = int.MaxValue)
    {
        if (maxChunks < 0) throw new ArgumentOutOfRangeException(nameof(maxChunks));
        lock (_gate)
        {
            ThrowIfDisposed();
            var count = Math.Min(maxChunks, _pending.Count);
            if (count == 0) return 0;
            var addresses = new ChunkAddress[count];
            var index = 0;
            foreach (var address in _pending)
            {
                addresses[index++] = address;
                if (index == count) break;
            }
            foreach (var address in addresses)
            {
                _chunks[address].Repackage();
                _pending.Remove(address);
            }
            return count;
        }
    }

    /// <summary>Removes a chunk and discards its pending edits, releasing its pooled storage.</summary>
    public bool Remove(ChunkAddress address)
    {
        lock (_gate)
        {
            ThrowIfDisposed();
            if (!_chunks.TryGetValue(address, out var chunk)) return false;
            chunk.Dispose();
            _chunks.Remove(address);
            _pending.Remove(address);
            return true;
        }
    }

    /// <summary>Discards all pending edits and releases storage owned by this store.</summary>
    public void Dispose()
    {
        lock (_gate)
        {
            if (_disposed) return;
            foreach (var chunk in _chunks.Values) chunk.Dispose();
            _chunks.Clear();
            _pending.Clear();
            _disposed = true;
        }
    }

    private DeferredOctreeChunk Find(ChunkAddress address)
    {
        ThrowIfDisposed();
        return _chunks[address];
    }

    private void ThrowIfDisposed()
    {
        if (_disposed) throw new ObjectDisposedException(nameof(DeferredChunkStore));
    }
}
