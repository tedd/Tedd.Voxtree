using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Configs;

namespace Tedd.Voxtree.Benchmark.Tests;

// Hypothesis: sparse-edit savings persist through the actual store's synchronized
// lookup, replacement and pending-work bookkeeping. Compare the same store API
// with immediate MakeHot versus deferred edits. Require >=20% edit-session gain
// and <=15% complete-cycle regression, independently confirmed beyond noise.
// The warm single-address fixture measures uncontended throughput, not concurrent
// scheduling or tail latency. SetChunk charges previous-editor disposal to the
// next invocation; construction and initial dictionary allocation are setup costs.
[MemoryDiagnoser]
[GroupBenchmarksBy(BenchmarkLogicalGroupRule.ByCategory)]
[CategoriesColumn]
public class DeferredStoreBenchmarks
{
    [Params(1, 20)] public int WriteCount { get; set; }
    private readonly ChunkAddress _address = new(0, 2, 3, 4);
    private OctreeChunk _source = null!;
    private DeferredChunkStore _store = null!;

    [GlobalSetup]
    public void Setup()
    {
        _source = DeferredChunkData.Create(DeferredChunkPattern.Terrain);
        _store = new DeferredChunkStore();
        _store.SetChunk(_address, _source);
        var hotEdits = ImmediateHotEdits();
        ValidatePending();
        var deferredEdits = DeferredEdits();
        ValidatePending();
        if (hotEdits != deferredEdits)
            throw new InvalidOperationException("Deferred store edit benchmark parity failed.");
        var hotCycle = ImmediateHotCompleteCycle();
        if (_store.PendingRepackageCount != 0)
            throw new InvalidOperationException("Hot store cycle did not drain pending work.");
        var deferredCycle = DeferredCompleteCycle();
        if (hotCycle != deferredCycle || _store.PendingRepackageCount != 0)
            throw new InvalidOperationException("Deferred store cycle benchmark parity failed.");
    }

    [GlobalCleanup] public void Cleanup() => _store.Dispose();

    [Benchmark(Baseline = true), BenchmarkCategory("Edit")]
    public uint ImmediateHotEdits()
    {
        _store.SetChunk(_address, _source);
        _store.MakeHot(_address);
        Write();
        return ReadChecksum();
    }

    [Benchmark, BenchmarkCategory("Edit")]
    public uint DeferredEdits()
    {
        _store.SetChunk(_address, _source);
        Write();
        return ReadChecksum();
    }

    [Benchmark(Baseline = true), BenchmarkCategory("CompleteCycle")]
    public uint ImmediateHotCompleteCycle()
    {
        _store.SetChunk(_address, _source);
        _store.MakeHot(_address);
        Write();
        return CompleteChecksum();
    }

    [Benchmark, BenchmarkCategory("CompleteCycle")]
    public uint DeferredCompleteCycle()
    {
        _store.SetChunk(_address, _source);
        Write();
        return CompleteChecksum();
    }

    private void Write()
    {
        for (var i = 0; i < WriteCount; i++)
        {
            var p = DeferredChunkData.Position(i);
            _store.Set(_address, i & 1, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p), (uint)(100 + i));
        }
        var first = DeferredChunkData.Position(0);
        _store.Set(_address, 1, DeferredChunkData.X(first), DeferredChunkData.Y(first), DeferredChunkData.Z(first), 501);
        _store.Set(_address, 1, DeferredChunkData.X(first), DeferredChunkData.Y(first), DeferredChunkData.Z(first), 502);
    }

    private uint ReadChecksum()
    {
        var p = DeferredChunkData.Position(0);
        return _store.Get(_address, 0, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p))
             + _store.Get(_address, 1, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p));
    }

    private uint CompleteChecksum()
    {
        var processed = _store.Repackage(1);
        var snapshot = _store.GetChunk(_address);
        return (uint)(processed + snapshot.SerializedLength) + ReadChecksum();
    }

    private void ValidatePending()
    {
        var pending = _store.GetPendingRepackageChunks();
        if (pending.Length != 1 || !pending[0].Equals(_address))
            throw new InvalidOperationException("Store benchmark pending snapshot mismatch.");
    }
}
