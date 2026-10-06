using System;
using System.Runtime.CompilerServices;
using System.Threading;

namespace Tedd.Voxtree;

/// <summary>
/// Owns the compact, immutable encoding of a cubic <see cref="uint"/> voxel volume.
/// </summary>
/// <remarks>
/// Use <see cref="OctreeSpan"/> and the caller-buffer build APIs when the operation
/// must not allocate. An owned build allocates exactly one byte array for the result.
/// Builds atomically publish immutable data, so concurrent reads and builds are safe
/// when build sources remain stable. The last build to publish wins. Capture AsSpan()
/// once to read the same snapshot across multiple queries.
/// </remarks>
public sealed partial class Octree
{
    /// <summary>The largest supported depth.</summary>
    public const int MaxLevels = 9;

    /// <summary>The current serialized format version.</summary>
    public const int FormatVersion = 1;

    private readonly int _levels;
    private byte[] _data = Array.Empty<byte>();

    /// <summary>Creates an unbuilt tree with the specified depth.</summary>
    /// <param name="levels">Depth in the inclusive range 0 through <see cref="MaxLevels"/>.</param>
    public Octree(int levels)
    {
        OctreeCodec.ValidateLevels(levels);
        _levels = levels;
    }

    /// <summary>Creates and builds an owned tree.</summary>
    /// <param name="levels">Depth in the inclusive range 0 through <see cref="MaxLevels"/>.</param>
    /// <param name="values">Exactly <c>(2^levels)^3</c> values in X/Y/Z-major order.</param>
    public Octree(int levels, ReadOnlySpan<uint> values)
        : this(levels)
    {
        Build(values);
    }


    /// <summary>Compiles an immutable point-lookup snapshot with direct 32-bit child indexes.</summary>
    /// <remarks>
    /// Compilation validates and expands tree metadata once. It trades additional memory for
    /// faster repeated reads; dense and uniform representations need no index. The result keeps
    /// the captured state even if this octree is rebuilt.
    /// </remarks>
    public OctreeLookup CreateLookup()
    {
        var encoded = Volatile.Read(ref _data);
        if (encoded.Length == 0) throw new InvalidOperationException("The octree has not been built.");
        return new OctreeLookup(encoded, encoded);
    }

    /// <summary>Creates an owned tree filled with one value without allocating a dense source.</summary>
    public Octree(int levels, uint value) : this(levels) => BuildUniform(value);

    /// <summary>Replaces this tree with one value throughout the volume, publishing one final encoded array.</summary>
    public void BuildUniform(uint value) =>
        Volatile.Write(ref _data, OctreeCodec.BuildUniformOwned(value, _levels));

    /// <summary>Gets the exact encoded size for a volume filled with one value.</summary>
    public static int GetUniformSize(uint value, int levels)
    {
        return OctreeCodec.GetUniformSize(value, levels);
    }

    /// <summary>Encodes a volume filled with one value into caller-owned memory without allocation.</summary>
    /// <exception cref="ArgumentException">The destination is too short.</exception>
    /// <exception cref="ArgumentOutOfRangeException">The depth is outside the supported range.</exception>
    public static int BuildUniform(uint value, int levels, Span<byte> destination)
    {
        if (TryBuildUniform(value, levels, destination, out var written)) return written;
        throw new ArgumentException("Encoded destination is too short.", nameof(destination));
    }

    /// <summary>Attempts to encode a volume filled with one value without allocation.</summary>
    /// <remarks>Insufficient capacity returns <see langword="false"/>, writes zero bytes, and leaves the destination unchanged.
    /// On success only <c>destination[..bytesWritten]</c> is part of the encoding.</remarks>
    public static bool TryBuildUniform(uint value, int levels, Span<byte> destination, out int bytesWritten)
    {
        return OctreeCodec.TryBuildUniform(value, levels, destination, out bytesWritten);
    }

    /// <summary>Gets whether this instance contains a completed build.</summary>
    public bool IsBuilt => Volatile.Read(ref _data).Length != 0;

    /// <summary>Gets the tree depth.</summary>
    public int Levels => _levels;

    /// <summary>Gets the number of cells along one axis.</summary>
    public int SideLength => 1 << _levels;

    /// <summary>Gets the total number of voxels represented by the tree.</summary>
    public int Count => OctreeCodec.GetVoxelCount(_levels);

    /// <summary>Gets the used encoded byte count, or zero before the first build.</summary>
    public int EncodedLength => Volatile.Read(ref _data).Length;

    /// <summary>Gets the immutable encoded bytes, or an empty memory before the first build.</summary>
    public ReadOnlyMemory<byte> Data => Volatile.Read(ref _data);

    /// <summary>Gets the value at the specified coordinates.</summary>
    public uint this[int x, int y, int z] => Get(x, y, z);

    /// <summary>
    /// Builds this instance from a dense volume, replacing the preceding build only after
    /// the new encoding has completed successfully.
    /// </summary>
    /// <remarks>This convenience API allocates one byte array of the exact encoded size.</remarks>
    public void Build(ReadOnlySpan<uint> values)
    {
        var encoded = OctreeCodec.BuildOwned(values, _levels);
        Volatile.Write(ref _data, encoded);
    }

    /// <summary>Gets the value at the specified coordinates.</summary>
    /// <exception cref="InvalidOperationException">The tree has not been built.</exception>
    /// <exception cref="ArgumentOutOfRangeException">A coordinate is outside the volume.</exception>
    /// <exception cref="FormatException">The encoded data is malformed.</exception>
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public uint Get(int x, int y, int z)
    {
        var encoded = Volatile.Read(ref _data);
        if (encoded.Length == 0)
            return OctreeThrowHelper.ThrowUnbuilt();
        if ((uint)x >= (uint)SideLength)
            return OctreeThrowHelper.ThrowCoordinate(nameof(x), x);
        if ((uint)y >= (uint)SideLength)
            return OctreeThrowHelper.ThrowCoordinate(nameof(y), y);
        if ((uint)z >= (uint)SideLength)
            return OctreeThrowHelper.ThrowCoordinate(nameof(z), z);

        if (!OctreeCodec.TryGetUnchecked(
                encoded,
                _levels,
                OctreeCodec.GetStorageKindUnchecked(encoded),
                x,
                y,
                z,
                out var value))
        {
            return OctreeThrowHelper.ThrowMalformed();
        }

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
    public uint Get(int x, int y, int z, out int lodLevel) => AsSpan().Get(x, y, z, out lodLevel);

    /// <summary>Gets the stored leaf LOD level at a coordinate and returns its voxel value.</summary>
    /// <remarks>LOD zero is one voxel, and LOD N is an aligned uniform cube with side 2^N.
    /// Uniform storage returns <see cref="Levels"/>; dense storage returns zero.</remarks>
    public int GetLod(int x, int y, int z, out uint value)
    {
        value = Get(x, y, z, out var lodLevel);
        return lodLevel;
    }

    /// <summary>Attempts to get a value and its stored leaf LOD level; failure returns zero in both outputs.</summary>
    /// <remarks>LOD zero is one voxel, and LOD N is an aligned cube with side 2^N.
    /// Uniform storage returns <see cref="Levels"/>; dense storage returns zero.</remarks>
    public bool TryGet(int x, int y, int z, out uint value, out int lodLevel)
    {
        var encoded = Volatile.Read(ref _data);
        value = default;
        lodLevel = 0;
        return encoded.Length != 0 &&
               OctreeSpan.CreateTrusted(encoded, _levels, OctreeCodec.GetStorageKindUnchecked(encoded))
                   .TryGet(x, y, z, out value, out lodLevel);
    }

    /// <summary>Attempts to get a value without throwing for an unbuilt tree, bad coordinate, or malformed data.</summary>
    public bool TryGet(int x, int y, int z, out uint value)
    {
        var encoded = Volatile.Read(ref _data);
        if (encoded.Length == 0)
        {
            value = default;
            return false;
        }

        return OctreeCodec.TryGet(
            encoded,
            _levels,
            OctreeCodec.GetStorageKindUnchecked(encoded),
            x,
            y,
            z,
            out value);
    }

    /// <summary>Returns whether all coordinates are inside the represented volume.</summary>
    public bool Contains(int x, int y, int z) =>
        (uint)x < (uint)SideLength &&
        (uint)y < (uint)SideLength &&
        (uint)z < (uint)SideLength;

    /// <summary>Expands the encoded volume into the beginning of <paramref name="destination"/>.</summary>
    /// <exception cref="InvalidOperationException">The tree has not been built.</exception>
    /// <exception cref="ArgumentException">The destination is too short or overlaps the encoded data.</exception>
    /// <exception cref="FormatException">The encoded structure is malformed.</exception>
    public void CopyTo(Span<uint> destination) => CopyTo(destination, DenseVoxelLayout.Linear);

    /// <summary>Expands the encoded volume directly into the requested dense layout.</summary>
    public void CopyTo(Span<uint> destination, DenseVoxelLayout layout)
    {
        AsSpan().CopyTo(destination, layout);
    }

    /// <summary>Attempts to expand the encoded volume into a caller-provided span.</summary>
    public bool TryCopyTo(Span<uint> destination) => TryCopyTo(destination, DenseVoxelLayout.Linear);

    /// <summary>Attempts to expand the encoded volume directly into the requested dense layout.</summary>
    public bool TryCopyTo(Span<uint> destination, DenseVoxelLayout layout)
    {
        DenseVoxel.Validate(layout);
        var encoded = Volatile.Read(ref _data);
        return encoded.Length != 0 &&
               OctreeSpan.CreateTrusted(encoded, _levels, OctreeCodec.GetStorageKindUnchecked(encoded))
                   .TryCopyTo(destination, layout);
    }

    /// <summary>Captures an allocation-free, stack-only snapshot that remains valid across subsequent builds.</summary>
    /// <exception cref="InvalidOperationException">The tree has not been built.</exception>
    public OctreeSpan AsSpan()
    {
        var encoded = Volatile.Read(ref _data);
        if (encoded.Length == 0)
            throw new InvalidOperationException("The octree has not been built.");
        return OctreeSpan.CreateTrusted(encoded, _levels, OctreeCodec.GetStorageKindUnchecked(encoded));
    }

    /// <summary>Computes the exact destination size for an allocation-free build.</summary>
    public static int GetRequiredSize(ReadOnlySpan<uint> source, int levels) =>
        OctreeCodec.GetRequiredSize(source, levels);

    /// <summary>
    /// Gets a value-independent capacity that can hold any encoding at the specified depth.
    /// </summary>
    /// <remarks>
    /// This avoids a sizing pass when one destination is reused for multiple builds.
    /// The exact encoding remains <c>destination[..bytesWritten]</c>.
    /// </remarks>
    public static int GetMaximumSize(int levels) => OctreeCodec.GetMaximumSize(levels);

    /// <summary>Builds into caller-owned memory and returns the used byte count.</summary>
    /// <exception cref="ArgumentException">The source length is invalid, the destination is too short, or the spans overlap.</exception>
    /// <exception cref="ArgumentOutOfRangeException"><paramref name="levels"/> is outside the supported range.</exception>
    public static int Build(ReadOnlySpan<uint> source, int levels, Span<byte> destination)
    {
        if (TryBuild(source, levels, destination, out var bytesWritten))
            return bytesWritten;

        var required = GetRequiredSize(source, levels);
        throw new ArgumentException(
            $"Destination must contain at least {required} bytes; it contains {destination.Length}.",
            nameof(destination));
    }

    /// <summary>
    /// Attempts to build into caller-owned memory without allocating.
    /// </summary>
    /// <remarks>
    /// On success, only <c>destination[..bytesWritten]</c> is part of the encoding.
    /// On insufficient capacity this method returns <see langword="false"/> and sets
    /// <paramref name="bytesWritten"/> to zero; destination contents are then unspecified.
    /// </remarks>
    /// <exception cref="ArgumentException">The source length is invalid or the spans overlap.</exception>
    /// <exception cref="ArgumentOutOfRangeException"><paramref name="levels"/> is outside the supported range.</exception>
    public static bool TryBuild(
        ReadOnlySpan<uint> source,
        int levels,
        Span<byte> destination,
        out int bytesWritten) =>
        OctreeCodec.TryBuild(source, levels, destination, out bytesWritten);

    /// <summary>Copies and validates an existing serialized octree into an owned instance.</summary>
    /// <exception cref="FormatException">The encoded data is malformed or unsupported.</exception>
    public static Octree FromEncoded(ReadOnlySpan<byte> encoded)
    {
        var copy = encoded.ToArray();
        if (!OctreeSpan.TryCreate(copy, out var view) || !view.IsWellFormed())
            throw new FormatException("The octree data is malformed or uses an unsupported format.");

        var result = new Octree(view.Levels);
        Volatile.Write(ref result._data, copy);
        return result;
    }
}
