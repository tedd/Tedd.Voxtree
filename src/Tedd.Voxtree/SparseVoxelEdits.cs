using System.Buffers;

namespace Tedd.Voxtree;

// Exclusively owned. Keys are shared across channels; validity bits distinguish an
// unwritten channel from an explicit zero. Only initialized keys are searched.
internal sealed class SparseVoxelEdits<T> : IDisposable where T : unmanaged
{
    private const int InitialCapacity = 32;
    private readonly int _capacity;
    private readonly T[]?[] _values;
    private int _physicalCapacity;
    private int _wordsPerChannel;
    private ushort[]? _shortKeys;
    private int[]? _wideKeys;
    private ulong[]? _present;

    internal SparseVoxelEdits(int levels, int channels, int capacity)
    {
        _capacity = capacity;
        _physicalCapacity = Math.Min(capacity, InitialCapacity);
        _wordsPerChannel = (_physicalCapacity + 63) / 64;
        _values = new T[channels][];
        try
        {
            if (levels <= 5) _shortKeys = ArrayPool<ushort>.Shared.Rent(_physicalCapacity);
            else _wideKeys = ArrayPool<int>.Shared.Rent(_physicalCapacity);
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
        if (index < 0 && Count == _physicalCapacity) Grow();
        // Rent before publishing a new key, so allocation failure cannot create an empty entry.
        var values = _values[channel] ??= ArrayPool<T>.Shared.Rent(_physicalCapacity);
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

    private void Grow()
    {
        var capacity = Math.Min(_capacity, checked(_physicalCapacity * 2));
        var wordsPerChannel = (capacity + 63) / 64;
        ushort[]? shortKeys = null;
        int[]? wideKeys = null;
        ulong[]? present = null;
        var values = new T[_values.Length][];
        try
        {
            if (_shortKeys is not null)
            {
                shortKeys = ArrayPool<ushort>.Shared.Rent(capacity);
                _shortKeys.AsSpan(0, Count).CopyTo(shortKeys);
            }
            else
            {
                wideKeys = ArrayPool<int>.Shared.Rent(capacity);
                _wideKeys!.AsSpan(0, Count).CopyTo(wideKeys);
            }

            var words = checked(_values.Length * wordsPerChannel);
            present = ArrayPool<ulong>.Shared.Rent(words);
            present.AsSpan(0, words).Clear();
            for (var channel = 0; channel < _values.Length; channel++)
            {
                _present!.AsSpan(channel * _wordsPerChannel, _wordsPerChannel)
                    .CopyTo(present.AsSpan(channel * wordsPerChannel));
                if (_values[channel] is not { } source) continue;
                var destination = values[channel] = ArrayPool<T>.Shared.Rent(capacity);
                source.AsSpan(0, Count).CopyTo(destination);
            }
        }
        catch
        {
            if (shortKeys is not null) ArrayPool<ushort>.Shared.Return(shortKeys);
            if (wideKeys is not null) ArrayPool<int>.Shared.Return(wideKeys);
            if (present is not null) ArrayPool<ulong>.Shared.Return(present);
            foreach (var buffer in values)
                if (buffer is not null) ArrayPool<T>.Shared.Return(buffer);
            throw;
        }

        if (_shortKeys is not null) ArrayPool<ushort>.Shared.Return(_shortKeys);
        if (_wideKeys is not null) ArrayPool<int>.Shared.Return(_wideKeys);
        ArrayPool<ulong>.Shared.Return(_present!);
        _shortKeys = shortKeys;
        _wideKeys = wideKeys;
        _present = present;
        for (var channel = 0; channel < _values.Length; channel++)
        {
            if (_values[channel] is { } previous) ArrayPool<T>.Shared.Return(previous);
            _values[channel] = values[channel];
        }
        _physicalCapacity = capacity;
        _wordsPerChannel = wordsPerChannel;
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
