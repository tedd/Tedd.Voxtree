using System.Buffers.Binary;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

// Benchmark-only native index tests cache-line alignment without changing the persisted format.
[MemoryDiagnoser]
public unsafe class AccessTraversal
{
    private const int Operations = 1024;
    private byte[] _data = null!;
    private OctreeLookup _compiled = null!;
    private uint[] _source = null!, _nodes = null!;
    private uint* _aligned;
    private int[] _x = null!, _y = null!, _z = null!, _indices = null!;

    [Params(DataPattern.Clustered, DataPattern.Sparse)] public DataPattern Pattern { get; set; }
    [Params(QueryPattern.Sequential, QueryPattern.Random)] public QueryPattern Queries { get; set; }

    [GlobalSetup]
    public void Setup()
    {
        _source = BenchmarkData.Create(5, Pattern);
        var tree = new Octree(5, _source);
        _data = tree.Data.ToArray();
        _compiled = tree.CreateLookup();
        (_x, _y, _z, _indices) = BenchmarkData.CreateQueries(5, Queries, Operations);
        if ((_data[1] & 3) != 0) throw new InvalidOperationException("Expected tree representation.");
        var nodes = new List<uint>();
        AddNode(_data.Length - 1 - _data[^1]);
        _nodes = nodes.ToArray();
        var count = _nodes.Length / 9;
        _aligned = (uint*)NativeMemory.AlignedAlloc((nuint)(count * 64), 64);
        for (var n = 0; n < count; n++)
        {
            _aligned[n * 16] = _nodes[n * 9];
            for (var c = 0; c < 8; c++)
            {
                var token = _nodes[n * 9 + 1 + c];
                _aligned[n * 16 + 1 + c] = (_nodes[n * 9] & (1u << c)) != 0 ? token : token / 9 * 16;
            }
        }
        for (var i = 0; i < _source.Length; i++)
        {
            var x = i >> 10; var y = (i >> 5) & 31; var z = i & 31;
            if (_compiled.Get(x, y, z) != _source[i] || GetCandidate(x, y, z, false) != _source[i] ||
                GetCandidate(x, y, z, true) != _source[i] ||
                GetIndex(x, y, z) != _source[i] || GetAligned(x, y, z) != _source[i])
                throw new InvalidOperationException("Traversal parity failed.");
        }
        Console.WriteLine($"Representation bytes: encoded={_data.Length}, index36={_nodes.Length * 4}, aligned64={count * 64}, dense={_source.Length * 4}");

        int AddNode(int offset)
        {
            var result = nodes.Count;
            for (var i = 0; i < 9; i++) nodes.Add(0);
            var cursor = offset;
            var mask = _data[cursor++];
            nodes[result] = mask;
            for (var c = 0; c < 8; c++)
            {
                if (!Read(_data, ref cursor, out var token)) throw new InvalidOperationException();
                nodes[result + 1 + c] = (mask & (1 << c)) != 0 ? token : (uint)AddNode(offset - (int)token);
            }
            return result;
        }
    }

    [GlobalCleanup] public void Cleanup() => NativeMemory.AlignedFree(_aligned);

    [Benchmark(Baseline = true, OperationsPerInvoke = Operations)]
    public uint Encoded()
    {
        var tree = new OctreeSpan(_data);
        uint sum = 0;
        for (var i = 0; i < Operations; i++) sum += tree.Get(_x[i], _y[i], _z[i]);
        return sum;
    }
    [Benchmark(OperationsPerInvoke = Operations)] public uint SingleByte() => Candidates(false);
    [Benchmark(OperationsPerInvoke = Operations)] public uint InlineSingleByte() => Candidates(true);
    [Benchmark(OperationsPerInvoke = Operations)]
    public uint Indexed36()
    {
        uint sum = 0;
        for (var i = 0; i < Operations; i++) sum += GetIndex(_x[i], _y[i], _z[i]);
        return sum;
    }
    [Benchmark(OperationsPerInvoke = Operations)]
    public uint Aligned64()
    {
        uint sum = 0;
        for (var i = 0; i < Operations; i++) sum += GetAligned(_x[i], _y[i], _z[i]);
        return sum;
    }
    [Benchmark(OperationsPerInvoke = Operations)]
    public uint DenseSnapshot()
    {
        uint sum = 0;
        for (var i = 0; i < Operations; i++) sum += _source[(_x[i] * 32 + _y[i]) * 32 + _z[i]];
        return sum;
    }

    [Benchmark(OperationsPerInvoke = Operations)]
    public uint CompiledSnapshot()
    {
        uint sum = 0;
        for (var i = 0; i < Operations; i++) sum += _compiled.Get(_x[i], _y[i], _z[i]);
        return sum;
    }

    private uint Candidates(bool inline)
    {
        uint sum = 0;
        for (var i = 0; i < Operations; i++) sum += GetCandidate(_x[i], _y[i], _z[i], inline);
        return sum;
    }

    private uint GetIndex(int x, int y, int z)
    {
        if ((uint)(x | y | z) >= 32) throw new ArgumentOutOfRangeException();
        var offset = 0;
        for (var bit = 4; bit >= 0; bit--)
        {
            var child = (((x >> bit) & 1) << 2) | (((y >> bit) & 1) << 1) | ((z >> bit) & 1);
            var token = _nodes[offset + child + 1];
            if ((_nodes[offset] & (1u << child)) != 0) return token;
            offset = (int)token;
        }
        throw new InvalidOperationException();
    }

    private uint GetAligned(int x, int y, int z)
    {
        if ((uint)(x | y | z) >= 32) throw new ArgumentOutOfRangeException();
        var offset = 0;
        for (var bit = 4; bit >= 0; bit--)
        {
            var child = (((x >> bit) & 1) << 2) | (((y >> bit) & 1) << 1) | ((z >> bit) & 1);
            var token = _aligned[offset + child + 1];
            if ((_aligned[offset] & (1u << child)) != 0) return token;
            offset = (int)token;
        }
        throw new InvalidOperationException();
    }

    // Retains selected-path bounds/canonical-token validation of the public lookup.
    private uint GetCandidate(int x, int y, int z, bool inline)
    {
        if ((uint)(x | y | z) >= 32) throw new ArgumentOutOfRangeException();
        ReadOnlySpan<byte> body = _data.AsSpan(0, _data.Length - 1);
        var rootLength = _data[^1];
        var offset = body.Length - rootLength;
        if (rootLength is < 9 or > 41 || offset < 2) throw new FormatException();
        for (var bit = 4; bit >= 0; bit--)
        {
            var start = offset;
            if ((uint)start >= (uint)body.Length) throw new FormatException();
            var cursor = start;
            var mask = body[cursor++];
            var child = (((x >> bit) & 1) << 2) | (((y >> bit) & 1) << 1) | ((z >> bit) & 1);
            uint token = 0;
            for (var c = 0; c <= child; c++)
                if (!(inline ? ReadInline(body, ref cursor, out token) : ReadFast(body, ref cursor, out token)))
                    throw new FormatException();
            if ((mask & (1 << child)) != 0) return token;
            if (bit == 0 || token == 0 || token > (uint)(start - 2)) throw new FormatException();
            offset = start - (int)token;
        }
        throw new FormatException();
    }

    private static bool ReadFast(ReadOnlySpan<byte> data, ref int offset, out uint value)
    {
        if ((uint)offset < (uint)data.Length && data[offset] < 128)
        {
            value = data[offset++];
            return true;
        }
        return Read(data, ref offset, out value);
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static bool ReadInline(ReadOnlySpan<byte> data, ref int offset, out uint value)
    {
        if ((uint)offset < (uint)data.Length && data[offset] < 128)
        {
            value = data[offset++];
            return true;
        }
        return Read(data, ref offset, out value);
    }

    private static bool Read(ReadOnlySpan<byte> data, ref int offset, out uint value)
    {
        value = 0;
        var start = offset;
        for (var shift = 0; shift <= 28; shift += 7)
        {
            if ((uint)offset >= (uint)data.Length) return false;
            var current = data[offset++];
            if (shift == 28 && (current & 0xf0) != 0) return false;
            value |= (uint)(current & 0x7f) << shift;
            if ((current & 0x80) == 0) return offset - start == 1 || (current & 0x7f) != 0;
        }
        return false;
    }
}
