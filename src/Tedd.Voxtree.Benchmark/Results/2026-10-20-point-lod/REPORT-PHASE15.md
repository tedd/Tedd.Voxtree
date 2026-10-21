# Per-call build-plan reuse and compact-word projection

Integration branch main; starting commit 0a5038d, preparation commit 6b00f8f.
Production remains f0772c8/package 2.0.28. No source or package is promoted.
The previous turn completed P29; this phase addresses redundant construction
work and evaluates a separate layout candidate. The full public-method 10x
objective remains active.

P30 changes only OctreeCodec and GenericOctreeCodec on complete P27. Eligible
owned tree builds already have a validated BuildPlan, but TryBuild remeasures
it. A private planned write core reuses that plan; public caller-buffer TryBuild
retains its original ordered validation and planning. The planned write bodies
remain identical by hash. No input cache, selection, format, writer policy,
field, ownership or reader change is introduced. P29 is not combined.

The complete source review matches all point/bulk/corpus snapshots. Framework
tests pass 407/408/409 on .NET 8/10/11, with 408 hardware-off tests. All 48 point
and 88 complete-operation oracles pass. The differential writer oracle passes
378 cases, 16,178,022 cells and 2,832 capacities across all widths, levels 0..6,
Morton/linear and exact/short/oversized destinations, including failed-prefix
mutations. The full 1,286-chunk/42,139,648-cell census passes with independent
release value/LOD controls and an explicitly aliased exact P27 byte witness.
Encoded/lookup payload and eligibility remain unchanged.

The native prerequisite confirms both preselected u7/u8 fixtures use tree
storage for both widths: 1,222/1,223 and 49/50 bytes. The first derived audit
incorrectly expected an explicit control TryBuild call. Actual code inlines the
first planner and writer, retaining an additional external CreateBuildPlan call
in the control. The candidate removes that call; public caller-buffer paths
still plan. The original audit/script error is retained; only the derived audit
is corrected, without rerunning producers or adding timing observations.

| Matched final Tier1 method | Control bytes/frame | Candidate bytes/frame |
|---|---:|---:|
| UInt32 BuildOwned | 4,107 / 472 | 2,980 / 392 |
| UInt16 BuildOwned | 3,768 / 344 | 2,648 / 280 |

Separate candidate planned cores are 793/798 bytes with fixed rsp subtractions
152/136 for UInt32/UInt16. Twenty-one optimized versions are indexed. Fixed
reservations and source/call removal do not establish total recursive stack,
dynamic call counts, a causal time share, PMU behavior or exact quiet code.

All 88 exploratory cases/2,112 records complete correctly and quiescently;
target, controller and outer driver join/exit successfully. Plans precede data,
source stays frozen, and no old or replacement observations enter the family.
The eight >=1.20 speedup primaries all pass against complete P27:

| Complete operation | UInt32 speedup | UInt16 |
|---|---:|---:|
| u7 constructor plus first Get | 1.398 | 1.594 |
| u7 owned Build | 1.670 | 1.388 |
| u8 constructor plus first Get | 1.639 | 1.489 |
| u8 owned Build | 1.527 | 1.426 |

Median target-thread allocation remains identical: u7 constructor/build 1,280/
1,248 bytes and u8 constructor/build 112/80 bytes per operation in both widths.
Twenty-four of 80 other time guards are adverse under the frozen 1.05 rule.
Retain all, including the unchanged packed UInt32 constructor's 0.749 estimate.
Namespace/layout/PGO effects and same-process dependence prevent assigning all
guard differences to source work removal. P30 is inconclusive for adoption,
despite its passed primary. Fresh normal confirmation and broader guards remain;
no ratios are multiplied or direct-release 10x claim inferred.

K2 is a separate metadata-only projection, registered before evaluation. The
existing complete P27 corpus is hash-bound to the original source/assembly and
phase13 archive. A prospective UInt16 word uses 13 raw value bits and 3 LOD bits
for depths 3..6, retaining original eligibility and full-value fallback. All
selected actual maxima fit; the corpus maximum is 4,514. All existing maximum
capacities and prospective 2.5-per-selected-chunk growth bounds pass. The fixed
dominant region/slot/hash is retained and passes.

| Corpus encoded payload | Release | Actual Q | Compact-word projection |
|---|---:|---:|---:|
| Classic UInt32 | 13,693,396 | 14,371,418 | 18,659,626 |
| Generic UInt16 | 13,694,682 | 14,419,428 | 19,052,144 |
| Generic UInt32 | 13,694,682 | 14,372,704 | 18,660,912 |

Selection remains 132/142/132 chunks; maximum selected encoded growth is
2.481/2.491/2.481 times release. Classic encoding alone projects about 36.3%
growth. Assuming a future owned lookup shares the compact encoded words,
classic encoded-plus-distinct-lookup payload projects 44,613,886 bytes versus
48,861,892 released, an 8.69% reduction. This conditional combined result must
not be substituted for the larger standalone encoded footprint. Every chunk
and the separate 686-unique-array summary are retained.

K2 also verifies length-minus-header parity: Q is 2 modulo4; proposed words are
0 modulo4. It supports representation/conditional-payload feasibility only.
No encoding, decoder, allocation, compressed file size, access frequency or
latency result is produced. Actual sharing/correctness/native code and timing
remain mandatory. COMPACT-LEAF13-FORMAT-PROTOCOL records the next unexecuted
source study, using published O fallback and a distinct compact R magic.

The verified phase15 supplement contains 3,391 logical paths, 3,185 content
blobs, three catalog exports and 88 new exploratory metric rows. Size 6,524,640
bytes; SHA-256 ff0ea9f6783fb3bbab80e1f3a5d1ee9fe3623212199d6ea603e7679637ad0fc2.
Every CRC, mapping, blob length/hash, catalog table and required path passes.
Earlier immutable archives remain the parent reproduction chain.

All execution uses the shared Windows host/measurement admission. No world,
production database, shared installation or unrelated docs/articles changes.
No alternate branch/worktree was created. The active task workspace remains
retained for immutable inputs and subsequent work on the full objective.
