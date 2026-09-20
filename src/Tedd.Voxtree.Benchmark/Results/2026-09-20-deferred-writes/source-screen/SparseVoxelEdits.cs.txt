using System.Buffers;

namespace Tedd.Voxtree;

// Exclusively owned. Keys are shared across channels; validity bits distinguish an
// unwritten channel from an explicit zero. Only initialized keys are searched.
internal sealed class SparseVoxelEdits<T> : IDisposable where T : unmanaged
{
    private readonly int _capacity;
    private readonly int _wordsPerChannel;
    private readonly T[]?[] _values;
    private ushort[]? _shortKeys;
    private int[]? _wideKeys;
    private ulong[]? _present;

    internal SparseVoxelEdits(int levels, int channels, int capacity)
    {
        _capacity = capacity;
        _wordsPerChannel = (capacity + 63) / 64;
        _values = new T[channels][];
        try
        {
            if (levels <= 5) _shortKeys = ArrayPool<ushort>.Shared.Rent(capacity);
            else _wideKeys = ArrayPool<int>.Shared.Rent(capacity);
            var words = checked(channels * _wordsPerChannel);
            _present = ArrayPool<ulong>.Shared.Rent(words);
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
        var values = _values[channel] ??= ArrayPool<T>.Shared.Rent(_capacity);
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

    public void Dispose()
    {
        if (_shortKeys is not null) ArrayPool<ushort>.Shared.Return(_shortKeys);
        if (_wideKeys is not null) ArrayPool<int>.Shared.Return(_wideKeys);
        if (_present is not null) ArrayPool<ulong>.Shared.Return(_present);
        _shortKeys = null;
        _wideKeys = null;
        _present = null;
        for (var channel = 0; channel < _values.Length; channel++)
        {
            if (_values[channel] is { } values) ArrayPool<T>.Shared.Return(values);
            _values[channel] = null;
        }
        Count = 0;
    }
}
