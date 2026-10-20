using System.Runtime.InteropServices;
using Xunit;

namespace Tedd.Voxtree.Tests;

public class PointTokenPrefixTests
{
    [Fact]
    public void SelectedAndPrecedingTokenWidthsPreserveValuesAndLods()
    {
        for (var longChild = 0; longChild < 8; longChild++)
        {
            var values = Enumerable.Range(0, 8).Select(i => (UInt128)(uint)(i + 1)).ToArray();
            values[longChild] = (UInt128)1 << 120;
            CheckGeneric<byte>(values.Select(v => (byte)v).ToArray());
            CheckGeneric<ushort>(values.Select(v => (ushort)v).ToArray());
            CheckGeneric<uint>(values.Select(v => (uint)v).ToArray());
            CheckGeneric<ulong>(values.Select(v => (ulong)v).ToArray());
            CheckGeneric(values);

            var narrow = values.Select(v => (uint)v).ToArray();
            narrow[longChild] = uint.MaxValue;
            // Each child is a 2^3 cube, keeping even long-token fixtures compressed.
            var dense = Expand(narrow);
            var tree = new Octree(2, dense);
            Assert.Equal(0, tree.Data.Span[1] & 3);
            for (var child = 0; child < 8; child++)
            {
                var x = (child >> 2) * 2;
                var y = (child >> 1 & 1) * 2;
                var z = (child & 1) * 2;
                Assert.Equal(narrow[child], tree.Get(x, y, z, out var lod));
                Assert.Equal(1, lod);
                Assert.True(tree.AsSpan().TryGet(x, y, z, out var value, out lod));
                Assert.Equal(narrow[child], value);
                Assert.Equal(1, lod);
            }
        }
    }

    [Fact]
    public void InvalidPrecedingTokensAreRejectedWithoutValidatingLaterSiblings()
    {
        var header = new Octree(1, Enumerable.Range(1, 8).Select(i => (uint)i).ToArray()).Data.Span[..2].ToArray();
        var genericHeader = new Octree<ulong>(1, Enumerable.Range(1, 8).Select(i => (ulong)i).ToArray()).Data.Span[..3].ToArray();
        foreach (var invalid in new[] { new byte[] { 0x80, 0 }, new byte[] { 0xff, 0xff, 0xff, 0xff, 0x10 } })
        for (var badChild = 0; badChild < 8; badChild++)
        {
            var data = Root(header, badChild, invalid);
            for (var child = 0; child < 8; child++)
            {
                var x = child >> 2; var y = child >> 1 & 1; var z = child & 1;
                var success = new OctreeSpan(data).TryGet(x, y, z, out var value, out var lod);
                Assert.Equal(child < badChild, success);
                Assert.Equal(child < badChild ? (uint)(child + 1) : 0u, value);
                Assert.Equal(0, lod);
            }
        }
        foreach (var invalid in new[] { new byte[] { 0x80, 0 }, Enumerable.Repeat((byte)0xff, 9).Append((byte)2).ToArray() })
        for (var badChild = 0; badChild < 8; badChild++)
        {
            var data = Root(genericHeader, badChild, invalid);
            for (var child = 0; child < 8; child++)
            {
                var success = new OctreeSpan<ulong>(data).TryGet(child >> 2, child >> 1 & 1, child & 1, out var value, out var lod);
                Assert.Equal(child < badChild, success);
                Assert.Equal(child < badChild ? (ulong)(child + 1) : 0ul, value);
                Assert.Equal(0, lod);
            }
        }
    }

    [Fact]
    public void BorrowedPrefixMutationIsObservedAndTruncationDoesNotOverread()
    {
        var original = new Octree(1, Enumerable.Range(1, 8).Select(i => (uint)i).ToArray()).Data.ToArray();
        var borrowed = new OctreeSpan(original);
        Assert.Equal(8u, borrowed.Get(1, 1, 1));
        original[3] = 11;
        Assert.Equal(11u, borrowed.Get(0, 0, 0));
        for (var length = 2; length < original.Length; length++)
        {
            var slice = original.AsSpan(0, length);
            // Some truncated bytes can describe a different partial path. A safe
            // reader may accept it, but it must never access outside this slice.
            if (OctreeSpan.TryCreate(slice, out var span))
                span.TryGet(1, 1, 1, out _, out _);
        }
    }

    private static byte[] Root(byte[] header, int badChild, byte[] invalid)
    {
        var bytes = new List<byte>(header) { 255 };
        for (var child = 0; child < 8; child++)
            if (child == badChild) bytes.AddRange(invalid); else bytes.Add((byte)(child + 1));
        bytes.Add((byte)(bytes.Count - header.Length));
        return bytes.ToArray();
    }

    private static T[] Expand<T>(T[] children)
    {
        var result = new T[64];
        for (var x = 0; x < 4; x++)
        for (var y = 0; y < 4; y++)
        for (var z = 0; z < 4; z++)
            result[(x * 4 + y) * 4 + z] = children[((x >> 1) << 2) | ((y >> 1) << 1) | (z >> 1)];
        return result;
    }

    private static void CheckGeneric<T>(T[] children) where T : unmanaged
    {
        var tree = new Octree<T>(2, Expand(children));
        for (var child = 0; child < 8; child++)
        {
            var x = (child >> 2) * 2; var y = (child >> 1 & 1) * 2; var z = (child & 1) * 2;
            var value = tree.Get(x, y, z, out var lod);
            Assert.True(MemoryMarshal.AsBytes(new[] { children[child] }.AsSpan()).SequenceEqual(MemoryMarshal.AsBytes(new[] { value }.AsSpan())));
            Assert.Equal(1, lod);
        }
    }
}
