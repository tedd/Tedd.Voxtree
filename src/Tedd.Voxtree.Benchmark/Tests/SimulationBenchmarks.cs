using BenchmarkDotNet.Attributes;
using Tedd.Voxtree.Simulations;

namespace Tedd.Voxtree.Benchmark.Tests;

[MemoryDiagnoser]
public class SimulationBenchmarks
{
    [Params(3, 5)] public int Levels { get; set; }
    [Params(SimulationKind.Water, SimulationKind.Heat, SimulationKind.Tracer)]
    public SimulationKind Kind { get; set; }
    [Params(SimulationAccess.Linear, SimulationAccess.Random)]
    public SimulationAccess Access { get; set; }
    private SimulationWorkload _workload = null!;

    [GlobalSetup]
    public void Setup() => _workload = new SimulationWorkload(Levels, Kind, Access);

    // Each invocation starts from the same state; setup cost is deliberately included.
    [Benchmark]
    public ulong EightSteps()
    {
        _workload.Reset();
        return _workload.Run(8);
    }
}

[MemoryDiagnoser, DisassemblyDiagnoser(maxDepth: 3)]
public class DenseSimulationAccess
{
    [Params(DenseVoxelLayout.Linear, DenseVoxelLayout.Morton)]
    public DenseVoxelLayout Layout { get; set; }
    [Params(SimulationAccess.Linear, SimulationAccess.Random)]
    public SimulationAccess Access { get; set; }
    private uint[] _values = null!;
    private int[] _order = null!;

    [GlobalSetup]
    public void Setup()
    {
        _values = new uint[32 * 32 * 32];
        _order = Enumerable.Range(0, _values.Length).ToArray();
        if (Access == SimulationAccess.Random)
        {
            var random = new Random(1729);
            random.Shuffle(_order);
        }
        var block = new DenseVoxelBlockSpan(_values, 5, 1, Layout);
        foreach (var i in _order) block[0, i >> 10, (i >> 5) & 31, i & 31] = (uint)i;
    }

    [Benchmark(OperationsPerInvoke = 32768)]
    public ulong Read()
    {
        var block = new DenseVoxelBlockSpan(_values, 5, 1, Layout);
        ulong sum = 0;
        foreach (var i in _order) sum += block[0, i >> 10, (i >> 5) & 31, i & 31];
        return sum;
    }
}
