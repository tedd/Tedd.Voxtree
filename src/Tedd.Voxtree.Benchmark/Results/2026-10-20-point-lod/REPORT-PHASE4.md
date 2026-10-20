# Complete corpus and fresh point callers

Integration branch: main. Research checkpoint 565e11b retains the preceding
experiments. No packed-format implementation is adopted into library source.
The public-method objective remains active; the released control here is
f0772c8 (2.0.28), not the original project revision.

## Complete immutable corpus

The full s1 snapshot contains six verified region files, 1,286 block chunks,
686 distinct dense arrays and 42,139,648 represented cells. The new offline
census checked every chunk and cell without excluding duplicates. It passed
on x64 .NET 10.0.13 with complete P18 source in the primary namespace and
f0772c8 in Snapshot. The independent dense partition oracle agrees with all
three released/candidate types: legacy UInt32, generic UInt16 and generic
UInt32. Owned/span value/LOD reads, compiled UInt32 lookup, FromEncoded, full
validation, dense copies and CountMatches/Any cases all passed.

| Payload over every chunk | Released bytes | Candidate bytes |
|---|---:|---:|
| Legacy UInt32 encoding | 13,693,396 | 68,784,288 |
| Generic UInt16 encoding | 13,694,682 | 37,977,158 |
| Generic UInt32 encoding | 13,694,682 | 68,785,574 |
| UInt32 encoding plus distinct lookup payload | 48,861,892 | 71,567,508 |

Packed eligibility is 517 chunks for either UInt32 API and 574 for UInt16.
The width-specific density threshold admits more narrow trees, while four
UInt32-eligible chunks exceed the UInt16 reserved-bit limit. Maximum block ID
is 4514. Every ineligible representation retained identical bytes. Owned
packed lookups share their encoded arrays; the last row counts shared storage
once. Combined payload increases approximately 46.5%. These counts exclude
object/array headers and GC overhead and do not establish process retention,
allocation cost, access frequency or corpus-wide speedup.

The first census attempt incorrectly treated the p18 bundle's Snapshot (P17)
as f0772c8. It stopped at eligibility after eleven chunks, with the preceding
semantic checks passing. The failed log, partial rows and disposition remain
retained. A separate p18census bundle correctly binds released source; the
original attempt was not overwritten or relabeled as a candidate failure.

## Fresh point family

PACKED-POINT-CONFIRMATION.md freezes eight complete reads over the dominant
mixed-u16-air sample. Both builds use primary-namespace AfterBatch callers;
all eight resolved bodies match and five raw metadata-token hashes match.
Dependencies, runtime settings and fixture match. The full selected treatment
includes P15 storage, P17 dispatch and P18 private helper hints; its control is
f0772c8. Ratios from preceding individual interventions are never multiplied.

Six cases completed their original 24-session budgets. All 144 sessions were
correct, quiescent and joined; measured-thread allocation was zero. The table
uses the original fixed sixteen-objective family, with adjusted difference
interval coverage 0.996875. Speedup is released/candidate elapsed time.

| Complete public read | Speedup | Adjusted interval |
|---|---:|---:|
| UInt16 owned value | 15.91 | 12.53..20.21 |
| UInt16 owned LOD | 12.42 | 6.63..23.27 |
| UInt16 borrowed value | 20.39 | 14.27..29.16 |
| UInt16 borrowed LOD | 14.06 | 12.69..15.57 |
| UInt32 owned value | 14.63 | 12.17..17.58 |
| UInt32 owned LOD | 11.84 | 10.53..13.32 |

Five complete cases have lower speedup bounds above ten under the declared
paired-independence assumptions. The complete family did not finish. UInt32
borrowed value failed as op-eda90bea36b04b04bfd40548c9ad1cf5, execution
op-eda90bea36b04b04bfd40548c9ad1cf5-confirmation, after 22 retained sessions.
All 22 passed the same correctness/quiescence/shutdown checks. A later launch,
normal-session-36134eb98af6433e97b07f40d09e32f5 (PID 6636, start ticks
639281322744341251), has a launch record but no completed session record;
its process was verified absent. The generic confirmation_failed record does
not localize the cause. Controller 131664 exited with code zero. No replacement,
resume, partial-case comparison or final UInt32 borrowed-LOD run was performed.

The audit retains all 166 completed-session records, the failed execution and
unexecuted case. Allocation models remain unresolved due to degenerate variance;
zero observed bytes are not relabeled as statistical equivalence. Time estimates
cannot waive C3 precision or fallback/build/bulk/query guards. The four strata
and repeated random point set are not an observed game access trace.

## Complete-operation screen

BULK-CONSUMER-PROTOCOL.md freezes 88 cases over both widths and all four
retained samples. It includes original construction/Build, caller-buffer
Build/TryBuild, exact sizing, FromEncoded, copy, structural validation, count/
miss and original construction plus 65,536 sequential value/LOD reads. The
screen completed all 88 cases and 2,112 correct/quiescent run records in one
process; target and controller exited normally. It charges original encoding
and retains every adverse result. Same-process blocks remain exploratory;
latency does not establish an allocation guard. Dominant-sample ratios follow.

| Complete operation | UInt32 speedup | UInt16 speedup |
|---|---:|---:|
| Owned construction plus first Get | 1.340 | 1.048 |
| Owned Build plus first Get | 1.104 | 1.175 |
| Caller-buffer Build | 0.498 | 0.527 |
| Caller-buffer TryBuild | 0.574 | 0.524 |
| GetRequiredSize | 1.014 | 1.029 |
| FromEncoded plus first Get | 0.689 | 0.861 |
| CopyTo | 1.736 | 2.201 |
| IsWellFormed | 0.690 | 0.913 |
| CountMatches zero | 0.356 | 0.450 |
| CountMatches miss | 0.294 | 0.433 |
| Construction plus 65,536 value/LOD reads | 4.617 | 7.206 |

Below one is an adverse estimate. All sparse and empty observations remain in
the complete audit, including adverse estimates on unchanged formats. These
results do not qualify a universal implementation. The build/read workload
is sequential across the full volume, whereas point confirmation repeats a
random 1,024-point set. Caller/JIT history also differs; do not attribute the
entire ratio difference solely to encoding or splice the epochs.

Median measured-thread allocation per dominant owned construction was 27,608
bytes for either released API, versus 131,136 UInt32 or 65,600 UInt16 candidate
bytes. Owned Build was 27,576 versus 131,104/65,568. Caller builds, sizing,
copy, validation and count recorded zero thread allocation in their measured
batches. These are observed counters, not passed inferential allocation guards
or complete retained/process-memory measurements.

The RTree work supplies the relevant distinction: matched complete callers,
source boundaries and ordinary PGO require their own validation; fewer source
loads, smaller helper code and a faster consumer do not establish a library
win. Actual selected-binary caller diagnostics remain separate from quiet
timings. No Rust-parity claim is transferred to voxel methods.

## Selected-build x64 evidence

Four exact normal-build owned-LOD diagnostics and two CPU/JIT count cases
completed, followed by native-only count-body probes. Every owned process
joined with exit zero. The first selectors omitted the actual Packed/RunCore
methods; original listings remain retained. The corrected body2 probe uses
the identical p18bulk DLL and exports no added timing comparisons.

Complete non-OSR Packed Tier1 bodies are 514 UInt32 and 515 UInt16 native bytes,
each reserving 72 bytes with sub rsp. Their hot inner loops retain coordinate
index work, span bounds checks, LOD checks, per-voxel VoxelBox construction and
the call to general State.Accept. TryGet does not reparse the header: earlier
header-hoisting language was incorrect. The next experiment should specialize
counting and reduce general per-cell dispatch, with semantic guards intact.
CPU stacks include State.Accept and old compressed CountWhole/ReadNode paths,
but also priming, validation, waiting and runtime threads. Their shares do not
establish a complete-call causal fraction or hardware bottleneck.

Recorded full Tier1 owned-LOD caller bodies change from 3320 to 2764 bytes for
UInt16 (fixed subtraction 248 to 200) and 3002 to 3736 for UInt32 (248 to 216).
The faster UInt32 caller is larger; code size alone does not predict latency.
These bodies also retain other operation branches. Isolated diagnostic PGO
history differs from quiet sessions, so no exact timed-body identity is claimed.

native-summary-phase4-audited.json indexes all seven listings and supersedes
the initial indexes for availability claims. Missing or multiple size markers
are explicitly ambiguous/incomplete, not zero or a reliable method/call size.
In particular, an interleaved UInt32 OSR/Accept segment cannot support an Accept
size or ownership claim. Fixed subtractions are not total stack usage.

## Remaining gate

The frozen bulk budget is complete; the point budget remains failed/incomplete.
The readable source review verifies all f0772c8 control files and every selected
P18 file after explicit newline normalization, retaining raw hashes and the
original exact patch. Six library files differ, including the added helper.
Assess operation-specific tradeoffs and localize the confirmation failure.
Point-only success cannot establish a universal 10x implementation.
Format constants, wire discrimination, compatibility and the wider API catalogue
remain prerequisites for adoption. Task scratch remains necessary under
D:\Workspaces\AI\voxtree-point-lod-20261020; no temporary worktree was created.

## Evidence preservation

`evidence-phase4.zip` preserves 23,430 original paths as 18,629 unique content
blobs, including 28 complete read-only catalog exports. `manifest.json` maps
each original path to its blob, byte count and SHA-256. Identical bytes are
stored once; reconstruct paths using each entry's `blob` field. This archive
is 43,636,870 bytes, SHA-256
`da27ca826ca5e88640a22cc3bfda6c5a8978273766ce2a8f1278b59e0e49bddd`.
The companion CSV contains 594 cumulative metric rows, not 594 independent
experiments. Earlier immutable archives remain unchanged.

CRC, unique mappings, every blob byte count/hash, catalog tables and required
failure/source/diagnostic records passed verification after final worker
shutdown. Exact frozen point and original bulk protocols match their original
binding hashes. The bulk text is retained separately from later appended
diagnostic instructions. Raw failed executions, 22 partial sessions, the later
launch, all adverse results and both incomplete first diagnostic selectors are
preserved. All initial and corrected native indexes remain distinguishable.

No new NuGet package or implementation follows from this checkpoint. Production
library source remains at committed release behavior; only research is integrated.
