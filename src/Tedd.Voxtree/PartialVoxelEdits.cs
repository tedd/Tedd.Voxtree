namespace Tedd.Voxtree;

// Allocated only after sparse overflow. Keeping this state behind one reference
// leaves the ordinary sparse-write path independent of partially dense channels.
internal sealed class PartialVoxelEdits<T> where T : unmanaged
{
    internal PartialVoxelEdits(int channels, SparseVoxelEdits<T> edits)
    {
        DenseChannels = new T[channels][];
        Edits = edits;
    }

    internal T[]?[] DenseChannels { get; }
    internal SparseVoxelEdits<T>? Edits { get; set; }
}
