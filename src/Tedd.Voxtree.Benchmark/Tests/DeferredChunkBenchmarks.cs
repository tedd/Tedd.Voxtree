using System.Numerics;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics;
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Configs;

namespace Tedd.Voxtree.Benchmark.Tests;

public enum DeferredChunkPattern { Uniform, Terrain }

internal static class DeferredChunkData
{
    internal const int Volume = 32 * 32 * 32;

    internal static OctreeChunk Create(DeferredChunkPattern pattern)
    {
        var values = new uint[Volume * 2];
        for (var c = 0; c < 2; c++)
        for (var x = 0; x < 32; x++)
        for (var y = 0; y < 32; y++)
        for (var z = 0; z < 32; z++)
            values[c * Volume + (x * 32 + y) * 32 + z] = pattern == DeferredChunkPattern.Uniform
                ? (uint)(c + 1)
                : y < 12 + ((x + z) & 3) ? (uint)(c + 1) : 0;
        return OctreeChunk.FromDense(5, 2, values);
    }

    // Odd stride gives unique positions within the 15-bit position domain.
    internal static int Position(int index) => (index * 977 + 1234) & 32767;
    internal static int X(int position) => position >> 10;
    internal static int Y(int position) => (position >> 5) & 31;
    internal static int Z(int position) => position & 31;
}

[MemoryDiagnoser]
[GroupBenchmarksBy(BenchmarkLogicalGroupRule.ByCategory)]
[CategoriesColumn]
public class DeferredChunkWrites
{
    [Params(1, 5, 20)] public int WriteCount { get; set; }
    [Params(DeferredChunkPattern.Uniform, DeferredChunkPattern.Terrain)]
    public DeferredChunkPattern Pattern { get; set; }
    private OctreeChunk _source = null!;

    [GlobalSetup]
    public void Setup()
    {
        _source = DeferredChunkData.Create(Pattern);
        if (MarkHotEdits() != DeferredEdits() || MarkHotAndCommit() != DeferredAndRepackage())
            throw new InvalidOperationException("Deferred write benchmark parity failed.");
    }

    [Benchmark(Baseline = true), BenchmarkCategory("Edits")]
    public uint MarkHotEdits()
    {
        var editor = _source.MarkHot();
        Write(editor);
        var p = DeferredChunkData.Position(0);
        return editor[0, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)]
             + editor[1, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)];
    }

    [Benchmark, BenchmarkCategory("Edits")]
    public uint DeferredEdits()
    {
        using var editor = new DeferredOctreeChunk(_source);
        Write(editor);
        var p = DeferredChunkData.Position(0);
        return editor[0, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)]
             + editor[1, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)];
    }

    [Benchmark(Baseline = true), BenchmarkCategory("Repackage")]
    public uint MarkHotAndCommit()
    {
        var editor = _source.MarkHot();
        Write(editor);
        return Checksum(editor.Commit());
    }

    [Benchmark, BenchmarkCategory("Repackage")]
    public uint DeferredAndRepackage()
    {
        using var editor = new DeferredOctreeChunk(_source);
        Write(editor);
        return Checksum(editor.Repackage());
    }

    private void Write(HotOctreeChunk editor)
    {
        for (var i = 0; i < WriteCount; i++)
        {
            var p = DeferredChunkData.Position(i);
            editor[i & 1, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)] = (uint)(100 + i);
        }
        var first = DeferredChunkData.Position(0);
        editor[1, DeferredChunkData.X(first), DeferredChunkData.Y(first), DeferredChunkData.Z(first)] = 501;
        editor[1, DeferredChunkData.X(first), DeferredChunkData.Y(first), DeferredChunkData.Z(first)] = 502;
    }

    private void Write(DeferredOctreeChunk editor)
    {
        for (var i = 0; i < WriteCount; i++)
        {
            var p = DeferredChunkData.Position(i);
            editor[i & 1, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)] = (uint)(100 + i);
        }
        var first = DeferredChunkData.Position(0);
        editor[1, DeferredChunkData.X(first), DeferredChunkData.Y(first), DeferredChunkData.Z(first)] = 501;
        editor[1, DeferredChunkData.X(first), DeferredChunkData.Y(first), DeferredChunkData.Z(first)] = 502;
    }

    private static uint Checksum(OctreeChunk chunk)
    {
        var p = DeferredChunkData.Position(0);
        return (uint)chunk.SerializedLength
             + chunk.GetChannel(1).Get(DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p));
    }
}

[MemoryDiagnoser]
[GroupBenchmarksBy(BenchmarkLogicalGroupRule.ByCategory)]
[CategoriesColumn]
public class DeferredChunkReads
{
    private const int Queries = 256;
    [Params(1, 20)] public int PendingCount { get; set; }
    [Params(DeferredChunkPattern.Uniform, DeferredChunkPattern.Terrain)]
    public DeferredChunkPattern Pattern { get; set; }
    private OctreeChunk _source = null!;
    private HotOctreeChunk _hot = null!;
    private DeferredOctreeChunk _deferred = null!;
    private readonly int[] _hits = new int[Queries];
    private readonly int[] _misses = new int[Queries];

    [GlobalSetup]
    public void Setup()
    {
        _source = DeferredChunkData.Create(Pattern);
        _hot = _source.MarkHot();
        _deferred = new DeferredOctreeChunk(_source);
        for (var i = 0; i < PendingCount; i++)
        {
            var p = DeferredChunkData.Position(i);
            for (var c = 0; c < 2; c++)
                _hot[c, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)] =
                    _deferred[c, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)] = (uint)(100 + i + c);
        }
        var random = new Random(419);
        for (var i = 0; i < Queries; i++)
        {
            _hits[i] = DeferredChunkData.Position(random.Next(PendingCount));
            _misses[i] = DeferredChunkData.Position(PendingCount + random.Next(256));
        }
        if (HotHits() != DeferredHits() || CompressedMisses() != DeferredMisses())
            throw new InvalidOperationException("Deferred read benchmark parity failed.");
    }

    [GlobalCleanup] public void Cleanup() => _deferred.Dispose();

    [Benchmark(Baseline = true, OperationsPerInvoke = Queries), BenchmarkCategory("Hit")]
    public uint HotHits()
    {
        var sum = 0u;
        for (var i = 0; i < Queries; i++)
        {
            var p = _hits[i];
            sum += _hot[i & 1, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)];
        }
        return sum;
    }

    [Benchmark(OperationsPerInvoke = Queries), BenchmarkCategory("Hit")]
    public uint DeferredHits() => ReadDeferred(_hits);

    [Benchmark(Baseline = true, OperationsPerInvoke = Queries), BenchmarkCategory("Miss")]
    public uint CompressedMisses()
    {
        var sum = 0u;
        for (var i = 0; i < Queries; i++)
        {
            var p = _misses[i];
            sum += _source.GetChannel(i & 1).Get(DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p));
        }
        return sum;
    }

    [Benchmark(OperationsPerInvoke = Queries), BenchmarkCategory("Miss")]
    public uint DeferredMisses() => ReadDeferred(_misses);

    private uint ReadDeferred(int[] positions)
    {
        var sum = 0u;
        for (var i = 0; i < Queries; i++)
        {
            var p = positions[i];
            sum += _deferred[i & 1, DeferredChunkData.X(p), DeferredChunkData.Y(p), DeferredChunkData.Z(p)];
        }
        return sum;
    }
}

[MemoryDiagnoser]
[DisassemblyDiagnoser(maxDepth: 3)]
public class DeferredPositionLookup
{
    private const int Queries = 256;
    [Params(1, 5, 20, 256)] public int Count { get; set; }
    private ushort[] _positions = null!;
    private readonly ushort[] _queries = new ushort[Queries];

    [GlobalSetup]
    public void Setup()
    {
        _positions = new ushort[(Count + 15) & ~15];
        _positions.AsSpan().Fill(ushort.MaxValue);
        for (var i = 0; i < Count; i++) _positions[i] = (ushort)DeferredChunkData.Position(i);
        var random = new Random(947);
        for (var i = 0; i < Queries; i++)
            _queries[i] = (i % 4) switch
            {
                0 => _positions[0],
                1 => _positions[Count - 1],
                2 => _positions[random.Next(Count)],
                _ => (ushort)DeferredChunkData.Position(Count + random.Next(256))
            };
        // Exercise every prefix, vector tail, first/last lane and padding boundary.
        for (var length = 0; length <= Count; length++)
        {
            var logical = _positions.AsSpan(0, length);
            for (var i = 0; i <= Count; i++)
            {
                var target = (ushort)DeferredChunkData.Position(i);
                var expected = ScalarIndexOf(logical, target);
                if (logical.IndexOf(target) != expected || VectorIndexOf(logical, target) != expected)
                    throw new InvalidOperationException("Vector lookup differential check failed.");
            }
        }
        if (Scalar() != SpanIndexOf() || Scalar() != ExplicitVector256() || Scalar() != PaddedVector256())
            throw new InvalidOperationException("Position lookup benchmark parity failed.");
    }

    [Benchmark(Baseline = true, OperationsPerInvoke = Queries)]
    public int Scalar()
    {
        var sum = 0;
        var positions = _positions.AsSpan(0, Count);
        foreach (var target in _queries) sum += ScalarIndexOf(positions, target);
        return sum;
    }

    [Benchmark(OperationsPerInvoke = Queries)]
    public int SpanIndexOf()
    {
        var sum = 0;
        var positions = _positions.AsSpan(0, Count);
        foreach (var target in _queries) sum += positions.IndexOf(target);
        return sum;
    }

    [Benchmark(OperationsPerInvoke = Queries)]
    public int ExplicitVector256()
    {
        var sum = 0;
        var positions = _positions.AsSpan(0, Count);
        foreach (var target in _queries) sum += VectorIndexOf(positions, target);
        return sum;
    }

    [Benchmark(OperationsPerInvoke = Queries)]
    public int PaddedVector256()
    {
        var sum = 0;
        foreach (var target in _queries) sum += VectorIndexOf(_positions, target);
        return sum;
    }

    private static int ScalarIndexOf(ReadOnlySpan<ushort> values, ushort target)
    {
        for (var i = 0; i < values.Length; i++) if (values[i] == target) return i;
        return -1;
    }

    private static int VectorIndexOf(ReadOnlySpan<ushort> values, ushort target)
    {
        var offset = 0;
        if (Vector256.IsHardwareAccelerated && values.Length >= Vector256<ushort>.Count)
        {
            var needle = Vector256.Create(target);
            for (; offset <= values.Length - Vector256<ushort>.Count; offset += Vector256<ushort>.Count)
            {
                var current = Vector256.LoadUnsafe(ref Unsafe.AsRef(in values[0]), (nuint)offset);
                var mask = Vector256.Equals(current, needle).ExtractMostSignificantBits();
                if (mask != 0) return offset + BitOperations.TrailingZeroCount(mask);
            }
        }
        for (; offset < values.Length; offset++) if (values[offset] == target) return offset;
        return -1;
    }
}
