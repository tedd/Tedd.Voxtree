using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

[MemoryDiagnoser, DisassemblyDiagnoser(maxDepth: 2)]
public class AccessBoundsConversion
{
    private uint[] _source = null!, _destination = null!;

    [Params(3, 5)] public int Levels { get; set; }
    [Params(DenseVoxelLayout.Linear, DenseVoxelLayout.Morton)] public DenseVoxelLayout SourceLayout { get; set; }

    [GlobalSetup]
    public void Setup()
    {
        _source = BenchmarkData.Create(Levels, DataPattern.Random);
        _destination = new uint[_source.Length];
        Production();
        var expected = (uint[])_destination.Clone();
        PrevalidatedRows();
        if (!_destination.AsSpan().SequenceEqual(expected)) throw new InvalidOperationException("Row parity failed.");
        Array.Clear(_destination);
        ManagedReference();
        if (!_destination.AsSpan().SequenceEqual(expected)) throw new InvalidOperationException("Reference parity failed.");
    }

    [Benchmark(Baseline = true)]
    public void Production() => DenseVoxel.Convert(_source, _destination, Levels, SourceLayout,
        SourceLayout == DenseVoxelLayout.Linear ? DenseVoxelLayout.Morton : DenseVoxelLayout.Linear);

    [Benchmark]
    public void PrevalidatedRows() => Convert(_source, _destination, Levels, SourceLayout, false);

    [Benchmark]
    public void ManagedReference() => Convert(_source, _destination, Levels, SourceLayout, true);

    private static void Convert(ReadOnlySpan<uint> source, Span<uint> destination, int levels,
        DenseVoxelLayout sourceLayout, bool byRef)
    {
        if ((uint)levels > 9 || (uint)sourceLayout > 1) throw new ArgumentOutOfRangeException();
        var count = 1 << (levels * 3);
        if (source.Length != count || destination.Length < count) throw new ArgumentException();
        destination = destination[..count];
        if (source.Overlaps(destination)) throw new ArgumentException();
        if (byRef) ConvertRefs(source, destination, levels, sourceLayout);
        else ConvertRows(source, destination, levels, sourceLayout);
    }

    private static void ConvertRows(ReadOnlySpan<uint> source, Span<uint> destination, int levels, DenseVoxelLayout sourceLayout)
    {
        var side = 1 << levels;
        Span<int> axis = stackalloc int[side];
        for (var i = 0; i < axis.Length; i++)
            axis[i] = (int)global::Tedd.MortonEncoding.Encode((uint)i, 0u, 0u);
        var linear = 0;
        if (sourceLayout == DenseVoxelLayout.Linear)
        {
            for (var x = 0; x < side; x++)
            for (var y = 0; y < side; y++)
            {
                var xy = axis[x] | (axis[y] << 1);
                var row = source.Slice(linear, side);
                for (var z = 0; z < row.Length; z++)
                    destination[xy | (axis[z] << 2)] = row[z];
                linear += side;
            }
            return;
        }
        for (var x = 0; x < side; x++)
        for (var y = 0; y < side; y++)
        {
            var xy = axis[x] | (axis[y] << 1);
            var row = destination.Slice(linear, side);
            for (var z = 0; z < row.Length; z++)
                row[z] = source[xy | (axis[z] << 2)];
            linear += side;
        }
    }

    private static void ConvertRefs(ReadOnlySpan<uint> source, Span<uint> destination, int levels, DenseVoxelLayout sourceLayout)
    {
        var side = 1 << levels;
        Span<int> axis = stackalloc int[side];
        for (var i = 0; i < axis.Length; i++)
            axis[i] = (int)global::Tedd.MortonEncoding.Encode((uint)i, 0u, 0u);
        ref var input = ref MemoryMarshal.GetReference(source);
        ref var output = ref MemoryMarshal.GetReference(destination);
        var linear = 0;
        if (sourceLayout == DenseVoxelLayout.Linear)
        {
            for (var x = 0; x < side; x++)
            for (var y = 0; y < side; y++)
            {
                var xy = axis[x] | (axis[y] << 1);
                for (var z = 0; z < side; z++)
                    Unsafe.Add(ref output, xy | (axis[z] << 2)) = Unsafe.Add(ref input, linear++);
            }
            return;
        }
        for (var x = 0; x < side; x++)
        for (var y = 0; y < side; y++)
        {
            var xy = axis[x] | (axis[y] << 1);
            for (var z = 0; z < side; z++)
                Unsafe.Add(ref output, linear++) = Unsafe.Add(ref input, xy | (axis[z] << 2));
        }
    }
}
