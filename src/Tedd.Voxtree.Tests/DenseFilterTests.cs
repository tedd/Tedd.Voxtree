using System.Runtime.InteropServices;

namespace Tedd.Voxtree.Tests;

public class DenseFilterTests
{
    [Fact]
    public void DenseQueriesMatchScalarRawBitsAcrossWidthsAndTails()
    {
        Check<byte>();
        Check<ushort>();
        Check<uint>();
        Check<ulong>();
        Check<float>();
        Check<double>();
        Check<Raw32>();
        Check<Raw128>();
    }

    private static void Check<T>() where T : unmanaged
    {
        const int side = 8;
        var values = new T[side * side * side];
        var bytes = MemoryMarshal.AsBytes(values.AsSpan());
        new Random(9182).NextBytes(bytes);
        for (var i = 0; i < bytes.Length; i++) bytes[i] &= 0x7f;
        // Exercise zero, signed zero and NaN payloads without numeric equality.
        bytes[..Math.Min(16, bytes.Length)].Clear();
        if (typeof(T) == typeof(float))
        {
            var bits = MemoryMarshal.Cast<T, uint>(values.AsSpan());
            bits[0] = 0x80000000;
            bits[1] = 0x7fc00001;
            bits[2] = 0x7fc00002;
        }
        if (typeof(T) == typeof(double))
        {
            var bits = MemoryMarshal.Cast<T, ulong>(values.AsSpan());
            bits[0] = 0x8000000000000000;
            bits[1] = 0x7ff8000000000001;
            bits[2] = 0x7ff8000000000002;
        }
        var tree = new Octree<T>(3, values);
        Assert.Equal(2, tree.Data.Span[1] & 3); // Force coverage of the dense scan, not leaf collapse.
        var maskBytes = new byte[Marshal.SizeOf<T>()];
        Array.Fill(maskBytes, (byte)0x55);
        var mask = MemoryMarshal.Read<T>(maskBytes);
        Array.Fill(maskBytes, (byte)0xff);
        var missing = MemoryMarshal.Read<T>(maskBytes);
        var filters = new[]
        {
            VoxelFilter<T>.Any, VoxelFilter<T>.NonZero, VoxelFilter<T>.EqualTo(missing),
            VoxelFilter<T>.EqualTo(values[0]), VoxelFilter<T>.EqualTo(values[1]),
            VoxelFilter<T>.EqualTo(values[^1]), VoxelFilter<T>.NotEqualTo(values[2]),
            VoxelFilter<T>.Masked(mask, values[17]), VoxelFilter<T>.Masked(default, values[17])
        };
        for (var width = 0; width <= side; width++)
        {
            CheckBox(new VoxelBox(0, 0, 0, side, side, width)); // contiguous/full and strided
            CheckBox(new VoxelBox(1, 2, 0, 6, 7, width)); // multiple slabs and offset starts
            if (width < side) CheckBox(new VoxelBox(2, 1, 1, 5, 6, width + 1));
        }

        void CheckBox(VoxelBox box)
        {
            foreach (var filter in filters)
            {
                var count = 0;
                for (var x = box.MinX; x < box.MaxX; x++)
                for (var y = box.MinY; y < box.MaxY; y++)
                for (var z = box.MinZ; z < box.MaxZ; z++)
                    if (filter.Matches(values[(x * side + y) * side + z])) count++;
                Assert.Equal(count, tree.CountMatches(box, filter));
                Assert.Equal(count != 0, tree.Any(box, filter));
            }
        }
    }

    [Fact]
    public void UInt32QueriesMatchScalarIncludingAbsentAndLastMatches()
    {
        const int side = 8;
        var data = Enumerable.Range(0, 512).Select(i => (uint)(i * 7919 + 0x10000000)).ToArray();
        var tree = new Octree(3, data);
        Assert.Equal(2, tree.Data.Span[1] & 3);
        var filters = new[]
        {
            VoxelFilter.Any, VoxelFilter.NonZero, VoxelFilter.EqualTo(uint.MaxValue),
            VoxelFilter.NotEqualTo(data[0]), VoxelFilter.Masked(15, 7),
            VoxelFilter.Masked(0, 1), VoxelFilter.EqualTo(data[^1])
        };
        for (var width = 0; width <= side; width++)
        foreach (var filter in filters)
        {
            var box = new VoxelBox(1, 2, 0, side, side, width);
            var count = 0;
            for (var x = box.MinX; x < box.MaxX; x++)
            for (var y = box.MinY; y < box.MaxY; y++)
            for (var z = box.MinZ; z < box.MaxZ; z++)
                if (filter.Matches(data[(x * side + y) * side + z])) count++;
            Assert.Equal(count, tree.CountMatches(box, filter));
            Assert.Equal(count != 0, tree.Any(box, filter));
        }
    }

    [StructLayout(LayoutKind.Sequential)] private struct Raw32 { public uint Bits; }
    [StructLayout(LayoutKind.Sequential)] private struct Raw128 { public ulong Low, High; }
}
