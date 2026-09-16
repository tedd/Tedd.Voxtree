using System.Runtime.InteropServices;
using System.Runtime.Intrinsics.X86;
using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

// A rotating working set prevents a fixed small random query list from becoming cache-resident.
[MemoryDiagnoser]
public unsafe class AccessPrefetch
{
    private const int Operations = 65536;
    private uint* _data;
    private int[] _indices = null!;
    private int _mask, _epoch;

    [Params(1, 128)] public int MiB { get; set; }
    [Params(QueryPattern.Sequential, QueryPattern.Random)] public QueryPattern Queries { get; set; }

    [GlobalSetup]
    public void Setup()
    {
        var count = MiB * 1024 * 1024 / 4;
        _mask = count - 1;
        _data = (uint*)NativeMemory.AlignedAlloc((nuint)(count * 4), 64);
        for (var i = 0; i < count; i++) _data[i] = (uint)i;
        var random = new Random(123);
        _indices = new int[Operations + 64];
        for (var i = 0; i < _indices.Length; i++)
            _indices[i] = Queries == QueryPattern.Sequential ? i : random.Next(count);
        _epoch = 0;
        var expected = Demand();
        _epoch = 0;
        if (Prefetch16() != expected) throw new InvalidOperationException("Prefetch parity.");
        _epoch = 0;
        if (Prefetch64() != expected) throw new InvalidOperationException("Prefetch parity.");
    }

    [GlobalCleanup] public void Cleanup() => NativeMemory.AlignedFree(_data);

    [Benchmark(Baseline = true, OperationsPerInvoke = Operations)]
    public uint Demand()
    {
        var epoch = _epoch;
        _epoch = (_epoch + Operations) & _mask;
        uint sum = 0;
        for (var i = 0; i < Operations; i++) sum += _data[(_indices[i] + epoch) & _mask];
        return sum;
    }

    [Benchmark(OperationsPerInvoke = Operations)] public uint Prefetch16() => Prefetch(16);
    [Benchmark(OperationsPerInvoke = Operations)] public uint Prefetch64() => Prefetch(64);

    private uint Prefetch(int distance)
    {
        if (!Sse.IsSupported) return Demand();
        var epoch = _epoch;
        _epoch = (_epoch + Operations) & _mask;
        uint sum = 0;
        for (var i = 0; i < Operations; i++)
        {
            Sse.Prefetch0(_data + ((_indices[i + distance] + epoch) & _mask));
            sum += _data[(_indices[i] + epoch) & _mask];
        }
        return sum;
    }
}
