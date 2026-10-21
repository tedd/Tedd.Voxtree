# Packed count specialization and vector predicates

Integration branch: main; starting research commit 31c390d. Production library
source remains f0772c8. No prototype is adopted. The full public-method objective
remains active; these experiments address packed CountMatches and its guards.

## P19: remove general per-voxel dispatch

The isolated fork changes only two query source files. Count mode selects a
dedicated scalar loop, retaining TryGet word bounds/LOD validation and the
original predicate/iteration order. Other modes and all encoded bytes remain
unchanged. Actual Tier1 CountPacked bodies are scalar: 340 UInt32 / 387 UInt16
bytes, fixed rsp subtraction 40/56, and no hot State.Accept call.

All 48 point and 88 bulk oracles passed. Framework tests passed 408/409/410 on
.NET 8/10/11. The complete frozen 88-case family produced 2,112 correct,
quiescent run records, with target/controller joined. Same-process blocks are
non-independent and do not qualify adoption.

| Dominant complete caller | P19 speedup vs P18 |
|---|---:|
| UInt32 CountMatches zero | 3.375 |
| UInt16 CountMatches zero | 0.824 |
| UInt32 CountMatches miss | 3.602 |
| UInt16 CountMatches miss | 0.911 |

P19 fails its frozen four-case primary. The registry records not_supported;
removing calls and shrinking code did not produce a universal benefit. All
unchanged-format/noncount adverse estimates remain in the complete audit.

## P20: validate word ranges and count value bits in bulk

P20 uses P19 as control. It changes only the two query and two filter files,
with no new fields, encoder or ownership changes. On little-endian .NET 10+
with vector hardware support, count validates queried packed-word LOD ranges
and reuses MaskedVoxelSearch over value bits. Predicate shortcuts still follow
validation. Full Y/Z coverage uses a contiguous interval; other rows need at
least sixteen Z elements. Short/older/nonaccelerated paths retain scalar logic.

Framework tests passed 412/413/414, plus all 413 .NET 10 tests with intrinsics
disabled. Tests cover filter modes, both header alignments, vector boundaries,
clipping and malformed LODs at vector start/end/tail and outside the query.
All 48 point and 96 bulk oracles passed. The full immutable 1,286-chunk census
again checked all 42,139,648 cells and bulk values against f0772c8. Eligibility
and payload exactly match P18's census; the prior 46.5% combined UInt32 payload
increase is not removed by this count optimization.

The complete version-14 96-case family produced 2,304 correct/quiescent records
and joined shutdown. All ratios below are exploratory, against P19 in this new
epoch. They must not be multiplied by older ratios or presented as a direct
release-baseline confirmation.

| Dominant complete caller | UInt32 speedup | UInt16 speedup |
|---|---:|---:|
| Full CountMatches zero | 12.096 | 81.532 |
| Full CountMatches miss | 9.574 | 181.774 |
| Seven-element-row count | 0.305 | 0.491 |
| Seven-element-row miss | 0.307 | 0.439 |
| Seventeen-element-row count | 2.088 | 4.511 |
| Seventeen-element-row miss | 2.394 | 5.493 |

The full-count primary estimates exceed the frozen twofold target, but short-row
guards are adverse. P20 remains inconclusive and unselected for adoption.
Existing sparse/empty and all noncount results are retained, including losses.

## Code evidence and the next boundary

Exact selected-bundle masked-count Tier1 bodies are 312 UInt32 / 354 UInt16
bytes. Both emit packed comparisons/masks and population counts; the UInt16
listing also contains lane rearrangement for logical-word mask extraction.
The existing helper's bounded vector body and scalar tail are reused.

A separate native-only full-then-short probe validates both widths and variants
without exporting new timing comparisons. Its matched P19 scalar bodies are
316/391 bytes with fixed subtraction 40/56. P20 dispatchers expand to 1647/1468
bytes and 136/152. This supports testing a vector-helper boundary; it does not
prove front-end stalls, total stack use, exact quiet JIT identity or a causal
elapsed fraction. Different native-probe histories remain separate.

P21 adds NoInlining only to the two CountPackedVector helpers. A metadata audit
matches both resolved executable bodies; raw metadata-token IL hashes differ.
Implementation flags change IL to NoInlining. The complete source review
matches selected snapshots and contains only the two attribute additions.

Framework tests passed 412/413/414, plus 413 .NET 10 intrinsics-off tests and
all 48 point/96 bulk oracles. The frozen 96-case family completed 2,304 correct,
quiescent records with joined target/controller shutdown.

| Dominant complete caller | P21 / P20 speedup, UInt32 | UInt16 |
|---|---:|---:|
| Full count | 1.027 | 1.088 |
| Full miss | 0.867 | 0.952 |
| Seven-element-row count | 1.975 | 2.217 |
| Seven-element-row miss | 2.166 | 2.153 |
| Seventeen-element-row count | 1.174 | 1.018 |
| Seventeen-element-row miss | 1.018 | 1.121 |

The short-row primary estimates pass, but full-miss estimates do not establish
the required guard. The registry remains inconclusive; no source is adopted.
Actual dispatcher bodies shrink to 405/402 bytes with fixed subtraction 40/56.
Separate vector helpers are 1166/870 bytes, each reserving 72 bytes. This code
boundary improves the screened short path without qualifying a universal win.

## Next builder investigation

A native-only required-size/caller-build probe uses unchanged builder code,
with no timing comparison. Actual linear-subtree bodies are Tier0-FullOpts:
895 UInt32 / 885 UInt16 bytes. Their listings subtract 152/136 for the frame
and a further 96/64 at the summary stack allocation. They retain recursive
subtree and varint/value writer calls. UInt32 WriteVarUInt is 140 Tier1 bytes;
UInt16 WriteValue is 205. WriteByte is inlined, so an imagined per-byte call
overhead is not a supported explanation. These are not dynamic cost shares or
total recursive stack bounds.

A separate future leaf-level specialization can test removal of eight level-zero
summary calls and scratch work while preserving exact wire order and uniform
collapse. Measurement-only sizing is another distinct intervention. Neither is
implemented or claimed faster by this checkpoint.

## Retained limits

The original P18 normal confirmation remains failed after six complete cases,
22 retained sessions in the seventh, and an uncompleted later launch. No session
was replaced or resumed. A read-only Windows Application-event query for its
original UTC minute was available; its sole runtime event belonged to another
PID and did not bind to retained sessions or task text. It does not localize
the original cause. Fresh source confirmation remains a separate gate.

Same-process timing and zero observed thread allocation are not fresh guard
qualification. New format constants/discrimination, construction/query/fallback
guards and the broader API catalogue remain incomplete. Task sources, immutable
regions and closed catalogs remain under D:\Workspaces\AI\voxtree-point-lod-20261020
while optimization continues; no worktree or alternate branch was created.

The closed phase-five archive retains 33,550 logical paths as 27,530 unique
blobs, 34 catalog exports and 874 cumulative metric rows. Every mapping, length,
SHA-256, ZIP CRC and catalog table passed verification. Its SHA-256 is
eff69d284486a89b33757cfdf93dabc567ff181a9955d9dd1adf5af1c3a862b5;
the archive is 59,439,618 bytes. Verification and required-record checks are
retained in evidence-phase5-verified.json. Cumulative rows are not independent
experiments.
