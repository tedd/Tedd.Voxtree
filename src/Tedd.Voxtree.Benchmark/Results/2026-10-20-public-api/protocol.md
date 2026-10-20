# Public API performance investigation

Engineering evidence; baseline `d46c9ce`, integration branch `main`. Pre-existing
untracked `docs/articles/` is excluded. Objective: reduce complete public-operation
elapsed time with byte-identical encodings, bit-exact values, exception behavior,
allocation guarantees, snapshot publication, and synchronization preserved.
The requested 10x target is assessed per measured workload, not presumed for
constant-time accessors or unmeasured APIs.

## Prospective protocol

Use the DotNetLab registered synchronous harness, quiet validation, randomized
paired arms, 12 blocks, 256 operations per arm, four warmup batches, seed 20261020.
Blocks in one process are descriptive, not independent experiments. Complete
the frozen budget; retain failures and all observations without exclusions or
favorable-run selection. Correctness runs outside timing and compares both
encodings and decoded values to independent dense arrays. The workloads use no
external services or application databases; orchestration uses task-local SQLite
catalogs. Temporary files, builds, catalogs and IPC belong under
`D:\Workspaces\AI\voxtree-public-performance`.

Initial candidate G1 (parent C3/M3, registry V01/A09): replace scalar generic
linear uniform scans with runtime span searches. Predict lower build/size latency
on uniform and spatially clustered primitive values, little gain on random data;
16-byte custom storage is a separate fallback question. Falsifier: no repeatable
complete-operation benefit, byte mismatch, allocation increase, or material
regression on mixed data. Comparisons include uniform, first/last mismatch,
clustered, sparse and random inputs, primitive widths and a 16-byte cell.

Adoption: require repeatable improvement exceeding 5% for the intended scan-heavy
workload and no repeatable regression exceeding 5% on random/sparse guardrails.
Allocation must not increase. These thresholds apply to this small local change;
they are not universal optimization rules. The 10x objective requires an observed
baseline/candidate ratio of at least 10; a smaller useful improvement is reported
as such. No aggregate ratio establishes a tail-latency claim.

Confirmation is frozen after exploratory candidate selection and uses freshly
built controls and candidates, fixed alternating fresh-process sessions, with
all results retained. Runtime and dependency identity restrictions determine
whether DotNetLab normal-build promotion or an explicitly separate external
confirmation is applicable. No promotion claim follows from same-process runs.

## Initial gates (before measurements)

1. Scope: 546 public declaration lines found by lexical inventory; this count
   includes constructors/internal-type members and is not an exact exported ABI.
   Public families: codec/build/validation; point/LOD lookup; spatial queries;
   dense conversion/block extraction; neighborhood caches; chunk/channel
   serialization; hot/deferred mutation; world topology/queries; world entities;
   disk streaming; filters/value types; lock/lifecycle scopes.
2. Baseline: pending fresh harness measurements. Historical BDN artifacts are
   hypotheses only.
3. G1: prepared; baseline scalar loops in GenericOctreeCodec.IsUniform and
   IsUniformRegion; Morton already uses IndexOfAnyExcept on modern targets.
4. Remaining families: pending measured coverage, not a claim of exhausted
   optimization potential. No universal 10x assertion is justified.

G2 (parent C3/M7, registry V03/M18), prospective alternative: compare adjacent
exact-width storage cells as overlapping byte spans using SequenceEqual. All
adjacent cells are equal iff the entire nonempty span is uniform. For strided
rows first compare the initial cell with the root value. Storage consists only
of unsigned primitives or the padding-free two-ulong VoxelUInt128; user-defined
equality and floating-point numeric comparison never participate. This may
vectorize 16-byte storage and the netstandard asset on .NET 8, where a generic
IndexOfAnyExcept implementation may remain scalar. Risks: two overlapping read
streams, extra slicing, first-mismatch regressions, and short-row overhead.
Use the same frozen workloads, budgets and adoption thresholds; G2 is measured
against the original control, independently of G1. No combined-speedup claim.

Before G2 data: epoch G2 uses 40 scenarios (adds uniform byte/ushort owned/span
build callers). Fixed per-arm operations: uniform 4096, clustered 1024,
first/last 256, sparse 128, random 16. Twelve blocks and four warmup batches
remain fixed. This balances timing resolution against the observed large cost
spread; G1 observations are not pooled with G2 and G1's budget is not expanded.

G3, prospective combination: on modern targets retain G1's one-stream value
search for storage widths through eight bytes, and G2's byte equality for 16-byte
cells; on the netstandard asset use byte equality at every width. G1 and G2
exploration show the rationale for this dispatch. The sizeof condition is
constant for each closed generic. Run the complete G2 40-scenario/scaled protocol
again; do not add individual speedups. Fresh normal-build confirmation follows
only after this selection and all correctness/guardrail checks.

## Catalogue coverage for the investigated build operation

| Parent categories | Inspection / disposition |
| --- | --- |
| M1 allocation | Owned builds publish one final array. Size/span operations allocate none; pooling changes ownership or adds maintenance. No allocation change proposed. |
| M2 stack | Existing bounded eight-child stack buffers and maximum depth nine; no repeated heap scratch to remove. |
| M3 bounds / M4 byrefs | G1/G2/G3 use validated bounded rows and runtime bulk operations. No new unsafe access is required. Generated code remains a confirmation gate. |
| M5 layout / M6 location | Exact-width contiguous source rows; changing the persistent wire layout would violate byte parity. Compiled point indexes already exist, outside this build operation. |
| M7 traffic | G2 adjacent-cell byte comparison; compare against G1's value broadcast search and confirm G3 as a whole. |
| C1 dependency | No arithmetic reduction dominates the identified equality scan. Independent accumulators do not answer an early-exit equality predicate. |
| C2 branches | First/last mismatch and random fixtures falsify added setup/early-exit costs. G2 primitive sparse/random regressions motivate G3 width dispatch. |
| C3 SIMD | G1 library search; G2 byte equality; G3 width selection. Portable library paths retain ISA/runtime fallback. |
| C4 bit operations | Varint representation and integer-width dispatch remain intact; no bit-scanning or divide loop in the uniform predicate. |
| C5 stencils | Neighborhood and shared simulation code inspected; those kernels are separate operations with no change from this scan patch. |
| S1 bitmaps | Sparse edit validity masks already exist; they are not used by the dense-source uniform predicate. |
| S2 hashing / S3 frozen maps | Build recursion uses no map. World caches/mutable chunk maps are separate APIs; freezing them changes mutation semantics. |
| S4 preparation | Owned encoding already measures before exact allocation. Caching caller-owned mutable source data requires an invalidation contract absent from these APIs. |
| S5 compression | Preserve canonical uniform/tree/dense choice and every encoded byte. G1/G2/G3 specialize detection only. |
| R1 dispatch | Existing closed-generic size dispatch; G3 uses a sizeof constant, with code evidence required. No reflection/delegate dispatch in the scan. |
| R2 copies/inlining | Scalars and spans; changing the public value contract or introducing ref indirection has no supporting cost evidence. |
| R3 feature flags | No dynamic application flag is tested in the predicate. Target-framework and sizeof selections are compilation constants. |
| T1 false sharing | Synchronous exclusively read source, private destination and result; no concurrent writer in this operation. |
| T2 publication | Existing Volatile.Write snapshot publication is preserved. Mutable source must remain stable during builds. |
| T3 locks | No lock in the scan/build operation. World batch/ReaderWriterLockSlim semantics are unchanged. |
| T4 scheduling/I/O | In-memory small/medium synchronous builds; parallel scheduling would change resource use and needs separate application evidence. Disk compression/streaming cannot be inferred from this operation. |

This catalogue is scoped to the investigated build operation. It does not assert
exhaustive optimization of the entire exported API. Point/LOD reads, filters,
querying, conversion, serialization, editing, streaming, world operations and
lifecycle APIs require their own workloads; direct accessors and empty/no-op
paths cannot inherit a 10x claim from a build benchmark.

## RTree reference and next access-pattern study

User priority: .NET 10 steady-state voxel workloads. Reference checkout:
`D:\SourceCode\Tedd.RTree`, clean `main` at `ed13c1c`. Reports inspected:
2026-10-19 disassembly, binary-packed, specialization, and close-gap (including
R33 precision findings). Transfer hypotheses, not Rust timings or universal wins.
The RTree record also retains failed stack/representation/tiering/precision
studies; there is no basis to assume small local differences are noise-free.

G1/G2/G3 exploratory budgets all completed: 36/40/40 comparisons respectively,
864/960/960 correct and quiescent runs. All 17 G3 normal-build plans completed
their 24 joined process sessions. Uniform ushort normal-build point estimates
are approximately 10.1--11.1x; byte normal-build estimates are 7.1--8.0x, below
their 18--22x long-lived exploratory results. Do not pool these regimes.
Every allocation difference is exactly zero; DotNetLab labels its zero-variance
allocation model inconclusive, so automatic promotion is not established.

Q1 (A09/A16/V03/M02, parent C3/C5/M3): fuse Count/Any on a completely covered
level-one node. Parse every token as before; require mask 255, exact containment,
and matching operation kind. Apply the existing raw-bit filter to eight decoded
values directly, avoiding eight box constructions/clips and State.Accept calls.
Partial nodes, other query kinds, malformed-mask paths and storage formats keep
their existing traversal. Explicit counter-risk: extra dispatch on small queries
or Copy/Collect/Nearest. Compare complete public callers, not only this leaf.

New fixture version 2: affinity mask 4 (logical CPU 2), original .NET 10.0.13
tiering/PGO configuration; one fixed 1000-ms untimed prime per scenario/variant
per process, then the four fixed warmup batches. Reset logical outputs afterward.
This addresses the clarified steady-state objective without silently mixing
earlier fresh-process observations. It is a new epoch, not replacement samples.
Acquire both Global\Tedd.RTree.PerformanceHost and the Voxtree mutex in that order
across builds, correctness, diagnostics and dependent measurement windows.
Unrelated OS/application load and sibling-core contention remain uncontrolled.

Frozen Q1 study: 48 query scenarios, twelve descriptive paired blocks, 16 public
operations per arm, four warmup batches, seed 20261020, quiet profile, 120-second
per-plan budget. UInt32 and generic UInt64; levels 3/5; complete/clipped queries;
compressed low-cardinality, uniform and dense controls; Count/Any-miss/Any-first
and Copy/Collect/Nearest guards. Independent dense count/value/ID/nearest oracles
and baseline encoded-byte parity before timing. Retain every run, no exclusions
or extra samples. Same 5% benefit/regression engineering thresholds. No precise
small-effect claim follows if the host or interval does not resolve that guard.

Q1 completes all 48 plans and all 1152 paired-arm observations. Full compressed
count/miss costs improve about 2.2--2.8x; tiny unchanged paths remain noisy.
A separate CPU-diagnostic execution on the exact q1 binary and JIT listing is
retained; its timings are diagnostic and are not quiet confirmation.

Q2 prospective refinement (A03/A09/A16, parent C5/M3/R2): a fully contained
subtree needs no geometric intersection or child coordinates at all for Count
and Any. Use a separate matching traversal for partial boundary nodes; switch
covered subtrees to dedicated coordinate-free count/any recursion. An all-uniform
child mask permits filtering eight values then scaling by the child volume.
Keep the original traversal for Copy/Collect/Nearest, remove Q1's superseded
leaf body, validate every node/token and retain Any's original early-exit
order for mixed masks. No cached answers, changed encoding, or build-time index.
Use precisely the Q1 48-scenario/version-2 budget and thresholds against the
original d46c9ce control; no addition of Q1 and Q2 ratios. Validate all three
framework test suites and dense oracles again. Capture actual optimized caller
code/stack sizes and a separate CPU diagnostic before fresh confirmation.

Q3 prospective refinement (A09/V03/M3/C2): read the next eight token bytes as
one bounded little-endian word. If no byte has its continuation bit set, all
eight canonical varints have width one. Expand those bytes directly; otherwise
retain the existing validated parser. Generic storage constructs exact unsigned
values through StorageInteger, preserving raw bits and platform byte order.
No read crosses the encoded body; mixed value/offset masks keep their validation
and original child order. Counter-risk: guard cost on long-varint or tiny queries.
Run the complete frozen Q1/Q2 48-case protocol against the original control,
with all budgets and unchanged-operation controls retained. Compare Q2/Q3 as
separate candidates, never multiply their ratios. This candidate applies only
to the matching-query node reader; point reads remain a separate study.

Q4 prospective refinement (V03/C4/M7): for a mask-255 node with eight one-byte
tokens, filter the packed word directly on .NET 10+. Replicate the low seven
mask/expected bits into byte lanes. An expected bit above bit six is unreachable.
After masking/xor each lane lies in 0..127; adding 127 within each lane sets its
high bit exactly when it is nonzero, without inter-lane carry. PopCount of the
complemented high bits counts equality; invert the count for negated filters.
This removes eight decoded stores and wide-vector setup on this specific node
shape. Generic filters preserve the full expected bit representation, including
128-bit high words. Other nodes and older target assets retain Q3. Exhaustive
seven-bit mask/expected tests and raw-bit multiwidth tests precede the complete
48-case query protocol plus twelve prospective long-varint compressed-tree
guards (UInt32/UInt64, full/clipped, count/miss/first, level five). These use
aligned 2-cube uniform cells and large five-/nine-byte values so they remain
compressed while taking the fallback parser. Same twelve blocks, sixteen
operations, seed and warmups; declared family size sixty. Counter-risk: an extra failed guard on other
nodes and code/frame growth. Select using the complete operation, not the kernel.

Prospective final-source steady confirmation: retain the Q4 implementation if
the completed exploration and diagnostics support its mechanism, then compile
fresh baseline/candidate bundles using identical version-2 fixtures. Twelve
paired fresh, joined processes per case, seed 20261021, eight warmup batches,
the fixed one-second per-arm prime, 600-second per-plan limit, and both latency
and allocation objectives. Query operations per run remain 1024 (uniform 8192).
Query family: for each UInt32/UInt64, L5 tree full count/miss, L5 tree clipped
count, L3 tree clipped first, L5 wide full count/miss, L5 dense full count,
L5 uniform full first, and L3 tree clipped copy/collect/nearest: twenty-two
cases. Build family: byte/ushort uniform size/owned and UInt32/Cell128 random
size: six cases; operations uniform 8192, random 256. Family correction is
44 and 12 objectives respectively. All sessions and inconclusive guards remain;
no extra favorable repeats. Exact zero allocation differences are still subject
to DotNetLab's degenerate-variance outcome, not an automatic guardrail pass.

Final-source build exploration is a separate version-2 steady epoch: all forty
G3 workloads and the existing scaled budgets, twelve paired blocks/four warmups,
seed 20261020. Do not pool with version-1 exploration or the earlier seventeen
normal-build cases, which did not contain the one-second prime or CPU affinity.

Before any final confirmation starts, revise its build selection from six to
eight cases: add UInt16 sparse size (an adverse version-2 exploratory estimate)
and UInt64 random size (a prior counter-risk). All original six remain. The
build objective family is therefore sixteen. This is exploratory selection
before independent confirmation data, not a sample extension or exclusion.

Also before confirmation starts, add L5 wide full first for both value types
because the complete Q4 exploration shows an adverse UInt64 estimate. The query
selection now contains twenty-four cases (forty-eight latency/allocation
objectives); all original twenty-two remain. No confirmation observations have
been collected at either selection revision.

Fixture audit before confirmation: the original wide-pattern coordinate formula
included an X contribution in Y before division by two. Its storage was not
asserted; the twelve purported long-token compressed controls therefore do not
establish that workload. Retain their complete Q4 results but mark that scope
invalid. Correct coordinates explicitly, assert the storage kind of every query
fixture, and version the corrected wide inputs as 3 with a new input hash.
Library source is unchanged. Run a new complete sixty-case Q4 epoch under label
q4-fixed with the same frozen budget, rather than selectively retaining previous
controls. Build fresh steady-fixed baseline/candidate bundles using those exact
fixtures before the twenty-four-query/eight-build confirmation. No confirmation
data were collected before this correction. Old low-cardinality results remain
descriptive evidence for their actual inputs and are not pooled with this epoch.

Q5 prospective boundary refinement (A03/A09/C5/R2): emitted VisitMatches still
calls VoxelBox.Intersect and general State.Accept for intersecting uniform
children, although only Count/Any can reach it. Reject non-overlapping child
cubes with six scalar comparisons. Match the filter directly; Any needs no
intersection volume, and Count computes the clipped volume only for matching
uniform children. Internal nodes recurse without constructing a clipped box.
All eight tokens are still parsed before traversal; child order, offset checks,
and Any short-circuit validation remain unchanged. Coordinates are validated
nonnegative and bounded by 512, so endpoint and volume arithmetic are bounded.
Counter-risk: overlap branches or local state copies enlarge the frame or hurt
small immediate-hit queries. Run all sixty corrected fixtures against d46c9ce,
using exactly the q4-fixed budget. Revalidate all three framework suites and
all dense oracles, then inspect actual code/CPU evidence. Do not multiply Q4/Q5
ratios. No final confirmation has started; the frozen twenty-four-query and
eight-build selection/budgets will apply to the selected final source and new
fresh bundles, with matching exploratory scenario descriptors.

L1 prospective access-pattern candidate (A03/M5/M7/S4): a fully expanded
compiled point tree has (voxelCount-1)/7 nodes, consuming approximately 36/7
bytes per voxel versus four bytes for dense values. The maximum node count
also proves every stored leaf is at LOD zero; a missing internal child would
strictly lower the count. On little-endian targets compile this shape directly
into a private linear dense buffer. Preserve node indexes for any coarser leaf,
and existing uniform/borrowed-dense paths. No LOD information may be discarded.
Predict fewer dependent loads per point and lower payload/allocation for the
fully expanded shape; construction may cost more coordinate arithmetic.
Measure Get, Get-with-LOD, CreateLookup and a 65,536-read lifecycle, with scalar
value and independent LOD oracles and complete source snapshot retention.
Point protocol: levels 3/5/6, full/sparse patterns, Get/GetLOD/create (18 cases);
level-five uniform/dense with the same operations (6); level-five full sequential
Get/GetLOD (2); level-five/six full create-plus-65,536-random-reads (2): 28 cases.
Twelve descriptive paired blocks, four warmups, one-second per-arm prime,
affinity 4, seed 20261020, quiet profile, family 28, 120-second limit per plan.
Operations per run: reads 8192, create 8, lifecycle 1. Read loops dispatch once
per batch and count every public read; lifecycle operations count the complete
creation plus read sequence. Fixed inputs/coordinates, no mutation/I/O inside
timing. Record payload and allocations as well as time. Constructor tradeoffs
must be reported separately; retain only with a measured complete lifecycle
benefit and correct LODs, not an isolated lookup-kernel claim. Inspect actual
generated code and a separate CPU diagnostic before selecting this source.

L1 caller audit: version-1 Get controls show large directional differences even
where lookup read IL and representation are unchanged. Do not attribute those
differences to L1 or assume host noise. The shared large ExecuteBatch body may
give arm-specific inlining opportunities. Preserve all twenty-eight cases,
then move each operation/arm into a structurally matched NoInlining batch helper.
The public calls within each helper retain normal inlining. Version descriptors
as 2 and bind the dispatch change in the input hash; run a new complete 28-case
epoch with the identical budgets. Inspect caller and callee code. Mark all
version-1 point estimates caller_control_failure in the exported summary.

Final L1 selection requires a separate fresh-normal point family before the
query/build confirmation. Ten cases, chosen before any fresh-point data:
L3 full/sparse random Get; L5 full random Get/GetLOD/create/lifecycle;
L6 full random lifecycle; L5 sparse/uniform/dense random Get. Twelve paired,
joined process blocks, seed 20261021, eight warmups, the same fixed one-second
prime, allocation guard, objective family twenty, 600 seconds per plan. Fixed
operations: reads 65536, create 16, lifecycle 2. All cases remain, including
adverse controls. Confirm against fresh identical version-2 fixture bundles.
Generated-code diagnostics now inject JIT settings only into the owned target,
not its controller, so dynamic controller methods cannot interleave listings.
Prior diagnostic files remain raw evidence with any interleaving intact.

L2 prospective construction refinement (A03/A09/V03/M7): L1 fresh-point reads
improve, but CreateLookup is slower and the fixed lifecycle intervals remain
inconclusive. Constructor source still reparses all tokens in CountNodes even
when mask 255 proves there are no internal children. After the existing complete
IsWellFormed validation, return one immediately for that mask. For other nodes,
one bounded word can recognize eight one-byte tokens during counting/compilation.
For fully expanded dense compilation, expand a one-byte leaf directly into its
eight linear voxel destinations, avoiding per-token varint calls and repeated
coordinate multiplication. Retain the existing parser for longer tokens and
older target assets. Do not change Get or LOD logic, payload policy, encoded
bytes, or allocations. Add wide-token dense-lookup correctness coverage.
Run all twenty-eight version-2 point cases with the unchanged frozen budgets in
a new L2 epoch, followed by the same ten-case fresh-normal point family on new
bundles if supported. Keep every L1 normal result; do not extend or pool it.
Require complete-lifecycle benefit rather than selecting an isolated read gain.

Final query budget correction before any fresh query confirmation: use 64
operations per run for Count/Miss cases instead of 1024. A roughly 0.7-ms
baseline query would otherwise spend about 5.7 seconds in eight warmup batches
per fresh process. Sixty-four operations still yield roughly 45-ms baseline
and millisecond-scale candidate batches on that case, after the unchanged
one-second prime. All twenty-four cases, twelve blocks, eight warmup batches,
seed, family and thresholds remain fixed. Early-hit/output guards retain the
prior 1024 operations (uniform 8192). This prospective efficiency revision uses
exploratory costs; no fresh query outcomes exist and none are excluded.

## Catalogue coverage for queries and compiled lookups

| Parent categories | Inspection / disposition |
| --- | --- |
| A03/A09/A16, C5 | Covered count/existence omits geometry; boundary traversal rejects overlap directly and computes volume only for matches. Full compiled trees use dense values, with a proof that LOD zero is preserved. |
| C1 dependencies | Dense compiled lookup replaces depth-dependent node loads with direct indexing. No CPU sample-share-to-latency conversion or inferred cache-miss count is claimed. |
| C2 branches | Preserve mixed-mask Any order and all token validation. Full, clipped, early-hit/miss, sparse, uniform, dense and long-token controls expose dispatch costs. |
| C3/C4 SIMD and bit operations | Runtime span filtering remains the fallback. Eight canonical one-byte tokens use bounded word loads and exact byte-lane arithmetic/POPCNT; no new required ISA is exposed. |
| M1 allocation | Queries and reads introduce no heap allocation. Compiled full-tree payload shrinks; constructor arrays remain private owned snapshots. Pooling would require an ownership/disposal contract absent from this immutable API. |
| M2 stack/front end | Record actual reservations, dynamic buffers and native sizes. Q5 boundary code grows while covered-count code is smaller than the original general visitor. No arbitrary stack/prefetch/layout tuning is adopted without measurements. |
| M3/M4 bounds and byrefs | Bounded slices recognize canonical bytes; longer tokens use existing parsers. Preserve ref-struct state, source/destination checks, checked public coordinates and malformed-node behavior. No new unsafe pointer access. |
| M5/M6 layout/location | Serialized bytes are unchanged. Private dense compilation requires a maximum-node-count shape and little-endian numeric stores; every coarser LOD retains node indexes. No global arena, pinning or platform-specific allocator. |
| M7 traffic | Avoid eight decoded stores/filter-vector setup on packed count nodes, repeated geometry materialization, and reparsing validated leaf values while counting nodes. Batch leaf compilation directly into final storage. |
| R1/R2 dispatch/copies | Existing closed-generic width dispatch is retained. Specialized recursive operations replace the general Accept dispatch. Filter-by-reference and additional representation changes remain unmeasured hypotheses, not assumed wins. |
| R3 tiering | Preserve runtime defaults; fixed prime and separate epochs. Large unchanged point-control differences trigger caller isolation and fresh-process confirmation, not favorable sample removal. |
| S1/S2/S3 structure/compression | Existing node masks and canonical varints remain. The query walks use no map to freeze or replace. Sparse-edit/world dictionaries and compression backends require separate operations. |
| S4 preparation | Keep complete constructor validation. Count skips duplicate token reads only afterward. Measure CreateLookup and a fixed creation-plus-read lifecycle; no unbounded answer cache or caller-source invalidation assumption. |
| T1/T2 sharing/publication | Source snapshots remain immutable; private buffers are filled before constructor publication. Existing volatile source publication and concurrent snapshot tests remain. No shared writable scratch. |
| T3/T4 locking/scheduling/I/O | No new library lock or parallel task. World lock policies, deferred loading, disk streaming and production/external data paths are unchanged and have no inherited performance claim. |

This coverage concerns the operations actually investigated. It does not assert
an exhaustive search across all exported methods or universal 10x performance.
