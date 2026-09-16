using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

[MemoryDiagnoser]
public class AccessLookupBuild
{
    private Octree _tree = null!;
    [Params(DataPattern.Uniform, DataPattern.Clustered, DataPattern.Sparse, DataPattern.Random)]
    public DataPattern Pattern { get; set; }
    [GlobalSetup] public void Setup() => _tree = new Octree(5, BenchmarkData.Create(5, Pattern));
    [Benchmark] public OctreeLookup CompileBorrowed() => _tree.AsSpan().CreateLookup();
    [Benchmark] public OctreeLookup Compile() => _tree.CreateLookup();
    [Benchmark]
    public uint[] Decode()
    {
        var values = new uint[_tree.Count];
        _tree.CopyTo(values);
        return values;
    }
}
