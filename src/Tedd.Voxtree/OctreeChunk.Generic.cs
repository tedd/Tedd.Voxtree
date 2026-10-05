using System;
using System.Buffers.Binary;
using System.Runtime.InteropServices;

namespace Tedd.Voxtree;

/// <summary>A generic chunk with immutable voxel channels and mutable chunk-level side channels.</summary>
/// <remarks>
/// Side channels are owned byte arrays independent of the voxel value type. Typed side-channel spans
/// directly alias those arrays. This type is not thread-safe while side channels are accessed or changed.
/// </remarks>
public sealed class OctreeChunk<T> where T : unmanaged
{
    private const int HeaderSize = 12;
    private const int ExtendedHeaderSize = 16;
    private const int ExtendedFormatVersion = 4;
    private const int MaximumContiguousCopyLength = 64 * 1024;
    private readonly ReadOnlyMemory<byte>[] _channels;
    private readonly int _voxelSerializedLength;
    private readonly ReadOnlyMemory<byte> _serializedPacket;
    private readonly SideChannelCollection _sideChannels;

    /// <summary>Validates and retains channel encodings, copying only their memory descriptors.</summary>
    public OctreeChunk(int levels, ReadOnlySpan<ReadOnlyMemory<byte>> channels)
        : this(levels, ValidateAndCopy(levels, channels)) { }

    private OctreeChunk(int levels, ReadOnlyMemory<byte>[] channels,
        ReadOnlyMemory<byte> serializedPacket = default, bool? isEmpty = null,
        SideChannelCollection? sideChannels = null)
    {
        VoxelType<T>.Validate();
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
            if (!VoxelCodec<T>.IsEmpty(channel.Span, VoxelCodec<T>.GetStorageKindUnchecked(channel.Span))) return false;
        return true;
    }

    private static ReadOnlyMemory<byte>[] ValidateAndCopy(int levels,
        ReadOnlySpan<ReadOnlyMemory<byte>> channels)
    {
        VoxelType<T>.Validate();
        OctreeCodec.ValidateLevels(levels);
        if (channels.IsEmpty) throw new ArgumentException("At least one channel is required.", nameof(channels));
        foreach (var channel in channels)
            if (!OctreeSpan<T>.TryCreate(channel.Span, out var view) || view.Levels != levels || !view.IsWellFormed())
                throw new FormatException("Every channel must be a well-formed encoding with the specified value width and depth.");
        return channels.ToArray();
    }

    /// <summary>The chunk depth.</summary>
    public int Levels { get; }
    /// <summary>The chunk side length.</summary>
    public int SideLength => 1 << Levels;
    /// <summary>The number of independent channels.</summary>
    public int ChannelCount => _channels.Length;
    /// <summary>Whether every voxel-channel value has an all-zero bit representation.</summary>
    public bool IsEmpty { get; }
    /// <summary>The number of chunk-level side channels.</summary>
    public int SideChannelCount => _sideChannels.Count;

    /// <summary>Creates an exclusively owned, mutable Morton-order copy for intensive editing.</summary>
    public HotOctreeChunk<T> MarkHot() => HotOctreeChunk<T>.FromChunk(this);

    /// <summary>Creates an owned snapshot from channel-major dense data.</summary>
    public static OctreeChunk<T> FromDense(int levels, int channelCount, ReadOnlySpan<T> values,
        DenseVoxelLayout layout = DenseVoxelLayout.Linear)
    {
        VoxelType<T>.Validate();
        OctreeCodec.ValidateLevels(levels);
        DenseVoxel.Validate(layout);
        if (channelCount <= 0) throw new ArgumentOutOfRangeException(nameof(channelCount));
        var count = OctreeCodec.GetVoxelCount(levels);
        if (values.Length != checked(count * channelCount))
            throw new ArgumentException("Incorrect dense channel count.", nameof(values));
        var channels = new ReadOnlyMemory<byte>[channelCount];
        for (var index = 0; index < channelCount; index++)
            channels[index] = VoxelCodec<T>.BuildOwned(values.Slice(index * count, count), levels, layout);
        return new OctreeChunk<T>(levels, channels);
    }

    /// <summary>Creates an owned chunk from one uniform value per channel without a dense source.</summary>
    public static OctreeChunk<T> FromUniform(int levels, ReadOnlySpan<T> values)
    {
        VoxelType<T>.Validate();
        OctreeCodec.ValidateLevels(levels);
        if (values.IsEmpty) throw new ArgumentException("At least one channel value is required.", nameof(values));
        var channels = new ReadOnlyMemory<byte>[values.Length];
        for (var i = 0; i < values.Length; i++)
            channels[i] = VoxelCodec<T>.BuildUniformOwned(values[i], levels);
        return new OctreeChunk<T>(levels, channels);
    }

    /// <summary>Creates an all-zero chunk without traversing a dense volume.</summary>
    public static OctreeChunk<T> Empty(int levels, int channelCount)
    {
        VoxelType<T>.Validate();
        OctreeCodec.ValidateLevels(levels);
        if (channelCount <= 0) throw new ArgumentOutOfRangeException(nameof(channelCount));
        // Construct the canonical version-2 uniform-zero encoding directly.
        // A level-zero byte channel may otherwise select dense storage because
        // its dense and uniform encodings have equal length at that level.
        var bytes = new byte[GenericOctreeCodec<byte>.HeaderSize + 1];
        bytes[0] = OctreeCodec.Magic;
        bytes[1] = (byte)((Octree<T>.FormatVersion << 6)
            | (levels << 2) | (byte)StorageKind.Uniform);
        bytes[2] = VoxelType<T>.SizeCode;
        ReadOnlyMemory<byte> zero = bytes;
        var channels = new ReadOnlyMemory<byte>[channelCount];
        channels.AsSpan().Fill(zero);
        return new OctreeChunk<T>(levels, channels);
    }

    /// <summary>Gets a zero-copy view of a channel.</summary>
    public OctreeSpan<T> GetChannel(int channel)
    {
        var data = GetChannelData(channel).Span;
        return OctreeSpan<T>.CreateTrusted(data, Levels, VoxelCodec<T>.GetStorageKindUnchecked(data));
    }

    /// <summary>Gets one channel's encoded bytes.</summary>
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
    public Span<TSide> GetSideChannel<TSide>(int channelId) where TSide : unmanaged =>
        MemoryMarshal.Cast<byte, TSide>(_sideChannels.Get(channelId));

    /// <summary>Deletes a side channel. Returns false when the identifier does not exist.</summary>
    public bool DeleteSideChannel(int channelId) => _sideChannels.Delete(channelId);

    internal void CopySideChannelsTo(OctreeChunk<T> destination)
    {
        for (var index = 0; index < SideChannelCount; index++)
            destination._sideChannels.Create(_sideChannels.GetId(index), _sideChannels.GetDataAt(index));
    }
    internal OctreeChunk<T> WithPatchedChannels(byte[]?[] patches)
    {
        var channels = (ReadOnlyMemory<byte>[])_channels.Clone();
        for (var channel = 0; channel < channels.Length; channel++)
            if (patches[channel] is { } data) channels[channel] = data;
        return new OctreeChunk<T>(Levels, channels, sideChannels: _sideChannels.Clone());
    }

    /// <summary>Rebuilds one dense channel and returns a snapshot sharing the other encodings.</summary>
    public OctreeChunk<T> WithDenseChannel(int channel, ReadOnlySpan<T> values,
        DenseVoxelLayout layout = DenseVoxelLayout.Linear)
    {
        _ = GetChannelData(channel);
        var encoded = VoxelCodec<T>.BuildOwned(values, Levels, layout);
        var channels = (ReadOnlyMemory<byte>[])_channels.Clone();
        channels[channel] = encoded;
        return new OctreeChunk<T>(Levels, channels, sideChannels: _sideChannels.Clone());
    }

    /// <summary>Extracts every channel into consecutive dense block slices.</summary>
    public void CopyBlockTo(int x, int y, int z, int levels, Span<T> destination,
        DenseVoxelLayout layout = DenseVoxelLayout.Linear)
    {
        OctreeCodec.ValidateLevels(levels);
        DenseVoxel.Validate(layout);
        var side = 1 << levels;
        GenericOctreeQueries<T>.Validate(GetChannel(0),
            new VoxelBox(x, y, z, checked(x + side), checked(y + side), checked(z + side)));
        var count = OctreeCodec.GetVoxelCount(levels);
        var total = checked(count * ChannelCount);
        if (destination.Length < total) throw new ArgumentException("Destination is too short.", nameof(destination));
        destination = destination[..total];
        foreach (var channel in _channels)
            if (MemoryMarshal.AsBytes(destination).Overlaps(channel.Span))
                throw new ArgumentException("Destination overlaps a channel encoding.");
        for (var index = 0; index < ChannelCount; index++)
            GetChannel(index).CopyBlockTo(x, y, z, levels, destination.Slice(index * count, count), layout);
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
        VoxelType<T>.Validate();
        OctreeCodec.ValidateLevels(levels);
        if (channelCount <= 0) throw new ArgumentOutOfRangeException(nameof(channelCount));
        return checked(HeaderSize + channelCount * (sizeof(int) + Octree<T>.GetMaximumSize(levels)));
    }

    /// <summary>Gets the maximum packet capacity for a schema and a bounded set of side channels.</summary>
    public static int GetMaximumSerializedLength(int levels, int channelCount,
        int sideChannelCount, int sideChannelPayloadLength)
    {
        VoxelType<T>.Validate();
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
                       channelCount * Octree<T>.GetMaximumSize(levels) + sideChannelPayloadLength);
    }

    /// <summary>Gets the original contiguous packet when this chunk was loaded from a legacy voxel-only packet.</summary>
    public bool TryGetSerializedData(out ReadOnlyMemory<byte> packet)
    {
        packet = SideChannelCount == 0 ? _serializedPacket : default;
        return !packet.IsEmpty;
    }

    /// <summary>Saves every channel and its shared depth into caller memory.</summary>
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
            destination[0] = 0x4f;
            destination[1] = 0x43;
            destination[2] = ExtendedFormatVersion;
            destination[3] = (byte)Levels;
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

        destination[0] = 0x4f;
        destination[1] = 0x43;
        destination[2] = 2;
        destination[3] = (byte)Levels;
        BinaryPrimitives.WriteInt32LittleEndian(destination[4..], ChannelCount);
        BinaryPrimitives.WriteInt32LittleEndian(destination[8..], length);
        var offset = HeaderSize;
        foreach (var channel in _channels)
        {
            BinaryPrimitives.WriteInt32LittleEndian(destination[offset..], channel.Length);
            offset += sizeof(int);
            channel.Span.CopyTo(destination[offset..]);
            offset += channel.Length;
        }
        bytesWritten = length;
        return true;
    }

    /// <summary>Validates and loads a generic chunk packet without copying its channel payloads.</summary>
    public static OctreeChunk<T> FromEncoded(ReadOnlyMemory<byte> encoded)
    {
        VoxelType<T>.Validate();
        var data = encoded.Span;
        if (data.Length < HeaderSize || data[0] != 0x4f || data[1] != 0x43 ||
            data[3] > Octree.MaxLevels || BinaryPrimitives.ReadInt32LittleEndian(data[8..]) != data.Length)
            throw new FormatException("Invalid generic chunk packet header.");
        if (data[2] == ExtendedFormatVersion) return FromExtendedEncoded(encoded);
        if (data[2] != 2) throw new FormatException("Invalid generic chunk packet header.");

        var count = BinaryPrimitives.ReadInt32LittleEndian(data[4..]);
        if (count <= 0 || count > (data.Length - HeaderSize) / 8)
            throw new FormatException("Invalid channel count.");
        var offset = HeaderSize;
        var isEmpty = true;
        for (var index = 0; index < count; index++)
        {
            if (data.Length - offset < sizeof(int)) throw new FormatException("Truncated channel header.");
            var channelLength = BinaryPrimitives.ReadInt32LittleEndian(data[offset..]);
            offset += sizeof(int);
            if (channelLength < 4 || channelLength > data.Length - offset ||
                !OctreeSpan<T>.TryCreate(data.Slice(offset, channelLength), out var channel) ||
                channel.Levels != data[3] || !channel.IsWellFormed())
                throw new FormatException("Invalid generic channel payload.");
            if (isEmpty && !VoxelCodec<T>.IsEmpty(channel.Data, VoxelCodec<T>.GetStorageKindUnchecked(channel.Data)))
                isEmpty = false;
            offset += channelLength;
        }
        if (offset != data.Length) throw new FormatException("Trailing chunk packet data.");
        var channels = new ReadOnlyMemory<byte>[count];
        offset = HeaderSize;
        for (var index = 0; index < count; index++)
        {
            var channelLength = BinaryPrimitives.ReadInt32LittleEndian(data[offset..]);
            offset += sizeof(int);
            channels[index] = encoded.Slice(offset, channelLength);
            offset += channelLength;
        }
        return new OctreeChunk<T>(data[3], channels, encoded, isEmpty);
    }

    private static OctreeChunk<T> FromExtendedEncoded(ReadOnlyMemory<byte> encoded)
    {
        var data = encoded.Span;
        if (data.Length < ExtendedHeaderSize) throw new FormatException("Invalid generic chunk packet header.");
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
            if (length < 4 || position != expectedPayloadOffset || length > data.Length - position ||
                !OctreeSpan<T>.TryCreate(data.Slice(position, length), out var channel) ||
                channel.Levels != data[3] || !channel.IsWellFormed())
                throw new FormatException("Invalid generic channel payload.");
            if (isEmpty && !VoxelCodec<T>.IsEmpty(channel.Data, VoxelCodec<T>.GetStorageKindUnchecked(channel.Data)))
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
        return new OctreeChunk<T>(data[3], channels, isEmpty: isEmpty, sideChannels: sideChannels);
    }
}
