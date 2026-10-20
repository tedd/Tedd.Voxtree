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

P21 adds NoInlining only to the two CountPackedVector helpers, preserving
executable bodies, branches and format. Its frozen 96-case family tests at
least 20% lower short-row time while retaining full/17-row guards. Tests,
selected-binary code and complete timing results are pending in this checkpoint.

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
