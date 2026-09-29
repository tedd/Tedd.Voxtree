using System.Buffers.Binary;

namespace Tedd.Voxtree;

/// <summary>A stack-bound, zero-allocation view over a caller-owned version-1 chunk packet.</summary>
/// <remarks>
/// The packet must remain alive and immutable while the view is used. Construction validates the
/// packet envelope and channel headers. Call <see cref="IsWellFormed"/> before accepting untrusted
/// channel trees.
/// </remarks>
public readonly ref struct OctreeChunkSpan
{
    private const int HeaderSize = 12;
    private readonly ReadOnlySpan<byte> _data;
    private readonly int _levels;
    private readonly int _channelCount;

    /// <summary>Creates a zero-copy view over an exact chunk packet.</summary>
    public OctreeChunkSpan(ReadOnlySpan<byte> data)
    {
        if (!TryReadPacket(data, out _levels, out _channelCount))
            throw new FormatException("Invalid chunk packet envelope or channel header.");
        _data = data;
    }

    private OctreeChunkSpan(ReadOnlySpan<byte> data, int levels, int channelCount)
    {
        _data = data;
        _levels = levels;
        _channelCount = channelCount;
    }

    /// <summary>Whether this view was initialized from a supported packet envelope.</summary>
    public bool IsValid => !_data.IsEmpty;
    /// <summary>The shared channel depth.</summary>
    public int Levels => _levels;
    /// <summary>The shared channel side length.</summary>
    public int SideLength => 1 << _levels;
    /// <summary>The number of channels.</summary>
    public int ChannelCount => _channelCount;
    /// <summary>The exact serialized packet length.</summary>
    public int SerializedLength => _data.Length;
    /// <summary>The caller-owned packet bytes.</summary>
    public ReadOnlySpan<byte> Data => _data;

    /// <summary>Gets one channel's encoded bytes without allocation.</summary>
    public ReadOnlySpan<byte> GetChannelData(int channel)
    {
        if ((uint)channel >= (uint)_channelCount) throw new ArgumentOutOfRangeException(nameof(channel));
        var offset = HeaderSize;
        for (var index = 0; index <= channel; index++)
        {
            var length = BinaryPrimitives.ReadInt32LittleEndian(_data[offset..]);
            offset += sizeof(int);
            if (index == channel) return _data.Slice(offset, length);
            offset += length;
        }
        throw new InvalidOperationException();
    }

    /// <summary>Gets a zero-copy view of one channel.</summary>
    public OctreeSpan GetChannel(int channel) => new(GetChannelData(channel));

    /// <summary>Performs complete structural validation of every channel.</summary>
    public bool IsWellFormed()
    {
        if (!IsValid) return false;
        var offset = HeaderSize;
        for (var channel = 0; channel < _channelCount; channel++)
        {
            var length = BinaryPrimitives.ReadInt32LittleEndian(_data[offset..]);
            offset += sizeof(int);
            if (!new OctreeSpan(_data.Slice(offset, length)).IsWellFormed()) return false;
            offset += length;
        }
        return true;
    }

    /// <summary>Attempts to create a zero-copy view from a supported packet envelope.</summary>
    public static bool TryCreate(ReadOnlySpan<byte> data, out OctreeChunkSpan chunk)
    {
        if (!TryReadPacket(data, out var levels, out var channelCount))
        {
            chunk = default;
            return false;
        }
        chunk = new OctreeChunkSpan(data, levels, channelCount);
        return true;
    }

    private static bool TryReadPacket(ReadOnlySpan<byte> data, out int levels, out int channelCount)
    {
        levels = default;
        channelCount = default;
        if (data.Length < HeaderSize || data[0] != 0x4f || data[1] != 0x43 || data[2] != 1 ||
            data[3] > Octree.MaxLevels || BinaryPrimitives.ReadInt32LittleEndian(data[8..]) != data.Length)
            return false;
        channelCount = BinaryPrimitives.ReadInt32LittleEndian(data[4..]);
        if (channelCount <= 0 || channelCount > (data.Length - HeaderSize) / 7) return false;
        levels = data[3];
        var offset = HeaderSize;
        for (var channel = 0; channel < channelCount; channel++)
        {
            if (data.Length - offset < sizeof(int)) return false;
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[offset..]);
            offset += sizeof(int);
            if (length < 3 || length > data.Length - offset ||
                !OctreeSpan.TryCreate(data.Slice(offset, length), out var view) || view.Levels != levels)
                return false;
            offset += length;
        }
        return offset == data.Length;
    }
}

/// <summary>A stack-bound, zero-allocation view over a caller-owned version-2 generic chunk packet.</summary>
/// <remarks>
/// The packet must remain alive and immutable while the view is used. Construction validates the
/// packet envelope and channel headers. Call <see cref="IsWellFormed"/> before accepting untrusted
/// channel trees.
/// </remarks>
public readonly ref struct OctreeChunkSpan<T> where T : unmanaged
{
    private const int HeaderSize = 12;
    private readonly ReadOnlySpan<byte> _data;
    private readonly int _levels;
    private readonly int _channelCount;

    /// <summary>Creates a zero-copy view over an exact generic chunk packet.</summary>
    public OctreeChunkSpan(ReadOnlySpan<byte> data)
    {
        VoxelType<T>.Validate();
        if (!TryReadPacket(data, out _levels, out _channelCount))
            throw new FormatException("Invalid generic chunk packet envelope or channel header.");
        _data = data;
    }

    private OctreeChunkSpan(ReadOnlySpan<byte> data, int levels, int channelCount)
    {
        _data = data;
        _levels = levels;
        _channelCount = channelCount;
    }

    /// <summary>Whether this view was initialized from a supported packet envelope.</summary>
    public bool IsValid => !_data.IsEmpty;
    /// <summary>The shared channel depth.</summary>
    public int Levels => _levels;
    /// <summary>The shared channel side length.</summary>
    public int SideLength => 1 << _levels;
    /// <summary>The number of channels.</summary>
    public int ChannelCount => _channelCount;
    /// <summary>The exact serialized packet length.</summary>
    public int SerializedLength => _data.Length;
    /// <summary>The caller-owned packet bytes.</summary>
    public ReadOnlySpan<byte> Data => _data;

    /// <summary>Gets one channel's encoded bytes without allocation.</summary>
    public ReadOnlySpan<byte> GetChannelData(int channel)
    {
        if ((uint)channel >= (uint)_channelCount) throw new ArgumentOutOfRangeException(nameof(channel));
        var offset = HeaderSize;
        for (var index = 0; index <= channel; index++)
        {
            var length = BinaryPrimitives.ReadInt32LittleEndian(_data[offset..]);
            offset += sizeof(int);
            if (index == channel) return _data.Slice(offset, length);
            offset += length;
        }
        throw new InvalidOperationException();
    }

    /// <summary>Gets a zero-copy view of one channel.</summary>
    public OctreeSpan<T> GetChannel(int channel) => new(GetChannelData(channel));

    /// <summary>Performs complete structural validation of every channel.</summary>
    public bool IsWellFormed()
    {
        if (!IsValid) return false;
        var offset = HeaderSize;
        for (var channel = 0; channel < _channelCount; channel++)
        {
            var length = BinaryPrimitives.ReadInt32LittleEndian(_data[offset..]);
            offset += sizeof(int);
            if (!new OctreeSpan<T>(_data.Slice(offset, length)).IsWellFormed()) return false;
            offset += length;
        }
        return true;
    }

    /// <summary>Attempts to create a zero-copy view from a supported generic packet envelope.</summary>
    public static bool TryCreate(ReadOnlySpan<byte> data, out OctreeChunkSpan<T> chunk)
    {
        VoxelType<T>.Validate();
        if (!TryReadPacket(data, out var levels, out var channelCount))
        {
            chunk = default;
            return false;
        }
        chunk = new OctreeChunkSpan<T>(data, levels, channelCount);
        return true;
    }

    private static bool TryReadPacket(ReadOnlySpan<byte> data, out int levels, out int channelCount)
    {
        levels = default;
        channelCount = default;
        if (data.Length < HeaderSize || data[0] != 0x4f || data[1] != 0x43 || data[2] != 2 ||
            data[3] > Octree.MaxLevels || BinaryPrimitives.ReadInt32LittleEndian(data[8..]) != data.Length)
            return false;
        channelCount = BinaryPrimitives.ReadInt32LittleEndian(data[4..]);
        if (channelCount <= 0 || channelCount > (data.Length - HeaderSize) / 8) return false;
        levels = data[3];
        var offset = HeaderSize;
        for (var channel = 0; channel < channelCount; channel++)
        {
            if (data.Length - offset < sizeof(int)) return false;
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[offset..]);
            offset += sizeof(int);
            if (length < 4 || length > data.Length - offset ||
                !OctreeSpan<T>.TryCreate(data.Slice(offset, length), out var view) || view.Levels != levels)
                return false;
            offset += length;
        }
        return offset == data.Length;
    }
}
