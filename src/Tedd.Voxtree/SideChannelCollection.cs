namespace Tedd.Voxtree;

internal sealed class SideChannelCollection
{
    private readonly SortedList<int, byte[]> _channels = new();
    private int _payloadLength;

    internal int Count => _channels.Count;
    internal int PayloadLength => _payloadLength;

    internal int GetId(int index) => _channels.Keys[index];
    internal byte[] GetDataAt(int index) => _channels.Values[index];

    internal Span<byte> Create(int channelId, int byteLength)
    {
        ValidateId(channelId);
        if (byteLength < 0) throw new ArgumentOutOfRangeException(nameof(byteLength));
        if (_channels.ContainsKey(channelId))
            throw new ArgumentException("The side-channel identifier already exists.", nameof(channelId));

        var nextPayloadLength = checked(_payloadLength + byteLength);
        var data = new byte[byteLength];
        _channels.Add(channelId, data);
        _payloadLength = nextPayloadLength;
        return data;
    }

    internal Span<byte> Create(int channelId, ReadOnlySpan<byte> source)
    {
        var destination = Create(channelId, source.Length);
        source.CopyTo(destination);
        return destination;
    }

    internal Span<byte> Set(int channelId, ReadOnlySpan<byte> source)
    {
        ValidateId(channelId);
        var index = _channels.IndexOfKey(channelId);
        if (index >= 0)
        {
            var existing = _channels.Values[index];
            if (existing.Length == source.Length)
            {
                source.CopyTo(existing);
                return existing;
            }

            var replacement = source.ToArray();
            var nextPayloadLength = checked(_payloadLength - existing.Length + replacement.Length);
            _channels[channelId] = replacement;
            _payloadLength = nextPayloadLength;
            return replacement;
        }

        var addedPayloadLength = checked(_payloadLength + source.Length);
        var data = source.ToArray();
        _channels.Add(channelId, data);
        _payloadLength = addedPayloadLength;
        return data;
    }

    internal Span<byte> Get(int channelId)
    {
        ValidateId(channelId);
        if (!_channels.TryGetValue(channelId, out var data))
            throw new KeyNotFoundException($"Side channel {channelId} does not exist.");
        return data;
    }

    internal bool Delete(int channelId)
    {
        ValidateId(channelId);
        var index = _channels.IndexOfKey(channelId);
        if (index < 0) return false;
        _payloadLength -= _channels.Values[index].Length;
        _channels.RemoveAt(index);
        return true;
    }

    internal SideChannelCollection Clone()
    {
        var clone = new SideChannelCollection();
        for (var index = 0; index < Count; index++)
            clone.Create(GetId(index), GetDataAt(index));
        return clone;
    }

    private static void ValidateId(int channelId)
    {
        if (channelId < 0) throw new ArgumentOutOfRangeException(nameof(channelId));
    }
}
