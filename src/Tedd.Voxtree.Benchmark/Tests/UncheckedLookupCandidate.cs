using System.Buffers.Binary;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.CompilerServices;

namespace Tedd.Voxtree.Benchmark.Tests;

// Unchecked managed-reference variant of the frozen lookup hot path. Reflection only captures
// the already validated snapshot in setup; field types/order and Get/GetUnchecked match it.
internal sealed class UncheckedLookupCandidate
{
    private readonly uint[]? _nodes;
    private readonly ReadOnlyMemory<byte> _dense;
    private readonly uint _uniform;

    public UncheckedLookupCandidate(OctreeLookup lookup)
    {
        _nodes = (uint[]?)Field("_nodes");
        _dense = (ReadOnlyMemory<byte>)Field("_dense")!;
        _uniform = (uint)Field("_uniform")!;
        Levels = lookup.Levels;
        object? Field(string name) => typeof(OctreeLookup)
            .GetField(name, BindingFlags.NonPublic | BindingFlags.Instance)!.GetValue(lookup);
    }

    public int Levels { get; }
    public int SideLength => 1 << Levels;

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public uint Get(int x, int y, int z)
    {
        if ((uint)x >= (uint)SideLength) return ThrowCoordinate(nameof(x), x);
        if ((uint)y >= (uint)SideLength) return ThrowCoordinate(nameof(y), y);
        if ((uint)z >= (uint)SideLength) return ThrowCoordinate(nameof(z), z);
        return GetUnchecked(x, y, z);
    }

    private uint GetUnchecked(int x, int y, int z)
    {
        var nodes = _nodes;
        if (nodes is null)
        {
            if (_dense.IsEmpty) return _uniform;
            var index = ((x << Levels) + y) * SideLength + z;
            return BinaryPrimitives.ReadUInt32LittleEndian(_dense.Span.Slice(2 + index * sizeof(uint), sizeof(uint)));
        }
        ref var first = ref MemoryMarshal.GetReference(nodes.AsSpan());
        var offset = 0;
        for (var bit = Levels - 1; bit >= 0; bit--)
        {
            var child = (((x >> bit) & 1) << 2) | (((y >> bit) & 1) << 1) | ((z >> bit) & 1);
            var token = Unsafe.Add(ref first, offset + child + 1);
            if ((Unsafe.Add(ref first, offset) & (1u << child)) != 0) return token;
            offset = (int)token;
        }
        return ThrowMalformed();
    }

    [MethodImpl(MethodImplOptions.NoInlining)]
    private static uint ThrowCoordinate(string parameterName, int value) =>
        throw new ArgumentOutOfRangeException(parameterName, value, "Coordinate is outside the octree.");
    [MethodImpl(MethodImplOptions.NoInlining)]
    private static uint ThrowMalformed() => throw new FormatException("The octree data is malformed.");
}
