using System.Buffers.Binary;
using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

[MemoryDiagnoser]
public class ChunkValidationSinglePass
{
    [Params(1, 4, 16)]
    public int ChannelCount { get; set; }

    [Params(DataPattern.Uniform, DataPattern.Sparse, DataPattern.Random)]
    public DataPattern Pattern { get; set; }

    private byte[] _packet = null!;

    [GlobalSetup]
    public void Setup()
    {
        var chunk = ChunkSerializationData.Create(ChannelCount, Pattern);
        _packet = new byte[chunk.SerializedLength];
        chunk.CopyEncodedTo(_packet);
        if (!ValidateSinglePass(_packet) || !new OctreeChunkSpan(_packet).IsWellFormed())
            throw new InvalidOperationException("Validation controls disagree.");
    }

    [Benchmark(Baseline = true)]
    public bool EnvelopeThenValidate()
    {
        var view = new OctreeChunkSpan(_packet);
        return view.IsWellFormed();
    }

    [Benchmark]
    public bool ValidateInSinglePacketPass() => OctreeChunkSpan.TryCreateValidated(_packet, out _);

    private static bool ValidateSinglePass(ReadOnlySpan<byte> data)
    {
        const int headerSize = 12;
        if (data.Length < headerSize || data[0] != 0x4f || data[1] != 0x43 || data[2] != 1 ||
            data[3] > Octree.MaxLevels || BinaryPrimitives.ReadInt32LittleEndian(data[8..]) != data.Length)
            return false;

        var count = BinaryPrimitives.ReadInt32LittleEndian(data[4..]);
        if (count <= 0 || count > (data.Length - headerSize) / 7) return false;
        var levels = data[3];
        var offset = headerSize;
        for (var channel = 0; channel < count; channel++)
        {
            if (data.Length - offset < sizeof(int)) return false;
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[offset..]);
            offset += sizeof(int);
            if (length < 3 || length > data.Length - offset ||
                !OctreeSpan.TryCreate(data.Slice(offset, length), out var view) ||
                view.Levels != levels || !view.IsWellFormed())
                return false;
            offset += length;
        }
        return offset == data.Length;
    }
}

[MemoryDiagnoser]
public class ChunkSequentialChannelScan
{
    [Params(16, 64)]
    public int ChannelCount { get; set; }

    private byte[] _packet = null!;

    [GlobalSetup]
    public void Setup()
    {
        var chunk = ChunkSerializationData.Create(ChannelCount, DataPattern.Uniform);
        _packet = new byte[chunk.SerializedLength];
        chunk.CopyEncodedTo(_packet);
        if (IndexedScan(_packet) != SequentialScan(_packet))
            throw new InvalidOperationException("Channel scan controls disagree.");
    }

    [Benchmark(Baseline = true)]
    public int RepeatedIndexedScan() => IndexedScan(_packet);

    [Benchmark]
    public int SingleSequentialScan() => SequentialScan(_packet);

    private static int IndexedScan(ReadOnlySpan<byte> packet)
    {
        var view = new OctreeChunkSpan(packet);
        var checksum = 0;
        for (var channel = 0; channel < view.ChannelCount; channel++)
            checksum = unchecked((checksum * 31) + view.GetChannelData(channel).Length);
        return checksum;
    }

    private static int SequentialScan(ReadOnlySpan<byte> packet)
    {
        var view = new OctreeChunkSpan(packet);
        var checksum = 0;
        foreach (var channel in view.EnumerateChannelData())
            checksum = unchecked((checksum * 31) + channel.Length);
        return checksum;
    }
}

[MemoryDiagnoser]
public class ChunkLoadedOverlapCheck
{
    private OctreeChunk _loaded = null!;
    private byte[] _packet = null!;
    private byte[] _controlDestination = null!;
    private byte[] _candidateDestination = null!;
    private ReadOnlyMemory<byte>[] _channels = null!;

    [GlobalSetup]
    public void Setup()
    {
        var chunk = ChunkSerializationData.Create(16, DataPattern.Random);
        _packet = new byte[chunk.SerializedLength];
        chunk.CopyEncodedTo(_packet);
        _loaded = OctreeChunk.FromEncoded(_packet);
        _controlDestination = new byte[_packet.Length];
        _candidateDestination = new byte[_packet.Length];
        _channels = new ReadOnlyMemory<byte>[_loaded.ChannelCount];
        for (var channel = 0; channel < _channels.Length; channel++)
            _channels[channel] = _loaded.GetChannelData(channel);
        _loaded.CopyEncodedTo(_controlDestination);
        _loaded.CopyEncodedTo(_candidateDestination);
        if (!_controlDestination.AsSpan().SequenceEqual(_candidateDestination))
            throw new InvalidOperationException("Overlap-check controls disagree.");
    }

    [Benchmark(Baseline = true)]
    public int PerChannelOverlapChecks() =>
        ChunkSerializationData.CopyPerChannel(_loaded.Levels, _channels, _controlDestination);

    [Benchmark]
    public int SinglePacketOverlapCheck() => _loaded.CopyEncodedTo(_candidateDestination);
}
