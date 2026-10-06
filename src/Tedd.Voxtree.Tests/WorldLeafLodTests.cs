namespace Tedd.Voxtree.Tests;

public sealed class WorldLeafLodTests
{
    [Fact]
    public void ChannelsRetainIndependentLeafLevelsThroughPacketDeserialization()
    {
        var chunk = Chunk();
        var packet = new byte[chunk.SerializedLength];
        chunk.CopyEncodedTo(packet);
        var restored = OctreeChunk.FromEncoded(packet);
        var packetView = new OctreeChunkSpan(packet);
        foreach (var snapshot in new[] { chunk, restored })
        {
            Assert.Equal(1, snapshot.GetChannel(0).GetLod(0, 0, 0, out var value)); Assert.Equal(9u, value);
            Assert.Equal(3, snapshot.GetChannel(1).GetLod(0, 0, 0, out value)); Assert.Equal(17u, value);
        }
        Assert.Equal(1, packetView.GetChannel(0).GetLod(0, 0, 0, out var packetValue)); Assert.Equal(9u, packetValue);
        Assert.Equal(3, packetView.GetChannel(1).GetLod(0, 0, 0, out packetValue)); Assert.Equal(17u, packetValue);

        var generic = GenericChunk();
        var genericPacket = new byte[generic.SerializedLength];
        generic.CopyEncodedTo(genericPacket);
        var genericRestored = OctreeChunk<ulong>.FromEncoded(genericPacket);
        Assert.Equal(1, genericRestored.GetChannel(0).GetLod(0, 0, 0, out var genericValue)); Assert.Equal(9ul, genericValue);
        Assert.Equal(3, new OctreeChunkSpan<ulong>(genericPacket).GetChannel(1).GetLod(0, 0, 0, out genericValue));
        Assert.Equal(17ul, genericValue);
    }

    [Fact]
    public void WorldReturnsChannelLeafLevelsAndCollapsedEmptyRegionLevels()
    {
        using var world = new OctreeWorld(5, 3, 2, 1, initiallyEmpty: true);
        Assert.Equal(5, world.GetLod(0, 31, 31, 31, out var value)); Assert.Equal(0u, value);
        world.LoadChunk(1, 1, 1, Chunk());
        Assert.Equal(1, world.GetLod(0, 8, 8, 8, out value)); Assert.Equal(9u, value);
        Assert.Equal(17u, world.Get(1, 8, 8, 8, out var lod)); Assert.Equal(3, lod);
        Assert.True(world.TryGet(0, 9, 9, 9, out value, out lod)); Assert.Equal(9u, value); Assert.Equal(1, lod);
        Assert.Equal(4, world.GetLod(0, 31, 31, 31, out value)); Assert.Equal(0u, value);
        world.TryUnloadRegion(8, 8, 8, 3);
        Assert.False(world.TryGet(0, 8, 8, 8, out value, out lod)); Assert.Equal(0u, value); Assert.Equal(0, lod);
        Assert.Throws<InvalidOperationException>(() => world.GetLod(0, 8, 8, 8, out _));
        Assert.False(world.TryGet(0, -1, 0, 0, out value, out lod)); Assert.Equal(0u, value); Assert.Equal(0, lod);
        Assert.Throws<ArgumentOutOfRangeException>(() => world.Get(0, 32, 0, 0, out _));
        Assert.Throws<ArgumentOutOfRangeException>(() => world.GetLod(2, 0, 0, 0, out _));
    }

    [Fact]
    public void GenericWorldReturnsChannelLeafLevelsAndCollapsedEmptyRegionLevels()
    {
        using var world = new OctreeWorld<ulong>(5, 3, 2, 1, initiallyEmpty: true);
        Assert.Equal(5, world.GetLod(0, 31, 31, 31, out var value)); Assert.Equal(0ul, value);
        world.LoadChunk(1, 1, 1, GenericChunk());
        Assert.Equal(1, world.GetLod(0, 8, 8, 8, out value)); Assert.Equal(9ul, value);
        Assert.Equal(17ul, world.Get(1, 8, 8, 8, out var lod)); Assert.Equal(3, lod);
        Assert.True(world.TryGet(0, 9, 9, 9, out value, out lod)); Assert.Equal(9ul, value); Assert.Equal(1, lod);
        Assert.Equal(4, world.GetLod(0, 31, 31, 31, out value)); Assert.Equal(0ul, value);
        world.TryUnloadRegion(8, 8, 8, 3);
        Assert.False(world.TryGet(0, 8, 8, 8, out value, out lod)); Assert.Equal(0ul, value); Assert.Equal(0, lod);
        Assert.Throws<InvalidOperationException>(() => world.GetLod(0, 8, 8, 8, out _));
        Assert.False(world.TryGet(0, 32, 0, 0, out value, out lod)); Assert.Equal(0ul, value); Assert.Equal(0, lod);
        Assert.Throws<ArgumentOutOfRangeException>(() => world.Get(0, -1, 0, 0, out _));
        Assert.Throws<ArgumentOutOfRangeException>(() => world.GetLod(2, 0, 0, 0, out _));
    }

    [Theory]
    [InlineData(-2)]
    [InlineData(-1)]
    [InlineData(0)]
    [InlineData(1)]
    public void GlobalCoordinatesRouteToTheSelectedChannelLeaf(long chunkCoordinate)
    {
        var world = new WorldEntity(8, 2);
        var generic = new WorldEntity<ulong>(8, 2);
        world.SetChunk(chunkCoordinate, chunkCoordinate, chunkCoordinate, Chunk());
        generic.SetChunk(chunkCoordinate, chunkCoordinate, chunkCoordinate, GenericChunk());
        var origin = chunkCoordinate * 8;
        Assert.Equal(1, world.GetLod(0, origin, origin, origin, out var value)); Assert.Equal(9u, value);
        Assert.Equal(17u, world.Get(1, origin, origin, origin, out var lod)); Assert.Equal(3, lod);
        Assert.True(world.TryGet(0, origin + 1, origin + 1, origin + 1, out value, out lod));
        Assert.Equal(9u, value); Assert.Equal(1, lod);
        Assert.Equal(1, generic.GetLod(0, origin, origin, origin, out var genericValue)); Assert.Equal(9ul, genericValue);
        Assert.Equal(17ul, generic.Get(1, origin, origin, origin, out lod)); Assert.Equal(3, lod);
        Assert.True(generic.TryGet(0, origin + 1, origin + 1, origin + 1, out genericValue, out lod));
        Assert.Equal(9ul, genericValue); Assert.Equal(1, lod);
        Assert.False(world.TryGet(0, origin + 8, origin, origin, out value, out lod));
        Assert.Equal(0u, value); Assert.Equal(0, lod);
        Assert.False(generic.TryGet(0, origin + 8, origin, origin, out genericValue, out lod));
        Assert.Equal(0ul, genericValue); Assert.Equal(0, lod);
        Assert.Throws<InvalidOperationException>(() => world.GetLod(0, origin + 8, origin, origin, out _));
        Assert.Throws<InvalidOperationException>(() => generic.Get(0, origin + 8, origin, origin, out _));
        Assert.Throws<ArgumentOutOfRangeException>(() => world.GetLod(2, origin, origin, origin, out _));
        Assert.Throws<ArgumentOutOfRangeException>(() => generic.GetLod(2, origin, origin, origin, out _));
    }

    [Fact]
    public void EditedDenseDataUsesCurrentLeafTopologyOnlyAfterRepackaging()
    {
        var snapshot = Chunk();
        using var deferred = new DeferredOctreeChunk(snapshot);
        var hot = deferred.MakeHot();
        hot[0, 0, 0, 0] = 42;
        Assert.Equal(1, snapshot.GetChannel(0).GetLod(0, 0, 0, out var value)); Assert.Equal(9u, value);
        var current = deferred.Repackage();
        Assert.Equal(0, current.GetChannel(0).GetLod(0, 0, 0, out value)); Assert.Equal(42u, value);
        Assert.Equal(0, current.GetChannel(0).GetLod(1, 1, 1, out value)); Assert.Equal(9u, value);
        Assert.Equal(3, current.GetChannel(1).GetLod(0, 0, 0, out value)); Assert.Equal(17u, value);
    }

    private static OctreeChunk Chunk() => OctreeChunk.FromDense(3, 2, ChannelValues());
    private static OctreeChunk<ulong> GenericChunk() =>
        OctreeChunk<ulong>.FromDense(3, 2, ChannelValues().Select(v => (ulong)v).ToArray());

    private static uint[] ChannelValues()
    {
        var values = Enumerable.Repeat(1u, 1024).ToArray();
        Array.Fill(values, 17u, 512, 512);
        for (var x = 0; x < 2; x++)
        for (var y = 0; y < 2; y++)
        for (var z = 0; z < 2; z++)
            values[(x * 8 + y) * 8 + z] = 9;
        return values;
    }
}
