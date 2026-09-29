using System.Buffers;

namespace Tedd.Voxtree;

// Exclusively owned. Keys are shared across channels; validity bits distinguish an
// unwritten channel from an explicit zero. Only initialized keys are searched.
internal sealed class SparseVoxelEdits<T> : IDisposable where T : unmanaged
{
    private readonly int _capacity;
    private readonly int _wordsPerChannel;
    private readonly T[]?[] _values;
    private readonly ArrayPool<ushort> _shortKeyPool;
    private readonly ArrayPool<int> _wideKeyPool;
    private readonly ArrayPool<ulong> _presentPool;
    private readonly ArrayPool<T> _valuePool;
    private ushort[]? _shortKeys;
    private int[]? _wideKeys;
    private ulong[]? _present;

    internal SparseVoxelEdits(int levels, int channels, int capacity)
        : this(levels, channels, capacity, ArrayPool<ushort>.Shared, ArrayPool<int>.Shared,
            ArrayPool<ulong>.Shared, ArrayPool<T>.Shared)
    {
    }

    internal SparseVoxelEdits(int levels, int channels, int capacity,
        ArrayPool<ushort> shortKeyPool, ArrayPool<int> wideKeyPool,
        ArrayPool<ulong> presentPool, ArrayPool<T> valuePool)
    {
        _capacity = capacity;
        _wordsPerChannel = (capacity + 63) / 64;
        _values = new T[channels][];
        _shortKeyPool = shortKeyPool;
        _wideKeyPool = wideKeyPool;
        _presentPool = presentPool;
        _valuePool = valuePool;
        try
        {
            if (levels <= 5) _shortKeys = _shortKeyPool.Rent(capacity);
            else _wideKeys = _wideKeyPool.Rent(capacity);
            var words = checked(channels * _wordsPerChannel);
            _present = _presentPool.Rent(words);
            _present.AsSpan(0, words).Clear();
        }
        catch { Dispose(); throw; }
    }

    internal int Count { get; private set; }
    internal int Key(int index) => _shortKeys is not null ? _shortKeys[index] : _wideKeys![index];
    internal bool HasChannel(int channel) => _values[channel] is not null;
    internal bool HasValue(int channel, int index) =>
        (_present![channel * _wordsPerChannel + (index >> 6)] & (1UL << (index & 63))) != 0;
    internal T Value(int channel, int index) => _values[channel]![index];

    private int Find(int key) => _shortKeys is not null
        ? _shortKeys.AsSpan(0, Count).IndexOf((ushort)key)
        : _wideKeys.AsSpan(0, Count).IndexOf(key);

    internal bool TryGet(int channel, int key, out T value)
    {
        var index = Find(key);
        if (index >= 0 && HasValue(channel, index))
        {
            value = Value(channel, index);
            return true;
        }
        value = default;
        return false;
    }

    internal bool TrySet(int channel, int key, T value)
    {
        var index = Find(key);
        if (index < 0 && Count == _capacity) return false;
        // Rent before publishing a new key, so allocation failure cannot create an empty entry.
        var values = _values[channel] ??= _valuePool.Rent(_capacity);
        if (index < 0)
        {
            index = Count;
            if (_shortKeys is not null) _shortKeys[index] = (ushort)key;
            else _wideKeys![index] = key;
            Count++;
        }
        values[index] = value;
        _present![channel * _wordsPerChannel + (index >> 6)] |= 1UL << (index & 63);
        return true;
    }

    internal int SelectChannelToMaterialize()
    {
        var bestChannel = -1;
        var bestExclusive = -1;
        var bestTotal = -1;
        for (var channel = 0; channel < _values.Length; channel++)
        {
            if (_values[channel] is null) continue;
            var total = 0;
            var exclusive = 0;
            for (var index = 0; index < Count; index++)
            {
                if (!HasValue(channel, index)) continue;
                total++;
                var shared = false;
                for (var other = 0; other < _values.Length; other++)
                {
                    if (other == channel || _values[other] is null || !HasValue(other, index)) continue;
                    shared = true;
                    break;
                }
                if (!shared) exclusive++;
            }
            if (exclusive < bestExclusive || exclusive == bestExclusive && total <= bestTotal) continue;
            bestChannel = channel;
            bestExclusive = exclusive;
            bestTotal = total;
        }
        return bestChannel;
    }

    internal void RemoveChannel(int channel)
    {
        if (_values[channel] is not { } removed) return;
        var remainingChannels = 0;
        for (var other = 0; other < _values.Length; other++)
            if (other != channel && _values[other] is not null) remainingChannels++;

        if (remainingChannels == 0)
        {
            _present!.AsSpan(0, checked(_values.Length * _wordsPerChannel)).Clear();
            _values[channel] = null;
            Count = 0;
            _valuePool.Return(removed);
            return;
        }

        var wordCount = checked(_values.Length * _wordsPerChannel);
        var present = _presentPool.Rent(wordCount);
        present.AsSpan(0, wordCount).Clear();
        var write = 0;
        for (var read = 0; read < Count; read++)
        {
            var retained = false;
            for (var other = 0; other < _values.Length; other++)
            {
                if (other == channel || _values[other] is null || !HasValue(other, read)) continue;
                retained = true;
                break;
            }
            if (!retained) continue;

            if (_shortKeys is not null) _shortKeys[write] = _shortKeys[read];
            else _wideKeys![write] = _wideKeys[read];
            for (var other = 0; other < _values.Length; other++)
            {
                if (other == channel || _values[other] is null || !HasValue(other, read)) continue;
                _values[other]![write] = _values[other]![read];
                present[other * _wordsPerChannel + (write >> 6)] |= 1UL << (write & 63);
            }
            write++;
        }

        var previousPresent = _present!;
        _present = present;
        _values[channel] = null;
        Count = write;
        _presentPool.Return(previousPresent);
        _valuePool.Return(removed);
    }

    public void Dispose()
    {
        if (_shortKeys is not null) _shortKeyPool.Return(_shortKeys);
        if (_wideKeys is not null) _wideKeyPool.Return(_wideKeys);
        if (_present is not null) _presentPool.Return(_present);
        _shortKeys = null;
        _wideKeys = null;
        _present = null;
        for (var channel = 0; channel < _values.Length; channel++)
        {
            if (_values[channel] is { } values) _valuePool.Return(values);
            _values[channel] = null;
        }
        Count = 0;
    }
}
