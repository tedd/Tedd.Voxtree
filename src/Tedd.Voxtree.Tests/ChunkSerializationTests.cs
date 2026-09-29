namespace Tedd.Voxtree.Tests;

public sealed class ChunkSerializationTests
{
    [Fact]
    public void ReusableBufferSerializationReportsCapacityAndPreservesFailureDestination()
    {
        var values = TestData.Coordinates(3);
        var chunk = OctreeChunk.FromDense(3, 1, values);
        var capacity = OctreeChunk.GetMaximumSerializedLength(3, 1);
        Assert.True(capacity >= chunk.SerializedLength);

        var destination = Enumerable.Repeat((byte)0xa5, capacity).ToArray();
        Assert.True(chunk.TryCopyEncodedTo(destination, out var written));
        Assert.Equal(chunk.SerializedLength, written);
        Assert.All(destination.AsSpan(written).ToArray(), value => Assert.Equal(0xa5, value));

        var tooShort = Enumerable.Repeat((byte)0x5a, chunk.SerializedLength - 1).ToArray();
        Assert.False(chunk.TryCopyEncodedTo(tooShort, out written));
        Assert.Equal(0, written);
        Assert.All(tooShort, value => Assert.Equal(0x5a, value));
    }

    [Fact]
    public void LoadedChunkRetainsAndCopiesTheOriginalContiguousPacket()
    {
        var source = OctreeChunk.FromDense(3, 1, TestData.Coordinates(3));
        var packet = new byte[source.SerializedLength];
        source.CopyEncodedTo(packet);

        var loaded = OctreeChunk.FromEncoded(packet);
        Assert.True(loaded.TryGetSerializedData(out var retained));
        Assert.True(retained.Span.Overlaps(packet));

        var copy = new byte[packet.Length];
        Assert.True(loaded.TryCopyEncodedTo(copy, out var written));
        Assert.Equal(packet.Length, written);
        Assert.Equal(packet, copy);
        Assert.Throws<ArgumentException>(() => loaded.CopyEncodedTo(packet));
    }

    [Fact]
    public void LoadedLargeChunkUsesReusableDestinationWithoutChangingPacketBytes()
    {
        var values = TestData.Coordinates(5);
        var source = OctreeChunk.FromDense(5, 1, values);
        var packet = new byte[source.SerializedLength];
        source.CopyEncodedTo(packet);
        Assert.True(packet.Length > 64 * 1024);

        var loaded = OctreeChunk.FromEncoded(packet);
        var copy = new byte[packet.Length];
        Assert.True(loaded.TryCopyEncodedTo(copy, out var written));
        Assert.Equal(packet.Length, written);
        Assert.Equal(packet, copy);
        Assert.Throws<ArgumentException>(() => loaded.CopyEncodedTo(packet));
    }

    [Fact]
    public void ChunkSpanParsesCallerMemoryWithoutAllocationAndValidatesOnDemand()
    {
        var values = new uint[2 * 512];
        values[123] = 17;
        values[512 + 456] = 29;
        var source = OctreeChunk.FromDense(3, 2, values);
        var packet = new byte[source.SerializedLength];
        source.CopyEncodedTo(packet);

        Assert.True(OctreeChunkSpan.TryCreate(packet, out var view));
        Assert.Equal(3, view.Levels);
        Assert.Equal(2, view.ChannelCount);
        Assert.Equal(packet.Length, view.SerializedLength);
        Assert.True(view.IsWellFormed());
        Assert.True(OctreeChunkSpan.TryCreateValidated(packet, out var validated));
        Assert.Equal(view.ChannelCount, validated.ChannelCount);
        Assert.Equal(17u, view.GetChannel(0).Get(1, 7, 3));
        Assert.Equal(29u, view.GetChannel(1).Get(7, 1, 0));
        Assert.True(view.Data.Overlaps(packet));

        var channelIndex = 0;
        foreach (var channel in view.EnumerateChannelData())
        {
            Assert.True(channel.SequenceEqual(view.GetChannelData(channelIndex)));
            channelIndex++;
        }
        Assert.Equal(view.ChannelCount, channelIndex);

        var expectedChecksum = ParseRepeatedly(packet);
        var before = GC.GetAllocatedBytesForCurrentThread();
        var checksum = ParseRepeatedly(packet);
        Assert.Equal(0, GC.GetAllocatedBytesForCurrentThread() - before);
        Assert.Equal(expectedChecksum, checksum);

        Assert.False(OctreeChunkSpan.TryCreate(packet.AsSpan(0, packet.Length - 1), out _));
        Assert.False(OctreeChunkSpan.TryCreateValidated(packet.AsSpan(0, packet.Length - 1), out _));
    }

    [Fact]
    public void GenericChunkSpanAndReusableSerializationPreserveExactValues()
    {
        var values = Enumerable.Range(0, 128).Select(value => (ulong)value << 32).ToArray();
        var source = OctreeChunk<ulong>.FromDense(2, 2, values);
        var packet = new byte[OctreeChunk<ulong>.GetMaximumSerializedLength(2, 2)];
        Assert.True(source.TryCopyEncodedTo(packet, out var written));

        Assert.True(OctreeChunkSpan<ulong>.TryCreate(packet.AsSpan(0, written), out var view));
        Assert.True(view.IsWellFormed());
        Assert.True(OctreeChunkSpan<ulong>.TryCreateValidated(packet.AsSpan(0, written), out var validated));
        Assert.Equal(view.ChannelCount, validated.ChannelCount);
        Assert.Equal(values[64 + 27], view.GetChannel(1).Get(1, 2, 3));

        var channelIndex = 0;
        foreach (var channel in view.EnumerateChannelData())
        {
            Assert.True(channel.SequenceEqual(view.GetChannelData(channelIndex)));
            channelIndex++;
        }
        Assert.Equal(view.ChannelCount, channelIndex);

        var loaded = OctreeChunk<ulong>.FromEncoded(packet.AsMemory(0, written));
        Assert.True(loaded.TryGetSerializedData(out var retained));
        Assert.Equal(written, retained.Length);
    }

    private static int ParseRepeatedly(byte[] packet)
    {
        var checksum = 0;
        for (var iteration = 0; iteration < 100; iteration++)
        {
            var view = new OctreeChunkSpan(packet);
            checksum += view.ChannelCount + view.GetChannelData(0).Length;
        }
        return checksum;
    }
}
