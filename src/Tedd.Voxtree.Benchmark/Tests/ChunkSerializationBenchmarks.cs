using System.Buffers.Binary;
using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

[MemoryDiagnoser]
public class ChunkSerialization
{
    [Params(1, 4, 16)]
    public int ChannelCount { get; set; }

    [Params(DataPattern.Uniform, DataPattern.Sparse, DataPattern.Clustered, DataPattern.Random)]
    public DataPattern Pattern { get; set; }

    private OctreeChunk _chunk = null!;
    private OctreeChunk _loaded = null!;
    private byte[] _destination = null!;
    private byte[] _loadedDestination = null!;
    private byte[] _legacyDestination = null!;
    private ReadOnlyMemory<byte>[] _legacyChannels = null!;

    [GlobalSetup]
    public void Setup()
    {
        _chunk = ChunkSerializationData.Create(ChannelCount, Pattern);
        _destination = new byte[_chunk.SerializedLength];
        if (_chunk.CopyEncodedTo(_destination) != _destination.Length)
            throw new InvalidOperationException("Chunk serialization benchmark setup failed.");
        _loaded = OctreeChunk.FromEncoded(_destination);
        _loadedDestination = new byte[_destination.Length];
        _legacyDestination = new byte[_destination.Length];
        _legacyChannels = new ReadOnlyMemory<byte>[ChannelCount];
        for (var channel = 0; channel < ChannelCount; channel++)
            _legacyChannels[channel] = _loaded.GetChannelData(channel);
    }

    [Benchmark]
    public int SerializeToReusedBuffer() => _chunk.CopyEncodedTo(_destination);

    [Benchmark]
    public int SerializeLoadedPacketToReusedBuffer() => _loaded.CopyEncodedTo(_loadedDestination);

    [Benchmark(Baseline = true)]
    public int SerializeLoadedPerChannelControl() =>
        ChunkSerializationData.CopyPerChannel(_loaded.Levels, _legacyChannels, _legacyDestination);
}

[MemoryDiagnoser]
public class ChunkDeserialization
{
    [Params(1, 4, 16)]
    public int ChannelCount { get; set; }

    [Params(DataPattern.Uniform, DataPattern.Sparse, DataPattern.Clustered, DataPattern.Random)]
    public DataPattern Pattern { get; set; }

    private byte[] _packet = null!;

    [GlobalSetup]
    public void Setup()
    {
        var chunk = ChunkSerializationData.Create(ChannelCount, Pattern);
        _packet = new byte[chunk.SerializedLength];
        chunk.CopyEncodedTo(_packet);
        var restored = OctreeChunk.FromEncoded(_packet);
        if (restored.ChannelCount != ChannelCount || restored.IsEmpty != chunk.IsEmpty)
            throw new InvalidOperationException("Chunk deserialization benchmark setup failed.");
    }

    [Benchmark]
    public OctreeChunk DeserializeBorrowedPacket() => OctreeChunk.FromEncoded(_packet);

    [Benchmark]
    public int ParseBorrowedPacketView()
    {
        var view = new OctreeChunkSpan(_packet);
        return view.ChannelCount;
    }

    [Benchmark]
    public bool ValidateBorrowedPacketView()
    {
        var view = new OctreeChunkSpan(_packet);
        return view.IsWellFormed();
    }
}

internal static class ChunkSerializationData
{
    private const int Levels = 5;
    private const int Volume = 32 * 32 * 32;

    internal static OctreeChunk Create(int channelCount, DataPattern pattern)
    {
        var source = BenchmarkData.Create(Levels, pattern);
        var channels = new uint[checked(channelCount * Volume)];
        for (var channel = 0; channel < channelCount; channel++)
            source.CopyTo(channels, channel * Volume);
        return OctreeChunk.FromDense(Levels, channelCount, channels);
    }

    internal static int CopyPerChannel(int levels, ReadOnlySpan<ReadOnlyMemory<byte>> channels,
        Span<byte> destination)
    {
        var length = 12;
        foreach (var channel in channels)
            length = checked(length + sizeof(int) + channel.Length);
        if (destination.Length < length)
            throw new ArgumentException("Destination is too short.", nameof(destination));
        destination = destination[..length];
        foreach (var channel in channels)
            if (destination.Overlaps(channel.Span))
                throw new ArgumentException("Destination overlaps a channel encoding.", nameof(destination));
        destination[0] = 0x4f;
        destination[1] = 0x43;
        destination[2] = 1;
        destination[3] = (byte)levels;
        BinaryPrimitives.WriteInt32LittleEndian(destination[4..], channels.Length);
        BinaryPrimitives.WriteInt32LittleEndian(destination[8..], length);
        var offset = 12;
        foreach (var channel in channels)
        {
            var data = channel.Span;
            BinaryPrimitives.WriteInt32LittleEndian(destination[offset..], data.Length);
            offset += sizeof(int);
            data.CopyTo(destination[offset..]);
            offset += data.Length;
        }
        return length;
    }
}
