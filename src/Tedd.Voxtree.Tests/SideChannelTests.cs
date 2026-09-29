using System.Buffers.Binary;
using System.Runtime.InteropServices;

namespace Tedd.Voxtree.Tests;

public sealed class SideChannelTests
{
    [Fact]
    public void OwnedSideChannelsSupportCreateSetGetDeleteAndTypedViews()
    {
        var chunk = OctreeChunk.Empty(1, 1);
        Assert.Equal(0, chunk.SideChannelCount);

        chunk.CreateSideChannel(20, 3 * sizeof(int));
        var allocated = chunk.GetSideChannel<int>(20);
        Assert.Equal(new[] { 0, 0, 0 }, allocated.ToArray());
        allocated[1] = 42;

        var source = new ushort[] { 7, 8, 9 };
        var sourceBytes = ToBytes(source);
        chunk.CreateSideChannel(5, sourceBytes);
        var copied = chunk.GetSideChannel<ushort>(5);
        sourceBytes[0] = 0;
        source[0] = 99;
        Assert.Equal(new ushort[] { 7, 8, 9 }, copied.ToArray());
        Assert.Equal(2, chunk.SideChannelCount);
        Assert.Equal(5, chunk.GetSideChannelId(0));
        Assert.Equal(20, chunk.GetSideChannelId(1));
        Assert.Equal(42, chunk.GetSideChannel<int>(20)[1]);

        var sameBuffer = chunk.GetSideChannel(5);
        chunk.SetSideChannel(5, new byte[] { 1, 2, 3, 4, 5, 6 });
        Assert.True(sameBuffer.Overlaps(chunk.GetSideChannel(5)));
        var replacement = chunk.SetSideChannel(5, new byte[] { 3, 4 });
        Assert.Equal(new byte[] { 3, 4 }, replacement.ToArray());
        Assert.False(sameBuffer.Overlaps(replacement));

        Assert.Equal(new uint[] { 11, 12 },
            SetAndGet<uint>(chunk, 30, new uint[] { 11, 12 }));
        Assert.Equal(3, chunk.SideChannelCount);
        Assert.True(chunk.DeleteSideChannel(20));
        Assert.False(chunk.DeleteSideChannel(20));
        Assert.Equal(2, chunk.SideChannelCount);

        Assert.Throws<ArgumentException>(() => { chunk.CreateSideChannel(5, 1); });
        Assert.Throws<ArgumentOutOfRangeException>(() => { chunk.CreateSideChannel(-1, 1); });
        Assert.Throws<ArgumentOutOfRangeException>(() => { chunk.CreateSideChannel(8, -1); });
        Assert.Throws<ArgumentOutOfRangeException>(() => chunk.GetSideChannelId(2));
        Assert.Throws<KeyNotFoundException>(() => { chunk.GetSideChannel(999); });
        Assert.Throws<ArgumentOutOfRangeException>(() => { chunk.GetSideChannel(-1); });
        Assert.Throws<ArgumentOutOfRangeException>(() => chunk.DeleteSideChannel(-1));
        Assert.Empty(chunk.GetSideChannel<int>(5).ToArray());
        Assert.Throws<ArgumentNullException>(() => chunk.CreateSideChannel(40, (byte[])null!));
        Assert.Throws<ArgumentNullException>(() => chunk.SetSideChannel(40, (byte[])null!));
    }

    [Fact]
    public void SideChannelsRoundTripThroughOwnedAndBorrowedPackets()
    {
        var chunk = OctreeChunk.FromDense(1, 1, Enumerable.Range(0, 8).Select(i => (uint)i).ToArray());
        var legacyPacket = new byte[chunk.SerializedLength];
        chunk.CopyEncodedTo(legacyPacket);
        var loadedLegacy = OctreeChunk.FromEncoded(legacyPacket);
        Assert.True(new OctreeChunkSpan(legacyPacket).IsWellFormed());
        Assert.True(loadedLegacy.TryGetSerializedData(out _));
        loadedLegacy.CreateSideChannel(1, 0);
        Assert.False(loadedLegacy.TryGetSerializedData(out _));
        Assert.True(loadedLegacy.DeleteSideChannel(1));
        Assert.True(loadedLegacy.TryGetSerializedData(out _));
        var badLegacyCount = (byte[])legacyPacket.Clone();
        BinaryPrimitives.WriteInt32LittleEndian(badLegacyCount.AsSpan(4), 0);
        Assert.False(OctreeChunkSpan.TryCreate(badLegacyCount, out _));

        chunk.CreateSideChannel(40, new byte[] { 4, 5, 6 });
        chunk.CreateSideChannel(7, ToBytes(new int[] { 100, 200 }));
        var expectedMaximum = OctreeChunk.GetMaximumSerializedLength(1, 1, 2, 11);
        Assert.True(expectedMaximum >= chunk.SerializedLength);

        var tooShort = Enumerable.Repeat((byte)0xa5, chunk.SerializedLength - 1).ToArray();
        Assert.False(chunk.TryCopyEncodedTo(tooShort, out var shortWritten));
        Assert.Equal(0, shortWritten);
        Assert.All(tooShort, value => Assert.Equal(0xa5, value));

        var packet = new byte[chunk.SerializedLength];
        Assert.Equal(packet.Length, chunk.CopyEncodedTo(packet));
        Assert.Equal(3, packet[2]);
        Assert.Equal(2, BinaryPrimitives.ReadInt32LittleEndian(packet.AsSpan(12)));
        Assert.Equal(7, BinaryPrimitives.ReadInt32LittleEndian(packet.AsSpan(24)));
        Assert.Equal(8, BinaryPrimitives.ReadInt32LittleEndian(packet.AsSpan(28)));
        var firstPosition = BinaryPrimitives.ReadInt32LittleEndian(packet.AsSpan(32));
        Assert.Equal(new int[] { 100, 200 },
            System.Runtime.InteropServices.MemoryMarshal.Cast<byte, int>(packet.AsSpan(firstPosition, 8)).ToArray());

        Assert.True(OctreeChunkSpan.TryCreate(packet, out var view));
        Assert.True(OctreeChunkSpan.TryCreateValidated(packet, out var validatedView));
        Assert.Equal(2, view.SideChannelCount);
        Assert.Equal(view.SideChannelCount, validatedView.SideChannelCount);
        Assert.Equal(7, view.GetSideChannelId(0));
        Assert.Equal(40, view.GetSideChannelId(1));
        Assert.Equal(new int[] { 100, 200 }, view.GetSideChannel<int>(7).ToArray());
        Assert.Equal(new byte[] { 4, 5, 6 }, view.GetSideChannel(40).ToArray());
        Assert.Equal(7u, view.GetChannel(0).Get(1, 1, 1));
        var enumeratedChannels = view.EnumerateChannelData().GetEnumerator();
        Assert.True(enumeratedChannels.MoveNext());
        Assert.True(enumeratedChannels.Current.SequenceEqual(view.GetChannelData(0)));
        Assert.False(enumeratedChannels.MoveNext());
        Assert.True(view.IsWellFormed());
        Assert.Throws<KeyNotFoundException>(() => ReadMissingSideChannel(packet));
        Assert.Throws<KeyNotFoundException>(() => ReadLowerMissingSideChannel(packet));
        Assert.Throws<ArgumentOutOfRangeException>(() => ReadNegativeSideChannel(packet));
        Assert.Throws<ArgumentOutOfRangeException>(() => ReadSideChannelIdOutOfRange(packet));
        Assert.Equal(0, ReadSideChannelWithWrongType(packet));

        var restored = OctreeChunk.FromEncoded(packet);
        Assert.False(restored.TryGetSerializedData(out _));
        Assert.Equal(new int[] { 100, 200 }, restored.GetSideChannel<int>(7).ToArray());
        packet[firstPosition] ^= 0xff;
        Assert.Equal(100, restored.GetSideChannel<int>(7)[0]);

        restored.GetSideChannel<int>(7)[1] = 300;
        var secondPacket = new byte[restored.SerializedLength];
        restored.CopyEncodedTo(secondPacket);
        Assert.Equal(300, OctreeChunk.FromEncoded(secondPacket).GetSideChannel<int>(7)[1]);
    }

    [Fact]
    public void SideChannelsSurviveVoxelRebuildsWithoutSharingMutableBuffers()
    {
        var source = OctreeChunk.Empty(1, 1);
        source.CreateSideChannel(3, new byte[] { 1, 2, 3 });

        var rebuilt = source.WithDenseChannel(0, Enumerable.Repeat(17u, 8).ToArray());
        rebuilt.GetSideChannel(3)[0] = 9;
        Assert.Equal(1, source.GetSideChannel(3)[0]);
        Assert.Equal(9, rebuilt.GetSideChannel(3)[0]);

        var hot = source.MarkHot();
        hot[0, 0, 0, 0] = 5;
        var committed = hot.Commit();
        committed.GetSideChannel(3)[1] = 8;
        Assert.Equal(2, source.GetSideChannel(3)[1]);
        Assert.Equal(5u, committed.GetChannel(0).Get(0, 0, 0));
        Assert.Equal(new byte[] { 1, 8, 3 }, committed.GetSideChannel(3).ToArray());
    }

    [Fact]
    public void GenericChunksExposeIndependentTypedSideChannels()
    {
        var chunk = OctreeChunk<ushort>.FromDense(1, 1,
            new ushort[] { 1, 0, 0, 0, 0, 0, 0, 0 });
        chunk.CreateSideChannel(2, new byte[] { 9 });
        chunk.CreateSideChannel(8, ToBytes(new long[] { -1, long.MaxValue }));
        chunk.SetSideChannel(12, ToBytes(new short[] { -7, 11 }));
        Assert.Equal(2, chunk.GetSideChannelId(0));
        chunk.CreateSideChannel(20, 2)[1] = 5;
        chunk.CreateSideChannel(21, 2 * sizeof(int));
        chunk.GetSideChannel<int>(21)[1] = 6;
        Assert.Equal(new byte[] { 4, 5 }, chunk.SetSideChannel(20, new byte[] { 4, 5 }).ToArray());
        Assert.True(chunk.DeleteSideChannel(20));
        Assert.True(chunk.DeleteSideChannel(21));

        var packet = new byte[chunk.SerializedLength];
        chunk.CopyEncodedTo(packet);
        Assert.Equal(4, packet[2]);
        Assert.True(OctreeChunkSpan<ushort>.TryCreate(packet, out var view));
        Assert.True(OctreeChunkSpan<ushort>.TryCreateValidated(packet, out var validatedView));
        var constructedView = new OctreeChunkSpan<ushort>(packet);
        Assert.Equal(3, view.SideChannelCount);
        Assert.Equal(view.SideChannelCount, validatedView.SideChannelCount);
        Assert.Equal(2, constructedView.GetSideChannelId(0));
        Assert.Equal(new long[] { -1, long.MaxValue }, view.GetSideChannel<long>(8).ToArray());
        Assert.Equal(new short[] { -7, 11 }, view.GetSideChannel<short>(12).ToArray());
        var enumeratedChannels = view.EnumerateChannelData().GetEnumerator();
        Assert.True(enumeratedChannels.MoveNext());
        Assert.True(enumeratedChannels.Current.SequenceEqual(view.GetChannelData(0)));
        Assert.False(enumeratedChannels.MoveNext());
        Assert.True(view.IsWellFormed());

        var restored = OctreeChunk<ushort>.FromEncoded(packet);
        Assert.False(restored.TryGetSerializedData(out _));
        Assert.Equal(new byte[] { 9 }, restored.GetSideChannel(2).ToArray());
        Assert.True(restored.GetChannelData(0).Span.Overlaps(packet));
        var rebuilt = restored.WithDenseChannel(0, Enumerable.Repeat((ushort)4, 8).ToArray());
        Assert.Equal(long.MaxValue, rebuilt.GetSideChannel<long>(8)[1]);
        var hot = rebuilt.MarkHot();
        Assert.Equal(-1, hot.Commit().GetSideChannel<long>(8)[0]);

        Assert.True(restored.DeleteSideChannel(2));
        Assert.False(restored.DeleteSideChannel(2));
        Assert.Throws<KeyNotFoundException>(() => { restored.GetSideChannel(2); });
        Assert.Throws<ArgumentOutOfRangeException>(() => restored.GetSideChannelId(3));

        Assert.True(restored.DeleteSideChannel(8));
        Assert.True(restored.DeleteSideChannel(12));
        var legacy = new byte[restored.SerializedLength];
        restored.CopyEncodedTo(legacy);
        Assert.Equal(2, legacy[2]);
        Assert.True(new OctreeChunkSpan<ushort>(legacy).IsWellFormed());
        var badLegacyCount = (byte[])legacy.Clone();
        BinaryPrimitives.WriteInt32LittleEndian(badLegacyCount.AsSpan(4), 0);
        Assert.False(OctreeChunkSpan<ushort>.TryCreate(badLegacyCount, out _));
        Assert.Throws<ArgumentNullException>(() => restored.CreateSideChannel(1, (byte[])null!));
        Assert.Throws<ArgumentNullException>(() => restored.SetSideChannel(1, (byte[])null!));
    }

    [Fact]
    public void ExtendedPacketValidationRejectsMalformedDirectories()
    {
        var valid = CreatePacketWithTwoSideChannels();
        Assert.True(OctreeChunkSpan.TryCreate(valid, out _));

        AssertMalformed(valid, packet => packet[2] = 99);
        AssertMalformed(valid, packet => BinaryPrimitives.WriteInt32LittleEndian(packet.AsSpan(12), -1));
        AssertMalformed(valid, packet => BinaryPrimitives.WriteInt32LittleEndian(packet.AsSpan(12), int.MaxValue));
        AssertMalformed(valid, packet => BinaryPrimitives.WriteInt32LittleEndian(packet.AsSpan(4), 0));
        AssertMalformed(valid, packet => BinaryPrimitives.WriteInt32LittleEndian(packet.AsSpan(20), 0));
        AssertMalformed(valid, packet => BinaryPrimitives.WriteInt32LittleEndian(packet.AsSpan(28), -1));
        AssertMalformed(valid, packet => BinaryPrimitives.WriteInt32LittleEndian(packet.AsSpan(36), 1));
        AssertMalformed(valid, packet => BinaryPrimitives.WriteInt32LittleEndian(packet.AsSpan(44), packet.Length - 1));

        var truncated = valid[..^1];
        Assert.False(OctreeChunkSpan.TryCreate(truncated, out _));
        Assert.Throws<FormatException>(() => new OctreeChunkSpan(truncated));
        Assert.Throws<FormatException>(() => OctreeChunk.FromEncoded(truncated));

        var generic = OctreeChunk<ulong>.Empty(1, 1);
        generic.CreateSideChannel(1, new byte[] { 1 });
        generic.CreateSideChannel(2, new byte[] { 2 });
        var genericPacket = new byte[generic.SerializedLength];
        generic.CopyEncodedTo(genericPacket);
        var badGenericVersion = (byte[])genericPacket.Clone();
        badGenericVersion[2] = 99;
        Assert.False(OctreeChunkSpan<ulong>.TryCreate(badGenericVersion, out _));
        Assert.Throws<FormatException>(() => new OctreeChunkSpan<ulong>(badGenericVersion));
        Assert.Throws<FormatException>(() => OctreeChunk<ulong>.FromEncoded(badGenericVersion));
        Assert.Throws<KeyNotFoundException>(() => ReadLowerMissingGenericSideChannel(genericPacket));

        var badGenericChannel = (byte[])genericPacket.Clone();
        var genericChannelPosition = BinaryPrimitives.ReadInt32LittleEndian(badGenericChannel.AsSpan(20));
        badGenericChannel[genericChannelPosition + 2] = byte.MaxValue;
        Assert.False(OctreeChunkSpan<ulong>.TryCreate(badGenericChannel, out _));
        Assert.Throws<FormatException>(() => OctreeChunk<ulong>.FromEncoded(badGenericChannel));

        BinaryPrimitives.WriteInt32LittleEndian(genericPacket.AsSpan(36), 1);
        Assert.False(OctreeChunkSpan<ulong>.TryCreate(genericPacket, out _));
        Assert.Throws<FormatException>(() => OctreeChunk<ulong>.FromEncoded(genericPacket));
    }

    [Fact]
    public void CapacityOverloadValidatesSideChannelBounds()
    {
        Assert.Equal(OctreeChunk.GetMaximumSerializedLength(1, 1),
            OctreeChunk.GetMaximumSerializedLength(1, 1, 0, 0));
        Assert.Throws<ArgumentOutOfRangeException>(() =>
            OctreeChunk.GetMaximumSerializedLength(1, 1, -1, 0));
        Assert.Throws<ArgumentOutOfRangeException>(() =>
            OctreeChunk.GetMaximumSerializedLength(1, 1, 1, -1));
        Assert.Throws<ArgumentException>(() =>
            OctreeChunk.GetMaximumSerializedLength(1, 1, 0, 1));
        Assert.Throws<ArgumentException>(() =>
            OctreeChunk<ushort>.GetMaximumSerializedLength(1, 1, 0, 1));
        Assert.True(OctreeChunk<ushort>.GetMaximumSerializedLength(1, 1, 1, 32) >
                    OctreeChunk<ushort>.GetMaximumSerializedLength(1, 1));
        Assert.Equal(OctreeChunk<ushort>.GetMaximumSerializedLength(1, 1),
            OctreeChunk<ushort>.GetMaximumSerializedLength(1, 1, 0, 0));
    }

    [Fact]
    public void SideChannelsPersistThroughWorldStorageAndRespectConfiguredLimit()
    {
        var directory = Path.Combine(Path.GetTempPath(), "voxtree-side-" + Guid.NewGuid().ToString("N"));
        try
        {
            var options = new ChunkStorageOptions(directory)
            {
                Compression = ChunkCompression.Direct
            };
            Assert.Equal(64 * 1024 * 1024, options.MaximumSideChannelBytes);
            Assert.Throws<ArgumentOutOfRangeException>(() => options.MaximumSideChannelBytes = -1);

            var coordinate = new ChunkCoordinate(2, -3, 4);
            var chunk = OctreeChunk.Empty(1, 1);
            chunk.CreateSideChannel(77, ToBytes(new[] { 10, 20 }));
            var world = new WorldEntity(2, 1, options);
            world.SetChunk(coordinate, chunk);
            world.SaveChunk(coordinate);
            world.Clear();

            var loaded = world.LoadChunkFromStorage(coordinate);
            Assert.Equal(new[] { 10, 20 }, loaded.GetSideChannel<int>(77).ToArray());

            var genericCoordinate = new ChunkCoordinate(3, -3, 4);
            var genericChunk = OctreeChunk<ushort>.Empty(2, 1);
            genericChunk.CreateSideChannel(88, Array.Empty<byte>());
            var genericWorld = new WorldEntity<ushort>(4, 1, options);
            genericWorld.SetChunk(genericCoordinate, genericChunk);
            genericWorld.SaveChunk(genericCoordinate);
            genericWorld.Clear();
            Assert.Empty(genericWorld.LoadChunkFromStorage(genericCoordinate).GetSideChannel(88).ToArray());

            options.MaximumSideChannelBytes = 0;
            world.Clear();
            Assert.Throws<InvalidDataException>(() => world.LoadChunkFromStorage(coordinate));
            world.SetChunk(coordinate, loaded);
            Assert.Throws<InvalidOperationException>(() => world.SaveChunk(coordinate));
            genericWorld.Clear();
            Assert.Throws<InvalidDataException>(() => genericWorld.LoadChunkFromStorage(genericCoordinate));
            genericWorld.SetChunk(genericCoordinate, genericChunk);
            Assert.Throws<InvalidOperationException>(() => genericWorld.SaveChunk(genericCoordinate));
        }
        finally
        {
            if (Directory.Exists(directory)) Directory.Delete(directory, recursive: true);
        }
    }

    private static byte[] CreatePacketWithTwoSideChannels()
    {
        var chunk = OctreeChunk.Empty(1, 1);
        chunk.CreateSideChannel(1, new byte[] { 1, 2 });
        chunk.CreateSideChannel(2, new byte[] { 3, 4 });
        var packet = new byte[chunk.SerializedLength];
        chunk.CopyEncodedTo(packet);
        return packet;
    }

    private static void AssertMalformed(byte[] valid, Action<byte[]> corrupt)
    {
        var packet = (byte[])valid.Clone();
        corrupt(packet);
        Assert.False(OctreeChunkSpan.TryCreate(packet, out _));
        Assert.Throws<FormatException>(() => OctreeChunk.FromEncoded(packet));
    }

    private static void ReadMissingSideChannel(byte[] packet) =>
        new OctreeChunkSpan(packet).GetSideChannel(41);

    private static void ReadLowerMissingSideChannel(byte[] packet) =>
        new OctreeChunkSpan(packet).GetSideChannel(6);

    private static void ReadNegativeSideChannel(byte[] packet) =>
        new OctreeChunkSpan(packet).GetSideChannel(-1);

    private static void ReadSideChannelIdOutOfRange(byte[] packet) =>
        new OctreeChunkSpan(packet).GetSideChannelId(2);

    private static int ReadSideChannelWithWrongType(byte[] packet) =>
        new OctreeChunkSpan(packet).GetSideChannel<int>(40).Length;

    private static void ReadLowerMissingGenericSideChannel(byte[] packet) =>
        new OctreeChunkSpan<ulong>(packet).GetSideChannel(0);

    private static byte[] ToBytes<T>(T[] values) where T : unmanaged =>
        MemoryMarshal.AsBytes(values.AsSpan()).ToArray();

    private static T[] SetAndGet<T>(OctreeChunk chunk, int channelId, T[] values) where T : unmanaged
    {
        chunk.SetSideChannel(channelId, ToBytes(values));
        return chunk.GetSideChannel<T>(channelId).ToArray();
    }
}
