# .NET 10 voxel performance investigation

Baseline: `d46c9ce`. Integration branch: `main`. Requested target: 10x for each
public method. Measured scope: generic encoding, spatial count/existence
queries, and compiled point lookups, with complete-operation controls. This is not a 10x result across the
exported API. Reflection records 47 exported types, 462 ordinary declared public
methods, 699 methods including special-name members, and 41 constructors.

## Implementation

Generic encoding uses runtime vectorized equality searches for primitive storage
widths through eight bytes. Adjacent-cell byte equality handles 16-byte storage
and the portable target. The encoder keeps canonical byte output, storage-kind
selection, ownership and publication unchanged.

Count and existence queries separate boundary traversal from fully covered
subtrees. Covered recursion carries values and volumes without computing child
coordinates or intersecting boxes. A bounded eight-byte load recognizes eight
canonical one-byte tokens. On .NET 10+, fully uniform-child nodes can apply the
raw-bit filter directly to the packed word, without materializing eight wider
cells. Long tokens, mixed nodes and older target assets use validated fallbacks.
Boundary rejection uses scalar overlap checks. Count computes an intersection
volume only after a uniform child matches; Any needs no intersection volume.
Copy, collection and nearest queries retain the original traversal.

Packed filtering uses eight independent seven-bit lanes. After masking and xor,
each lane is 0..127. Adding 127 produces no carry between lanes and sets a lane's
high bit precisely when its value is nonzero. A population count of complemented
high bits gives the number of equal lanes. Expected bits above bit six make
equality impossible; negated filters invert the count. Generic 128-bit filters
also check the high word. No pointer overread, unsafe block, allocation, new
wire format or cached query answer is introduced.

The existing compiled point-lookup API now stores fully expanded trees as dense
values. A depth-L full tree has (8^L-1)/7 internal nodes, so the maximum node
count proves that every stored leaf is one voxel and has LOD zero. Four-byte
values replace approximately 36/7 bytes of node payload per voxel, reducing the
lookup payload by about 22%. Any coarser leaf retains the original node index.
Already dense encodings and uniform snapshots keep their existing paths.
Compilation skips reparsing leaf values while counting already validated nodes,
and batches one-byte tokens during compilation. The source still receives full
structural validation; longer tokens keep the original parser. No LOD metadata
is discarded. Reads use the existing public methods and bounds checks.

## Evidence and qualification

The machine is a Ryzen 9 5950X on Windows 11, High performance power scheme.
Measurements target x64 .NET 10.0.13. The installed SDK used for these builds is
11.0.100-rc.2.26504.105; the repository's unavailable SDK pin is unchanged.

Version-2 fixtures pin the owned harness to logical CPU 2 and prime each
scenario/variant for one second outside timing. Private input arrays and outputs
are reset logically. DotNetLab quiet paired blocks and fresh normal-build
sessions are distinct evidence regimes. Full budgets, seeds, sample families,
thresholds, candidate predictions and counter-risks are in [protocol.md](protocol.md).
Both RTree and Voxtree shared host locks cover the later studies. Unrelated host
load and SMT-sibling activity remain uncontrolled; the RTree precision research
does not establish a 5% precision guarantee on this machine.

`measurements.csv` contains every exported objective estimate and available
interval, including inconclusive and adverse results. Twelve initial Q4 wide
controls did not assert compressed storage and had a coordinate error. They are
retained with `invalid_compressed_scope`; corrected version-3 inputs assert the
storage kind and run in a separate complete sixty-case epoch. `evidence.zip` retains raw
runs/sessions, accepted operation IDs and requests, plans, source snapshots,
measured binaries/manifests/hashes, JIT listings, diagnostic artifacts, controller
logs and read-only JSON exports of task-local catalogs. `evidence.sha256` and the
archive's per-file manifest bind those contents. No build caches or SQLite files
are included. CPU-diagnostic timings are not quiet confirmation.

All 42 final normal-build plans complete their frozen budgets: 1,008 successful,
quiescent sessions with distinct process/start-time identities and joined exits.
Public API inventories match exactly, and the current library source matches
the final candidate snapshot. Primary timing classifications are 23 improved,
6 equivalent within the configured margin, and 13 inconclusive; none is classified
regressed. The inconclusive controls do not establish family-wide 5% equivalence.

| Final workload | Speedup estimate | Timing result |
| --- | ---: | --- |
| Uniform byte required size / owned build, side 32 | 20.15x / 19.89x | Improved |
| Uniform UInt16 required size / owned build, side 32 | 10.39x / 10.07x | Improved; intervals cross the 10x target |
| Full low-cardinality compressed count, UInt32 / UInt64, side 32 | 14.33x / 14.76x | Improved |
| Full compressed Any miss, UInt32 / UInt64, side 32 | 14.92x / 14.50x | Improved |
| Clipped compressed count, UInt32 / UInt64, side 32 | 5.52x / 5.06x | Improved |
| Full long-token compressed count, UInt32 / UInt64, side 32 | 2.79x / 1.68x | Improved |
| Fully expanded compiled Get / Get-with-LOD, side 32 | 2.91x / 2.94x | Improved |
| CreateLookup plus 65,536 reads, side 32 / side 64 | 2.08x / 1.65x | Improved |
| CreateLookup alone, fully expanded side 32 | 1.22x | Inconclusive |

These are paired geometric cost-ratio estimates, not pooled speedups or
single-call tail latencies. CSV rows contain the family-adjusted model intervals:
build coverage 99.6875%, query 99.8958%, point 99.75%. For example, UInt32 full
count is 13.91--14.76x, and side-32 compiled Get is 2.78--3.04x. Intervals are
conditional on the declared fresh-process independence/environment assumptions.
UInt32 random and UInt16 sparse build controls pass the configured equivalence
test; Cell128/UInt64 random build controls remain inconclusive.

Lookup payload is reduced about 22% at sides 32/64. This excludes CLR headers,
the retained source tree, unrelated fixtures, and peak process working set.
The benchmark retains both implementations' fixtures; allocation metrics cover
timed operations. Do not interpret descriptive multi-scenario process results
as fresh-process confirmation; JIT/PGO history and caller code differ. The first
point caller failed unchanged controls and remains separately marked
`caller_control_failure`; isolating helpers does not prove that inlining alone
caused the discrepancy.

Earlier version-1 build results lack the steady-state
prime and CPU affinity and must not be pooled with version 2. Their seventeen
normal-build cases are retained separately. Every earlier allocation difference
was exactly zero; DotNetLab treats that zero-variance model as inconclusive, so
automatic promotion was not established there. The final side-64 point lifecycle
also passes DotNetLab's allocation policy and automatic normal-build promotion.
Other zero-variance allocation guards can remain unresolved despite unchanged
or reduced observed byte counts; inspect each row rather than treating this as
an automatic family-wide pass.

## Generated code

The original non-generic `Visit` reserves 280 bytes with `sub rsp` and pushes
eight registers, plus a bounded dynamic token buffer; its native body is 2002
bytes. Q1's fused-leaf `Visit` grows to 296 bytes and 2504 native bytes. Q2 moves
covered counting to a 152-byte fixed reservation and 640-byte body, with a
separate 325-byte Tier1 node reader. These are emitted Windows x64 observations,
not total recursive stack usage or a claim that stack size alone explains time.
Q5 removes geometry/helper calls from the boundary path but grows its fixed
reservation to 264 bytes and native body to 1525 bytes (UInt32); that is a code/
stack tradeoff with measured latency benefits, not a universal stack reduction.
The final covered-count path reserves 152 bytes and emits a 911-byte body with
`POPCNT`. Generic UInt64 covered counting reserves 232 bytes plus its bounded
dynamic buffers and emits 906 native bytes. Source-specific target-only dumps
avoid controller JIT output interleaving; earlier raw dumps remain intact.
Q3/Q4 listings and separate CPU captures are retained. Sampling includes priming
and waiting; sample shares are not call counts or per-call speedups.

## Correctness and coverage

The latest checked source passes 392 tests on .NET 10, 393 on .NET 11 and 391 on
.NET 8 using the netstandard library asset: 1,176 framework tests in total.
The 128 benchmark scenarios validate original/candidate encodings, counts,
region outputs, collected IDs/values, nearest coordinates and point values/LODs
against dense and independent LOD oracles before measurement.
Additional tests exhaust all seven-bit mask/expected pairs on multiple packed
node patterns, negated/high-bit filters, partial/full cubes, different uniform
node volumes, seven storage representations, NaN payloads and signed zero.
Lookup tests cover full and nearly full trees, long-token fallback, every voxel
and LOD, borrowed-buffer reuse, and concurrent source rebuilding.

| API family | Evidence / limit |
| --- | --- |
| Generic required size, span encoding, owned build | Five widths; uniform, first/last mismatch, clustered, sparse and random inputs; byte parity and dense decode oracle. |
| Count and Any | Non-generic UInt32 and generic UInt64; levels 3/5, full/clipped, low-cardinality compressed, uniform, dense, and long-varint compressed controls. |
| Copy, collection, nearest | Complete query guard scenarios and correctness checks; no general speedup claim. |
| Other generic query widths | Raw-bit correctness and framework tests; no workload-specific speedup estimate. |
| Compiled point/LOD reads and creation | Three sizes, random/sequential reads, full/sparse/uniform/dense representations, allocation/payload checks, and complete creation/read lifecycle; no 10x claim. |
| Serialized point/LOD readers | Unchanged implementation; no inherited speedup claim. |
| Conversion, editing, neighborhood, chunks, world/entity and streaming APIs | Existing regression suite; no complete-operation performance claim from these studies. |
| Accessors and lifecycle methods | No inherited speedup from an encoder or query benchmark. |

## Reproduction

All scratch output must be in a dedicated `D:\Workspaces\AI\<name>` directory.
The scripts use a persistent DotNetLab controller for asynchronous operations,
scoped supported grants, verified target identity and joined shutdown. They do
not launch applications connected to external databases. Test file-storage paths
and TEMP/TMP are redirected into the task directory.

1. Build a fixture with `Build-Rig.ps1 -TaskRoot <task> -LabDirectory <matching lab DLL directory> -Label candidate`.
2. Run `Verify.ps1 -TaskRoot <task>` and `dotnet exec --fx-version 10.0.13 <bundle DLL> --validate` under `Host-Lock.ps1`.
3. Run `Measure.ps1` with `-Filter 'query-*'`, `-Filter 'build-*'` or `-Filter 'point-*'`, `-Budget scaled`, distinct labels and workspace paths.
4. Inspect exact accepted requests/operations before resuming interrupted work. Do not resubmit unknown work or silently extend a sample budget.
5. Build distinct fresh baseline/candidate bundles; use `-CandidateRevision d46c9ce` for the baseline primary namespace. Stage new task-owned library files before `Confirm.ps1` so its source diff includes them. Supply the frozen scenario list and matching exploration label/catalog.
6. After all owned workers and controllers exit, `Preserve.py <task> <durable Results directory>` exports evidence. Verify the archive and integration before deleting the task workspace.

The source-only fixture files deliberately use `.cs.txt` so the benchmark project
does not compile an additional entry point. Dependency/runtime identities are
part of the retained evidence; a different runtime or rebuilt fixture is a new
measurement epoch.

## Candidate disposition and completion boundary

G1's primitive searches and G2's byte equality inform G3's width-dependent
combination; their results are not multiplied. G3 is retained for the measured
encoding workloads. Q1's fused leaf, Q2's covered traversal and Q3's token batch
lead to Q4's packed filtering and Q5's specialized boundary walk. Q5 is retained,
including the packed filter. Corrected long-token controls are version 3; the
original twelve mischaracterized controls are never used as evidence for them.

L1's dense compiled representation preserves every stored LOD, but its first
normal-build lifecycle result was inconclusive. L2 removes duplicate token work
in construction and establishes the complete-lifecycle benefit; it is retained.
Exactly one final workload receives automatic DotNetLab promotion. The other
workload results retain their recorded allocation/guardrail limitations; no
automatic decision is overridden or represented as a pass.

All candidate epochs, all final cases and the earlier normal-build studies are
retained, including adverse, invalid-scope and inconclusive observations. There
are 1,656 joined normal measurement sessions across all retained normal studies.
The evidence archive contains 21,979 manifested files and exports from 27
task-local catalogs; its integrity and every file hash were checked.

The universal requested 10x target is not achieved. Serialized point reads,
world/entity operations, editing, conversion, streaming, lifecycle scopes and
many constant-time accessors have no new complete-operation speedup evidence.
The changes preserve the public API and serialized formats; the report makes
claims only for the measured runtime, inputs and operation definitions.
