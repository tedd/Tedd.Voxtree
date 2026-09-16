namespace Tedd.Voxtree.Tests;

public class OctreeLookupTests
{
    [Theory]
    [InlineData(0)]
    [InlineData(1)]
    [InlineData(3)]
    [InlineData(5)]
    public void CompiledLookupMatchesEveryVoxelAndRetainsSnapshot(int levels)
    {
        var side = 1 << levels;
        var random = new Random(917);
        foreach (var pattern in new[] { 0, 1, 2, 3 })
        {
            var source = new uint[side * side * side];
            for (var i = 0; i < source.Length; i++)
                source[i] = pattern switch
                {
                    0 => uint.MaxValue,
                    1 => (uint)((i / Math.Max(1, side * side / 2)) & 7),
                    2 => i % 71 == 0 ? uint.MaxValue : 0,
                    _ => (uint)random.NextInt64(0, 1L << 32)
                };
            var tree = new Octree(levels, source);
            var lookup = tree.CreateLookup();
            Assert.Equal(levels, lookup.Levels);
            Assert.Equal(side, lookup.SideLength);
            Assert.Equal(source.Length, lookup.Count);
            Assert.True(lookup.StorageBytes > 0);
            tree.Build(new uint[source.Length]);
            for (var x = 0; x < side; x++)
            for (var y = 0; y < side; y++)
            for (var z = 0; z < side; z++)
            {
                var expected = source[(x * side + y) * side + z];
                Assert.Equal(expected, lookup.Get(x, y, z));
                Assert.True(lookup.TryGet(x, y, z, out var value));
                Assert.Equal(expected, value);
            }
            Assert.Equal("x", Assert.Throws<ArgumentOutOfRangeException>(() => lookup.Get(-1, 0, 0)).ParamName);
            Assert.Equal("y", Assert.Throws<ArgumentOutOfRangeException>(() => lookup.Get(0, side, 0)).ParamName);
            Assert.Equal("z", Assert.Throws<ArgumentOutOfRangeException>(() => lookup.Get(0, 0, int.MinValue)).ParamName);
            Assert.False(lookup.TryGet(side, 0, 0, out var invalid));
            Assert.Equal(0u, invalid);
            Assert.False(lookup.TryGet(0, -1, 0, out _));
            Assert.False(lookup.TryGet(0, 0, int.MaxValue, out _));
        }
    }

    [Fact]
    public void BorrowedStorageCanBeReusedAfterCompilation()
    {
        foreach (var pattern in new[] { 0, 1, 2 })
        {
            var source = Enumerable.Range(0, 512).Select(i => pattern switch
            {
                0 => 17u,
                1 => (uint)(i / 64),
                _ => unchecked((uint)i * 2654435761u)
            }).ToArray();
            var encoded = new Octree(3, source).Data.ToArray();
            var lookup = new OctreeSpan(encoded).CreateLookup();
            Array.Clear(encoded);
            for (var i = 0; i < source.Length; i++)
                Assert.Equal(source[i], lookup[i >> 6, (i >> 3) & 7, i & 7]);
        }
    }

    [Fact]
    public void DefaultViewCannotBeCompiled()
    {
        Assert.Throws<InvalidOperationException>(() => CompileDefault());
        static void CompileDefault() => default(OctreeSpan).CreateLookup();
    }

    [Fact]
    public void CompilationRequiresBuiltTree() =>
        Assert.Throws<InvalidOperationException>(() => new Octree(3).CreateLookup());

    [Fact]
    public void SnapshotReadsAreIndependentOfConcurrentSourceBuilds()
    {
        var source = Enumerable.Range(0, 512).Select(i => (uint)(i / 64)).ToArray();
        var tree = new Octree(3, source);
        var lookup = tree.CreateLookup();
        Parallel.For(0, 64, worker =>
        {
            if ((worker & 1) == 0) tree.Build(new uint[512]);
            else
                for (var i = 0; i < 512; i++)
                    Assert.Equal(source[i], lookup[i >> 6, (i >> 3) & 7, i & 7]);
        });
    }

    [Fact]
    public void CompilationCapturesOnePublishedEncoding()
    {
        var first = Enumerable.Repeat(1u, 512).ToArray();
        var second = Enumerable.Repeat(uint.MaxValue, 512).ToArray();
        var tree = new Octree(3, first);
        Parallel.For(0, 100, worker =>
        {
            if ((worker & 1) == 0) tree.Build(worker % 4 == 0 ? first : second);
            else
            {
                var lookup = tree.CreateLookup();
                var expected = lookup[0, 0, 0];
                Assert.True(expected == 1 || expected == uint.MaxValue);
                for (var i = 0; i < 512; i++)
                    Assert.Equal(expected, lookup[i >> 6, (i >> 3) & 7, i & 7]);
            }
        });
    }
}
