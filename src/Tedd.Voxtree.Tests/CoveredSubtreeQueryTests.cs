using System.Runtime.InteropServices;

namespace Tedd.Voxtree.Tests;

public class CoveredSubtreeQueryTests
{
    [Fact]
    public void SevenBitNodeFiltersMatchEveryMaskAndExpectedValue()
    {
        foreach (var values in new[]
        {
            new uint[] { 0, 0, 1, 0, 127, 126, 1, 127 },
            new uint[] { 1, 2, 4, 8, 16, 32, 64, 127 },
            new uint[] { 127, 0, 127, 0, 0, 127, 0, 127 }
        })
        {
            var tree = new Octree(1, values);
            var generic = new Octree<uint>(1, values);
            var box = new VoxelBox(0, 0, 0, 2, 2, 2);
            for (uint mask = 0; mask < 128; mask++)
            for (uint expected = 0; expected < 128; expected++)
            {
                var count = values.Count(v => (v & mask) == (expected & mask));
                Assert.Equal(count, tree.CountMatches(box, VoxelFilter.Masked(mask, expected)));
                Assert.Equal(count != 0, tree.Any(box, VoxelFilter.Masked(mask, expected)));
                Assert.Equal(count, generic.CountMatches(box, VoxelFilter<uint>.Masked(mask, expected)));
                Assert.Equal(count != 0, generic.Any(box, VoxelFilter<uint>.Masked(mask, expected)));
            }
            foreach (var expected in new uint[] { 0, 1, 127, 128, uint.MaxValue })
            {
                var count = values.Count(v => v != expected);
                Assert.Equal(count, tree.CountMatches(box, VoxelFilter.NotEqualTo(expected)));
                Assert.Equal(count != 0, tree.Any(box, VoxelFilter.NotEqualTo(expected)));
                Assert.Equal(count, generic.CountMatches(box, VoxelFilter<uint>.NotEqualTo(expected)));
                Assert.Equal(count != 0, generic.Any(box, VoxelFilter<uint>.NotEqualTo(expected)));
            }
        }
    }

    [Fact]
    public void CompressedQueriesMatchDenseRawBitsAcrossWidthsAndNodeVolumes()
    {
        Check<byte>();
        Check<ushort>();
        Check<uint>();
        Check<ulong>();
        Check<float>();
        Check<double>();
        Check<Raw128>();
    }

    private static void Check<T>() where T : unmanaged
    {
        const int side = 16;
        var values = new T[side * side * side];
        var palette = new T[8];
        var paletteBytes = MemoryMarshal.AsBytes(palette.AsSpan());
        var width = Marshal.SizeOf<T>();
        // One-byte tokens, long varints, and distinct high bits. Float/double
        // cells are compared by representation, including NaN and signed zero.
        for (var i = 1; i < 8; i++)
        {
            paletteBytes[i * width] = (byte)(i < 4 ? i : 0x80 + i);
            if (i >= 4) paletteBytes[(i + 1) * width - 1] |= 0x80;
        }
        if (typeof(T) == typeof(float))
        {
            var bits = MemoryMarshal.Cast<T, uint>(palette.AsSpan());
            bits[4] = 0x80000000; bits[5] = 0x7fc00001; bits[6] = 0x7fc00002;
        }
        if (typeof(T) == typeof(double))
        {
            var bits = MemoryMarshal.Cast<T, ulong>(palette.AsSpan());
            bits[4] = 0x8000000000000000; bits[5] = 0x7ff8000000000001; bits[6] = 0x7ff8000000000002;
        }
        for (var x = 0; x < side; x++)
        for (var y = 0; y < side; y++)
        for (var z = 0; z < side; z++)
        {
            var p = ((x >> 2) + (y >> 2) * 3 + (z >> 2) * 5) & 7;
            if (x < 4 && y < 4 && z < 4) p = (x + y + z) & 3;
            values[(x * side + y) * side + z] = palette[p];
        }
        var tree = new Octree<T>(4, values);
        Assert.Equal(0, tree.Data.Span[1] & 3);
        var filters = new[]
        {
            VoxelFilter<T>.Any, VoxelFilter<T>.NonZero,
            VoxelFilter<T>.EqualTo(palette[0]), VoxelFilter<T>.EqualTo(palette[5]),
            VoxelFilter<T>.NotEqualTo(palette[6]), VoxelFilter<T>.Masked(palette[7], palette[3])
        };
        var boxes = new[]
        {
            new VoxelBox(0, 0, 0, side, side, side),
            new VoxelBox(0, 0, 0, 8, 8, 8),
            new VoxelBox(4, 4, 4, 8, 8, 8),
            new VoxelBox(1, 2, 3, 15, 14, 13),
            new VoxelBox(0, 0, 0, 2, 2, 2)
        };
        foreach (var box in boxes)
        foreach (var filter in filters)
        {
            var expected = 0;
            for (var x = box.MinX; x < box.MaxX; x++)
            for (var y = box.MinY; y < box.MaxY; y++)
            for (var z = box.MinZ; z < box.MaxZ; z++)
                if (filter.Matches(values[(x * side + y) * side + z])) expected++;
            Assert.Equal(expected, tree.CountMatches(box, filter));
            Assert.Equal(expected != 0, tree.Any(box, filter));
        }
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    private struct Raw128 { public ulong Low, High; }
}
