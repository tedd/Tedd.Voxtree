using System;
using System.Buffers.Binary;
using System.Runtime.InteropServices;

namespace Tedd.Voxtree;

/// <summary>A chunk with immutable voxel channels and optional mutable chunk-level side channels.</summary>
/// <remarks>
/// Encoded voxel-channel memory is borrowed and must remain alive and immutable. Dense factories own
/// their result arrays. Side channels are owned byte arrays; typed spans directly alias those arrays.
/// This type is not thread-safe while side channels are accessed or changed.
/// </remarks>
public sealed class OctreeChunk
{
    private const int HeaderSize = 12;
    private const int ExtendedHeaderSize = 16;
    private const int ExtendedFormatVersion = 3;
    private const int MaximumContiguousCopyLength = 64 * 1024;
    private readonly ReadOnlyMemory<byte>[] _channels;
    private readonly int _voxelSerializedLength;
    private readonly ReadOnlyMemory<byte> _serializedPacket;
    private readonly SideChannelCollection _sideChannels;

    /// <summary>Validates and retains channel encodings, copying only the memory descriptors.</summary>
    public OctreeChunk(int levels, ReadOnlySpan<ReadOnlyMemory<byte>> channels)
        : this(levels, ValidateAndCopy(levels, channels)) { }

    private OctreeChunk(int levels, ReadOnlyMemory<byte>[] channels,
        ReadOnlyMemory<byte> serializedPacket = default, bool? isEmpty = null,
        SideChannelCollection? sideChannels = null)
    {
        Levels = levels;
        _channels = channels;
        _serializedPacket = serializedPacket;
        _voxelSerializedLength = ComputeSerializedLength(channels);
        _sideChannels = sideChannels ?? new SideChannelCollection();
        IsEmpty = isEmpty ?? AreAllChannelsEmpty(channels);
    }

    private static int ComputeSerializedLength(ReadOnlySpan<ReadOnlyMemory<byte>> channels)
    {
        var length = HeaderSize;
        foreach (var channel in channels) length = checked(length + sizeof(int) + channel.Length);
        return length;
    }

    private static bool AreAllChannelsEmpty(ReadOnlySpan<ReadOnlyMemory<byte>> channels)
    {
        foreach (var channel in channels)
            if (!OctreeCodec.IsEmpty(channel.Span, OctreeCodec.GetStorageKindUnchecked(channel.Span))) return false;
        return true;
    }

    private static ReadOnlyMemory<byte>[] ValidateAndCopy(int levels, ReadOnlySpan<ReadOnlyMemory<byte>> channels)
    {
        OctreeCodec.ValidateLevels(levels);
        if (channels.IsEmpty) throw new ArgumentException("At least one channel is required.", nameof(channels));
        foreach (var channel in channels)
            if (!OctreeSpan.TryCreate(channel.Span, out var view) || view.Levels != levels || !view.IsWellFormed())
                throw new FormatException("Every channel must be a well-formed encoding with the specified depth.");
        return channels.ToArray();
    }

    /// <summary>The chunk depth, in 0..Octree.MaxLevels.</summary>
    public int Levels { get; }
    /// <summary>The chunk side length.</summary>
    public int SideLength => 1 << Levels;
    /// <summary>The number of independent channels.</summary>
    public int ChannelCount => _channels.Length;
    /// <summary>Whether every voxel in every voxel channel is zero.</summary>
    public bool IsEmpty { get; }
    /// <summary>The number of chunk-level side channels.</summary>
    public int SideChannelCount => _sideChannels.Count;
    /// <summary>Creates an exclusively owned, mutable Morton-order copy for intensive editing.</summary>
    public HotOctreeChunk MarkHot() => HotOctreeChunk.FromChunk(this);
    /// <summary>Creates an owned snapshot from channel-major dense data in either order.</summary>
    public static OctreeChunk FromDense(int levels, int channelCount, ReadOnlySpan<uint> values, DenseVoxelLayout layout = DenseVoxelLayout.Linear)
    {
        OctreeCodec.ValidateLevels(levels); DenseVoxel.Validate(layout);
        if (channelCount <= 0) throw new ArgumentOutOfRangeException(nameof(channelCount));
        var count = OctreeCodec.GetVoxelCount(levels);
        if (values.Length != checked(count * channelCount)) throw new ArgumentException("Incorrect dense channel count.", nameof(values));
        var channels = new ReadOnlyMemory<byte>[channelCount];
        for (var i = 0; i < channelCount; i++) channels[i] = OctreeCodec.BuildOwned(values.Slice(i * count, count), levels, layout);
        return new OctreeChunk(levels, channels);
    }
    /// <summary>Creates an all-zero chunk without allocating or traversing a dense volume.</summary>
    public static OctreeChunk Empty(int levels, int channelCount)
    {
        OctreeCodec.ValidateLevels(levels);
        if (channelCount <= 0) throw new ArgumentOutOfRangeException(nameof(channelCount));
        ReadOnlyMemory<byte> zero = new byte[] { 0x4f, (byte)(0x41 | (levels << 2)), 0 };
        var channels = new ReadOnlyMemory<byte>[channelCount];
        channels.AsSpan().Fill(zero);
        return new OctreeChunk(levels, channels);
    }
    /// <summary>Gets a zero-copy view of a channel.</summary>
    public OctreeSpan GetChannel(int channel)
    {
        var data = GetChannelData(channel).Span;
        return OctreeSpan.CreateTrusted(data, Levels, OctreeCodec.GetStorageKindUnchecked(data));
    }
    /// <summary>Gets a channel's encoded bytes for persistence or caching.</summary>
    public ReadOnlyMemory<byte> GetChannelData(int channel)
    {
        if ((uint)channel >= (uint)ChannelCount) throw new ArgumentOutOfRangeException(nameof(channel));
        return _channels[channel];
    }

    /// <summary>Gets a side-channel identifier by ascending index.</summary>
    public int GetSideChannelId(int index)
    {
        if ((uint)index >= (uint)SideChannelCount) throw new ArgumentOutOfRangeException(nameof(index));
        return _sideChannels.GetId(index);
    }

    /// <summary>Creates an owned zero-initialized byte side channel.</summary>
    public Span<byte> CreateSideChannel(int channelId, int byteLength) =>
        _sideChannels.Create(channelId, byteLength);

    /// <summary>Creates an owned side channel by copying a caller array.</summary>
    public Span<byte> CreateSideChannel(int channelId, byte[] source)
    {
        if (source is null) throw new ArgumentNullException(nameof(source));
        return _sideChannels.Create(channelId, source);
    }

    /// <summary>Creates or replaces a byte side channel by copying a caller array.</summary>
    public Span<byte> SetSideChannel(int channelId, byte[] source)
    {
        if (source is null) throw new ArgumentNullException(nameof(source));
        return _sideChannels.Set(channelId, source);
    }

    /// <summary>Gets direct mutable access to an owned byte side channel.</summary>
    public Span<byte> GetSideChannel(int channelId) => _sideChannels.Get(channelId);

    /// <summary>Gets direct mutable typed access to an owned side channel.</summary>
    public Span<T> GetSideChannel<T>(int channelId) where T : unmanaged =>
        MemoryMarshal.Cast<byte, T>(_sideChannels.Get(channelId));

    /// <summary>Deletes a side channel. Returns false when the identifier does not exist.</summary>
    public bool DeleteSideChannel(int channelId) => _sideChannels.Delete(channelId);

    internal void CopySideChannelsTo(OctreeChunk destination)
    {
        for (var index = 0; index < SideChannelCount; index++)
            destination._sideChannels.Create(_sideChannels.GetId(index), _sideChannels.GetDataAt(index));
    }
    /// <summary>Rebuilds only one changed dense channel and returns a new snapshot sharing the other encodings.</summary>
    public OctreeChunk WithDenseChannel(int channel, ReadOnlySpan<uint> values, DenseVoxelLayout layout = DenseVoxelLayout.Linear)
    {
        _ = GetChannelData(channel);
        var encoded = OctreeCodec.BuildOwned(values, Levels, layout);
        var channels = (ReadOnlyMemory<byte>[])_channels.Clone();
        channels[channel] = encoded;
        return new OctreeChunk(Levels, channels, sideChannels: _sideChannels.Clone());
    }
    /// <summary>Extracts all channels into consecutive dense block slices in the selected order.</summary>
    public void CopyBlockTo(int x, int y, int z, int levels, Span<uint> destination, DenseVoxelLayout layout = DenseVoxelLayout.Linear)
    {
        OctreeCodec.ValidateLevels(levels); DenseVoxel.Validate(layout);
        var side = 1 << levels;
        OctreeQueries.Validate(GetChannel(0), new VoxelBox(x, y, z, checked(x + side), checked(y + side), checked(z + side)));
        var count = OctreeCodec.GetVoxelCount(levels);
        var total = checked(count * ChannelCount);
        if (destination.Length < total) throw new ArgumentException("Destination is too short.", nameof(destination));
        destination = destination[..total];
        foreach (var channel in _channels)
            if (MemoryMarshal.AsBytes(destination).Overlaps(channel.Span)) throw new ArgumentException("Destination overlaps a channel encoding.");
        for (var i = 0; i < ChannelCount; i++) GetChannel(i).CopyBlockTo(x, y, z, levels, destination.Slice(i * count, count), layout);
    }
    /// <summary>Gets the byte count for the versioned chunk packet, including side channels.</summary>
    public int SerializedLength => SideChannelCount == 0
        ? _voxelSerializedLength
        : checked(ExtendedHeaderSize + ChannelCount * 2 * sizeof(int) +
                  SideChannelCount * 3 * sizeof(int) +
                  _voxelSerializedLength - HeaderSize - ChannelCount * sizeof(int) +
                  _sideChannels.PayloadLength);
    internal int SideChannelSerializedLength => SerializedLength - _voxelSerializedLength;

    /// <summary>Gets the maximum packet capacity for a voxel-only chunk schema.</summary>
    public static int GetMaximumSerializedLength(int levels, int channelCount)
    {
        OctreeCodec.ValidateLevels(levels);
        if (channelCount <= 0) throw new ArgumentOutOfRangeException(nameof(channelCount));
        return checked(HeaderSize + channelCount * (sizeof(int) + Octree.GetMaximumSize(levels)));
    }

    /// <summary>Gets the maximum packet capacity for a schema and a bounded set of side channels.</summary>
    public static int GetMaximumSerializedLength(int levels, int channelCount,
        int sideChannelCount, int sideChannelPayloadLength)
    {
        OctreeCodec.ValidateLevels(levels);
        if (channelCount <= 0) throw new ArgumentOutOfRangeException(nameof(channelCount));
        if (sideChannelCount < 0) throw new ArgumentOutOfRangeException(nameof(sideChannelCount));
        if (sideChannelPayloadLength < 0) throw new ArgumentOutOfRangeException(nameof(sideChannelPayloadLength));
        if (sideChannelCount == 0)
        {
            if (sideChannelPayloadLength != 0)
                throw new ArgumentException("A side-channel payload requires at least one side channel.",
                    nameof(sideChannelPayloadLength));
            return GetMaximumSerializedLength(levels, channelCount);
        }
        return checked(ExtendedHeaderSize + channelCount * 2 * sizeof(int) +
                       sideChannelCount * 3 * sizeof(int) +
                       channelCount * Octree.GetMaximumSize(levels) + sideChannelPayloadLength);
    }

    /// <summary>Gets the original contiguous packet when this chunk was loaded from a legacy voxel-only packet.</summary>
    public bool TryGetSerializedData(out ReadOnlyMemory<byte> packet)
    {
        packet = SideChannelCount == 0 ? _serializedPacket : default;
        return !packet.IsEmpty;
    }
    /// <summary>Saves all channels and their shared depth into caller memory. Returns bytes written.</summary>
    public int CopyEncodedTo(Span<byte> destination)
    {
        if (TryCopyEncodedTo(destination, out var bytesWritten)) return bytesWritten;
        throw new ArgumentException("Destination is too short.", nameof(destination));
    }
    /// <summary>Attempts to save this chunk into reusable caller memory.</summary>
    public bool TryCopyEncodedTo(Span<byte> destination, out int bytesWritten)
    {
        bytesWritten = 0;
        var length = SerializedLength;
        if (destination.Length < length) return false;
        destination = destination[..length];
        if (SideChannelCount == 0 && !_serializedPacket.IsEmpty)
        {
            if (destination.Overlaps(_serializedPacket.Span))
                throw new ArgumentException("Destination overlaps the encoded packet.", nameof(destination));
            if (length <= MaximumContiguousCopyLength)
            {
                _serializedPacket.Span.CopyTo(destination);
                bytesWritten = length;
                return true;
            }
        }
        else
        {
            foreach (var channel in _channels)
                if (destination.Overlaps(channel.Span)) throw new ArgumentException("Destination overlaps a channel encoding.");
        }
        if (SideChannelCount != 0)
        {
            destination[0] = 0x4f; destination[1] = 0x43;
            destination[2] = ExtendedFormatVersion; destination[3] = (byte)Levels;
            BinaryPrimitives.WriteInt32LittleEndian(destination[4..], ChannelCount);
            BinaryPrimitives.WriteInt32LittleEndian(destination[8..], length);
            BinaryPrimitives.WriteInt32LittleEndian(destination[12..], SideChannelCount);

            var channelHeaderOffset = ExtendedHeaderSize;
            var sideHeaderOffset = checked(channelHeaderOffset + ChannelCount * 2 * sizeof(int));
            var payloadOffset = checked(sideHeaderOffset + SideChannelCount * 3 * sizeof(int));
            foreach (var channel in _channels)
            {
                BinaryPrimitives.WriteInt32LittleEndian(destination[channelHeaderOffset..], channel.Length);
                BinaryPrimitives.WriteInt32LittleEndian(destination[(channelHeaderOffset + sizeof(int))..], payloadOffset);
                channelHeaderOffset += 2 * sizeof(int);
                channel.Span.CopyTo(destination[payloadOffset..]);
                payloadOffset += channel.Length;
            }
            for (var index = 0; index < SideChannelCount; index++)
            {
                var data = _sideChannels.GetDataAt(index);
                BinaryPrimitives.WriteInt32LittleEndian(destination[sideHeaderOffset..], _sideChannels.GetId(index));
                BinaryPrimitives.WriteInt32LittleEndian(destination[(sideHeaderOffset + sizeof(int))..], data.Length);
                BinaryPrimitives.WriteInt32LittleEndian(destination[(sideHeaderOffset + 2 * sizeof(int))..], payloadOffset);
                sideHeaderOffset += 3 * sizeof(int);
                data.CopyTo(destination[payloadOffset..]);
                payloadOffset += data.Length;
            }
            bytesWritten = length;
            return true;
        }

        destination[0] = 0x4f; destination[1] = 0x43; destination[2] = 1; destination[3] = (byte)Levels;
        BinaryPrimitives.WriteInt32LittleEndian(destination[4..], ChannelCount);
        BinaryPrimitives.WriteInt32LittleEndian(destination[8..], length);
        var offset = HeaderSize;
        foreach (var channel in _channels)
        {
            BinaryPrimitives.WriteInt32LittleEndian(destination[offset..], channel.Length);
            offset += sizeof(int); channel.Span.CopyTo(destination[offset..]); offset += channel.Length;
        }
        bytesWritten = length;
        return true;
    }

    /// <summary>Validates and loads a chunk packet without copying its channel payloads.</summary>
    /// <remarks>The exact packet memory must remain immutable and alive until this chunk and its users are released.</remarks>
    public static OctreeChunk FromEncoded(ReadOnlyMemory<byte> encoded)
    {
        var data = encoded.Span;
        if (data.Length < HeaderSize || data[0] != 0x4f || data[1] != 0x43 ||
            data[3] > Octree.MaxLevels || BinaryPrimitives.ReadInt32LittleEndian(data[8..]) != data.Length)
            throw new FormatException("Invalid chunk packet header.");
        if (data[2] == ExtendedFormatVersion) return FromExtendedEncoded(encoded);
        if (data[2] != 1) throw new FormatException("Invalid chunk packet header.");

        var count = BinaryPrimitives.ReadInt32LittleEndian(data[4..]);
        if (count <= 0 || count > (data.Length - HeaderSize) / 7) throw new FormatException("Invalid channel count.");
        var offset = HeaderSize;
        var isEmpty = true;
        // Validate before allocating descriptors for untrusted input.
        for (var i = 0; i < count; i++)
        {
            if (data.Length - offset < 4) throw new FormatException("Truncated channel header.");
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[offset..]); offset += 4;
            if (length < 3 || length > data.Length - offset ||
                !OctreeSpan.TryCreate(data.Slice(offset, length), out var channel) || channel.Levels != data[3] || !channel.IsWellFormed())
                throw new FormatException("Invalid channel payload.");
            if (isEmpty && !OctreeCodec.IsEmpty(channel.Data, OctreeCodec.GetStorageKindUnchecked(channel.Data)))
                isEmpty = false;
            offset += length;
        }
        if (offset != data.Length) throw new FormatException("Trailing chunk packet data.");
        var channels = new ReadOnlyMemory<byte>[count]; offset = HeaderSize;
        for (var i = 0; i < count; i++)
        {
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[offset..]); offset += 4;
            channels[i] = encoded.Slice(offset, length); offset += length;
        }
        return new OctreeChunk(data[3], channels, encoded, isEmpty);
    }

    private static OctreeChunk FromExtendedEncoded(ReadOnlyMemory<byte> encoded)
    {
        var data = encoded.Span;
        if (data.Length < ExtendedHeaderSize) throw new FormatException("Invalid chunk packet header.");
        var channelCount = BinaryPrimitives.ReadInt32LittleEndian(data[4..]);
        var sideChannelCount = BinaryPrimitives.ReadInt32LittleEndian(data[12..]);
        if (channelCount <= 0 || sideChannelCount < 0) throw new FormatException("Invalid channel count.");

        var directoryLength = (long)ExtendedHeaderSize + (long)channelCount * 2 * sizeof(int) +
                              (long)sideChannelCount * 3 * sizeof(int);
        if (directoryLength > data.Length) throw new FormatException("Truncated chunk directory.");

        var channelHeaderOffset = ExtendedHeaderSize;
        var sideHeaderOffset = checked(channelHeaderOffset + channelCount * 2 * sizeof(int));
        var expectedPayloadOffset = checked((int)directoryLength);
        var isEmpty = true;
        for (var index = 0; index < channelCount; index++)
        {
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[channelHeaderOffset..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(data[(channelHeaderOffset + sizeof(int))..]);
            channelHeaderOffset += 2 * sizeof(int);
            if (length < 3 || position != expectedPayloadOffset || length > data.Length - position ||
                !OctreeSpan.TryCreate(data.Slice(position, length), out var channel) ||
                channel.Levels != data[3] || !channel.IsWellFormed())
                throw new FormatException("Invalid channel payload.");
            if (isEmpty && !OctreeCodec.IsEmpty(channel.Data, OctreeCodec.GetStorageKindUnchecked(channel.Data)))
                isEmpty = false;
            expectedPayloadOffset += length;
        }

        var previousId = -1;
        for (var index = 0; index < sideChannelCount; index++)
        {
            var channelId = BinaryPrimitives.ReadInt32LittleEndian(data[sideHeaderOffset..]);
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[(sideHeaderOffset + sizeof(int))..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(data[(sideHeaderOffset + 2 * sizeof(int))..]);
            sideHeaderOffset += 3 * sizeof(int);
            if (channelId <= previousId || length < 0 || position != expectedPayloadOffset ||
                length > data.Length - position)
                throw new FormatException("Invalid side-channel payload.");
            previousId = channelId;
            expectedPayloadOffset += length;
        }
        if (expectedPayloadOffset != data.Length) throw new FormatException("Trailing chunk packet data.");

        var channels = new ReadOnlyMemory<byte>[channelCount];
        channelHeaderOffset = ExtendedHeaderSize;
        for (var index = 0; index < channelCount; index++)
        {
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[channelHeaderOffset..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(data[(channelHeaderOffset + sizeof(int))..]);
            channelHeaderOffset += 2 * sizeof(int);
            channels[index] = encoded.Slice(position, length);
        }

        var sideChannels = new SideChannelCollection();
        sideHeaderOffset = ExtendedHeaderSize + channelCount * 2 * sizeof(int);
        for (var index = 0; index < sideChannelCount; index++)
        {
            var channelId = BinaryPrimitives.ReadInt32LittleEndian(data[sideHeaderOffset..]);
            var length = BinaryPrimitives.ReadInt32LittleEndian(data[(sideHeaderOffset + sizeof(int))..]);
            var position = BinaryPrimitives.ReadInt32LittleEndian(data[(sideHeaderOffset + 2 * sizeof(int))..]);
            sideHeaderOffset += 3 * sizeof(int);
            sideChannels.Create(channelId, data.Slice(position, length));
        }
        return new OctreeChunk(data[3], channels, isEmpty: isEmpty, sideChannels: sideChannels);
    }
}
