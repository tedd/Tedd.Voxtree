using System.Runtime.InteropServices;

namespace Tedd.Voxtree.Tests;

public sealed class LeafLodTests
{
    [Theory]
    [InlineData(0)]
    [InlineData(1)]
    [InlineData(3)]
    [InlineData(9)]
    public void UniformStorageReturnsTheWholeVolumeLevel(int levels)
    {
        foreach (var expected in new[] { 0u, 42u, uint.MaxValue })
        {
            var tree = new Octree(levels, expected);
            var lookup = tree.CreateLookup();
            var last = tree.SideLength - 1;
            foreach (var coordinate in new[] { 0, last })
            {
                Assert.Equal(expected, tree.Get(coordinate, coordinate, coordinate, out var lod));
                Assert.Equal(levels, lod);
                Assert.Equal(levels, tree.GetLod(coordinate, coordinate, coordinate, out var value));
                Assert.Equal(expected, value);
                Assert.Equal(expected, tree.AsSpan().Get(coordinate, coordinate, coordinate, out lod));
                Assert.Equal(levels, lod);
                Assert.Equal(levels, lookup.GetLod(coordinate, coordinate, coordinate, out value));
                Assert.Equal(expected, value);
                Assert.True(tree.TryGet(coordinate, coordinate, coordinate, out value, out lod));
                Assert.Equal(expected, value);
                Assert.Equal(levels, lod);
            }
        }
    }

    [Fact]
    public void EveryCoordinateReportsItsContainingLeafRatherThanTheTreeDepth()
    {
        var source = MixedLeaves();
        var tree = new Octree(3, source);
        Assert.Equal(0, tree.Data.Span[1] & 3); // Tree representation.
        var span = tree.AsSpan();
        var lookup = tree.CreateLookup();
        var seen = new HashSet<int>();
        for (var x = 0; x < 8; x++)
        for (var y = 0; y < 8; y++)
        for (var z = 0; z < 8; z++)
        {
            var expected = source[(x * 8 + y) * 8 + z];
            var expectedLod = LargestUniformCube(source, 3, x, y, z);
            seen.Add(expectedLod);
            Assert.Equal(expected, tree.Get(x, y, z, out var lod));
            Assert.Equal(expectedLod, lod);
            Assert.Equal(expectedLod, tree.GetLod(x, y, z, out var value));
            Assert.Equal(expected, value);
            Assert.Equal(expectedLod, span.GetLod(x, y, z, out value));
            Assert.Equal(expected, value);
            Assert.True(tree.TryGet(x, y, z, out value, out lod));
            Assert.Equal(expected, value);
            Assert.Equal(expectedLod, lod);
            Assert.True(span.TryGet(x, y, z, out value, out lod));
            Assert.Equal(expected, value);
            Assert.Equal(expectedLod, lod);
            Assert.Equal(expected, lookup.Get(x, y, z, out lod));
            Assert.Equal(expectedLod, lod);
            Assert.True(lookup.TryGet(x, y, z, out value, out lod));
            Assert.Equal(expected, value);
            Assert.Equal(expectedLod, lod);
        }
        Assert.Equal(new[] { 0, 1, 2 }, seen.Order().ToArray());
    }

    [Fact]
    public void AdjacentDifferentTwoCubedLeavesEachReturnLevelOne()
    {
        var source = new uint[512];
        for (var x = 0; x < 8; x++)
        for (var y = 0; y < 8; y++)
        for (var z = 0; z < 8; z++)
            source[(x * 8 + y) * 8 + z] = (uint)(1 + ((x >> 1) * 4 + (y >> 1)) * 4 + (z >> 1));
        var tree = new Octree(3, source);
        for (var x = 0; x < 8; x++)
        for (var y = 0; y < 8; y++)
        for (var z = 0; z < 8; z++)
        {
            Assert.Equal(1, tree.GetLod(x, y, z, out var value));
            Assert.Equal(source[(x * 8 + y) * 8 + z], value);
        }
        Assert.NotEqual(tree[1, 0, 0], tree[2, 0, 0]);
    }

    [Fact]
    public void DenseEncodingReturnsZeroEvenForAnIncidentallyUniformSubregion()
    {
        var source = Enumerable.Range(0, 512).Select(i => unchecked((uint)i * 2654435761u)).ToArray();
        for (var x = 0; x < 2; x++)
        for (var y = 0; y < 2; y++)
        for (var z = 0; z < 2; z++)
            source[(x * 8 + y) * 8 + z] = uint.MaxValue;
        var tree = new Octree(3, source);
        Assert.Equal(2, tree.Data.Span[1] & 3); // Dense representation has no collapsed leaves.
        var lookup = tree.CreateLookup();
        for (var i = 0; i < source.Length; i++)
        {
            var x = i >> 6; var y = (i >> 3) & 7; var z = i & 7;
            Assert.Equal(source[i], tree.Get(x, y, z, out var lod));
            Assert.Equal(0, lod);
            Assert.Equal(0, tree.AsSpan().GetLod(x, y, z, out var value));
            Assert.Equal(source[i], value);
            Assert.Equal(0, lookup.GetLod(x, y, z, out value));
            Assert.Equal(source[i], value);
        }
    }

    [Fact]
    public void GenericQueriesPreserveAllSupportedWidthsAndCustomBitPatterns()
    {
        var source = MixedLeaves();
        AssertGeneric(source.Select(v => (byte)v).ToArray());
        AssertGeneric(source.Select(v => (ushort)(v * 257)).ToArray());
        AssertGeneric(source.Select(v => unchecked((int)(v * 0x01010101u))).ToArray());
        AssertGeneric(source.Select(v => (ulong)v * 0x0101010101010101ul).ToArray());
        AssertGeneric(source.Select(v => new Cell128(v, ulong.MaxValue - v)).ToArray());
    }

    [Theory]
    [InlineData(0)]
    [InlineData(3)]
    [InlineData(9)]
    public void GenericUniformQueriesReturnWholeVolumeLevel(int levels)
    {
        AssertGenericUniform(levels, byte.MaxValue);
        AssertGenericUniform(levels, ushort.MaxValue);
        AssertGenericUniform(levels, int.MinValue);
        AssertGenericUniform(levels, ulong.MaxValue);
        AssertGenericUniform(levels, new Cell128(ulong.MaxValue, ulong.MaxValue));
    }

    [Fact]
    public void GenericDenseQueriesReturnZero()
    {
        var source = Enumerable.Range(0, 64).Select(i => ulong.MaxValue - (ulong)i).ToArray();
        var tree = new Octree<ulong>(2, source);
        Assert.Equal(2, tree.Data.Span[1] & 3);
        for (var i = 0; i < source.Length; i++)
        {
            var x = i >> 4; var y = (i >> 2) & 3; var z = i & 3;
            Assert.Equal(0, tree.GetLod(x, y, z, out var value));
            Assert.Equal(source[i], value);
            Assert.True(tree.AsSpan().TryGet(x, y, z, out value, out var lod));
            Assert.Equal(source[i], value);
            Assert.Equal(0, lod);
        }
    }

    [Theory]
    [InlineData(-1, 0, 0, "x")]
    [InlineData(8, 0, 0, "x")]
    [InlineData(0, -1, 0, "y")]
    [InlineData(0, 8, 0, "y")]
    [InlineData(0, 0, -1, "z")]
    [InlineData(0, 0, 8, "z")]
    public void InvalidCoordinatesFailWithDefaultOutputs(int x, int y, int z, string parameter)
    {
        var tree = new Octree(3, 42u);
        var generic = new Octree<ulong>(3, 42ul);
        var lookup = tree.CreateLookup();
        Assert.Equal(parameter, Assert.Throws<ArgumentOutOfRangeException>(() => tree.Get(x, y, z, out _)).ParamName);
        Assert.Equal(parameter, Assert.Throws<ArgumentOutOfRangeException>(() => tree.AsSpan().GetLod(x, y, z, out _)).ParamName);
        Assert.Equal(parameter, Assert.Throws<ArgumentOutOfRangeException>(() => generic.GetLod(x, y, z, out _)).ParamName);
        Assert.Equal(parameter, Assert.Throws<ArgumentOutOfRangeException>(() => generic.AsSpan().Get(x, y, z, out _)).ParamName);
        Assert.Equal(parameter, Assert.Throws<ArgumentOutOfRangeException>(() => lookup.GetLod(x, y, z, out _)).ParamName);
        Assert.False(tree.TryGet(x, y, z, out var value, out var lod));
        Assert.Equal(0u, value); Assert.Equal(0, lod);
        Assert.False(tree.AsSpan().TryGet(x, y, z, out value, out lod));
        Assert.Equal(0u, value); Assert.Equal(0, lod);
        Assert.False(generic.TryGet(x, y, z, out var genericValue, out lod));
        Assert.Equal(0ul, genericValue); Assert.Equal(0, lod);
        Assert.False(generic.AsSpan().TryGet(x, y, z, out genericValue, out lod));
        Assert.Equal(0ul, genericValue); Assert.Equal(0, lod);
        Assert.False(lookup.TryGet(x, y, z, out value, out lod));
        Assert.Equal(0u, value); Assert.Equal(0, lod);
    }

    [Fact]
    public void UnbuiltTreesAndDefaultViewsRejectQueries()
    {
        var tree = new Octree(3);
        var generic = new Octree<ulong>(3);
        Assert.Throws<InvalidOperationException>(() => tree.GetLod(0, 0, 0, out _));
        Assert.Throws<InvalidOperationException>(() => generic.Get(0, 0, 0, out _));
        Assert.Throws<InvalidOperationException>(() => default(OctreeSpan).GetLod(0, 0, 0, out _));
        Assert.Throws<InvalidOperationException>(() => default(OctreeSpan<ulong>).Get(0, 0, 0, out _));
        Assert.False(tree.TryGet(0, 0, 0, out var value, out var lod));
        Assert.Equal(0u, value); Assert.Equal(0, lod);
        Assert.False(generic.TryGet(0, 0, 0, out var genericValue, out lod));
        Assert.Equal(0ul, genericValue); Assert.Equal(0, lod);
        Assert.False(default(OctreeSpan).TryGet(0, 0, 0, out value, out lod));
        Assert.Equal(0u, value); Assert.Equal(0, lod);
        Assert.False(default(OctreeSpan<ulong>).TryGet(0, 0, 0, out genericValue, out lod));
        Assert.Equal(0ul, genericValue); Assert.Equal(0, lod);
    }

    [Fact]
    public void MalformedQueriedPathsReturnFalseOrThrowFormatException()
    {
        var encoded = new Octree(3, MixedLeaves()).Data.ToArray();
        var genericEncoded = new Octree<ulong>(3, MixedLeaves().Select(v => (ulong)v).ToArray()).Data.ToArray();
        encoded[encoded.Length - 1 - encoded[^1] + 1] = 0; // Zero distance to a nonuniform child.
        genericEncoded[genericEncoded.Length - 1 - genericEncoded[^1] + 1] = 0;
        Assert.False(new OctreeSpan(encoded).TryGet(0, 0, 0, out var value, out var lod));
        Assert.Equal(0u, value); Assert.Equal(0, lod);
        Assert.False(new OctreeSpan<ulong>(genericEncoded).TryGet(0, 0, 0, out var genericValue, out lod));
        Assert.Equal(0ul, genericValue); Assert.Equal(0, lod);
        Assert.Throws<FormatException>(() => new OctreeSpan(encoded).GetLod(0, 0, 0, out _));
        Assert.Throws<FormatException>(() => new OctreeSpan<ulong>(genericEncoded).Get(0, 0, 0, out _));

        var uniform = new Octree(3, 42u).Data.ToArray();
        var uniformView = new OctreeSpan(uniform);
        uniform[^1] = 0x80; // Borrowed data was corrupted after view creation.
        Assert.False(uniformView.TryGet(0, 0, 0, out value, out lod));
        Assert.Equal(0u, value); Assert.Equal(0, lod);
    }

    [Fact]
    public void CapturedSpansAndDecodedLookupRetainLeafTopologyAfterRebuild()
    {
        var tree = new Octree(3, MixedLeaves());
        var span = tree.AsSpan();
        var lookup = span.CreateLookup();
        var generic = new Octree<ulong>(3, MixedLeaves().Select(v => (ulong)v).ToArray());
        var genericSpan = generic.AsSpan();
        tree.BuildUniform(77);
        generic.BuildUniform(77);
        Assert.Equal(3, tree.GetLod(0, 0, 0, out var value)); Assert.Equal(77u, value);
        Assert.Equal(1, span.GetLod(0, 0, 0, out value)); Assert.Equal(9u, value);
        Assert.Equal(1, lookup.GetLod(0, 0, 0, out value)); Assert.Equal(9u, value);
        Assert.Equal(3, generic.GetLod(0, 0, 0, out var genericValue)); Assert.Equal(77ul, genericValue);
        Assert.Equal(1, genericSpan.GetLod(0, 0, 0, out genericValue)); Assert.Equal(9ul, genericValue);
    }

    [Fact]
    public void ValueAndLodComeFromOnePublishedSnapshotDuringConcurrentBuilds()
    {
        var source = MixedLeaves();
        var tree = new Octree(3, source);
        Parallel.For(0, 100, worker =>
        {
            if ((worker & 1) == 0)
            {
                if (worker % 4 == 0) tree.BuildUniform(77);
                else tree.Build(source);
            }
            else
            {
                for (var i = 0; i < 100; i++)
                {
                    var value = tree.Get(0, 0, 0, out var lod);
                    Assert.True((value == 9 && lod == 1) || (value == 77 && lod == 3));
                }
            }
        });
    }

    [Fact]
    public void PointQueriesAllocateNothingAfterWarmup()
    {
        var tree = new Octree(3, MixedLeaves());
        var span = tree.AsSpan();
        var lookup = tree.CreateLookup();
        var generic = new Octree<ulong>(3, MixedLeaves().Select(v => (ulong)v).ToArray());
        var genericSpan = generic.AsSpan();
        for (var pass = 0; pass < 2; pass++)
        {
            var before = GC.GetAllocatedBytesForCurrentThread();
            ulong sum = 0;
            for (var i = 0; i < 10_000; i++)
            {
                var x = i & 7; var y = (i >> 3) & 7; var z = (i >> 6) & 7;
                sum += tree.Get(x, y, z, out var lod) + (uint)lod;
                sum += (uint)span.GetLod(x, y, z, out var value) + value;
                sum += lookup.Get(x, y, z, out lod) + (uint)lod;
                sum += generic.Get(x, y, z, out lod) + (uint)lod;
                sum += (uint)genericSpan.GetLod(x, y, z, out var genericValue) + genericValue;
            }
            var allocated = GC.GetAllocatedBytesForCurrentThread() - before;
            Assert.NotEqual(0ul, sum);
            if (pass == 1) Assert.Equal(0, allocated);
        }
    }

    private static void AssertGeneric<T>(T[] source) where T : unmanaged
    {
        var tree = new Octree<T>(3, source);
        Assert.Equal(0, tree.Data.Span[1] & 3);
        var span = tree.AsSpan();
        var reference = MixedLeaves();
        for (var i = 0; i < source.Length; i++)
        {
            var x = i >> 6; var y = (i >> 3) & 7; var z = i & 7;
            var expectedLod = LargestUniformCube(reference, 3, x, y, z);
            Assert.Equal(source[i], tree.Get(x, y, z, out var lod));
            Assert.Equal(expectedLod, lod);
            Assert.Equal(expectedLod, tree.GetLod(x, y, z, out var value));
            Assert.Equal(source[i], value);
            Assert.Equal(expectedLod, span.GetLod(x, y, z, out value));
            Assert.Equal(source[i], value);
            Assert.True(tree.TryGet(x, y, z, out value, out lod));
            Assert.Equal(source[i], value); Assert.Equal(expectedLod, lod);
            Assert.True(span.TryGet(x, y, z, out value, out lod));
            Assert.Equal(source[i], value); Assert.Equal(expectedLod, lod);
        }
    }

    private static void AssertGenericUniform<T>(int levels, T expected) where T : unmanaged
    {
        var tree = new Octree<T>(levels, expected);
        var last = tree.SideLength - 1;
        Assert.Equal(levels, tree.GetLod(last, last, last, out var value));
        Assert.Equal(expected, value);
        Assert.True(tree.AsSpan().TryGet(last, last, last, out value, out var lod));
        Assert.Equal(expected, value); Assert.Equal(levels, lod);
    }

    private static uint[] MixedLeaves()
    {
        var source = Enumerable.Repeat(1u, 512).ToArray();
        for (var x = 0; x < 2; x++)
        for (var y = 0; y < 2; y++)
        for (var z = 0; z < 2; z++)
            source[(x * 8 + y) * 8 + z] = 9;
        source[^1] = 8;
        return source;
    }

    // Independent dense reference: find the largest aligned cube with equal values.
    private static int LargestUniformCube(uint[] source, int levels, int x, int y, int z)
    {
        var side = 1 << levels;
        var expected = source[(x * side + y) * side + z];
        for (var level = 1; level <= levels; level++)
        {
            var size = 1 << level;
            var ox = x & -size; var oy = y & -size; var oz = z & -size;
            for (var cx = ox; cx < ox + size; cx++)
            for (var cy = oy; cy < oy + size; cy++)
            for (var cz = oz; cz < oz + size; cz++)
                if (source[(cx * side + cy) * side + cz] != expected) return level - 1;
        }
        return levels;
    }

    [StructLayout(LayoutKind.Sequential)]
    private readonly record struct Cell128(ulong Low, ulong High);
}
