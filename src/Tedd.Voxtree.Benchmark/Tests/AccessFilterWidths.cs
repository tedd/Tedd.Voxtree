using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

[MemoryDiagnoser]
[GenericTypeArguments(typeof(byte))]
[GenericTypeArguments(typeof(ushort))]
[GenericTypeArguments(typeof(uint))]
[GenericTypeArguments(typeof(ulong))]
public class AccessFilterWidths<T> where T : unmanaged
{
    private T[] _values = null!;
    private Octree<T> _tree = null!;
    private VoxelFilter<T> _filter;
    private VoxelBox _box;

    [Params(false, true)] public bool Strided { get; set; }

    [GlobalSetup]
    public void Setup()
    {
        _values = new T[32768];
        new Random(217).NextBytes(MemoryMarshal.AsBytes(_values.AsSpan()));
        var bytes = Enumerable.Repeat((byte)0x55, Unsafe.SizeOf<T>()).ToArray();
        _filter = VoxelFilter<T>.Masked(MemoryMarshal.Read<T>(bytes), _values[7]);
        _tree = new Octree<T>(5, _values);
        _box = new VoxelBox(0, 0, 0, 32, 32, Strided ? 31 : 32);
        if ((_tree.Data.Span[1] & 3) != 2 || Scalar() != Query())
            throw new InvalidOperationException("Dense filter parity failed.");
    }

    // Scalar oracle excludes tree validation/dispatch, making it a conservative control.
    [Benchmark(Baseline = true)]
    public int Scalar()
    {
        var count = 0;
        for (var row = 0; row < 1024; row++)
        for (var z = 0; z < _box.MaxZ; z++)
            if (_filter.Matches(_values[row * 32 + z])) count++;
        return count;
    }

    [Benchmark] public int Query() => _tree.CountMatches(_box, _filter);
}
