# P31: compact single-word leaf format, conditional on K2

Prepared before implementation. Require terminal original P30 evidence and a
supported K2 representation/payload projection before registering this source
experiment. Integration branch main; production remains f0772c8. Parent is the
complete P30 plan-reuse source, excluding P29's rejected direct-return changes.
P30's exploratory source alone is not promoted by choosing it as a new control.

Registry M05/M17/A09/A12. P24 established single-word direct-release point time
benefit with excessive broad expansion; P27 reduced combined payload but added
an indexed table load. Test a fixed two-byte word for the narrow real-world
range rather than a cache or separate expanded owned representation. No public
type/ownership/field changes, deferred first-read work or cross-call input cache.

Wire design: distinct R magic0x52, version3, packed kind3. Header2 classicUInt32;
header3 generic with the original logical size code1 UInt16 or2 UInt32. Payload
is N little-endian UInt16 words in linear XYZ order: raw value in low13 bits,
canonical stored-leaf LOD in high3 bits. Depth3..6 only, raw value0..8191 and
LOD0..6; all-one word has invalid LOD7. Exact length=header+2*N, within unchanged
GetMaximumSize for both logical widths. No new public raw-value restriction:
values outside this compact range retain exact published O/v1/v2 encoding.

Retain original Q's selection model (old tree storage, <=256 joint states and
the conceptual Q size <=1.25 old bytes), then require every raw value<=8191 and
the actual R length<=2.5 old bytes. The conceptual state table is a selection
heuristic, not an R payload. TrySelect can use its existing bounded state keys;
the direct R writer needs no second collection, sort or index table. Its uniform-
cube draw fills packed words. Reuse P30's planned write core so exact sizes,
destination tails, short-buffer outcomes and failed-prefix semantics remain.

Q and P were unpublished prototypes. This candidate replaces their packed
representation and rejects those magics rather than adding a polymorphic Q/R
hot reader. Preserve all actually published O/v1/v2 readers. Keep their existing
uniform/dense/tree LOD semantics and exact fallback bytes. Update the prototype
format constant/documentation to R; do not present Q rejection as published-file
compatibility. K2's corpus projection is unchanged because all selected actual
corpus maxima fit13 bits. Higher synthetic values explicitly test legacy fallback.

Implement every required consumer: checked point/value-with-LOD, lookup and owned
sharing, full canonical validation, empty, dense/Morton copy, counts/any/query/
nearest/clipping. Get should use one indexed payload word load, checked LOD and
the raw-bit mask, preserving exception/output/coordinate order and atomic snapshot.
Standalone borrowed views retain checked reads and after-creation mutation tests.
Never substitute an unchecked data-derived read or truncate a high input value.

Use format-appropriate bulk operations prospectively: compact-word counts resolve
mask/expected/negation once, validate visited LOD fields and count raw low bits.
Long rows may reuse the existing masked-search/vector strategy; preserve safe
tails and scalar/HW-off behavior. Any keeps its original early-exit semantics.
Copy decodes the word mask directly; all other query ordering/ties/clipping remain
under their original contracts. This is one complete new-format/consumer design,
not an isolated attribution of its benefit to one instruction or vector width.

Before timing: register hypothesis; full source/compiled-snapshot review. Independent
dense-to-word byte oracle, raw8191/8192 boundaries, full UInt16/UInt32/float/struct
fallback bits, depth3/6 and fallback depths, Morton/linear, exact/short/oversized
capacities, malformed magic/version/width/length/LOD, canonical partitions and
mutated borrowed data. Retain original semantic loops when adapting only wire/
private-storage assertions. Full .NET8/10/11 and .NET10 HW-off suites. Recheck all
1286 chunks/42139648 cells with f0772c8 semantic/fallback controls, P30 eligibility
witness and exact K2 projected sizes/actual lookup sharing. No world/app writes.

Freeze new fixture versions and input metadata before observation; no pooling
with Q epochs. First screen all48 point/compiled/create/lifecycle cases,12 paired
blocks/four warmups, bounded-lifecycle counts, seed20261103, family48. Require all
eight dominant owned/span UInt16/UInt32 Get/LOD speedup estimates>=1.20 versus P30;
all40 other time guards<=1.05 cost. Then a separately frozen full96 version14-
derived complete-operation family, including seven/seventeen-cell clipped count/
miss cases;12 pairs/four warmups, bounded-consumer counts, seed20261104, family96.
Require the existing1.05 time guards; report every cost and allocation observation.

Allocation/payload policy is prospective for this changed representation: selected
encoded bytes and constructor/build/fromencoded thread allocation may grow up to
2.5 times release; complete encoded-plus-distinct-lookup corpus payload must not
exceed release, and all observed steady point reads must allocate zero bytes.
Report constructor, encoded, lifecycle and combined costs separately. This policy
does not waive or revise old failed models or infer variance-based equivalence
from all-zero observations. Validate the allocation/accounting guard independently
of time inference and retain any unavailable/degenerate model quality flags.

.NET10.0.13 x64, ordinary tiering/PGO, affinity4, three-second primes, quiet profile,
120s/case. Native diagnostics precede quiet runs: actual owned/span Get/LOD callers
for both widths plus builder/count/validation. Retain tiers/OSR, code size, fixed
frames and actual load/call sites. No PMU, causal-share, total-stack or exact quiet
code-identity claim. Hold shared host admission; controllers own the central mutex.
Full fixed budgets, no extra samples/replacements/resumed families/source changes.

Passing exploratory point estimates are supported-awaiting-confirmation only for
that endpoint; unresolved mandatory guards remain inconclusive for adoption. Fresh
independent direct-f0772c8 normal-build confirmation must show all eight10x time
primaries with the original adjusted bounds, identical resolved caller IL, correct/
quiescent/joined sessions, and qualified construction/query/fallback/memory/API
guards. Do not multiply source-epoch ratios or label the full public API complete
from this read subset. No production source/package promotion from either screen.
