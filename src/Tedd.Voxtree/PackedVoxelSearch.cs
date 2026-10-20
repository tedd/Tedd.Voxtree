#if NET10_0_OR_GREATER
using System;
using System.Buffers.Binary;
using System.Numerics;
using System.Runtime.CompilerServices;

namespace Tedd.Voxtree;

internal static class PackedVoxelSearch
{
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static bool TryReadTokens(ReadOnlySpan<byte> data, int offset, out ulong values)
    {
        values = 0;
        if (offset < OctreeCodec.HeaderSize || data.Length - offset < 9) return false;
        values = BinaryPrimitives.ReadUInt64LittleEndian(data.Slice(offset + 1, sizeof(ulong)));
        return (values & 0x8080808080808080UL) == 0;
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static bool TryReadNode(ReadOnlySpan<byte> data, int offset, int level, int headerSize, out ulong values)
    {
        values = 0;
        if (level <= 0 || offset < headerSize || data.Length - offset < 9 || data[offset] != byte.MaxValue)
            return false;
        values = BinaryPrimitives.ReadUInt64LittleEndian(data.Slice(offset + 1, sizeof(ulong)));
        return (values & 0x8080808080808080UL) == 0;
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static int Count(ulong values, ulong mask, ulong expected, bool negate)
    {
        if ((expected & ~0x7fUL) != 0) return negate ? 8 : 0;
        const ulong lanes = 0x0101010101010101UL;
        var differences = (values & ((mask & 0x7f) * lanes)) ^ (expected * lanes);
        // Every lane is at most 127. Adding 127 cannot carry to another lane;
        // its high bit is clear precisely for zero, including adjacent zeros.
        var equal = BitOperations.PopCount(~(differences + 0x7f7f7f7f7f7f7f7fUL) & 0x8080808080808080UL);
        return negate ? 8 - equal : equal;
    }
}
#endif
