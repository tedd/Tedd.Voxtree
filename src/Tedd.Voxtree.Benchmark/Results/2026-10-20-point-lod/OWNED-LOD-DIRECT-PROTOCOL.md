# P28: direct owned LOD getter, prospective isolated boundary test

Parent: complete P27 byte-palette-source. Control is that exact source in
Snapshot.Voxtree; treatment changes only Octree.Get(x,y,z,out lodLevel) and its
generic counterpart. No encoder, wire byte, table, reader, span, lookup, query,
type constraint or public signature changes. Production remains f0772c8.

Mechanism C18/A11: eliminate the intermediate trusted span and expose the
existing checked codec call to the caller through a small explicitly inlined
owned method. P27's separate diagnostic Tier1 callers retain AsSpan and span
Get calls. Their complete multi-operation bodies do not establish a causal
time fraction, hot-branch count, PMU event or exact quiet-code identity. P16's
earlier broad inlining experiment failed; this experiment changes the boundary
and single-snapshot implementation rather than applying hints to old bodies.
RTree's disassembly study also separates actual library changes from consumer
changes; the point fixture and checksum remain byte-identical here.

Invariants: one Volatile.Read of the published array; unbuilt check precedes
out-LOD initialization and coordinates; same exception type/message and caller
out value on unbuilt failure; built failure initializes LOD to zero before x,
y,z checks in that order; same checked storage dispatch and malformed failure;
value/LOD come from one captured array during concurrent Build. No unchecked
data-dependent read is introduced. Wire and selection source remain exact P27.

Prerequisites: P27 original fixed families terminate and close without replacing
or resuming observations. Register this hypothesis before creating P28. Review
the complete source delta and match compiled snapshots. Run original suites and
palette tests on .NET8/10/11 plus .NET10 intrinsics-off, with additional owned
failure-state and generic publication tests. Validate all48 version15 point
scenarios against full dense value/natural-LOD oracles before measurement.

Exploratory budget: all48 unchanged version15 Scenarios-byte-palette cases,
twelve paired same-process blocks, four warmups; bounded-lifecycle counts256
create,16 lifecycle(each65536 reads),33554432 compiled/uniform reads and2097152
other reads; seed20261031, family48 time contrasts, quiet-validation,120s/case,
.NET10.0.13 x64, ordinary tiering/PGO, affinity4 and three-second primes. Freeze
all plans before first observation. Two primary dominant owned-LOD cases
(UInt16/UInt32) must each improve at least10% over complete P27. Every other46
case retains candidate/control cost<=1.05 as guard; report all allocations.
No source change, favorable extra samples, changed thresholds or pooled older
data. Stop on failed/tainted execution and inspect original state; no automatic
replacement. Same-process namespace effects are exploratory, not independence.

Before timing, collect matched owned LOD native diagnostics for both widths in
the selected P28 bundle. Preserve actual branch/call bodies, complete/incomplete
tier listings, code size and fixed stack reservations separately from timing.
Hold the shared Windows host admission across preparation and dependent windows;
DotNetLab controllers own Global\Tedd.DotNetLab.Measurement.v1 during timed runs.

Any primary failure is not_supported. A primary pass with unresolved guards is
inconclusive for adoption. Direct-release fresh normal-build confirmation is
still required before claiming10x; never multiply P27 and P28 ratios. Full
construction/query/fallback/memory/allocation guards and the broader public API
goal remain open. This protocol authorizes no prototype promotion by itself.
