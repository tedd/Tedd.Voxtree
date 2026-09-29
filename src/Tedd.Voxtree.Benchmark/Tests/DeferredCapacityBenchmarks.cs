using System.Buffers;
using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

[MemoryDiagnoser]
public class DeferredCapacityBenchmarks
{
    [Params(
        "C20-W1-1of2",
        "C20-W20-1of2",
        "C32-W20-1of2",
        "C64-W20-1of2",
        "C256-W20-1of2",
        "C32-W32-1of2",
        "C256-W32-1of2",
        "C64-W64-1of2",
        "C256-W64-1of2",
        "C20-W21-1of8",
        "C256-W257-1of8",
        "C256-W257-8of8",
        "C512-W512-1of8",
        "C1024-W512-1of8",
        "C1024-W1024-1of2",
        "C2048-W2048-1of2",
        "C4096-W4096-1of2")]
    public string Case { get; set; } = null!;

    [Params(DeferredChunkPattern.Uniform, DeferredChunkPattern.Terrain)]
    public DeferredChunkPattern Pattern { get; set; }

    private OctreeChunk _source = null!;
    private int _capacity;
    private int _writes;
    private int _channels;
    private int _channelsWritten;
    private byte[] _encoded = null!;
    private ReusableArrayPool<ushort> _shortKeys = null!;
    private ReusableArrayPool<int> _wideKeys = null!;
    private ReusableArrayPool<ulong> _presence = null!;
    private ReusableArrayPool<uint> _values = null!;

    [GlobalSetup]
    public void Setup()
    {
        var parts = Case.Split('-');
        _capacity = int.Parse(parts[0].AsSpan(1));
        _writes = int.Parse(parts[1].AsSpan(1));
        var channelParts = parts[2].Split("of", StringSplitOptions.None);
        _channelsWritten = int.Parse(channelParts[0]);
        _channels = int.Parse(channelParts[1]);
        _source = CreateSource(Pattern, _channels);
        _encoded = new byte[checked(12 + _channels * (sizeof(int) + Octree.GetMaximumSize(5)))];
        _shortKeys = new ReusableArrayPool<ushort>(_capacity);
        _wideKeys = new ReusableArrayPool<int>(_capacity);
        _presence = new ReusableArrayPool<ulong>(checked(_channels * ((_capacity + 63) / 64)));
        _values = new ReusableArrayPool<uint>(_capacity);

        var expected = ExpectedChecksum();
        if (DeferredCompleteCycle() != expected || ImmediateCompleteCycle() != expected)
            throw new InvalidOperationException("Capacity benchmark parity failed.");
    }

    [Benchmark]
    public uint DeferredEditSession()
    {
        using var owner = new DeferredOctreeChunk(_source, _capacity);
        Write(owner);
        var position = DeferredChunkData.Position(_writes - 1);
        var channel = (_writes - 1) % _channelsWritten;
        return owner[channel, DeferredChunkData.X(position), DeferredChunkData.Y(position), DeferredChunkData.Z(position)];
    }

    [Benchmark]
    public uint CallerProvidedEditSession()
    {
        using var owner = new DeferredOctreeChunk(_source, _capacity, true,
            _shortKeys, _wideKeys, _presence, _values);
        Write(owner);
        var position = DeferredChunkData.Position(_writes - 1);
        var channel = (_writes - 1) % _channelsWritten;
        return owner[channel, DeferredChunkData.X(position), DeferredChunkData.Y(position), DeferredChunkData.Z(position)];
    }

    [Benchmark]
    public uint DeferredCompleteCycle()
    {
        using var owner = new DeferredOctreeChunk(_source, _capacity);
        Write(owner);
        return Checksum(owner.Repackage());
    }

    [Benchmark]
    public uint ImmediateEditSession()
    {
        using var owner = new DeferredOctreeChunk(_source, _capacity, deferredWritesEnabled: false);
        Write(owner);
        var position = DeferredChunkData.Position(_writes - 1);
        var channel = (_writes - 1) % _channelsWritten;
        return owner[channel, DeferredChunkData.X(position), DeferredChunkData.Y(position), DeferredChunkData.Z(position)];
    }

    [Benchmark]
    public uint ImmediateCompleteCycle()
    {
        using var owner = new DeferredOctreeChunk(_source, _capacity, deferredWritesEnabled: false);
        Write(owner);
        return Checksum(owner.Repackage());
    }

    [Benchmark]
    public uint DeferredSerializeCycle()
    {
        using var owner = new DeferredOctreeChunk(_source, _capacity);
        Write(owner);
        var written = owner.CopyEncodedTo(_encoded);
        return (uint)written + _encoded[written - 1];
    }

    [Benchmark]
    public uint DeferredMakeHotCycle()
    {
        using var owner = new DeferredOctreeChunk(_source, _capacity);
        Write(owner);
        var hot = owner.MakeHot();
        var position = DeferredChunkData.Position(_writes - 1);
        var channel = (_writes - 1) % _channelsWritten;
        return hot[channel, DeferredChunkData.X(position), DeferredChunkData.Y(position), DeferredChunkData.Z(position)];
    }

    private void Write(DeferredOctreeChunk owner)
    {
        for (var index = 0; index < _writes; index++)
        {
            var position = DeferredChunkData.Position(index);
            owner[index % _channelsWritten,
                DeferredChunkData.X(position), DeferredChunkData.Y(position), DeferredChunkData.Z(position)] =
                (uint)(10_000 + index);
        }
    }

    private uint Checksum(OctreeChunk chunk)
    {
        var first = DeferredChunkData.Position(0);
        var last = DeferredChunkData.Position(_writes - 1);
        return (uint)chunk.SerializedLength
             + chunk.GetChannel(0).Get(DeferredChunkData.X(first), DeferredChunkData.Y(first), DeferredChunkData.Z(first))
             + chunk.GetChannel((_writes - 1) % _channelsWritten).Get(
                 DeferredChunkData.X(last), DeferredChunkData.Y(last), DeferredChunkData.Z(last));
    }

    private uint ExpectedChecksum()
    {
        var values = new uint[DeferredChunkData.Volume * _channels];
        _source.CopyBlockTo(0, 0, 0, 5, values);
        for (var index = 0; index < _writes; index++)
        {
            var position = DeferredChunkData.Position(index);
            values[(index % _channelsWritten) * DeferredChunkData.Volume + position] = (uint)(10_000 + index);
        }
        return Checksum(OctreeChunk.FromDense(5, _channels, values));
    }

    private static OctreeChunk CreateSource(DeferredChunkPattern pattern, int channels)
    {
        var values = new uint[DeferredChunkData.Volume * channels];
        for (var channel = 0; channel < channels; channel++)
        for (var x = 0; x < 32; x++)
        for (var y = 0; y < 32; y++)
        for (var z = 0; z < 32; z++)
            values[channel * DeferredChunkData.Volume + (x * 32 + y) * 32 + z] =
                pattern == DeferredChunkPattern.Uniform
                    ? (uint)(channel + 1)
                    : y < 12 + ((x + z) & 3) ? (uint)(channel + 1) : 0;
        return OctreeChunk.FromDense(5, channels, values);
    }
}

internal sealed class ReusableArrayPool<T> : ArrayPool<T>
{
    private readonly T[] _buffer;
    private bool _rented;

    internal ReusableArrayPool(int length) => _buffer = new T[length];

    public override T[] Rent(int minimumLength)
    {
        if (_rented || minimumLength > _buffer.Length)
            return ArrayPool<T>.Shared.Rent(minimumLength);
        _rented = true;
        return _buffer;
    }

    public override void Return(T[] array, bool clearArray = false)
    {
        if (!ReferenceEquals(array, _buffer))
        {
            ArrayPool<T>.Shared.Return(array, clearArray);
            return;
        }
        if (clearArray) array.AsSpan().Clear();
        _rented = false;
    }
}

[MemoryDiagnoser]
public class DeferredRepeatedWriteBenchmarks
{
    [Params(20, 256)]
    public int WriteCount { get; set; }

    private OctreeChunk _source = null!;

    [GlobalSetup]
    public void Setup()
    {
        _source = DeferredChunkData.Create(DeferredChunkPattern.Terrain);
        if (RepeatedPosition() == 0 || DistinctPositions() == 0)
            throw new InvalidOperationException("Repeated-write benchmark parity failed.");
    }

    [Benchmark]
    public uint RepeatedPosition()
    {
        using var owner = new DeferredOctreeChunk(_source);
        const int position = 1234;
        for (var index = 0; index < WriteCount; index++)
            owner[index & 1, DeferredChunkData.X(position), DeferredChunkData.Y(position), DeferredChunkData.Z(position)] =
                (uint)(10_000 + index);
        return owner[(WriteCount - 1) & 1,
            DeferredChunkData.X(position), DeferredChunkData.Y(position), DeferredChunkData.Z(position)];
    }

    [Benchmark]
    public uint DistinctPositions()
    {
        using var owner = new DeferredOctreeChunk(_source);
        for (var index = 0; index < WriteCount; index++)
        {
            var position = DeferredChunkData.Position(index);
            owner[index & 1, DeferredChunkData.X(position), DeferredChunkData.Y(position), DeferredChunkData.Z(position)] =
                (uint)(10_000 + index);
        }
        var last = DeferredChunkData.Position(WriteCount - 1);
        return owner[(WriteCount - 1) & 1,
            DeferredChunkData.X(last), DeferredChunkData.Y(last), DeferredChunkData.Z(last)];
    }
}

[MemoryDiagnoser]
public class DeferredStorageAcquisitionBenchmarks
{
    [Params(20, 32, 64, 256, 512)]
    public int Capacity { get; set; }

    private ushort[] _callerKeys = null!;
    private ulong[] _callerPresence = null!;
    private uint[] _callerValues = null!;

    [GlobalSetup]
    public void Setup()
    {
        _callerKeys = new ushort[Capacity];
        _callerPresence = new ulong[2 * ((Capacity + 63) / 64)];
        _callerValues = new uint[Capacity];
    }

    [Benchmark(Baseline = true)]
    public uint SharedPoolRoundTrip()
    {
        var keys = ArrayPool<ushort>.Shared.Rent(Capacity);
        var presence = ArrayPool<ulong>.Shared.Rent(2 * ((Capacity + 63) / 64));
        var values = ArrayPool<uint>.Shared.Rent(Capacity);
        presence.AsSpan(0, 2 * ((Capacity + 63) / 64)).Clear();
        keys[0] = 1234;
        values[0] = 5678;
        var result = (uint)(keys[0] + presence[0]) + values[0];
        ArrayPool<uint>.Shared.Return(values);
        ArrayPool<ulong>.Shared.Return(presence);
        ArrayPool<ushort>.Shared.Return(keys);
        return result;
    }

    [Benchmark]
    public uint ExactOwnedArrays()
    {
        var keys = new ushort[Capacity];
        var presence = new ulong[2 * ((Capacity + 63) / 64)];
        var values = new uint[Capacity];
        keys[0] = 1234;
        values[0] = 5678;
        return (uint)(keys[0] + presence[0]) + values[0];
    }

    [Benchmark]
    public uint CallerReusedArrays()
    {
        _callerPresence.AsSpan().Clear();
        _callerKeys[0] = 1234;
        _callerValues[0] = 5678;
        return (uint)(_callerKeys[0] + _callerPresence[0]) + _callerValues[0];
    }
}

[MemoryDiagnoser]
public class DeferredInsertionLookupBenchmarks
{
    [Params(20, 32, 64, 128, 256, 512, 1024)]
    public int Count { get; set; }

    private ushort[] _source = null!;
    private ushort[] _keys = null!;
    private Dictionary<ushort, int> _dictionary = null!;

    [GlobalSetup]
    public void Setup()
    {
        _source = new ushort[Count];
        _keys = new ushort[Count];
        _dictionary = new Dictionary<ushort, int>(Count);
        for (var index = 0; index < Count; index++)
            _source[index] = (ushort)DeferredChunkData.Position(index);
        if (LinearBuild() != DictionaryBuild()) throw new InvalidOperationException("Insertion lookup parity failed.");
    }

    [Benchmark(Baseline = true)]
    public int LinearBuild()
    {
        var populated = 0;
        var checksum = 0;
        foreach (var key in _source)
        {
            var index = _keys.AsSpan(0, populated).IndexOf(key);
            if (index < 0)
            {
                index = populated++;
                _keys[index] = key;
            }
            checksum += index;
        }
        return checksum;
    }

    [Benchmark]
    public int DictionaryBuild()
    {
        _dictionary.Clear();
        var checksum = 0;
        foreach (var key in _source)
        {
            if (!_dictionary.TryGetValue(key, out var index))
            {
                index = _dictionary.Count;
                _dictionary.Add(key, index);
            }
            checksum += index;
        }
        return checksum;
    }
}
