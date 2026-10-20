# Point and stored-LOD investigation: first confirmation

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
