# Bottom-up packed writer disposition

Integration branch: main. The production library still matches f0772c8;
neither P24 nor P25 is adopted. P24's separately confirmed eight-case point
primary remains supported, with unresolved allocation and broad adoption guards.
This phase tests one writer mechanism against complete P24, not the release.

P25 changes only PackedLeafEncoding.cs. Initialize destination words with raw
values and LOD zero, mark uniform parents from eight child anchors bottom-up,
then fill canonical leaves. No extra array, changed header, selection rule or
reader is introduced. Complete source review independently matches treatment
and control snapshots, including namespace and newline normalization; raw hashes
and the full one-file patch are retained.

The .NET 8/10/11 suites pass 406/407/408 tests, plus 407 with .NET 10 hardware
intrinsics disabled. All 48 point and 88 complete-operation oracles pass.
The exact P24 differential checks 378 cases, 16,178,022 cell comparisons and
2,788 capacities through depth six, including linear/Morton, all storage widths,
reserved-bit boundaries, short-buffer mutations and exact leaf LOD.
Two full immutable corpus passes check all 1,286 chunks and 42,139,648 cells:
one requires exact P24 bytes for all three APIs, the other independently checks
values, LOD, queries, lookup and old-reader rejection against f0772c8. Payload
and eligibility remain equal to P24/P18; the encoded-memory tradeoff persists.
The inherited CS0162 unreachable-code warning remains; no warning-free build
claim is made.

The prospectively frozen version-13 88-case screen completed 2,112 correct,
quiescent records in one process. Target and controller joined; the target
and parent driver exit zero. Twelve same-process pairs remain exploratory,
not independent confirmation. Every observation and adverse case is retained.

| Dominant complete operation | UInt32 speedup vs P24 | UInt16 |
|---|---:|---:|
| Constructor plus first Get | 1.182 | 1.102 |
| Caller-buffer Build | 0.996 | 1.070 |
| Caller-buffer TryBuild | 0.914 | 1.031 |

All six primary estimates fail the frozen twofold target. Twenty of the
remaining 82 cases are adverse under the original 1.05 cost policy; the
protocol's nominal 0.95 speedup cut identifies the same twenty here. Both
readings are preserved, without changing a threshold after data. Not every
adverse observation establishes a writer effect: several operations have
unchanged source, and this namespace/caller regime retains compilation and
environmental limitations. The hypothesis is not_supported. No result is
multiplied by P24 speedups, and no source or package is promoted.

The native-only writer probe exits zero and retains eight optimized versions,
including OSR. Final Tier1 WriteBottomUp bodies are 949/1019 UInt32/UInt16
bytes, each with a 72-byte rsp subtraction. FillMarked bodies are 1107/1304
bytes, with 152/168-byte subtractions and recursive calls. These are fixed
reservations, excluding pushes, outgoing arguments, callees and recursion;
they are not total stack bounds, quiet-run code identities, hardware counters
or measured elapsed fractions.

Two distinct future cuts follow from source and code, without selecting a
new candidate here: replace scalar initialization with bounded raw copying
for little-endian linear input, and stop split level-one fills because their
single-voxel children are already initialized. Keep endianness/Morton fallback,
extra-input slicing and exact output semantics. Each needs its own prospective
experiment; neither is claimed faster. Separately, the earlier joint-state
palette representation remains a possible way to reduce P24's payload growth;
whole-corpus state cardinality, wire discrimination and complete callers must
be investigated before implementation or a performance claim.

The phase-eleven supplement contains 3,735 logical paths, 3,500 unique blobs,
four catalog exports and 104 metric rows: 88 new exploratory time contrasts
and sixteen repeated P24 confirmation objectives. These are not 104 independent
experiments. Every blob hash/length, mapping, CRC, table and required record
passes verification. Archive size 7,402,357 bytes; SHA-256
25e5f3c892e0ba36940b205a22360ea875650ec9a9b03a4348162a0959b14e3f.
The archive also retains both P24 post-confirmation hypothesis revisions,
which follow the earlier phase-ten snapshot without changing its observations.
Phases nine and ten remain part of the reproduction chain.

The queued writer driver verified its used dependencies after admission.
Its oracle fixture's extra terminal blank line was preserved during execution
and normalized in the repository after joined shutdown; original fixture bytes
and hashes remain in the archive. No measurements were replaced for formatting.
The full public-method goal remains active. The task workspace is retained for
active immutable inputs and subsequent experiments; no worktree or branch was
created. Unrelated docs/articles is untouched. No additional NuGet release is
published from these prototypes.
