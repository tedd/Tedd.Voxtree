using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

// End-to-end query costs, including bounds validation and dense dispatch.
[MemoryDiagnoser]
public class AccessQueries
{
    private Octree _tree = null!;
    private Octree<uint> _generic = null!;
    private VoxelBox _box;
    private VoxelFilter _masked = VoxelFilter.Masked(15, 7);
    private VoxelFilter<uint> _genericMasked = VoxelFilter<uint>.Masked(15, 7);

    [Params(3, 5)] public int Levels { get; set; }
    [Params(false, true)] public bool Strided { get; set; }

    [GlobalSetup]
    public void Setup()
    {
        var side = 1 << Levels;
        var data = BenchmarkData.Create(Levels, DataPattern.Random);
        data[0] = 7;
        _tree = new Octree(Levels);
        _tree.Build(data);
        _generic = new Octree<uint>(Levels, data);
        _box = new VoxelBox(0, 0, 0, side, side, Strided ? side - 1 : side);
        var masked = 0;
        for (var x = 0; x < side; x++)
        for (var y = 0; y < side; y++)
        for (var z = 0; z < _box.MaxZ; z++)
            if ((data[(x * side + y) * side + z] & 15) == 7) masked++;
        if (MaskedCount() != masked || GenericMaskedCount() != masked ||
            EqualityCount() != GenericEqualityCount() || AnyMissing() || GenericAnyMissing() ||
            !AnyFirst() || !GenericAnyFirst())
            throw new InvalidOperationException("Query parity failed.");
    }

    [Benchmark] public int MaskedCount() => _tree.CountMatches(_box, _masked);
    [Benchmark] public int GenericMaskedCount() => _generic.CountMatches(_box, _genericMasked);
    [Benchmark] public int EqualityCount() => _tree.CountMatches(_box, VoxelFilter.EqualTo(7));
    [Benchmark] public int GenericEqualityCount() => _generic.CountMatches(_box, VoxelFilter<uint>.EqualTo(7));
    [Benchmark] public bool AnyMissing() => _tree.Any(_box, VoxelFilter.Masked(0x80000000, 0x80000000));
    [Benchmark] public bool GenericAnyMissing() => _generic.Any(_box, VoxelFilter<uint>.Masked(0x80000000, 0x80000000));
    [Benchmark] public bool AnyFirst() => _tree.Any(_box, _masked);
    [Benchmark] public bool GenericAnyFirst() => _generic.Any(_box, _genericMasked);
}
