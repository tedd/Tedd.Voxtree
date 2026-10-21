# P39 terminal validation: prerequisites supported

Original/integration branch: main; starting8def711. P39
hyp-fc98c25d5bb74f60a4380c3e70f2d013 passes its model, source, compiled semantics,
corpus and native-work gates. This establishes an algorithmic candidate for
timing, with no speedup, allocation, adoption or complete public-method10x claim.
Production remains f0772c8 / NuGet2.0.28.

On exact unpromoted P31, one ValidateCube branch handles level1 with originLOD0.
Four exactly bounded UInt32 little-endian row reads replace repeated validation
of its eight scalar leaves. The OR mask0xE000E000 proves that every LOD field is
zero; XOR against the repeated origin word requires at least one differing raw
value. The latter preserves canonical rejection of a redundant uniform cube.
Uniform/coarser/invalid-origin paths, writer/selection/format, point reads and
all other54 source files remain byte-identical. Removing the exact insertion
recovers the parent file. No unsafe load, vector/annotation or layout change is
introduced. P32–P38 are excluded.

Before source creation, the original independent model passes2,629,760 cases:
2,097,152 metadata assignments,128 equality partitions,466,944 complete
single-word states and65,536 fixed-seed vectors. This is a factored-domain proof,
not exhaustive enumeration of all possible eight-word tuples. Any nonzero LOD
field rejects independently of raw bits; with metadata zero only equality to
the origin matters. All37,440 aligned terminal cubes at sides8/16/32/64 map the
four row pairs to exactly the old eight leaves within the exact-length payload.
Maximum byte end524,288 is within Int32. Model source/protocol hashes and the
unaltered original producer are retained.

The compiled P31/P39 inventories contain1,236 library IL bodies. Exactly one
resolved body changes: CompactLeafEncoding<T>.ValidateCube. All1,235 others,
implementation flags and the47-type exported public surface match. The initial
protocol inherited the published-source1,203 count; a pre-inventory coverage
addendum corrected that reference without altering the original protocol/hash
or excluding methods. It is retained in the private catalog and archive. Both
input binaries and the original self-tested decoder are hash-bound.

The complete regression producer passes417/418/419 tests on .NET8/10/11;
netstandard2.1 builds. Existing compact-format writer/selection/fallback and
independent-byte tests remain included. New compiled tests exercise all128
terminal equality partitions, every child/invalid LOD, extreme raw values,
coarse uniform leaves, redundant uniform leaves, boundary origins, truncated/
extra payloads and misaligned bounded spans. They compare public validation and
FromEncoded outcomes with original P31, using separately compiled Parent source;
published Snapshot source remains the independent writer/semantic reference.
The test rig gains an optional task-local additional source directory; existing
default behavior is unchanged. Exact original test modules and dependencies are
preserved without rebuilds or reruns.

The full immutable Forcecraft corpus passes all1,286 chunks/42,139,648 cells,
including686 unique arrays and duplicates. Every value, natural LOD, public
validation, FromEncoded result, copy, lookup, count/Any and representable-word
byte oracle is checked against released-source semantics. An exact P31 assembly
witness verifies complete output bytes in classicUInt32/genericUInt16/UInt32.
Every result row, selection decision and payload total matches the original P31
corpus. P39 changes neither encoded size nor the parent's payload tradeoff.
Input regions are read-only task-owned copies; the game and its stores are never
opened. Spatial contents do not establish request-frequency weights.

All96 complete-operation cases in the new version23 P31/candidate fixture pass
both arms. Separate exact-binary cycling validation diagnostics produce22
indexed Tier1/OSR listings, including complete validators and actual callers.
Normal runtime is CoreCLR10.0.13 x64, roll-forward disabled, with pinned
SDK11.0.100-rc.2.26504.105 and normal tiering/PGO. Shared legacy admission and
Global\Tedd.DotNetLab.Measurement.v1 cover model/build/tests/corpus/native work.
No timed controller or comparative sampling is started.

| Complete Tier1 validator | P31 native bytes / fixed rsp subtraction | P39 |
|---|---:|---:|
| UInt32 | 1307 / 168 | 1772 / 184 |
| UInt16 | 1307 / 168 | 1752 / 184 |

The JIT emits both a direct terminal region and another in a partially inlined
recursive child. Each region contains four checked dword payload loads, four
range checks, the metadata mask and four XOR comparisons, with no calls in that
specialized block. The direct success returns; the inlined success resumes its
enclosing validation loop. Rejection reaches a call-free false-result epilogue;
range-check failures retain the throwing fallback. Higher recursion and uniform
span-search paths remain.

Parent code already partially inlines recursion. Its direct level1 case retains
the eight-child leaf-validation/span-search work but need not issue eight native
recursive calls; other depths have different boundary costs. The qualified
mechanism is removal of repeated leaf-validation work, not a universal call-count
reduction. Native bodies grow445–465 bytes and reserve16 additional fixed rsp
bytes; these costs require timing/full-caller qualification. No instruction-
cache, spill, cycle, total-stack or latency conclusion follows from code size.

Two offline audit-index versions stopped before writing a prerequisite result:
the first expected one emitted terminal region; the second did not follow the
false block's fallthrough into its epilogue. Original auditor sources/failure
records are retained. The final index checks every emitted terminal region,
distinguishes stack-local reloads from payload reads, and follows rejection
edges. No candidate source, model, build, test, corpus or native producer was
replaced or rerun to repair those indexing limitations.

Phase31 preserves all original model/source/compiled/test/corpus/native evidence,
coverage correction, auditor failures, decoder and original binaries:
5,786,192 bytes,641 mapped paths,470 blobs,one catalog,zero comparative metric
rows; SHA256:
`ae33771d50d61a0f2324394e38a1bc17c810c3e744569b9e61de2b45e5179fbd`.
Every CRC, blob length/hash, mapping, catalog and required original path verifies.
The exporter also retains Python/PowerShell/protocol sources in model snapshots;
existing archives remain immutable.

Next, select/freeze a separate complete timing family before new observations.
It must cover public validation/FromEncoded/lookup-creation/lifecycle targets,
malformed/early-exit and uniform/coarse cases, steady-state point/LOD, writer/
copy/count/fallback/storage/allocation and realistic consumers. Bind the exact
selected source, controls, caller/PGO regime, work units, justified process
budgets and interval rules. A P31-local result cannot qualify original-release
or original-baseline10x claims. Retain P31's previous not_supported disposition,
all old adverse cases and allocation-model limitations; no ratio multiplication,
pooling, expanded old families or automatic source promotion.

Research is integrated directly into main; unrelated docs/articles is untouched.
No production library, package, remote branch, application, database or user world
is written. No temporary branch/worktree exists. The active task retains
D:\Workspaces\AI\voxtree-point-lod-20261020 for immutable samples and required
source/binary inputs; cleanup follows completion and verified shutdown.
