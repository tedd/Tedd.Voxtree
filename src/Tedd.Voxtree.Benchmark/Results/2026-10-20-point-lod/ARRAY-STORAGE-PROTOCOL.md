# P10: exact owned-array storage

Both production call sites of the internal OctreeLookup constructor supply
either the owning Octree's complete immutable byte array or default from a
borrowed OctreeSpan. The latter is copied before retention. No call supplies a
slice, MemoryManager, or other ReadOnlyMemory implementation. This invariant
permits an exact byte[] field and byte[]? constructor argument instead of the
current ReadOnlyMemory<byte> field/argument, without changing the public API,
ownership, encoded bytes, bounds checks or snapshot publication.

P10a isolates this type refinement against f0772c8. It is expected to remove
MemoryManager-capable span dispatch in dense compiled reads and reduce the
lookup object's x64 field storage by eight bytes. Treat the object-size number
as a prediction until allocation measurements confirm it. Preserve all source
call sites and borrowed-slice/rebuild/concurrency tests. Constructor payload
StorageBytes continues to exclude object/array headers; measure actual managed
allocation independently.

Use version-7 synthetic fixtures with all existing value/LOD oracles plus
uniform and dense compiled Get/LOD/create/compile+65,536-read cases. Freeze the
16 L5 compiled cases for full, sparse, uniform and dense representations, each
with those four operations. Quiet 12-pair screening, family 16, 3-second primes
and bounded-lifecycle budget; default tiering/PGO and the same x64 runtime/affinity.
Inspect native code separately. Failed host precision controls continue to
prevent claiming a 5% latency-guard pass from small screening estimates.

P10b separately applies the same array invariant to frozen P9, then uses the
byte[] as a direct state-index grid whenever the uint[] field holds state pairs.
Whole-byte stores replace masked read/modify/write word stores at construction;
point reads need no byte extraction shift/mask. Object fields become smaller,
but a selected state grid has two array headers rather than one. Require
new payload+16 <= original node payload as a conservative bound covering the
extra header minus the smaller object's predicted x64 size saving. Verify
actual allocation, including alignment, before using that claim.

P10b's control is exact P9; its version-6 real-world caller family, 16 compiled
scenarios, 12 pairs, primes, budgets and thresholds are unchanged. Validate all
voxels/LODs and 255/256/257-state, ownership and concurrency cases before timing.
Native code must confirm elimination of the indexed-word byte extraction; do
not infer a speedup from the source edit. No unsafe indexing or value-only
specialization is part of either first candidate. Both remain isolated until
fresh original-baseline confirmation, fallback/lifecycle guards and adoption
tradeoffs are resolved. The full public-method 10x target remains unmet.
