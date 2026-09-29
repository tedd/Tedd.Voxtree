using System.Buffers.Binary;
using System.Runtime.InteropServices;

namespace Tedd.Voxtree;

/// <summary>A stack-bound, zero-allocation view over a caller-owned UInt32 chunk packet.</summary>
/// <remarks>
/// The packet must remain alive and immutable while the view is used. Construction validates the
/// packet envelope and channel directories. Call <see cref="IsWellFormed"/> before accepting
/// untrusted voxel trees.
/// </remarks>
public readonly ref struct OctreeChunkSpan
{
    private const int HeaderSize = 12;
    private const int ExtendedHeaderSize = 16;
    private const byte LegacyFormatVersion = 1;
    private const byte ExtendedFormatVersion = 3;
    private readonly ReadOnlySpan<byte> _data;
    private readonly int _levels;
    private readonly int _channelCount;
    private readonly int _sideChannelCount;
    private readonly byte _formatVersion;

    /// <summary>Creates a zero-copy view over an exact chunk packet.</summary>
    public OctreeChunkSpan(ReadOnlySpan<byte> data)
    {
        if (!TryReadPacket(data, out _levels, out _channelCount,
                out _sideChannelCount, out _formatVersion))
            throw new FormatException("Invalid chunk packet envelope or channel directory.");
        _data = data;
    }

    private OctreeChunkSpan(ReadOnlySpan<byte> data, int levels, int channelCount,
        int sideChannelCount, byte formatVersion)
    {
        _data = data;
        _levels = levels;
        _channelCount = channelCount;
        _sideChannelCount = sideChannelCount;
        _formatVersion = formatVersion;
    }

    /// <summary>Whether this view was initialized from a supported packet envelope.</summary>
    public bool IsValid => !_data.IsEmpty;
    /// <summary>The shared voxel-channel depth.</summary>
    public int Levels => _levels;
    /// <summary>The shared voxel-channel side length.</summary>
    public int SideLength => 1 << _levels;
    /// <summary>The number of voxel channels.</summary>
    public int ChannelCount => _channelCount;
    /// <summary>The number of chunk-level side channels.</summary>
    public int SideChannelCount => _sideChannelCount;
    /// <summary>The exact serialized packet length.</summary>
    public int SerializedLength => _data.Length;
    /// <summary>The caller-owned packet bytes.</summary>
    public ReadOnlySpan<byte> Data => _data;

    /// <summary>Gets one voxel channel's encoded bytes without allocation.</summary>
    public ReadOnlySpan<byte> GetChannelData(int channel)
    {
        if ((uint)channel >= (uint)_channelCount) throw new ArgumentOutOfRangeException(nameof(channel));
        if (_formatVersion == ExtendedFormatVersion)
        {
            var header = ExtendedHeaderSize + channel * 2 * sizeof(int);
            var length = BinaryPrimitives.ReadInt32LittleEndian(_data[header..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(_data[(header + sizeof(int))..]);
            return _data.Slice(position, length);
        }

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

    /// <summary>Gets a zero-copy view of one voxel channel.</summary>
    public OctreeSpan GetChannel(int channel) => new(GetChannelData(channel));

    /// <summary>Gets a side-channel identifier by ascending index.</summary>
    public int GetSideChannelId(int index)
    {
        if ((uint)index >= (uint)_sideChannelCount) throw new ArgumentOutOfRangeException(nameof(index));
        var header = GetSideHeaderOffset() + index * 3 * sizeof(int);
        return BinaryPrimitives.ReadInt32LittleEndian(_data[header..]);
    }

    /// <summary>Gets a read-only zero-copy byte view of a side channel.</summary>
    public ReadOnlySpan<byte> GetSideChannel(int channelId)
    {
        if (channelId < 0) throw new ArgumentOutOfRangeException(nameof(channelId));
        var header = FindSideChannelHeader(channelId);
        var length = BinaryPrimitives.ReadInt32LittleEndian(_data[(header + sizeof(int))..]);
        var position = BinaryPrimitives.ReadInt32LittleEndian(_data[(header + 2 * sizeof(int))..]);
        return _data.Slice(position, length);
    }

    /// <summary>Gets a read-only zero-copy typed view of a side channel.</summary>
    public ReadOnlySpan<T> GetSideChannel<T>(int channelId) where T : unmanaged =>
        MemoryMarshal.Cast<byte, T>(GetSideChannel(channelId));

    /// <summary>Performs complete structural validation of every voxel channel.</summary>
    public bool IsWellFormed()
    {
        if (!IsValid) return false;
        for (var channel = 0; channel < _channelCount; channel++)
            if (!new OctreeSpan(GetChannelData(channel)).IsWellFormed()) return false;
        return true;
    }

    /// <summary>Attempts to create a zero-copy view from a supported packet envelope.</summary>
    public static bool TryCreate(ReadOnlySpan<byte> data, out OctreeChunkSpan chunk)
    {
        if (!TryReadPacket(data, out var levels, out var channelCount,
                out var sideChannelCount, out var formatVersion))
        {
            chunk = default;
            return false;
        }
        chunk = new OctreeChunkSpan(data, levels, channelCount, sideChannelCount, formatVersion);
        return true;
    }

    private int GetSideHeaderOffset() => ExtendedHeaderSize + _channelCount * 2 * sizeof(int);

    private int FindSideChannelHeader(int channelId)
    {
        var low = 0;
        var high = _sideChannelCount - 1;
        var baseOffset = GetSideHeaderOffset();
        while (low <= high)
        {
            var middle = low + ((high - low) >> 1);
            var header = baseOffset + middle * 3 * sizeof(int);
            var current = BinaryPrimitives.ReadInt32LittleEndian(_data[header..]);
            if (current == channelId) return header;
            if (current < channelId) low = middle + 1;
            else high = middle - 1;
        }
        throw new KeyNotFoundException($"Side channel {channelId} does not exist.");
    }

    private static bool TryReadPacket(ReadOnlySpan<byte> data, out int levels,
        out int channelCount, out int sideChannelCount, out byte formatVersion)
    {
        levels = default;
        channelCount = default;
        sideChannelCount = default;
        formatVersion = default;
        if (data.Length < HeaderSize || data[0] != 0x4f || data[1] != 0x43 ||
            data[3] > Octree.MaxLevels || BinaryPrimitives.ReadInt32LittleEndian(data[8..]) != data.Length)
            return false;

        formatVersion = data[2];
        channelCount = BinaryPrimitives.ReadInt32LittleEndian(data[4..]);
        levels = data[3];
        if (formatVersion == LegacyFormatVersion)
            return TryReadLegacyPacket(data, levels, channelCount);
        if (formatVersion != ExtendedFormatVersion || data.Length < ExtendedHeaderSize)
            return false;

        sideChannelCount = BinaryPrimitives.ReadInt32LittleEndian(data[12..]);
        if (channelCount <= 0 || sideChannelCount < 0) return false;
        var directoryLength = (long)ExtendedHeaderSize + (long)channelCount * 2 * sizeof(int) +
                              (long)sideChannelCount * 3 * sizeof(int);
        if (directoryLength > data.Length) return false;

        var header = ExtendedHeaderSize;
        var expectedPosition = (int)directoryLength;
        for (var channel = 0; channel < channelCount; channel++)
        {
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[header..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(data[(header + sizeof(int))..]);
            header += 2 * sizeof(int);
            if (length < 3 || position != expectedPosition || length > data.Length - position ||
                !OctreeSpan.TryCreate(data.Slice(position, length), out var view) || view.Levels != levels)
                return false;
            expectedPosition += length;
        }

        var previousId = -1;
        for (var index = 0; index < sideChannelCount; index++)
        {
            var channelId = BinaryPrimitives.ReadInt32LittleEndian(data[header..]);
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[(header + sizeof(int))..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(data[(header + 2 * sizeof(int))..]);
            header += 3 * sizeof(int);
            if (channelId <= previousId || length < 0 || position != expectedPosition ||
                length > data.Length - position)
                return false;
            previousId = channelId;
            expectedPosition += length;
        }
        return expectedPosition == data.Length;
    }

    private static bool TryReadLegacyPacket(ReadOnlySpan<byte> data, int levels, int channelCount)
    {
        if (channelCount <= 0 || channelCount > (data.Length - HeaderSize) / 7) return false;
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

/// <summary>A stack-bound, zero-allocation view over a caller-owned generic chunk packet.</summary>
/// <remarks>
/// The packet must remain alive and immutable while the view is used. Construction validates the
/// packet envelope and channel directories. Call <see cref="IsWellFormed"/> before accepting
/// untrusted voxel trees.
/// </remarks>
public readonly ref struct OctreeChunkSpan<T> where T : unmanaged
{
    private const int HeaderSize = 12;
    private const int ExtendedHeaderSize = 16;
    private const byte LegacyFormatVersion = 2;
    private const byte ExtendedFormatVersion = 4;
    private readonly ReadOnlySpan<byte> _data;
    private readonly int _levels;
    private readonly int _channelCount;
    private readonly int _sideChannelCount;
    private readonly byte _formatVersion;

    /// <summary>Creates a zero-copy view over an exact generic chunk packet.</summary>
    public OctreeChunkSpan(ReadOnlySpan<byte> data)
    {
        VoxelType<T>.Validate();
        if (!TryReadPacket(data, out _levels, out _channelCount,
                out _sideChannelCount, out _formatVersion))
            throw new FormatException("Invalid generic chunk packet envelope or channel directory.");
        _data = data;
    }

    private OctreeChunkSpan(ReadOnlySpan<byte> data, int levels, int channelCount,
        int sideChannelCount, byte formatVersion)
    {
        _data = data;
        _levels = levels;
        _channelCount = channelCount;
        _sideChannelCount = sideChannelCount;
        _formatVersion = formatVersion;
    }

    /// <summary>Whether this view was initialized from a supported packet envelope.</summary>
    public bool IsValid => !_data.IsEmpty;
    /// <summary>The shared voxel-channel depth.</summary>
    public int Levels => _levels;
    /// <summary>The shared voxel-channel side length.</summary>
    public int SideLength => 1 << _levels;
    /// <summary>The number of voxel channels.</summary>
    public int ChannelCount => _channelCount;
    /// <summary>The number of chunk-level side channels.</summary>
    public int SideChannelCount => _sideChannelCount;
    /// <summary>The exact serialized packet length.</summary>
    public int SerializedLength => _data.Length;
    /// <summary>The caller-owned packet bytes.</summary>
    public ReadOnlySpan<byte> Data => _data;

    /// <summary>Gets one voxel channel's encoded bytes without allocation.</summary>
    public ReadOnlySpan<byte> GetChannelData(int channel)
    {
        if ((uint)channel >= (uint)_channelCount) throw new ArgumentOutOfRangeException(nameof(channel));
        if (_formatVersion == ExtendedFormatVersion)
        {
            var header = ExtendedHeaderSize + channel * 2 * sizeof(int);
            var length = BinaryPrimitives.ReadInt32LittleEndian(_data[header..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(_data[(header + sizeof(int))..]);
            return _data.Slice(position, length);
        }

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

    /// <summary>Gets a zero-copy view of one voxel channel.</summary>
    public OctreeSpan<T> GetChannel(int channel) => new(GetChannelData(channel));

    /// <summary>Gets a side-channel identifier by ascending index.</summary>
    public int GetSideChannelId(int index)
    {
        if ((uint)index >= (uint)_sideChannelCount) throw new ArgumentOutOfRangeException(nameof(index));
        var header = GetSideHeaderOffset() + index * 3 * sizeof(int);
        return BinaryPrimitives.ReadInt32LittleEndian(_data[header..]);
    }

    /// <summary>Gets a read-only zero-copy byte view of a side channel.</summary>
    public ReadOnlySpan<byte> GetSideChannel(int channelId)
    {
        if (channelId < 0) throw new ArgumentOutOfRangeException(nameof(channelId));
        var header = FindSideChannelHeader(channelId);
        var length = BinaryPrimitives.ReadInt32LittleEndian(_data[(header + sizeof(int))..]);
        var position = BinaryPrimitives.ReadInt32LittleEndian(_data[(header + 2 * sizeof(int))..]);
        return _data.Slice(position, length);
    }

    /// <summary>Gets a read-only zero-copy typed view of a side channel.</summary>
    public ReadOnlySpan<TSide> GetSideChannel<TSide>(int channelId) where TSide : unmanaged =>
        MemoryMarshal.Cast<byte, TSide>(GetSideChannel(channelId));

    /// <summary>Performs complete structural validation of every voxel channel.</summary>
    public bool IsWellFormed()
    {
        if (!IsValid) return false;
        for (var channel = 0; channel < _channelCount; channel++)
            if (!new OctreeSpan<T>(GetChannelData(channel)).IsWellFormed()) return false;
        return true;
    }

    /// <summary>Attempts to create a zero-copy view from a supported generic packet envelope.</summary>
    public static bool TryCreate(ReadOnlySpan<byte> data, out OctreeChunkSpan<T> chunk)
    {
        VoxelType<T>.Validate();
        if (!TryReadPacket(data, out var levels, out var channelCount,
                out var sideChannelCount, out var formatVersion))
        {
            chunk = default;
            return false;
        }
        chunk = new OctreeChunkSpan<T>(data, levels, channelCount, sideChannelCount, formatVersion);
        return true;
    }

    private int GetSideHeaderOffset() => ExtendedHeaderSize + _channelCount * 2 * sizeof(int);

    private int FindSideChannelHeader(int channelId)
    {
        var low = 0;
        var high = _sideChannelCount - 1;
        var baseOffset = GetSideHeaderOffset();
        while (low <= high)
        {
            var middle = low + ((high - low) >> 1);
            var header = baseOffset + middle * 3 * sizeof(int);
            var current = BinaryPrimitives.ReadInt32LittleEndian(_data[header..]);
            if (current == channelId) return header;
            if (current < channelId) low = middle + 1;
            else high = middle - 1;
        }
        throw new KeyNotFoundException($"Side channel {channelId} does not exist.");
    }

    private static bool TryReadPacket(ReadOnlySpan<byte> data, out int levels,
        out int channelCount, out int sideChannelCount, out byte formatVersion)
    {
        levels = default;
        channelCount = default;
        sideChannelCount = default;
        formatVersion = default;
        if (data.Length < HeaderSize || data[0] != 0x4f || data[1] != 0x43 ||
            data[3] > Octree.MaxLevels || BinaryPrimitives.ReadInt32LittleEndian(data[8..]) != data.Length)
            return false;

        formatVersion = data[2];
        channelCount = BinaryPrimitives.ReadInt32LittleEndian(data[4..]);
        levels = data[3];
        if (formatVersion == LegacyFormatVersion)
            return TryReadLegacyPacket(data, levels, channelCount);
        if (formatVersion != ExtendedFormatVersion || data.Length < ExtendedHeaderSize)
            return false;

        sideChannelCount = BinaryPrimitives.ReadInt32LittleEndian(data[12..]);
        if (channelCount <= 0 || sideChannelCount < 0) return false;
        var directoryLength = (long)ExtendedHeaderSize + (long)channelCount * 2 * sizeof(int) +
                              (long)sideChannelCount * 3 * sizeof(int);
        if (directoryLength > data.Length) return false;

        var header = ExtendedHeaderSize;
        var expectedPosition = (int)directoryLength;
        for (var channel = 0; channel < channelCount; channel++)
        {
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[header..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(data[(header + sizeof(int))..]);
            header += 2 * sizeof(int);
            if (length < 4 || position != expectedPosition || length > data.Length - position ||
                !OctreeSpan<T>.TryCreate(data.Slice(position, length), out var view) || view.Levels != levels)
                return false;
            expectedPosition += length;
        }

        var previousId = -1;
        for (var index = 0; index < sideChannelCount; index++)
        {
            var channelId = BinaryPrimitives.ReadInt32LittleEndian(data[header..]);
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[(header + sizeof(int))..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(data[(header + 2 * sizeof(int))..]);
            header += 3 * sizeof(int);
            if (channelId <= previousId || length < 0 || position != expectedPosition ||
                length > data.Length - position)
                return false;
            previousId = channelId;
            expectedPosition += length;
        }
        return expectedPosition == data.Length;
    }

    private static bool TryReadLegacyPacket(ReadOnlySpan<byte> data, int levels, int channelCount)
    {
        if (channelCount <= 0 || channelCount > (data.Length - HeaderSize) / 8) return false;
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
