# P7: direct mixed-LOD compiled snapshots

The Forcecraft census falsifies P6 eligibility for all 1,286 block arrays. Its
dominant nonuniform stratum has mixed leaf depths and UInt16 values, with the
first selected terrain array containing only 14 distinct values. Investigate a
palette-indexed compiled UInt32 lookup, independently of P1/P3/P5 and P6, using
f0772c8 as control. This changes private memory only, never serialized bytes.

Hypothesis A04/M01/M24: replace dependent node traversal by a direct four-bit
voxel palette index plus an independent four-bit stored-LOD entry per aligned
2³ cube. A nonuniform 2³ cube has LOD zero at every voxel; a uniform cube's
voxels all belong to the same canonical leaf at LOD >=1. Thus one LOD per 2³
cube preserves exact stored LOD for mixed trees. Palette contains at most 16
arbitrary UInt32 values; indices never truncate the values. LOD <=MaxLevels
fits a nibble. Preserve uniform, dense and fully expanded snapshot paths.

Before allocating, require depth >=3 and the conservative packed payload
N/2+N/16+64 <= existing nodeCount*36. Collect at most 16 distinct leaf values;
reject on the seventeenth. Two owned arrays hold the palette and packed
value/LOD payload. Reuse existing fields and a private discriminator so object
size does not grow. Account for both arrays in StorageBytes and report CLR
array-header differences separately from payload. No source-byte retention,
mutable shared cache or per-read allocation is introduced.

Risks: constructor work grows through palette collection and writing the
expanded index grid; sparse/over-16-value rejection adds a pass; packed reads
add a guard on the existing node path; boundary nibble writes may corrupt an
adjacent cell; a coarse LOD could be collapsed incorrectly. Validate every
value and LOD, uint.MaxValue, 1/16/17-entry boundaries, arbitrary topology,
misleading node counts, borrowed ownership, concurrent reads, unchanged
uniform/full/dense paths and constructor plus complete read lifecycle.

Use a new task-owned source fork and fixture version, preserving all earlier
results. Extend real-world UInt32 fixtures with compiled Get/LOD, constructor
and compile+65,536-read lifecycle across all four strata; keep UInt16 owned/span
controls. All-voxel correctness precedes timing. Inspect actual default-tiered
x64 Get/packed-read bodies, fixed stack reservations and constructor recursion.
Freeze concrete scenario identities and screening/confirmation budgets after
the executable exists. No source-level operation count or payload reduction
proves a timing gain. Unresolved host precision continues to prevent claiming
5% regression equivalence; any alternative evidence regime must be declared
before observation. The whole-public-API 10x objective remains unverified.

P7 source built successfully and all 48 version-6 real-world fixtures passed
every value/LOD and complete lifecycle check. The first targeted full-width
test inputs selected dense serialization, so their expected coarse LODs were
invalid; all six new cases failed while existing tests passed. Preserve that
original source/build/results. Corrected P7b inputs assert tree storage before
testing, using seven coarse octants and one detailed octant with 2, 16 or 17
full-width palette values, plus a nested LOD-1 cube at depth 5. No candidate
implementation changed. P7b passed 401 .NET 10, 402 .NET 11 and 400 .NET 8 tests.

Freeze the first P7 timing screen to all 16 real-world compiled scenarios,
four strata times Get, Get-with-LOD, constructor and compile+65,536-read lifecycle.
Use the existing quiet 12-pair protocol, family size 16, 3-second primes and
precision budgets (33,554,432 point reads, 4,096 constructors or 128 complete
lifecycles per batch). Control is the namespace snapshot of f0772c8, treatment
the isolated p7 source/bundle. Retain every contrast, including unchanged sparse
and empty cases. Inspect native code in a separate owned diagnostic process
before this quiet window. These screens cannot qualify promotion or resolve
the prior failed 5% precision controls; fresh identical-caller confirmation and
synthetic fallback guards remain mandatory for adoption.

The first screen did not finish its frozen 16-case budget. Get and Get-with-LOD
completed with descriptive speedups of 1.504x and 1.224x. Constructor operation
`op-cb68c2011c344a1eaeb9e6f8d87e6d5d` reached its 120-second plan limit after
14 retained constructor observations. Execution
`exec-60cc8e0aeae34f07aa737a97b16323ca` failed and target
`target-d674e714a0b6587c16c46615` was tainted because quiescence was not
established. Its PID/start were 151300/639281175286221684. The owned controller
and target subsequently exited; read-only catalog inspection preserved the
reason and every partial run. No automatic tainted-target resume or retry is
permitted. The remaining 13 cases are not complete and no promotion is claimed.

The last complete partial pair recorded roughly 219 microseconds per baseline
constructor and 589 microseconds per treatment constructor, with 66,240 versus
18,584 measured thread-allocation bytes per operation. These are diagnostic
observations from a failed execution, not a qualified constructor estimate.
They expose a material build/read tradeoff despite the smaller payload.

A separate bounded-lifecycle screening epoch may use a new target/catalog and
new plans for the same complete 16-case family, with 256 constructors and 16
complete lifecycles per batch; point counts, primes, 12-pair budget and policies
remain unchanged. All old results stay separate. This is a prospective budget
correction to fit complete work within the 120-second execution limit, not
sample replacement or precision qualification. Candidate code remains frozen.

## P7w: exact array representation (prospective)

The P7 Tier1 packed helper is 346 native bytes with a 56-byte fixed stack
reservation and a ReadOnlyMemory span path containing possible MemoryManager
dispatch, span-bound validation and three subsequent range checks. The complete
value-only caller is 628 bytes versus the original index's 338. These are code
observations, not a measured cost attribution.

Test a separate word-grid source fork: one UInt32 array holds 16 full-width
palette slots, then eight voxel-index nibbles per word and eight LOD nibbles per
word. Direct array reads remove the MemoryManager-capable span conversion and
one CLR array allocation. Logical shifts make packing independent of host byte
order. All public semantics, eligibility and the conservative payload bound
stay fixed; padding unused palette slots adds at most 60 payload bytes while
removing one array header. Preserve the original P7 and bounded screens.

First compare P7w to the exact P7 source (not f0772c8) with identical version-6
terrain callers, all-voxel/LOD oracles, 16 compiled scenarios and the frozen
bounded-lifecycle screening budget. Inspect actual default-tiered native code
and fixed stack reservations separately. Cross-check 2/16/17-entry palettes,
UInt32 extremes, coarse/fine boundaries, ownership and concurrency. Value-only
specialization and unsafe indexing are excluded from this first causal change.
Any promising source still requires fresh confirmation against the original
API baseline, full synthetic fallback guards and resolved adoption tradeoffs.
