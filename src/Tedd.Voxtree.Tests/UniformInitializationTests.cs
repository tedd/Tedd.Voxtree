using System.Runtime.InteropServices;

namespace Tedd.Voxtree.Tests;

public class UniformInitializationTests
{
    [Theory]
    [InlineData(0u)]
    [InlineData(127u)]
    [InlineData(128u)]
    [InlineData(16383u)]
    [InlineData(16384u)]
    [InlineData(0x0fffffffu)]
    [InlineData(uint.MaxValue)]
    public void UInt32MatchesDenseEncoding(uint value)
    {
        for (var levels = 0; levels <= 3; levels++)
        {
            var source = new uint[1 << (levels * 3)];
            Array.Fill(source, value);
            var expected = new Octree(levels, source);
            var tree = new Octree(levels, value);
            Assert.Equal(expected.Data.ToArray(), tree.Data.ToArray());
            Assert.Equal(tree.EncodedLength, Octree.GetUniformSize(value, levels));
            Assert.True(tree.IsBuilt);
            Assert.True(tree.AsSpan().IsWellFormed());
            Assert.Equal(value, Octree.FromEncoded(tree.Data.Span).Get(0, 0, 0));
            Assert.Equal(value, tree.CreateLookup().Get(tree.SideLength - 1, 0, 0));
            var decoded = new uint[tree.Count];
            tree.CopyTo(decoded);
            Assert.Equal(source, decoded);

            var destination = new byte[tree.EncodedLength + 3];
            Array.Fill(destination, (byte)0xcc);
            Assert.Equal(tree.EncodedLength, Octree.BuildUniform(value, levels, destination));
            Assert.Equal(tree.Data.ToArray(), destination[..tree.EncodedLength]);
            Assert.All(destination[tree.EncodedLength..], b => Assert.Equal(0xcc, b));
            Assert.False(Octree.TryBuildUniform(value, levels, destination.AsSpan(0, tree.EncodedLength - 1), out var written));
            Assert.Equal(0, written);
            Assert.Equal(tree.Data.ToArray(), destination[..tree.EncodedLength]);
        }
    }

    [Fact]
    public void GenericValuesMatchDenseEncodingAtEveryWidth()
    {
        CheckGeneric((byte)0);
        CheckGeneric(byte.MaxValue);
        CheckGeneric(ushort.MaxValue);
        CheckGeneric(-1);
        CheckGeneric(ulong.MaxValue);
        CheckGeneric(UInt128.MaxValue);
        CheckGeneric(new Cell128(ulong.MaxValue, 0x0123456789abcdef));
        CheckGeneric(BitConverter.Int32BitsToSingle(unchecked((int)0xffc01234)));
    }

    private static void CheckGeneric<T>(T value) where T : unmanaged
    {
        for (var levels = 0; levels <= 3; levels++)
        {
            var source = new T[1 << (levels * 3)];
            Array.Fill(source, value);
            var expected = new Octree<T>(levels, source);
            var tree = new Octree<T>(levels, value);
            Assert.Equal(expected.Data.ToArray(), tree.Data.ToArray());
            Assert.Equal(tree.EncodedLength, Octree<T>.GetUniformSize(value, levels));
            Assert.True(tree.AsSpan().IsWellFormed());
            Assert.Equal(value, Octree<T>.FromEncoded(tree.Data.Span).Get(tree.SideLength - 1, 0, 0));
            var decoded = new T[tree.Count];
            tree.CopyTo(decoded);
            Assert.Equal(MemoryMarshal.AsBytes(source.AsSpan()).ToArray(), MemoryMarshal.AsBytes(decoded.AsSpan()).ToArray());

            var destination = new byte[tree.EncodedLength + 3];
            Array.Fill(destination, (byte)0xcc);
            Assert.Equal(tree.EncodedLength, Octree<T>.BuildUniform(value, levels, destination));
            Assert.Equal(tree.Data.ToArray(), destination[..tree.EncodedLength]);
            Assert.All(destination[tree.EncodedLength..], b => Assert.Equal(0xcc, b));
            Assert.False(Octree<T>.TryBuildUniform(value, levels, destination.AsSpan(0, tree.EncodedLength - 1), out var written));
            Assert.Equal(0, written);
            Assert.Equal(tree.Data.ToArray(), destination[..tree.EncodedLength]);
        }
    }

    [Fact]
    public void RebuildPreservesCapturedSnapshots()
    {
        var tree = new Octree(2, 1u);
        var snapshot = tree.AsSpan();
        tree.BuildUniform(2u);
        Assert.Equal(1u, snapshot.Get(3, 3, 3));
        Assert.Equal(2u, tree.Get(3, 3, 3));

        var generic = new Octree<ulong>(2, 1ul);
        var genericSnapshot = generic.AsSpan();
        generic.BuildUniform(2ul);
        Assert.Equal(1ul, genericSnapshot.Get(3, 3, 3));
        Assert.Equal(2ul, generic.Get(3, 3, 3));
    }

    [Fact]
    public void MaximumDepthUsesOnlyCompactStorage()
    {
        _ = new Octree(9, uint.MaxValue);
        _ = new Octree<UInt128>(9, UInt128.MaxValue);
        var before = GC.GetAllocatedBytesForCurrentThread();
        var tree = new Octree(9, uint.MaxValue);
        var generic = new Octree<UInt128>(9, UInt128.MaxValue);
        var allocated = GC.GetAllocatedBytesForCurrentThread() - before;
        Assert.InRange(allocated, 1, 256);
        Assert.Equal(7, tree.EncodedLength);
        Assert.Equal(22, generic.EncodedLength);
        Assert.True(tree.AsSpan().IsWellFormed());
        Assert.True(generic.AsSpan().IsWellFormed());
        Assert.Equal(UInt128.MaxValue, Octree<UInt128>.FromEncoded(generic.Data.Span).Get(511, 511, 511));
        Assert.Equal(uint.MaxValue, tree.Get(511, 511, 511));
        Assert.Equal(UInt128.MaxValue, generic.Get(511, 511, 511));
    }

    [Fact]
    public void CallerBufferBuildsAllocateNothing()
    {
        var buffer = new byte[22];
        for (var i = 0; i < 100; i++)
        {
            Octree.BuildUniform(uint.MaxValue, 9, buffer);
            Octree<UInt128>.BuildUniform(UInt128.MaxValue, 9, buffer);
        }
        var before = GC.GetAllocatedBytesForCurrentThread();
        for (var i = 0; i < 100; i++)
        {
            Octree.BuildUniform(uint.MaxValue, 9, buffer);
            Octree<UInt128>.BuildUniform(UInt128.MaxValue, 9, buffer);
        }
        Assert.Equal(0, GC.GetAllocatedBytesForCurrentThread() - before);
    }

    [Fact]
    public void UniformChunksPreserveChannelValuesAndEmptiness()
    {
        var chunk = OctreeChunk.FromUniform(9, new uint[] { 0, 42, uint.MaxValue });
        Assert.False(chunk.IsEmpty);
        Assert.Equal(3, chunk.ChannelCount);
        Assert.Equal(42u, chunk.GetChannel(1).Get(511, 511, 511));
        Assert.Equal(uint.MaxValue, chunk.GetChannel(2).Get(0, 0, 0));
        Assert.True(OctreeChunk.FromUniform(9, new uint[] { 0, 0 }).IsEmpty);
        var packet = new byte[chunk.SerializedLength];
        Assert.Equal(packet.Length, chunk.CopyEncodedTo(packet));
        Assert.Equal(42u, OctreeChunk.FromEncoded(packet).GetChannel(1).Get(511, 511, 511));

        var generic = OctreeChunk<ulong>.FromUniform(9, new ulong[] { 0, ulong.MaxValue });
        Assert.False(generic.IsEmpty);
        Assert.Equal(ulong.MaxValue, generic.GetChannel(1).Get(511, 511, 511));
        Assert.True(OctreeChunk<ulong>.FromUniform(9, new ulong[] { 0, 0 }).IsEmpty);
        packet = new byte[generic.SerializedLength];
        Assert.Equal(packet.Length, generic.CopyEncodedTo(packet));
        Assert.Equal(ulong.MaxValue, OctreeChunk<ulong>.FromEncoded(packet).GetChannel(1).Get(511, 511, 511));
    }

    [Theory]
    [InlineData(-1)]
    [InlineData(10)]
    public void InvalidDepthIsRejected(int levels)
    {
        Assert.Throws<ArgumentOutOfRangeException>(() => new Octree(levels, 0u));
        Assert.Throws<ArgumentOutOfRangeException>(() => new Octree<byte>(levels, (byte)0));
        Assert.Throws<ArgumentOutOfRangeException>(() => Octree.GetUniformSize(0u, levels));
        Assert.Throws<ArgumentOutOfRangeException>(() => Octree<byte>.GetUniformSize(0, levels));
        Assert.Throws<ArgumentOutOfRangeException>(() => Octree.TryBuildUniform(0, levels, new byte[22], out _));
        Assert.Throws<ArgumentOutOfRangeException>(() => Octree<byte>.TryBuildUniform(0, levels, new byte[22], out _));
        Assert.Throws<ArgumentOutOfRangeException>(() => OctreeChunk.FromUniform(levels, new uint[] { 0 }));
        Assert.Throws<ArgumentOutOfRangeException>(() => OctreeChunk<byte>.FromUniform(levels, new byte[] { 0 }));
    }

    [Fact]
    public void InvalidCapacityChannelsAndTypesAreRejected()
    {
        Assert.Throws<ArgumentException>(() => Octree.BuildUniform(0, 1, Array.Empty<byte>()));
        Assert.Throws<ArgumentException>(() => Octree<byte>.BuildUniform(0, 1, Array.Empty<byte>()));
        Assert.Throws<ArgumentException>(() => OctreeChunk.FromUniform(1, Array.Empty<uint>()));
        Assert.Throws<ArgumentException>(() => OctreeChunk<byte>.FromUniform(1, Array.Empty<byte>()));
        Assert.Throws<NotSupportedException>(() => new Octree<Cell24>(1, default(Cell24)));
        Assert.Throws<NotSupportedException>(() => Octree<Cell24>.GetUniformSize(default, 1));
        Assert.Throws<NotSupportedException>(() => Octree<Cell24>.TryBuildUniform(default, 1, new byte[22], out _));
    }

    [StructLayout(LayoutKind.Sequential)]
    private readonly record struct Cell128(ulong Low, ulong High);

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    private struct Cell24 { public byte A; public byte B; public byte C; }
}
