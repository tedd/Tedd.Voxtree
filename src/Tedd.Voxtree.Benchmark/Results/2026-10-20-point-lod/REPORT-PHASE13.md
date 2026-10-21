# Bounded byte-palette source and complete consumer screen

Integration branch main. Production library remains f0772c8; no prototype is
adopted and no new package is published. P27 implements the preceding J1 design
on complete P24, excluding rejected P25/P26 writer changes. All1286 chunks and
42139648 cells are retained, including duplicates and686 unique arrays.

Q/version3/kind3 stores a byte index per voxel followed by sorted full-value/LOD
states. UInt16 entries occupy4 bytes and UInt32 entries8; all raw value bits
remain available. Up to256 states are represented without a byte-count sentinel.
Eligibility requires released tree storage, depth3..6, the existing maximum
capacity and at most25% per-chunk encoding growth. That growth threshold is an
experimental policy. Legacy fallbacks retain exact released bytes; released
readers reject the new magic. Earlier unpublished prototypes are rejected.

The implementation uses bounded stack hash storage, canonical uniform-cube
collection and sorted IDs. It introduces no heap map. Selection precedes
caller-buffer writes so an exact selected-format destination can be smaller
than the legacy tree. Insufficient destinations retain failure/output behavior
and the legacy speculative prefix. Borrowed index mutation is checked before
table reads; unsigned invalid LOD fields, duplicate/unused states, unmerged
partitions and malformed headers are rejected by their applicable validators.

Initial .NET8/10/11 suites pass402/403/404, with403 .NET10 hardware-off tests.
All48 point and88 complete-operation oracles pass. The full corpus agrees with
independent dense value/natural-LOD oracles across classicUInt32, genericUInt16
and genericUInt32, every selected consumer and exact legacy fallback. Exact
J1 eligibility is132/142/132. Actual encoded payload is14371418/14419428/14372704
bytes. Classic encoding grows4.95% versus13693396 released bytes; encoding plus
distinct lookup payload falls17.47%, from48861892 to40325678 bytes. These are
actual payload sums, excluding CLR headers and GC retention, not access traces.

Both fixed exploratory families complete:48 point cases/1152 records and88
consumer cases/2112 records. Every record is correct and quiescent; original
targets, controllers and outer driver join/exit successfully. Both controls are
complete f0772c8. Plans precede observations, source stays frozen between the
families, and no older observations or failed-run replacements enter them.

| Dominant point operation | UInt32 speedup | UInt16 |
|---|---:|---:|
| Owned Get |9.954|12.666|
| Owned Get with LOD |8.287|11.730|
| Span Get |12.360|13.679|
| Span Get with LOD |12.043|14.767|

Two of eight primary estimates miss10x;14 of40 other point guards are adverse
under the frozen1.05 cost policy. Both arms observe zero thread allocation for
the eight primary read cases. These observations do not resolve degenerate
allocation equivalence or replace fresh independent normal-build confirmation.

| Dominant complete operation | UInt32 speedup | UInt16 |
|---|---:|---:|
| Constructor plus first Get |0.642|0.681|
| Caller-buffer Build |0.348|0.342|
| Caller-buffer TryBuild |0.330|0.336|
| Full count of zero |0.418|0.280|
| Full count miss |0.526|0.255|
| Constructor plus65536 value/LOD reads |3.680|5.152|

56 of88 consumer guards are adverse. Dominant constructor thread allocation
increases from27608 to33048/32944 bytes per UInt32/UInt16 operation. Caller-buffer
builds, counts and misses observe zero in both arms. Every allocation and timing
observation remains in the audit and raw catalog. The registered P27 hypothesis
is revised to not_supported. Smaller combined payload and faster sustained reads
do not qualify the complete candidate for adoption. Namespace/layout/PGO effects,
same-process dependence and unresolved host equivalence limit causal inference;
unchanged-source guards cannot automatically be attributed to the new algorithm.

Five separate native probes index53 optimized versions, including the builder.
Selected diagnostic Tier1 palette TryGet bodies are189/191 bytes forUInt32/
UInt16; TryReadState125/124, each with rsp subtraction40. The owned callers are
3876/2828 bytes with fixed subtractions216/200. These are code/frame observations,
not total recursive stack, a causal time share or exact quiet-run code identity.

P28's proposed direct owned LOD boundary fails its preimplementation code gate:
the valid palette LOD path already inlines AsSpan, span Get, dispatch and reader
for both widths. Remaining AsSpan/Get calls occur in other branches of the same
multi-operation caller. The SHA-bound branch audit identifies those sites and
the call-free palette fallthrough. No candidate source, registration or timing
is executed. The committed prospective protocol remains historical; its setup
driver refuses execution. Further point work must inspect the executed branch
rather than infer its calls from the whole method's call list.

Two additional owned contract tests subsequently pass with the complete palette
suite:404/405/406 tests on .NET8/10/11. They check unbuilt versus built out-LOD
state, coordinate precedence, and generic value/LOD snapshot publication.
This post-closure validation is separate from the frozen timing prerequisites;
its p27contracts log, three TRX files and source bindings remain task-local for
the next scoped preservation supplement. No timed source was changed.

The verified phase13 supplement contains4869 logical paths,4609 content blobs,
three catalog exports and136 new exploratory metric rows. Size8329563 bytes;
SHA-2567422449b511b453305509c7dda8e006c069168610164e1bb1515cc1cbfff58b7.
All CRCs, mappings, blob lengths/hashes, catalog tables and required paths pass.
The full release/control/selected-source diff matches both actual compiled
snapshots. Earlier immutable archives remain the parent reproduction chain.

All execution waits on the shared Windows host admission and central measurement
mutex. The task changes no shared installation, world data or production database.
The complete public-method10x goal remains active. The task workspace is retained
for immutable inputs and subsequent investigations; no alternate branch/worktree
was created. Unrelated docs/articles remains untouched.
