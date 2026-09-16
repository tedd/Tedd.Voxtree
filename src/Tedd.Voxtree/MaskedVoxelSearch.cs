#if NET10_0_OR_GREATER
using System.Numerics;
using System.Runtime.InteropServices;
using System.Runtime.Intrinsics;

namespace Tedd.Voxtree;

// Unsigned storage types preserve raw-bit equality for floats and custom voxel structs.
internal static class MaskedVoxelSearch<T> where T : unmanaged, IBinaryInteger<T>
{
    internal static int Count(ReadOnlySpan<T> values, T mask, T expected, bool negate)
    {
        if (mask == ~T.Zero)
        {
            var equal = values.Count(expected);
            return negate ? values.Length - equal : equal;
        }
        var count = 0;
        var i = 0;
        ref var start = ref MemoryMarshal.GetReference(values);
        if (Vector256.IsHardwareAccelerated && values.Length >= Vector256<T>.Count)
        {
            var masks = Vector256.Create(mask);
            var targets = Vector256.Create(expected);
            for (; i <= values.Length - Vector256<T>.Count; i += Vector256<T>.Count)
            {
                var matches = Vector256.Equals(Vector256.LoadUnsafe(ref start, (nuint)i) & masks, targets);
                count += BitOperations.PopCount(matches.ExtractMostSignificantBits());
            }
        }
        else if (Vector128.IsHardwareAccelerated && values.Length >= Vector128<T>.Count)
        {
            var masks = Vector128.Create(mask);
            var targets = Vector128.Create(expected);
            for (; i <= values.Length - Vector128<T>.Count; i += Vector128<T>.Count)
            {
                var matches = Vector128.Equals(Vector128.LoadUnsafe(ref start, (nuint)i) & masks, targets);
                count += BitOperations.PopCount(matches.ExtractMostSignificantBits());
            }
        }
        for (; i < values.Length; i++)
            count += (values[i] & mask) == expected ? 1 : 0;
        return negate ? values.Length - count : count;
    }

    internal static bool Any(ReadOnlySpan<T> values, T mask, T expected, bool negate)
    {
        // Preserve cheap early success for the common case of a match at the start.
        if (!values.IsEmpty && (((values[0] & mask) == expected) != negate)) return true;
        if (mask == ~T.Zero)
            return negate ? values.IndexOfAnyExcept(expected) >= 0 : values.IndexOf(expected) >= 0;
        var i = 0;
        ref var start = ref MemoryMarshal.GetReference(values);
        if (Vector256.IsHardwareAccelerated && values.Length >= Vector256<T>.Count)
        {
            var masks = Vector256.Create(mask);
            var targets = Vector256.Create(expected);
            for (; i <= values.Length - Vector256<T>.Count; i += Vector256<T>.Count)
            {
                var actual = Vector256.LoadUnsafe(ref start, (nuint)i) & masks;
                if (negate ? !Vector256.EqualsAll(actual, targets) : Vector256.EqualsAny(actual, targets))
                    return true;
            }
        }
        else if (Vector128.IsHardwareAccelerated && values.Length >= Vector128<T>.Count)
        {
            var masks = Vector128.Create(mask);
            var targets = Vector128.Create(expected);
            for (; i <= values.Length - Vector128<T>.Count; i += Vector128<T>.Count)
            {
                var actual = Vector128.LoadUnsafe(ref start, (nuint)i) & masks;
                if (negate ? !Vector128.EqualsAll(actual, targets) : Vector128.EqualsAny(actual, targets))
                    return true;
            }
        }
        for (; i < values.Length; i++)
            if (((values[i] & mask) == expected) != negate) return true;
        return false;
    }
}
#endif
