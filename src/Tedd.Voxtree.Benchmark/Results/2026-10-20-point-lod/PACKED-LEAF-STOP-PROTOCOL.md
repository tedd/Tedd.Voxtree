# P26: stop the packed fill at initialized single-voxel leaves

The full public-method 10x goal remains unchanged. This is one component
experiment, not a narrower completion criterion. Parent/control is complete
P25, despite its rejected twofold constructor hypothesis; no P19..P23 source
is combined with this fork. P24 remains the selected point-reader prototype.

Registry A03/A09/M25/C18. P25's emitted FillMarked retains recursive calls,
1107/1304-byte final UInt32/UInt16 bodies, and fixed rsp subtractions 152/168.
Source initialization writes every raw value with LOD zero before marking.
A split level-one node therefore already contains its eight final LOD-zero
words. Return after the coarse-leaf branch when level==1, avoiding eight calls,
loads and repeated fills. Keep all other code unchanged, including scalar
initialization; raw copying is a separate unselected candidate. The RTree and
P22 leaf-specialization studies motivate this boundary, not a transferable gain.

Proof obligation: a level-one node that collapsed is filled by the existing
coarse-leaf branch. A noncollapsed node has eight level-zero children; the
bottom-up marker cannot have promoted any of them above zero. No output is
published during construction. Preserve exact bytes, canonical LOD, capacity
failure mutations, endian/Morton behavior, headers, readers, fallbacks and all
supported value widths. No new fields, arrays, caches, public API or unsafe load.

Prediction: each of the six dominant UInt16/UInt32 constructor+first-Get,
caller-buffer Build and TryBuild callers is at least 1.25x faster than P25.
Falsifier: any primary below 1.25, or semantic failure. Original regression
guard for every other caller: candidate/control cost <=1.05, equivalently
speedup >=1/1.05; retain all adverse observations. No attribution of elapsed
fraction, stack-depth bound, PMU behavior or useful speedup from static code.

Before timing: full .NET8/10/11 suite and .NET10 intrinsics-off; all 48 point
and 88 complete-operation oracles; exact P25 differential through depths0..6
with all storage widths, linear/Morton, boundaries, capacities and mutations.
Full 1286-chunk/42139648-cell offline census requires exact P25 bytes for
classic UInt32, generic UInt16 and generic UInt32 and validates complete reads,
LOD, copy, queries and lookup. P25's release census and P24's format tests are
retained parent evidence; exact P25 equality and unchanged reader source provide
the new transitive binding, without rerunning or replacing parent measurements.
Capture matched selected-bundle baseline/candidate FillMarked and builder x64
diagnostics separately from quiet timing; retain every tier/OSR version.

Freeze the existing version13 complete 88-case family before timing: twelve
same-process pairs, four warmups, original bounded-consumer operation counts
(16 construction/size/fromencoded,64 copy/validation/count/miss,2 buildread),
three-second primes, affinity4, ordinary tiering/PGO, .NET10.0.13 x64,
seed20261028, quiet-validation, 120 seconds per case, family88. All 2112 run
records must be correct/quiescent and target/controller joined. Same-process
data remain exploratory. Preserve allocations as observations, not inferred
equivalence. Stop on failure; no replacement, favorable extra sampling or
pooling. A primary pass with unresolved guards is inconclusive for adoption.

External phases hold the inspected shared Windows host admission; timed
controllers own Global\Tedd.DotNetLab.Measurement.v1. Only task-local sources,
catalogs, copied immutable regions and owned processes are used. No database
server, application, world, shared DotNetLab installation or production writes.
Freeze queued driver/dependency hashes. Commit evidence to original main.
No source/package promotion without direct release confirmation and the full
constructor/query/fallback/memory/API guards; never multiply separate ratios.
