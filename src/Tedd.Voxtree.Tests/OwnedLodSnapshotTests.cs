using Xunit;

namespace Tedd.Voxtree.Tests;

public class OwnedLodSnapshotTests
{
    [Fact]
    public void OwnedLodPreservesFailureOrderAndCallerOutput()
    {
        var tree = new Octree(3);
        int lod = 123;
        var unbuilt = Assert.Throws<InvalidOperationException>(() => tree.Get(-1, -1, -1, out lod));
        Assert.Equal("The octree has not been built.", unbuilt.Message);
        Assert.Equal(123, lod);
        tree.BuildUniform(42);
        foreach (var p in new[] { (-1, -1, -1, "x"), (8, 8, 8, "x"), (0, -1, -1, "y"), (0, 8, 8, "y"), (0, 0, -1, "z"), (0, 0, 8, "z") })
        {
            lod = 123;
            Assert.Equal(p.Item4, Assert.Throws<ArgumentOutOfRangeException>(() => tree.Get(p.Item1, p.Item2, p.Item3, out lod)).ParamName);
            Assert.Equal(0, lod);
        }
        Assert.Equal(42u, tree.Get(7, 7, 7, out lod));
        Assert.Equal(3, lod);
        GenericFailureState((ushort)42);
        GenericFailureState(42u);
        GenericFailureState(42ul);
    }

    private static void GenericFailureState<T>(T value) where T : unmanaged
    {
        var tree = new Octree<T>(3);
        int lod = 123;
        var unbuilt = Assert.Throws<InvalidOperationException>(() => tree.Get(-1, -1, -1, out lod));
        Assert.Equal("The octree has not been built.", unbuilt.Message);
        Assert.Equal(123, lod);
        tree.BuildUniform(value);
        foreach (var p in new[] { (-1, -1, -1, "x"), (8, 8, 8, "x"), (0, -1, -1, "y"), (0, 8, 8, "y"), (0, 0, -1, "z"), (0, 0, 8, "z") })
        {
            lod = 123;
            Assert.Equal(p.Item4, Assert.Throws<ArgumentOutOfRangeException>(() => tree.Get(p.Item1, p.Item2, p.Item3, out lod)).ParamName);
            Assert.Equal(0, lod);
        }
        Assert.Equal(value, tree.Get(7, 7, 7, out lod));
        Assert.Equal(3, lod);
    }

    [Fact]
    public void GenericOwnedValueAndLodUseOnePublishedSnapshot()
    {
        GenericPublication((ushort)9, (ushort)77);
        GenericPublication(9u, 77u);
        GenericPublication(9ul, 77ul);
    }

    private static void GenericPublication<T>(T mixedValue, T uniformValue) where T : unmanaged
    {
        var source = new T[512];
        for (int x = 0; x < 2; x++)
            for (int y = 0; y < 2; y++)
                for (int z = 0; z < 2; z++) source[(x * 8 + y) * 8 + z] = mixedValue;
        var tree = new Octree<T>(3, source);
        using var start = new ManualResetEventSlim(false);
        var writer = Task.Run(() =>
        {
            start.Wait();
            for (int i = 0; i < 100; i++)
            {
                tree.BuildUniform(uniformValue);
                tree.Build(source);
            }
        });
        start.Set();
        for (int i = 0; i < 10000; i++)
        {
            var value = tree.Get(0, 0, 0, out var lod);
            Assert.True((EqualityComparer<T>.Default.Equals(value, mixedValue) && lod == 1) ||
                        (EqualityComparer<T>.Default.Equals(value, uniformValue) && lod == 3));
        }
        writer.GetAwaiter().GetResult();
    }
}
