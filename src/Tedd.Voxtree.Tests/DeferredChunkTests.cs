using System.Runtime.InteropServices;

namespace Tedd.Voxtree.Tests;

public sealed class DeferredChunkTests
{
    [Fact]
    public void DeferredWritesCanBeDisabledWithoutChangingSnapshotSemantics()
    {
        var source = OctreeChunk.Empty(2, 2);
        using var defaultOwner = new DeferredOctreeChunk(source);
        using var owner = new DeferredOctreeChunk(source, deferredWritesEnabled: false);
        using var generic = new DeferredOctreeChunk<ulong>(
            OctreeChunk<ulong>.Empty(2, 2), deferredWritesEnabled: false);

        Assert.True(defaultOwner.DeferredWritesEnabled);
        Assert.False(owner.DeferredWritesEnabled);
        Assert.False(generic.DeferredWritesEnabled);
        Assert.False(owner.IsHot);

        owner[0, 1, 2, 3] = 41;
        generic[1, 3, 2, 1] = ulong.MaxValue;
        Assert.True(owner.IsHot);
        Assert.True(generic.IsHot);
        Assert.Equal(0, owner.PendingPositionCount);
        Assert.Equal(0, generic.PendingPositionCount);
        Assert.Equal(41u, owner[0, 1, 2, 3]);
        Assert.Equal(ulong.MaxValue, generic[1, 3, 2, 1]);
        Assert.Equal(0u, source.GetChannel(0).Get(1, 2, 3));

        var snapshot = owner.Repackage();
        Assert.Equal(41u, snapshot.GetChannel(0).Get(1, 2, 3));
        AssertClean(owner);
        owner[1, 0, 0, 0] = 73;
        Assert.True(owner.IsHot);
        Assert.Equal(73u, owner.Repackage().GetChannel(1).Get(0, 0, 0));
    }

    [Fact]
    public void OneToTwentyWritesRemainSparseAndMatchDenseReference()
    {
        const int levels = 5, channels = 3, count = 32 * 32 * 32;
        var original = Enumerable.Range(0, count * channels).Select(i => (uint)(i % 13)).ToArray();
        var expected = (uint[])original.Clone();
        var source = OctreeChunk.FromDense(levels, channels, original);
        using var owner = new DeferredOctreeChunk(source);

        for (var i = 0; i < 20; i++)
        {
            var key = (i * 1543 + 19) % count;
            var channel = i % channels;
            var (x, y, z) = Position(key, levels);
            owner[channel, x, y, z] = expected[channel * count + key] = (uint)(1000 + i);
            Assert.Equal(i + 1, owner.PendingPositionCount);
            Assert.False(owner.IsHot);
            Assert.True(owner.IsDirty);
            AssertOwner(owner, expected);
        }

        var snapshot = owner.Repackage();
        AssertSnapshot(snapshot, expected);
        AssertSnapshot(source, original);
        AssertClean(owner);
        Assert.Same(snapshot, owner.GetChunk());
    }

    [Theory]
    [InlineData(1)]
    [InlineData(15)]
    [InlineData(16)]
    [InlineData(17)]
    [InlineData(20)]
    [InlineData(31)]
    [InlineData(32)]
    [InlineData(33)]
    [InlineData(63)]
    [InlineData(64)]
    [InlineData(65)]
    [InlineData(127)]
    [InlineData(128)]
    [InlineData(129)]
    [InlineData(256)]
    public void CapacityCountsSharedPositionsAndOverflowPreservesAllChannels(int capacity)
    {
        const int levels = 3, count = 512, channels = 3;
        var expected = Enumerable.Repeat(7u, count * channels).ToArray();
        using var owner = new DeferredOctreeChunk(OctreeChunk.FromDense(levels, channels, expected), capacity);
        for (var key = 0; key < capacity; key++)
        {
            var (x, y, z) = Position(key, levels);
            owner[0, x, y, z] = expected[key] = (uint)(key + 100);
            owner[1, x, y, z] = expected[count + key] = 0;
        }
        var last = Position(capacity - 1, levels);
        owner[0, last.X, last.Y, last.Z] = expected[capacity - 1] = uint.MaxValue;
        owner[2, last.X, last.Y, last.Z] = expected[2 * count + capacity - 1] = 99;
        Assert.Equal(capacity, owner.PendingPositionCount);
        Assert.False(owner.IsHot);
        AssertOwner(owner, expected);

        var next = Position(capacity, levels);
        owner[2, next.X, next.Y, next.Z] = expected[2 * count + capacity] = 123;
        Assert.True(owner.IsHot);
        Assert.Equal(0, owner.PendingPositionCount);
        AssertOwner(owner, expected);
        AssertSnapshot(owner.Repackage(), expected);
        AssertClean(owner);
    }

    [Fact]
    public void ExplicitMakeHotAppliesEditsAndReturnedSnapshotsRemainImmutable()
    {
        const int levels = 2, count = 64;
        var original = Enumerable.Repeat(11u, count * 2).ToArray();
        var expected = (uint[])original.Clone();
        var source = OctreeChunk.FromDense(levels, 2, original);
        using var owner = new DeferredOctreeChunk(source, 20);
        owner[0, 3, 1, 2] = expected[54] = 0;
        owner[1, 1, 3, 2] = expected[count + 30] = 500;
        var hot = owner.MakeHot();
        Assert.Same(hot, owner.MakeHot());
        Assert.Equal(0, owner.PendingPositionCount);
        Assert.Equal(0u, hot[0, 3, 1, 2]);
        Assert.Equal(500u, hot[1, 1, 3, 2]);
        hot.GetChannelSpan(1)[DenseVoxel.GetIndex(2, 1, 3, levels, DenseVoxelLayout.Morton)] = 900;
        expected[count + 39] = 900;
        var first = owner.Repackage();
        var firstExpected = (uint[])expected.Clone();
        Assert.False(hot.IsHot);
        AssertClean(owner);
        AssertSnapshot(first, firstExpected);

        owner[1, 2, 1, 3] = expected[count + 39] = 77;
        Assert.False(owner.IsHot);
        Assert.Equal(1, owner.PendingPositionCount);
        var second = owner.Repackage();
        AssertSnapshot(second, expected);
        AssertSnapshot(first, firstExpected);
        AssertSnapshot(source, original);
    }

    [Fact]
    public void ReusedPoolsCannotExposeStaleKeysValuesOrChannelValidity()
    {
        const int levels = 3, count = 512;
        var source = OctreeChunk.FromDense(levels, 3, Enumerable.Repeat(17u, count * 3).ToArray());
        for (var cycle = 0; cycle < 8; cycle++)
        {
            using (var dirty = new DeferredOctreeChunk(source, 256))
            {
                for (var key = 0; key < 256; key++)
                {
                    var (x, y, z) = Position(key, levels);
                    for (var channel = 0; channel < 3; channel++) dirty[channel, x, y, z] = uint.MaxValue;
                }
                if (cycle % 2 == 0) dirty.Repackage();
            }
            using var fresh = new DeferredOctreeChunk(source, 256);
            fresh[1, 7, 7, 7] = 0;
            var expected = Enumerable.Repeat(17u, count * 3).ToArray();
            expected[2 * count - 1] = 0;
            AssertOwner(fresh, expected);
            AssertSnapshot(fresh.Repackage(), expected);
        }
    }

    [Theory]
    [InlineData(DenseVoxelLayout.Linear)]
    [InlineData(DenseVoxelLayout.Morton)]
    public void SerializationAndBulkReadsFlushPendingChanges(DenseVoxelLayout layout)
    {
        using var owner = new DeferredOctreeChunk(OctreeChunk.Empty(3, 2));
        owner[0, 7, 6, 5] = 91;
        var length = owner.SerializedLength;
        AssertClean(owner);
        owner[1, 2, 3, 4] = 82;
        var encoded = new byte[length + 4096];
        var written = owner.CopyEncodedTo(encoded);
        var restored = OctreeChunk.FromEncoded(encoded.AsMemory(0, written));
        Assert.Equal(91u, restored.GetChannel(0).Get(7, 6, 5));
        Assert.Equal(82u, restored.GetChannel(1).Get(2, 3, 4));
        AssertClean(owner);

        owner[0, 3, 2, 1] = 73;
        owner[1, 1, 3, 2] = 64;
        var block = Enumerable.Repeat(uint.MaxValue, 130).ToArray();
        owner.CopyBlockTo(1, 1, 1, 2, block, layout);
        Assert.Equal(73u, block[DenseVoxel.GetIndex(2, 1, 0, 2, layout)]);
        Assert.Equal(64u, block[64 + DenseVoxel.GetIndex(0, 2, 1, 2, layout)]);
        Assert.Equal(uint.MaxValue, block[128]);
        Assert.Equal(uint.MaxValue, block[129]);
        AssertClean(owner);
    }

    [Fact]
    public void ValidationAndDisposalRejectInvalidOperationsWithoutChangingSnapshots()
    {
        var source = OctreeChunk.Empty(1, 2);
        Assert.Throws<ArgumentNullException>(() => new DeferredOctreeChunk(null!));
        Assert.Throws<ArgumentOutOfRangeException>(() => new DeferredOctreeChunk(source, 0));
        Assert.Throws<ArgumentOutOfRangeException>(() => new DeferredOctreeChunk(source, 1_048_577));
        using var owner = new DeferredOctreeChunk(source, 256);
        Assert.Equal(8, owner.Capacity);
        foreach (var (channel, x, y, z) in new[] { (-1, 0, 0, 0), (2, 0, 0, 0), (0, -1, 0, 0),
                     (0, 2, 0, 0), (0, 0, -1, 0), (0, 0, 2, 0), (0, 0, 0, -1), (0, 0, 0, 2) })
        {
            Assert.Throws<ArgumentOutOfRangeException>(() => owner[channel, x, y, z] = 1);
            Assert.Throws<ArgumentOutOfRangeException>(() => _ = owner[channel, x, y, z]);
        }
        AssertClean(owner);
        owner[0, 1, 1, 1] = 42;
        owner.Dispose();
        owner.Dispose();
        Assert.Equal(0u, source.GetChannel(0).Get(1, 1, 1));
        Assert.Throws<ObjectDisposedException>(() => _ = owner[0, 0, 0, 0]);
        Assert.Throws<ObjectDisposedException>(() => owner[0, 0, 0, 0] = 1);
        Assert.Throws<ObjectDisposedException>(() => owner.MakeHot());
        Assert.Throws<ObjectDisposedException>(() => owner.Repackage());
        Assert.Throws<ObjectDisposedException>(() => owner.GetChunk());
        Assert.Throws<ObjectDisposedException>(() => _ = owner.SerializedLength);
        Assert.Throws<ObjectDisposedException>(() => owner.CopyEncodedTo(new byte[100]));
        Assert.Throws<ObjectDisposedException>(() => owner.CopyBlockTo(0, 0, 0, 0, new uint[2]));
    }

    [Fact]
    public void LevelZeroHasOneSharedPositionAcrossChannels()
    {
        using var owner = new DeferredOctreeChunk(OctreeChunk.Empty(0, 2));
        Assert.Equal(1, owner.Capacity);
        owner[0, 0, 0, 0] = 45;
        owner[1, 0, 0, 0] = 67;
        owner[0, 0, 0, 0] = 0;
        Assert.Equal(1, owner.PendingPositionCount);
        Assert.False(owner.IsHot);
        AssertSnapshot(owner.Repackage(), new uint[] { 0, 67 });
    }

    [Fact]
    public void SparseRepackageSharesUnmodifiedChannelEncodings()
    {
        var source = OctreeChunk.FromDense(2, 3, Enumerable.Repeat(19u, 64 * 3).ToArray());
        using var owner = new DeferredOctreeChunk(source);
        owner[1, 3, 2, 1] = 73;
        var snapshot = owner.Repackage();
        Assert.True(snapshot.GetChannelData(0).Equals(source.GetChannelData(0)));
        Assert.True(snapshot.GetChannelData(2).Equals(source.GetChannelData(2)));
        Assert.False(snapshot.GetChannelData(1).Equals(source.GetChannelData(1)));
        Assert.Equal(73u, snapshot.GetChannel(1).Get(3, 2, 1));

        var genericSource = OctreeChunk<ulong>.FromDense(2, 3, Enumerable.Repeat(ulong.MaxValue, 64 * 3).ToArray());
        using var generic = new DeferredOctreeChunk<ulong>(genericSource);
        generic[1, 3, 2, 1] = 0;
        var genericSnapshot = generic.Repackage();
        Assert.True(genericSnapshot.GetChannelData(0).Equals(genericSource.GetChannelData(0)));
        Assert.True(genericSnapshot.GetChannelData(2).Equals(genericSource.GetChannelData(2)));
        Assert.False(genericSnapshot.GetChannelData(1).Equals(genericSource.GetChannelData(1)));
        Assert.Equal(0UL, genericSnapshot.GetChannel(1).Get(3, 2, 1));
    }

    [Fact]
    public void MaximumDepthSparseKeysRetainEveryCoordinateBitWithoutDenseAllocation()
    {
        using var owner = new DeferredOctreeChunk(OctreeChunk.Empty(9, 2), 20);
        using var generic = new DeferredOctreeChunk<ulong>(OctreeChunk<ulong>.Empty(9, 2), 20);
        var points = new[] { (0, 0, 0), (0, 0, 511), (0, 511, 0), (511, 0, 0),
            (255, 511, 511), (511, 511, 511) };
        for (var i = 0; i < points.Length; i++)
        {
            var (x, y, z) = points[i];
            owner[0, x, y, z] = (uint)(i + 1);
            generic[1, x, y, z] = ulong.MaxValue - (ulong)i;
        }
        for (var i = 0; i < points.Length; i++)
        {
            var (x, y, z) = points[i];
            Assert.Equal((uint)(i + 1), owner[0, x, y, z]);
            Assert.Equal(ulong.MaxValue - (ulong)i, generic[1, x, y, z]);
            Assert.Equal(0u, owner[1, x, y, z]);
            Assert.Equal(0UL, generic[0, x, y, z]);
        }
        Assert.Equal(points.Length, owner.PendingPositionCount);
        Assert.Equal(points.Length, generic.PendingPositionCount);
        Assert.False(owner.IsHot);
        Assert.False(generic.IsHot);
    }

    [Theory]
    [InlineData(12345, 1)]
    [InlineData(54321, 17)]
    [InlineData(78432, 256)]
    public void RandomizedWritesAndTransitionsMatchDenseReference(int seed, int capacity)
    {
        const int levels = 3, channels = 3, count = 512;
        var random = new Random(seed);
        var expected = Enumerable.Range(0, count * channels).Select(_ => (uint)random.Next(4)).ToArray();
        using var owner = new DeferredOctreeChunk(OctreeChunk.FromDense(levels, channels, expected), capacity);
        for (var operation = 0; operation < 400; operation++)
        {
            var channel = random.Next(channels);
            var key = random.Next(count);
            var (x, y, z) = Position(key, levels);
            var value = operation % 7 == 0 ? 0 : (uint)random.Next();
            owner[channel, x, y, z] = expected[channel * count + key] = value;
            if (operation % 47 == 0) owner.MakeHot();
            if (operation % 61 == 0) AssertSnapshot(owner.Repackage(), expected);
            if (operation % 11 == 0) AssertOwner(owner, expected);
        }
        AssertSnapshot(owner.GetChunk(), expected);
    }

    [Fact]
    public void GenericValuesRemainExactAcrossSparseHotAndSerializedStates()
    {
        AssertGeneric((byte)255, (byte)128, (byte)37);
        AssertGeneric(ushort.MaxValue, (ushort)32768, (ushort)413);
        AssertGeneric(ulong.MaxValue, 0x8000_0000_0000_0001UL, 0xfedc_ba98_7654_3210UL);
    }

    [Fact]
    public void FloatNaNPayloadsAndSignedZeroRemainBitExactAcrossEveryState()
    {
        var bits = new uint[] { 0, 0x8000_0000, 0x7fc0_1234, 0x7fc0_5678,
            0xffc0_9abc, 0x7f80_0001, 0x7f80_0000, 0xff80_0000 };
        AssertBitExactTransitions(bits.Select(value => BitConverter.Int32BitsToSingle(unchecked((int)value))).ToArray());
    }

    [Fact]
    public void SixteenByteValuesRemainBitExactAcrossEveryState()
    {
        AssertBitExactTransitions(new[]
        {
            Guid.Empty,
            Guid.Parse("01234567-89ab-cdef-0123-456789abcdef"),
            Guid.Parse("01234567-89ab-cdef-fedc-ba9876543210"),
            Guid.Parse("fedcba98-7654-3210-0123-456789abcdef"),
            Guid.Parse("ffffffff-ffff-ffff-ffff-ffffffffffff")
        });
    }

    [Theory]
    [InlineData(91472, 1)]
    [InlineData(27491, 17)]
    [InlineData(39271, 256)]
    public void GenericRandomizedWritesMatchDenseReference(int seed, int capacity)
    {
        const int levels = 3, channels = 3, count = 512;
        var random = new Random(seed);
        var expected = Enumerable.Repeat(ulong.MaxValue, count * channels).ToArray();
        using var owner = new DeferredOctreeChunk<ulong>(
            OctreeChunk<ulong>.FromDense(levels, channels, expected), capacity);
        for (var operation = 0; operation < 400; operation++)
        {
            var channel = random.Next(channels);
            var key = random.Next(count);
            var (x, y, z) = Position(key, levels);
            var value = operation % 7 == 0 ? 0 : 0x8000_0000_0000_0000UL | (ulong)random.NextInt64();
            owner[channel, x, y, z] = expected[channel * count + key] = value;
            if (operation % 47 == 0) owner.MakeHot();
            if (operation % 61 == 0)
            {
                var actual = new ulong[expected.Length];
                owner.Repackage().CopyBlockTo(0, 0, 0, levels, actual);
                Assert.Equal(expected, actual);
            }
            if (operation % 11 == 0)
                for (var c = 0; c < channels; c++)
                    for (var k = 0; k < count; k++)
                    {
                        var p = Position(k, levels);
                        Assert.Equal(expected[c * count + k], owner[c, p.X, p.Y, p.Z]);
                    }
        }
        var final = new ulong[expected.Length];
        owner.GetChunk().CopyBlockTo(0, 0, 0, levels, final);
        Assert.Equal(expected, final);
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public void WidePositionKeysDoNotAliasAtSixtyFourVoxelSide(bool makeHot)
    {
        using var owner = new DeferredOctreeChunk(OctreeChunk.Empty(6, 2), 20);
        using var generic = new DeferredOctreeChunk<ulong>(OctreeChunk<ulong>.Empty(6, 2), 20);
        var points = new[] { (0, 0, 0), (16, 0, 0), (32, 0, 0), (48, 0, 0), (63, 63, 63) };
        for (var i = 0; i < points.Length; i++)
        {
            var (x, y, z) = points[i];
            owner[0, x, y, z] = (uint)(i + 1);
            generic[1, x, y, z] = ulong.MaxValue - (ulong)i;
        }
        Assert.Equal(points.Length, owner.PendingPositionCount);
        Assert.Equal(points.Length, generic.PendingPositionCount);
        if (makeHot) { owner.MakeHot(); generic.MakeHot(); }
        for (var i = 0; i < points.Length; i++)
        {
            var (x, y, z) = points[i];
            Assert.Equal((uint)(i + 1), owner[0, x, y, z]);
            Assert.Equal(ulong.MaxValue - (ulong)i, generic[1, x, y, z]);
            Assert.Equal(0u, owner[1, x, y, z]);
            Assert.Equal(0UL, generic[0, x, y, z]);
        }
        var snapshot = owner.Repackage();
        var genericSnapshot = generic.Repackage();
        for (var i = 0; i < points.Length; i++)
        {
            var (x, y, z) = points[i];
            Assert.Equal((uint)(i + 1), snapshot.GetChannel(0).Get(x, y, z));
            Assert.Equal(ulong.MaxValue - (ulong)i, genericSnapshot.GetChannel(1).Get(x, y, z));
        }
    }

    private static void AssertBitExactTransitions<T>(T[] patterns) where T : unmanaged
    {
        const int levels = 2, count = 64, channels = 2;
        var original = Enumerable.Range(0, count * channels).Select(i => patterns[i % patterns.Length]).ToArray();
        var expected = (T[])original.Clone();
        var source = OctreeChunk<T>.FromDense(levels, channels, original);
        using var owner = new DeferredOctreeChunk<T>(source, 20);
        for (var i = 0; i < 20; i++)
        {
            var key = (i * 17) & (count - 1);
            var p = Position(key, levels);
            var channel = i % channels;
            owner[channel, p.X, p.Y, p.Z] = expected[channel * count + key] = patterns[(i + 1) % patterns.Length];
            if (i % 5 == 0)
                owner[1 - channel, p.X, p.Y, p.Z] = expected[(1 - channel) * count + key] = default;
        }
        Assert.False(owner.IsHot);
        Assert.Equal(20, owner.PendingPositionCount);
        var pointReads = new T[expected.Length];
        for (var channel = 0; channel < channels; channel++)
            for (var key = 0; key < count; key++)
            {
                var p = Position(key, levels);
                pointReads[channel * count + key] = owner[channel, p.X, p.Y, p.Z];
            }
        AssertBytesEqual(expected, pointReads);
        var sparseSnapshot = owner.Repackage();
        var sparseExpected = (T[])expected.Clone();
        var decoded = new T[expected.Length];
        sparseSnapshot.CopyBlockTo(0, 0, 0, levels, decoded);
        AssertBytesEqual(expected, decoded);

        for (var i = 0; i < patterns.Length; i++)
        {
            var p = Position(i, levels);
            owner[1, p.X, p.Y, p.Z] = expected[count + i] = patterns[i];
        }
        var hot = owner.MakeHot();
        Assert.Equal(0, owner.PendingPositionCount);
        for (var i = 0; i < patterns.Length; i++)
        {
            var p = Position(count - 1 - i, levels);
            hot[0, p.X, p.Y, p.Z] = expected[count - 1 - i] = patterns[i];
        }
        var encoded = new byte[owner.SerializedLength];
        Assert.Equal(encoded.Length, owner.CopyEncodedTo(encoded));
        var restored = OctreeChunk<T>.FromEncoded(encoded);
        restored.CopyBlockTo(0, 0, 0, levels, decoded);
        AssertBytesEqual(expected, decoded);
        sparseSnapshot.CopyBlockTo(0, 0, 0, levels, decoded);
        AssertBytesEqual(sparseExpected, decoded);
        source.CopyBlockTo(0, 0, 0, levels, decoded);
        AssertBytesEqual(original, decoded);
    }

    private static void AssertBytesEqual<T>(T[] expected, T[] actual) where T : unmanaged =>
        Assert.Equal(MemoryMarshal.AsBytes(expected.AsSpan()).ToArray(), MemoryMarshal.AsBytes(actual.AsSpan()).ToArray());

    private static void AssertGeneric<T>(T initial, T firstValue, T secondValue) where T : unmanaged
    {
        const int levels = 2, count = 64;
        var source = OctreeChunk<T>.FromDense(levels, 2, Enumerable.Repeat(initial, count * 2).ToArray());
        using var owner = new DeferredOctreeChunk<T>(source, 1);
        owner[0, 3, 2, 1] = firstValue;
        owner[1, 3, 2, 1] = default;
        Assert.Equal(1, owner.PendingPositionCount);
        Assert.Equal(firstValue, owner[0, 3, 2, 1]);
        Assert.Equal(default, owner[1, 3, 2, 1]);
        Assert.Equal(initial, owner[1, 1, 2, 3]);
        var first = owner.Repackage();
        Assert.Equal(firstValue, first.GetChannel(0).Get(3, 2, 1));
        Assert.Equal(default, first.GetChannel(1).Get(3, 2, 1));
        owner[0, 0, 1, 2] = secondValue;
        owner[1, 1, 2, 3] = firstValue;
        Assert.True(owner.IsHot);
        Assert.Equal(0, owner.PendingPositionCount);
        Assert.Same(owner.MakeHot(), owner.MakeHot());
        var block = new T[count * 2];
        owner.CopyBlockTo(0, 0, 0, levels, block);
        Assert.Equal(secondValue, block[6]);
        Assert.Equal(firstValue, block[count + 27]);
        Assert.False(owner.IsDirty);
        owner[0, 3, 2, 1] = secondValue;
        var bytes = new byte[owner.SerializedLength];
        Assert.Equal(bytes.Length, owner.CopyEncodedTo(bytes));
        var restored = OctreeChunk<T>.FromEncoded(bytes);
        Assert.Equal(secondValue, restored.GetChannel(0).Get(3, 2, 1));
        Assert.Equal(firstValue, first.GetChannel(0).Get(3, 2, 1));
        Assert.Equal(initial, source.GetChannel(0).Get(3, 2, 1));
        Assert.Throws<ArgumentOutOfRangeException>(() => owner[-1, 0, 0, 0] = default);
        Assert.Throws<ArgumentOutOfRangeException>(() => _ = owner[0, 4, 0, 0]);
        owner.Dispose();
        owner.Dispose();
        Assert.Throws<ObjectDisposedException>(() => owner.MakeHot());
        Assert.Throws<ObjectDisposedException>(() => owner.Repackage());
        Assert.Throws<ObjectDisposedException>(() => _ = owner[0, 0, 0, 0]);
        Assert.Throws<ObjectDisposedException>(() => owner[0, 0, 0, 0] = default);
    }

    private static (int X, int Y, int Z) Position(int key, int levels)
    {
        var mask = (1 << levels) - 1;
        return (key >> (2 * levels), (key >> levels) & mask, key & mask);
    }

    private static void AssertOwner(DeferredOctreeChunk owner, uint[] expected)
    {
        var count = 1 << (3 * owner.Levels);
        for (var channel = 0; channel < owner.ChannelCount; channel++)
            for (var key = 0; key < count; key++)
            {
                var (x, y, z) = Position(key, owner.Levels);
                Assert.Equal(expected[channel * count + key], owner[channel, x, y, z]);
            }
    }

    private static void AssertSnapshot(OctreeChunk snapshot, uint[] expected)
    {
        var actual = new uint[expected.Length];
        snapshot.CopyBlockTo(0, 0, 0, snapshot.Levels, actual);
        Assert.Equal(expected, actual);
    }

    private static void AssertClean(DeferredOctreeChunk owner)
    {
        Assert.False(owner.IsHot);
        Assert.False(owner.IsDirty);
        Assert.Equal(0, owner.PendingPositionCount);
    }
}
