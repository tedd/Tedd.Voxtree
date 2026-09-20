namespace Tedd.Voxtree.Tests;

public sealed class DeferredChunkStoreTests
{
    private static readonly ChunkAddress Address = new(0, -3, 4, 5);

    [Fact]
    public void PointReadsIncludeEditsAndSnapshotsRemainImmutable()
    {
        using var store = new DeferredChunkStore();
        var source = OctreeChunk.Empty(2, 2);
        store.SetChunk(Address, source);
        Assert.Same(source, store.GetChunk(Address));

        store.Set(Address, 0, 1, 2, 3, 7);
        store.Set(Address, 0, 1, 2, 3, 9);
        store.Set(Address, 1, 1, 2, 3, 11);
        Assert.Equal(9u, store.Get(Address, 0, 1, 2, 3));
        Assert.Equal(11u, store.Get(Address, 1, 1, 2, 3));
        Assert.Equal(0u, source.GetChannel(0).Get(1, 2, 3));
        Assert.Equal(new[] { Address }, store.GetPendingRepackageChunks());

        var snapshot = store.GetChunk(Address);
        Assert.Equal(0, store.PendingRepackageCount);
        store.Set(Address, 0, 1, 2, 3, 17);
        Assert.Equal(9u, snapshot.GetChannel(0).Get(1, 2, 3));
        Assert.Equal(17u, store.Get(Address, 0, 1, 2, 3));
        Assert.Equal(11u, snapshot.GetChannel(1).Get(1, 2, 3));
    }

    [Fact]
    public void PendingAddressesAreCopiedAndRepackagingIsBounded()
    {
        using var store = new DeferredChunkStore();
        for (var x = 0; x < 3; x++)
        {
            var address = new ChunkAddress(0, x, 0, 0);
            store.SetChunk(address, OctreeChunk.Empty(1, 1));
            store.Set(address, 0, 0, 0, 0, (uint)(x + 1));
        }
        var pending = store.GetPendingRepackageChunks();
        Assert.Equal(0, store.Repackage(0));
        Assert.Equal(2, store.Repackage(2));
        Assert.Equal(1, store.PendingRepackageCount);
        Assert.Equal(3, pending.Length);
        Assert.Equal(1, store.Repackage());
        Assert.Equal(0, store.Repackage());
        for (var x = 0; x < 3; x++)
            Assert.Equal((uint)(x + 1), store.Get(new ChunkAddress(0, x, 0, 0), 0, 0, 0, 0));
    }

    [Fact]
    public void ReplacingAndRemovingChunksDiscardPendingEdits()
    {
        using var store = new DeferredChunkStore();
        var original = OctreeChunk.Empty(1, 1);
        store.SetChunk(Address, original);
        store.Set(Address, 0, 0, 0, 0, 41);
        store.SetChunk(Address, original);
        Assert.Equal(0, store.PendingRepackageCount);
        Assert.Equal(0u, store.Get(Address, 0, 0, 0, 0));
        store.Set(Address, 0, 0, 0, 0, 42);
        Assert.True(store.Remove(Address));
        Assert.False(store.Remove(Address));
        Assert.Equal(0, store.PendingRepackageCount);
        Assert.Throws<KeyNotFoundException>(() => store.GetChunk(Address));
    }

    [Fact]
    public void SnapshotCopiesApplySparseEditsBeforeSerializationAndDenseExtraction()
    {
        using var store = new DeferredChunkStore();
        store.SetChunk(Address, OctreeChunk.Empty(2, 2));
        store.Set(Address, 1, 3, 2, 1, 123);
        var packet = new byte[4096];
        var length = store.CopyEncodedTo(Address, packet);
        var loaded = OctreeChunk.FromEncoded(packet.AsMemory(0, length));
        Assert.Equal(123u, loaded.GetChannel(1).Get(3, 2, 1));
        Assert.Equal(0, store.PendingRepackageCount);

        store.Set(Address, 0, 2, 1, 3, 456);
        var dense = new uint[128];
        store.CopyBlockTo(Address, 0, 0, 0, 2, dense);
        Assert.Equal(456u, dense[(2 * 4 + 1) * 4 + 3]);
        Assert.Equal(123u, dense[64 + (3 * 4 + 2) * 4 + 1]);
        Assert.Equal(0, store.PendingRepackageCount);
    }

    [Fact]
    public void DensePromotionRemainsPrivateAndIsScheduled()
    {
        using var store = new DeferredChunkStore(1);
        store.SetChunk(Address, OctreeChunk.Empty(2, 1));
        store.Set(Address, 0, 0, 0, 0, 4);
        store.MakeHot(Address);
        store.Set(Address, 0, 1, 2, 3, 5);
        Assert.Equal(1, store.PendingRepackageCount);
        Assert.Equal(1, store.Repackage());
        Assert.Equal(4u, store.Get(Address, 0, 0, 0, 0));
        Assert.Equal(5u, store.Get(Address, 0, 1, 2, 3));
    }

    [Fact]
    public void GenericStorePreservesBitPatternsAcrossPromotionAndRepackaging()
    {
        using var store = new DeferredChunkStore<ulong>(2);
        var source = OctreeChunk<ulong>.Empty(2, 2);
        store.SetChunk(Address, source);
        store.Set(Address, 1, 1, 2, 3, ulong.MaxValue);
        store.Set(Address, 0, 1, 2, 3, 1UL << 63);
        Assert.Equal(ulong.MaxValue, store.Get(Address, 1, 1, 2, 3));
        Assert.Equal(1, store.PendingRepackageCount);
        store.MakeHot(Address);
        store.Set(Address, 1, 0, 0, 0, 123);
        var packet = new byte[4096];
        var length = store.CopyEncodedTo(Address, packet);
        var snapshot = OctreeChunk<ulong>.FromEncoded(packet.AsMemory(0, length));
        Assert.Equal(1UL << 63, snapshot.GetChannel(0).Get(1, 2, 3));
        Assert.Equal(ulong.MaxValue, snapshot.GetChannel(1).Get(1, 2, 3));
        Assert.Equal(123UL, snapshot.GetChannel(1).Get(0, 0, 0));
        Assert.Equal(0UL, source.GetChannel(1).Get(1, 2, 3));
        Assert.Empty(store.GetPendingRepackageChunks());
        store.Set(Address, 0, 0, 0, 0, 9);
        Assert.Equal(1, store.Repackage(1));
        Assert.True(store.Remove(Address));
    }

    [Fact]
    public void ConcurrentWritesReadsAndRepackagingPreserveEveryPosition()
    {
        using var store = new DeferredChunkStore(8);
        store.SetChunk(Address, OctreeChunk.Empty(2, 1));
        Parallel.For(0, 4, x =>
        {
            for (var y = 0; y < 4; y++)
            {
                store.Set(Address, 0, x, y, 0, (uint)(1 + 4 * x + y));
                Assert.Equal((uint)(1 + 4 * x + y), store.Get(Address, 0, x, y, 0));
                store.Repackage(1);
            }
        });
        var snapshot = store.GetChunk(Address);
        for (var x = 0; x < 4; x++)
            for (var y = 0; y < 4; y++)
                Assert.Equal((uint)(1 + 4 * x + y), snapshot.GetChannel(0).Get(x, y, 0));
        Assert.Empty(store.GetPendingRepackageChunks());
    }

    [Fact]
    public void InvalidWritesDoNotScheduleAndDisposalRejectsOperations()
    {
        Assert.Throws<ArgumentOutOfRangeException>(() => new DeferredChunkStore(0));
        Assert.Throws<ArgumentOutOfRangeException>(() => new DeferredChunkStore<ushort>(0));
        Assert.Throws<ArgumentOutOfRangeException>(() => new DeferredChunkStore(1_048_577));
        Assert.Throws<ArgumentOutOfRangeException>(() => new DeferredChunkStore<ushort>(1_048_577));
        var store = new DeferredChunkStore();
        store.SetChunk(Address, OctreeChunk.Empty(1, 1));
        Assert.Throws<ArgumentOutOfRangeException>(() => store.Set(Address, 1, 0, 0, 0, 7));
        Assert.Throws<ArgumentOutOfRangeException>(() => store.Set(Address, 0, 2, 0, 0, 7));
        Assert.Equal(0, store.PendingRepackageCount);
        Assert.Throws<ArgumentOutOfRangeException>(() => store.Repackage(-1));
        store.Dispose();
        store.Dispose();
        Assert.Throws<ObjectDisposedException>(() => store.Get(Address, 0, 0, 0, 0));
        Assert.Throws<ObjectDisposedException>(() => store.SetChunk(Address, OctreeChunk.Empty(1, 1)));
        Assert.Throws<ObjectDisposedException>(() => store.GetPendingRepackageChunks());
        Assert.Throws<ObjectDisposedException>(() => store.Repackage());
    }
}
