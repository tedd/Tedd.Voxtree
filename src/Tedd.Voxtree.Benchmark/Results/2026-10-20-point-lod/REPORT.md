# Point and stored-LOD investigation: first confirmation

Later layout, admission, control and packed-leaf evidence is retained in
[REPORT-PHASE3.md](REPORT-PHASE3.md). Complete corpus, fresh callers and bulk
consumers continue in [REPORT-PHASE4.md](REPORT-PHASE4.md). This report preserves
the earlier epoch.

Baseline: `f0772c8`. Integration branch: `main`. The active objective remains
10x for every public method; this investigation does not establish that result.
The selected implementation is pending precision and guard verification and is
not yet adopted by this research checkpoint.

## Established evidence

All 24 frozen confirmation plans completed: 576 distinct fresh process/start
identities, correct outputs, quiescent measurements, zero exit codes, and joined
exits. Baseline and treatment execute identical `AfterBatch` caller IL; the
baseline label is mapped to that caller outside the read loop. Runtime is x64
CoreCLR 10.0.13 with ordinary tiering/PGO and affinity mask 4 on a Ryzen 9 5950X.
Both shared performance-host mutexes cover the dependent windows. Frequency,
SMT-sibling activity and unrelated desktop work remain uncontrolled.

| Complete operation | Speedup estimate | Family-adjusted interval | Result |
|---|---:|---:|---|
| UInt32 owned Get, full 32³ compressed tree | 1.271x | 1.162–1.391x | Improved |
| Compiled Get, regular LOD-2 leaves | 2.191x | 1.628–2.947x | Improved |
| Compiled Get with LOD, regular LOD-2 leaves | 1.902x | 1.389–2.603x | Improved |
| Compile plus 65,536 reads, regular LOD-2 leaves | 2.314x | 1.553–3.447x | Improved |

The remaining twenty timing contrasts are inconclusive. In particular, unchanged
compiled full/sparse reads and generic long-token guards have wide intervals;
the data does not establish 5% equivalence. Early same-process namespace controls
also failed, so screening ratios are not adoption evidence. All observations,
including adverse outcomes, remain in measurements.csv and evidence.zip.

Most reads measure only a fraction of a millisecond. Retained sessions show
sporadic multi-fold wall-time excursions: one candidate LOD batch is 446 ns/read
among ordinary 50–60 ns/read batches. This establishes inadequate precision of
those guards, not a demonstrated cache, branch, CPU-frequency or scheduler cause.
A prospective longer-window epoch is required; do not append favorable samples
to these frozen plans. Automatic promotion can also remain unresolved for
zero-variance allocation models despite all observed point-read allocations
being zero. No family-wide guard pass or promotion is claimed.

## Candidate mechanisms

- P1 selects a validated one-byte token prefix with a bounded word read. It is
  retained for further verification only in the non-generic UInt32 path.
  The generic prefix variant was not selected after adverse long-token screens.
- P3a validates and skips unused generic values without constructing their
  integer accumulator. The inspected UInt128 skip body falls from 250 to 172
  Tier1 native bytes; its fixed stack reservation remains 40 bytes. Fresh timing
  for generic callers is inconclusive in this first epoch.
- P5a stores one UInt32 per leaf for a verified regular leaf depth, preserving
  its exact LOD. The LOD-2 32³ fixture uses 2,048 rather than 2,628 payload bytes
  (22.1% less). Existing fields encode the private layout, so object size does
  not increase. Mixed topology retains the node index; a perfect node count
  alone is insufficient. Source snapshots remain independently owned.
- P4 computes a Morton key once rather than three coordinate shifts per level.
  It did not establish a consistent benefit and is not selected. Its filter
  froze thirteen scenarios, including the GetLod alias, rather than the twelve
  initially intended; all thirteen were executed and retained. The first source
  shape assertion failed before build/timing and is retained as a setup failure.

The grid GetUnchecked body grows from 374 to 421 Tier1 native bytes in the
diagnostic epoch; both reserve 56 stack bytes. Static code size and stack
reservations are not total stack usage or causal elapsed-time fractions.
DotNetLab CPU sampling includes priming and waiting and supplies no PMU cache,
branch-miss or cycle attribution. Target-only JIT listings bind exact binaries.

The RTree research supplied useful controls: actual callers and consumers must
match; default-tiering guards matter; lower instruction counts, larger SIMD
widths and smaller FullOpts bodies do not independently establish a gain.
No Rust-parity claim is inherited by these voxel methods.

## Correctness and scope

The selected source passed 400 .NET 10, 401 .NET 11 and 399 .NET 8 framework
tests; the .NET 10 suite also passed with hardware intrinsics disabled. Public
reflection inventories match. All 51 version-2 fixtures validate values and
stored LODs against dense and aligned-cube oracles, including complete compile/
read lifecycles. Malformed-path probes agree with baseline for 16,384 UInt32,
16,384 UInt64 and 16,384 UInt128 cases per checked build. New unit tests cover
canonical/overflow token prefixes, later siblings, borrowed mutation, exact
leaf depths, coincidental perfect node counts and snapshot ownership.

The user permits memory and serialized format changes. The current grid
experiment changes private memory representation; serialized bytes remain
compatible. Other API families retain the earlier investigation's coverage
limits and remain within the active 10x objective.

## Reproduction and next gate

The committed drivers and generated `.cs.txt` fixtures are reproduction inputs;
the archive preserves actual historical copies, binaries, plans, requests,
accepted operation IDs, sessions, catalog exports and native code. Two setup
errors preceded confirmation (scenario-list variable collision and equal arm
labels); no timing sessions were launched for those rejected requests. Their
logs and failed requests remain available.

Next: freeze longer timed batches and adequate priming in a new identity epoch,
validate unchanged-source precision controls, and establish the mandatory
regression guards before incremental implementation commits. Broader layout and
format experiments remain in scope for pursuing the full public-method target.

## Precision and real-world follow-up

The longer-window unchanged-source control completed all six cases and 144
fresh, distinct process/start identities. Every session was correct,
quiescent, allocation-free on the measured thread, and exited successfully.
None established 5% timing equivalence. The first confirmation's four benefits
therefore do not qualify the unverified regression guards; no implementation
promotion is made. C1's four-process wall/thread/process-clock diagnostic found
substantial CPU-time variation even at High priority. Its 64 blocks were
correct with zero GC deltas. Preemption alone does not explain the variance;
frequency, SMT interference and code/layout effects remain hypotheses.

The user's Forcecraft samples resolved to
`D:/SourceCode/Tedd.Forcecraft10/data/Worlds`: six region files totaling
180,354,048 bytes. An existing writer handle prevented the first strict scan;
the retained S1 copies have matching source-before/source-after/copy hashes.
The snapshot is stable per file, not atomic across the world. Offline readers
verified every record CRC and envelope without starting Forcecraft or modifying
its data. S2's independent palette reader agrees with the original Forcecraft
reader on all 686 palette records.

The 1,286 chunks include 600 empty and 686 nonuniform arrays (686 distinct voxel
arrays including the empty array). Of the nonuniform chunks, 681 contain values
above 255, three lie within 0..255 and two within 0..127; all have mixed LODs.
Maximum block ID is 4,514. No chunk qualifies for P6's byte-only encoding.
P6 remains an isolated prototype: its 51 point/lifecycle fixtures pass, while
five wire-assumption tests per runtime fail. Its complete compatibility gate
has not passed and it is not selected for this corpus.

`forcecraft-corpus.zip` retains the full census and four deterministically
selected raw samples. Version-5 fixtures validate all voxels and LODs for 32
UInt16/UInt32 owned/span scenarios. The eight dominant-stratum diagnostic
screens establish no broad performance qualification; their estimates include
adverse UInt32 results and remain distinct from adoption evidence.

P7 explores a mixed-LOD compiled lookup with four-bit palette indices and one
LOD nibble per 2³ cube, selected only within the old node-payload budget. It
changes no serialized bytes or public object fields. All 48 version-6 terrain
fixtures and 1,203 tests across .NET 8/10/11 pass. Six first boundary tests had
incorrectly expected compressed storage for dense-encoded inputs; their
failures are retained, and corrected fixtures assert their storage precondition.
The implementation is still isolated. Its default Tier1 GetUnchecked body grows
from 338 to 628 bytes for value-only reads, with fixed stack reservation rising
from 56 to 72 bytes. The inspected packed helper includes ReadOnlyMemory span
dispatch and bounds checks; smaller source-level dependency depth does not
establish a proportional speedup. All 16 compiled timing/lifecycle contrasts
must complete before selection. Fresh confirmation and synthetic guards remain
pending. The full public API inventory retains 47 exported types, 699 declared
methods including accessors and 41 constructors; the 10x objective is unmet.

P7's first screen ended before the complete family: its first two point
contrasts reported descriptive 1.504x/1.224x speedups, then the 4,096-constructor
batch plan exceeded 120 seconds and tainted the target for unestablished
quiescence. Fourteen partial constructor observations remain in the catalog;
the last complete pair was approximately 219/589 microseconds per constructor
(baseline/treatment), exposing a substantial construction penalty. Both owned
processes subsequently exited. No tainted target is resumed, no remaining case
is treated as complete, and no partial-plan gain is promoted. A separately
declared bounded-lifecycle epoch is required to complete the whole family.

The separate `evidence-phase2.zip` preserves 8,275 files, ten read-only catalog
exports and 222 metric rows, including incomplete/tainted P7 records. SHA-256:
`c7522e931b9bab8097cf957c5ce16dfe1c430d69550de68d90b18131ef862124`.
The four raw C1 JSONL files are also retained in `clock-observations/`.
The original `evidence.zip` and its 194-row measurement snapshot remain intact.
