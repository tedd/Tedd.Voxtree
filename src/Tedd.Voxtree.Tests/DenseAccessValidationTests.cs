namespace Tedd.Voxtree.Tests;

public class DenseAccessValidationTests
{
    [Theory]
    [InlineData(DenseVoxelLayout.Linear)]
    [InlineData(DenseVoxelLayout.Morton)]
    public void ConstructedViewsPreserveCheckedIndexSemantics(DenseVoxelLayout layout)
    {
        foreach (var coordinate in new[] { int.MinValue, -1, 2, 3, int.MaxValue })
        foreach (var axis in new[] { 0, 1, 2 })
        {
            var xyz = new int[3]; xyz[axis] = coordinate;
            Assert.Equal("x", Assert.Throws<ArgumentOutOfRangeException>(() =>
                DenseVoxel.GetIndex(xyz[0], xyz[1], xyz[2], 1, layout)).ParamName);
            Assert.Equal("x", Assert.Throws<ArgumentOutOfRangeException>(() => Access(xyz, layout, false)).ParamName);
            Assert.Equal("x", Assert.Throws<ArgumentOutOfRangeException>(() => Access(xyz, layout, true)).ParamName);
        }
        var values = new uint[16];
        var block = new DenseVoxelBlockSpan(values, 1, 2, layout);
        var generic = new DenseVoxelBlockSpan<uint>(values, 1, 2, layout);
        block[1, 1, 1, 1] = 42;
        Assert.Equal(42u, generic[1, 1, 1, 1]);
        generic[0, 0, 0, 0] = 17;
        Assert.Equal(17u, block[0, 0, 0, 0]);
    }

    private static void Access(int[] xyz, DenseVoxelLayout layout, bool generic)
    {
        if (generic)
        {
            var block = new DenseVoxelBlockSpan<uint>(new uint[8], 1, 1, layout);
            block[0, xyz[0], xyz[1], xyz[2]] = 1;
        }
        else
        {
            var block = new DenseVoxelBlockSpan(new uint[8], 1, 1, layout);
            _ = block[0, xyz[0], xyz[1], xyz[2]];
        }
    }

    [Fact]
    public void HotEditorsCheckLifetimeThenChannelThenCoordinates()
    {
        var hot = HotOctreeChunk.Empty(0, 1);
        var generic = HotOctreeChunk<uint>.Empty(0, 1);
        Assert.Equal("channel", Assert.Throws<ArgumentOutOfRangeException>(() => hot[-1, -1, 0, 0] = 1).ParamName);
        Assert.Equal("channel", Assert.Throws<ArgumentOutOfRangeException>(() => generic[-1, -1, 0, 0] = 1).ParamName);
        foreach (var xyz in new[] { new[] { -1, 0, 0 }, new[] { 0, 1, 0 }, new[] { 0, 0, int.MaxValue } })
        {
            Assert.Equal("x", Assert.Throws<ArgumentOutOfRangeException>(() => hot[0, xyz[0], xyz[1], xyz[2]] = 1).ParamName);
            Assert.Equal("x", Assert.Throws<ArgumentOutOfRangeException>(() => generic[0, xyz[0], xyz[1], xyz[2]] = 1).ParamName);
        }
        hot[0, 0, 0, 0] = 9; generic[0, 0, 0, 0] = 9;
        Assert.Equal(9u, hot.Commit().GetChannel(0).Get(0, 0, 0));
        Assert.Equal(9u, generic.Commit().GetChannel(0).Get(0, 0, 0));
        Assert.Throws<InvalidOperationException>(() => hot[-1, -1, 0, 0] = 1);
        Assert.Throws<InvalidOperationException>(() => generic[-1, -1, 0, 0] = 1);
    }
}
