using System;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Threading;

namespace Tedd.Voxtree;

/// <summary>Owns a compact, immutable encoding of a cubic voxel volume of unmanaged <typeparamref name="T"/> values.</summary>
/// <remarks>
/// <typeparamref name="T"/> must occupy exactly 1, 2, 4, 8, or 16 bytes. Its bit representation is
/// preserved; no numeric conversion, boxing, widening, or per-value allocation occurs.
/// </remarks>
public sealed partial class Octree<T> where T : unmanaged
{
    /// <summary>The largest supported depth.</summary>
    public const int MaxLevels = Octree.MaxLevels;
    /// <summary>The generic serialized format version.</summary>
    public const int FormatVersion = 2;

    private readonly int _levels;
    private byte[] _data = Array.Empty<byte>();

    /// <summary>Creates an unbuilt tree with the specified depth.</summary>
    public Octree(int levels)
    {
        VoxelType<T>.Validate();
        OctreeCodec.ValidateLevels(levels);
        _levels = levels;
    }

    /// <summary>Creates and builds an owned tree.</summary>
    public Octree(int levels, ReadOnlySpan<T> values) : this(levels) => Build(values);

    /// <summary>Creates an owned tree filled with one value without allocating a dense source.</summary>
    public Octree(int levels, T value) : this(levels) => BuildUniform(value);

    /// <summary>Replaces this tree with one value throughout the volume, publishing one final encoded array.</summary>
    public void BuildUniform(T value) =>
        Volatile.Write(ref _data, VoxelCodec<T>.BuildUniformOwned(value, _levels));

    /// <summary>Gets the exact encoded size for a volume filled with one value.</summary>
    public static int GetUniformSize(T value, int levels)
    {
        VoxelType<T>.Validate();
        return VoxelCodec<T>.GetUniformSize(value, levels);
    }

    /// <summary>Encodes a volume filled with one value into caller-owned memory without allocation.</summary>
    /// <exception cref="ArgumentException">The destination is too short.</exception>
    /// <exception cref="ArgumentOutOfRangeException">The depth is outside the supported range.</exception>
    public static int BuildUniform(T value, int levels, Span<byte> destination)
    {
        if (TryBuildUniform(value, levels, destination, out var written)) return written;
        throw new ArgumentException("Encoded destination is too short.", nameof(destination));
    }

    /// <summary>Attempts to encode a volume filled with one value without allocation.</summary>
    /// <remarks>Insufficient capacity returns <see langword="false"/>, writes zero bytes, and leaves the destination unchanged.
    /// On success only <c>destination[..bytesWritten]</c> is part of the encoding.</remarks>
    public static bool TryBuildUniform(T value, int levels, Span<byte> destination, out int bytesWritten)
    {
        VoxelType<T>.Validate();
        return VoxelCodec<T>.TryBuildUniform(value, levels, destination, out bytesWritten);
    }

    /// <summary>Gets whether this instance contains a completed build.</summary>
    public bool IsBuilt => Volatile.Read(ref _data).Length != 0;
    /// <summary>Gets the tree depth.</summary>
    public int Levels => _levels;
    /// <summary>Gets the number of cells along one axis.</summary>
    public int SideLength => 1 << _levels;
    /// <summary>Gets the total represented voxel count.</summary>
    public int Count => OctreeCodec.GetVoxelCount(_levels);
    /// <summary>Gets the used encoded byte count, or zero before the first build.</summary>
    public int EncodedLength => Volatile.Read(ref _data).Length;
    /// <summary>Gets the immutable encoded bytes, or empty memory before the first build.</summary>
    public ReadOnlyMemory<byte> Data => Volatile.Read(ref _data);
    /// <summary>Gets the value at the specified coordinates.</summary>
    public T this[int x, int y, int z] => Get(x, y, z);

    /// <summary>Builds this instance from a linear dense volume.</summary>
    public void Build(ReadOnlySpan<T> values) => Build(values, DenseVoxelLayout.Linear);

    /// <summary>Builds one dense channel in the specified order, publishing one final encoded array.</summary>
    public void Build(ReadOnlySpan<T> values, DenseVoxelLayout layout) =>
        Volatile.Write(ref _data, VoxelCodec<T>.BuildOwned(values, _levels, layout));

    /// <summary>Gets the value at the specified coordinates.</summary>
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public T Get(int x, int y, int z)
    {
        var encoded = Volatile.Read(ref _data);
        if (encoded.Length == 0) return GenericOctreeThrowHelper<T>.ThrowUnbuilt();
        if ((uint)x >= (uint)SideLength) return GenericOctreeThrowHelper<T>.ThrowCoordinate(nameof(x), x);
        if ((uint)y >= (uint)SideLength) return GenericOctreeThrowHelper<T>.ThrowCoordinate(nameof(y), y);
        if ((uint)z >= (uint)SideLength) return GenericOctreeThrowHelper<T>.ThrowCoordinate(nameof(z), z);
        if (!VoxelCodec<T>.TryGetUnchecked(encoded, _levels, VoxelCodec<T>.GetStorageKindUnchecked(encoded),
                x, y, z, out var value))
            return GenericOctreeThrowHelper<T>.ThrowMalformed();
        return value;
    }

    /// <summary>Gets the voxel value and the LOD level of its stored leaf in one query.</summary>
    /// <param name="x">Voxel X coordinate.</param>
    /// <param name="y">Voxel Y coordinate.</param>
    /// <param name="z">Voxel Z coordinate.</param>
    /// <param name="lodLevel">Zero for a single voxel; N for an aligned uniform cube with side 2^N.
    /// Uniform storage returns <see cref="Levels"/>; dense storage returns zero.</param>
    /// <exception cref="InvalidOperationException">The tree has not been built.</exception>
    /// <exception cref="ArgumentOutOfRangeException">A coordinate is outside the volume.</exception>
    /// <exception cref="FormatException">The encoded data is malformed.</exception>
    public T Get(int x, int y, int z, out int lodLevel) => AsSpan().Get(x, y, z, out lodLevel);

    /// <summary>Gets the stored leaf LOD level at a coordinate and returns its voxel value.</summary>
    /// <remarks>LOD zero is one voxel, and LOD N is an aligned uniform cube with side 2^N.
    /// Uniform storage returns <see cref="Levels"/>; dense storage returns zero.</remarks>
    public int GetLod(int x, int y, int z, out T value)
    {
        value = Get(x, y, z, out var lodLevel);
        return lodLevel;
    }

    /// <summary>Attempts to get a value and its stored leaf LOD level; failure returns default outputs.</summary>
    /// <remarks>LOD zero is one voxel, and LOD N is an aligned cube with side 2^N.
    /// Uniform storage returns <see cref="Levels"/>; dense storage returns zero.</remarks>
    public bool TryGet(int x, int y, int z, out T value, out int lodLevel)
    {
        var encoded = Volatile.Read(ref _data);
        value = default;
        lodLevel = 0;
        return encoded.Length != 0 &&
               OctreeSpan<T>.CreateTrusted(encoded, _levels, VoxelCodec<T>.GetStorageKindUnchecked(encoded))
                   .TryGet(x, y, z, out value, out lodLevel);
    }

    /// <summary>Attempts to get a value without throwing for an unbuilt tree, bad coordinate, or malformed data.</summary>
    public bool TryGet(int x, int y, int z, out T value)
    {
        var encoded = Volatile.Read(ref _data);
        if (encoded.Length == 0)
        {
            value = default;
            return false;
        }
        return VoxelCodec<T>.TryGet(encoded, _levels, VoxelCodec<T>.GetStorageKindUnchecked(encoded),
            x, y, z, out value);
    }

    /// <summary>Returns whether all coordinates are inside the represented volume.</summary>
    public bool Contains(int x, int y, int z) =>
        (uint)x < (uint)SideLength && (uint)y < (uint)SideLength && (uint)z < (uint)SideLength;

    /// <summary>Expands the encoded volume into the beginning of <paramref name="destination"/>.</summary>
    public void CopyTo(Span<T> destination) => CopyTo(destination, DenseVoxelLayout.Linear);

    /// <summary>Expands the encoded volume directly into the requested dense layout.</summary>
    public void CopyTo(Span<T> destination, DenseVoxelLayout layout) => AsSpan().CopyTo(destination, layout);

    /// <summary>Attempts to expand the encoded volume into caller-provided storage.</summary>
    public bool TryCopyTo(Span<T> destination) => TryCopyTo(destination, DenseVoxelLayout.Linear);

    /// <summary>Attempts to expand the encoded volume directly into the requested dense layout.</summary>
    public bool TryCopyTo(Span<T> destination, DenseVoxelLayout layout)
    {
        DenseVoxel.Validate(layout);
        var encoded = Volatile.Read(ref _data);
        return encoded.Length != 0 &&
               OctreeSpan<T>.CreateTrusted(encoded, _levels, VoxelCodec<T>.GetStorageKindUnchecked(encoded))
                   .TryCopyTo(destination, layout);
    }

    /// <summary>Captures an allocation-free snapshot that remains valid across subsequent builds.</summary>
    public OctreeSpan<T> AsSpan()
    {
        var encoded = Volatile.Read(ref _data);
        if (encoded.Length == 0) throw new InvalidOperationException("The octree has not been built.");
        return OctreeSpan<T>.CreateTrusted(encoded, _levels, VoxelCodec<T>.GetStorageKindUnchecked(encoded));
    }

    /// <summary>Computes the exact destination size for a linear allocation-free build.</summary>
    public static int GetRequiredSize(ReadOnlySpan<T> source, int levels) =>
        GetRequiredSize(source, levels, DenseVoxelLayout.Linear);

    /// <summary>Computes the exact destination size for a linear or Morton allocation-free build.</summary>
    public static int GetRequiredSize(ReadOnlySpan<T> source, int levels, DenseVoxelLayout layout)
    {
        VoxelType<T>.Validate();
        return VoxelCodec<T>.GetRequiredSize(source, levels, layout);
    }

    /// <summary>Gets a value-independent capacity that can hold any encoding at the specified depth.</summary>
    public static int GetMaximumSize(int levels)
    {
        VoxelType<T>.Validate();
        return VoxelCodec<T>.GetMaximumSize(levels);
    }

    /// <summary>Builds a linear source into caller-owned memory and returns the used byte count.</summary>
    public static int Build(ReadOnlySpan<T> source, int levels, Span<byte> destination) =>
        Build(source, levels, destination, DenseVoxelLayout.Linear);

    /// <summary>Builds a linear or Morton source into caller-owned memory and returns the used byte count.</summary>
    public static int Build(ReadOnlySpan<T> source, int levels, Span<byte> destination, DenseVoxelLayout layout)
    {
        if (TryBuild(source, levels, destination, out var written, layout)) return written;
        throw new ArgumentException("Encoded destination is too short.", nameof(destination));
    }

    /// <summary>Attempts a linear caller-buffer build without allocation.</summary>
    public static bool TryBuild(ReadOnlySpan<T> source, int levels, Span<byte> destination, out int bytesWritten) =>
        TryBuild(source, levels, destination, out bytesWritten, DenseVoxelLayout.Linear);

    /// <summary>Attempts a linear or Morton caller-buffer build without allocation.</summary>
    public static bool TryBuild(ReadOnlySpan<T> source, int levels, Span<byte> destination,
        out int bytesWritten, DenseVoxelLayout layout)
    {
        VoxelType<T>.Validate();
        return VoxelCodec<T>.TryBuild(source, levels, destination, out bytesWritten, layout);
    }

    /// <summary>Copies and validates an existing version-2 encoding into an owned instance.</summary>
    public static Octree<T> FromEncoded(ReadOnlySpan<byte> encoded)
    {
        VoxelType<T>.Validate();
        var copy = encoded.ToArray();
        if (!OctreeSpan<T>.TryCreate(copy, out var view) || !view.IsWellFormed())
            throw new FormatException("The octree data is malformed, has another element width, or uses an unsupported format.");
        var result = new Octree<T>(view.Levels);
        Volatile.Write(ref result._data, copy);
        return result;
    }
}

/// <summary>A stack-only, allocation-free view over a serialized generic octree.</summary>
public readonly ref partial struct OctreeSpan<T> where T : unmanaged
{
    private readonly ReadOnlySpan<byte> _data;
    private readonly int _levels;
    private readonly StorageKind _storageKind;

    /// <summary>Creates a view over an exact serialized octree slice.</summary>
    public OctreeSpan(ReadOnlySpan<byte> data)
    {
        VoxelType<T>.Validate();
        if (!VoxelCodec<T>.TryReadHeader(data, out _levels, out _storageKind))
            throw new FormatException("The octree header is malformed, has another element width, or uses an unsupported format.");
        _data = data;
    }

    private OctreeSpan(ReadOnlySpan<byte> data, int levels, StorageKind storageKind)
    {
        _data = data;
        _levels = levels;
        _storageKind = storageKind;
    }

    internal static OctreeSpan<T> CreateTrusted(ReadOnlySpan<byte> data, int levels, StorageKind storageKind) =>
        new(data, levels, storageKind);

    /// <summary>Gets whether this is a non-default view with a supported header.</summary>
    public bool IsValid => !_data.IsEmpty;
    /// <summary>Gets the encoded depth.</summary>
    public int Levels => _levels;
    /// <summary>Gets the number of cells along one axis.</summary>
    public int SideLength => 1 << _levels;
    /// <summary>Gets the total represented voxel count.</summary>
    public int Count => OctreeCodec.GetVoxelCount(_levels);
    /// <summary>Gets the exact encoded byte count.</summary>
    public int EncodedLength => _data.Length;
    /// <summary>Gets the underlying encoded bytes without copying.</summary>
    public ReadOnlySpan<byte> Data => _data;
    /// <summary>Gets the value at the specified coordinates.</summary>
    public T this[int x, int y, int z] => Get(x, y, z);

    /// <summary>Gets the value at the specified coordinates.</summary>
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public T Get(int x, int y, int z)
    {
        if (!IsValid) return GenericOctreeThrowHelper<T>.ThrowInvalidView();
        if ((uint)x >= (uint)SideLength) return GenericOctreeThrowHelper<T>.ThrowCoordinate(nameof(x), x);
        if ((uint)y >= (uint)SideLength) return GenericOctreeThrowHelper<T>.ThrowCoordinate(nameof(y), y);
        if ((uint)z >= (uint)SideLength) return GenericOctreeThrowHelper<T>.ThrowCoordinate(nameof(z), z);
        if (!VoxelCodec<T>.TryGetUnchecked(_data, _levels, _storageKind, x, y, z, out var value))
            return GenericOctreeThrowHelper<T>.ThrowMalformed();
        return value;
    }

    /// <summary>Gets the voxel value and the LOD level of its stored leaf in one query.</summary>
    /// <param name="x">Voxel X coordinate.</param>
    /// <param name="y">Voxel Y coordinate.</param>
    /// <param name="z">Voxel Z coordinate.</param>
    /// <param name="lodLevel">Zero for a single voxel; N for an aligned uniform cube with side 2^N.
    /// Uniform storage returns <see cref="Levels"/>; dense storage returns zero.</param>
    /// <exception cref="InvalidOperationException">This is a default view.</exception>
    /// <exception cref="ArgumentOutOfRangeException">A coordinate is outside the volume.</exception>
    /// <exception cref="FormatException">The encoded structure is malformed.</exception>
    public T Get(int x, int y, int z, out int lodLevel)
    {
        lodLevel = 0;
        if (!IsValid) return GenericOctreeThrowHelper<T>.ThrowInvalidView();
        if ((uint)x >= (uint)SideLength) return GenericOctreeThrowHelper<T>.ThrowCoordinate(nameof(x), x);
        if ((uint)y >= (uint)SideLength) return GenericOctreeThrowHelper<T>.ThrowCoordinate(nameof(y), y);
        if ((uint)z >= (uint)SideLength) return GenericOctreeThrowHelper<T>.ThrowCoordinate(nameof(z), z);
        if (!VoxelCodec<T>.TryGetUnchecked(_data, _levels, _storageKind, x, y, z, out var value, out lodLevel))
            return GenericOctreeThrowHelper<T>.ThrowMalformed();
        return value;
    }

    /// <summary>Gets the stored leaf LOD level at a coordinate and returns its voxel value.</summary>
    /// <remarks>LOD zero is one voxel, and LOD N is an aligned uniform cube with side 2^N.
    /// Uniform storage returns <see cref="Levels"/>; dense storage returns zero.</remarks>
    public int GetLod(int x, int y, int z, out T value)
    {
        value = Get(x, y, z, out var lodLevel);
        return lodLevel;
    }

    /// <summary>Attempts to get a value and its stored leaf LOD level; failure returns default outputs.</summary>
    /// <remarks>LOD zero is one voxel, and LOD N is an aligned cube with side 2^N.
    /// Uniform storage returns <see cref="Levels"/>; dense storage returns zero.</remarks>
    public bool TryGet(int x, int y, int z, out T value, out int lodLevel)
    {
        value = default;
        lodLevel = 0;
        if (!Contains(x, y, z)) return false;
        if (VoxelCodec<T>.TryGetUnchecked(_data, _levels, _storageKind, x, y, z, out value, out lodLevel))
            return true;
        value = default;
        lodLevel = 0;
        return false;
    }

    /// <summary>Attempts to get a value without throwing for a bad coordinate or malformed structure.</summary>
    public bool TryGet(int x, int y, int z, out T value)
    {
        if (!IsValid)
        {
            value = default;
            return false;
        }
        return VoxelCodec<T>.TryGet(_data, _levels, _storageKind, x, y, z, out value);
    }

    /// <summary>Returns whether all coordinates are inside the represented volume.</summary>
    public bool Contains(int x, int y, int z) => IsValid &&
        (uint)x < (uint)SideLength && (uint)y < (uint)SideLength && (uint)z < (uint)SideLength;

    /// <summary>Expands the encoded volume into the beginning of <paramref name="destination"/>.</summary>
    public void CopyTo(Span<T> destination) => CopyTo(destination, DenseVoxelLayout.Linear);

    /// <summary>Validates and expands the complete volume directly into the requested dense layout.</summary>
    public void CopyTo(Span<T> destination, DenseVoxelLayout layout)
    {
        DenseVoxel.Validate(layout);
        if (!IsValid) throw new InvalidOperationException("The octree view is not initialized.");
        if (destination.Length < Count)
            throw new ArgumentException($"Destination must contain at least {Count} elements.", nameof(destination));
        if (MemoryMarshal.AsBytes(destination[..Count]).Overlaps(_data))
            throw new ArgumentException("Destination must not overlap the encoded octree.", nameof(destination));
        if (!VoxelCodec<T>.TryCopyTo(_data, _levels, _storageKind, destination, layout))
            throw new FormatException("The octree data is malformed.");
    }

    /// <summary>Attempts to expand the encoded volume into caller-provided storage.</summary>
    public bool TryCopyTo(Span<T> destination) => TryCopyTo(destination, DenseVoxelLayout.Linear);

    /// <summary>Attempts validated expansion into the requested layout; failure leaves the destination unchanged.</summary>
    public bool TryCopyTo(Span<T> destination, DenseVoxelLayout layout)
    {
        DenseVoxel.Validate(layout);
        return IsValid && VoxelCodec<T>.TryCopyTo(_data, _levels, _storageKind, destination, layout);
    }

    /// <summary>Performs allocation-free structural and primitive-encoding validation.</summary>
    public bool IsWellFormed() => IsValid && VoxelCodec<T>.IsWellFormed(_data, _levels, _storageKind);

    /// <summary>Attempts to create a view from a supported version-2 header.</summary>
    public static bool TryCreate(ReadOnlySpan<byte> data, out OctreeSpan<T> octree)
    {
        VoxelType<T>.Validate();
        if (!VoxelCodec<T>.TryReadHeader(data, out var levels, out var storageKind))
        {
            octree = default;
            return false;
        }
        octree = new OctreeSpan<T>(data, levels, storageKind);
        return true;
    }
}

internal static class GenericOctreeThrowHelper<T> where T : unmanaged
{
    [MethodImpl(MethodImplOptions.NoInlining)]
    internal static T ThrowUnbuilt() => throw new InvalidOperationException("The octree has not been built.");
    [MethodImpl(MethodImplOptions.NoInlining)]
    internal static T ThrowInvalidView() => throw new InvalidOperationException("The octree view is not initialized.");
    [MethodImpl(MethodImplOptions.NoInlining)]
    internal static T ThrowCoordinate(string parameterName, int value) =>
        throw new ArgumentOutOfRangeException(parameterName, value, "The coordinate lies outside the octree volume.");
    [MethodImpl(MethodImplOptions.NoInlining)]
    internal static T ThrowMalformed() => throw new FormatException("The octree data is malformed.");
}
