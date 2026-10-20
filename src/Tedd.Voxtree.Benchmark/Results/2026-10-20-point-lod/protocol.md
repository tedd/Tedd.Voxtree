# Point and stored-LOD access investigation

Integration branch: `main`; baseline `f0772c851b6a50c3cf855b606f9d6fd29c89b56b`.
The pre-existing untracked `docs/articles/` directory is outside this task.
Scratch: `D:\Workspaces\AI\voxtree-point-lod-20261020`.

## Objective and constraints

Continue toward 10x per public operation, prioritizing .NET 10 steady-state
serialized point and stored-leaf LOD reads. Historical gains are not fresh
controls and will not be multiplied into new ratios. A universal 10x claim
requires evidence unavailable from a point-only study.

Use the DotNetLab guided process directly; no additional parent optimization
skill is installed in this session. All builds, validation, diagnostic and
dependent timing windows hold the RTree host mutex followed by the Voxtree
mutex. Use task-owned catalogs and controllers; do not change the shared
DotNetLab connection. Library, tests and the application-owned harness have no
database/service write path. Inspect every added driver before execution.

Preserve public signatures, encoded bytes, leaf LODs, ownership/publication,
coordinate exceptions, TryGet failure outputs, malformed/truncated/overlong/
overflow token rejection, generic raw bits (including NaNs), and portable
fallbacks. No unsafe code, implicit per-query cache, changed output consumer,
global JIT setting, or uncontrolled pre-expansion of compressed trees.

## Initial candidate registry

| ID | Registry cues | Prediction and falsifier | Guard / cost |
|---|---|---|---|
| P1 | A03, C03, C06, C18, M24 | Select one-byte token prefixes from a bounded word instead of decoding preceding siblings. Full and coarse low-cardinality reads should improve; no improvement falsifies useful adoption. | Retain scalar parser for long/invalid tokens; no overread, including borrowed buffers. |
| P2 | A03, C12, C14, V11 | Select a token boundary from a word of continuation flags, if validation can remain exact. More mixed-token benefit than P1. | Overflow/overlong validation is mandatory; reject if correctness or fallback cost is excessive. |
| P3 | C18, C09, R03, M25 | A smaller point traversal / value-only specialization reduces out-parameter spills and inlining pressure. | Inspect actual Tier1 caller; copying/inlining can grow code or lose PGO. |
| P4 | C11, C14, C20, M01 | Precompute a bounded traversal key or simplify coordinate/index arithmetic to shorten per-level dependencies. | Include shallow/sparse/dense controls; BMI2 requires dispatch and software fallback. |
| P5 | M01, M21, A04 | Compact compiled node representation or direct value access reduces dependent loads. | Preserve arbitrary UInt32 values and LOD, account construction, payload and lifecycle. No unbounded dense expansion. |

RTree reference findings: generated-code research distinguished library
traversal from consumer changes, rejected first SIMD interventions below their
frozen useful threshold, and recorded Tier1 code growth and default-tiering
regressions despite FullOpts wins. These motivate exact callers, default
tiering, code/stack inspection, and unchanged consumer controls here. Native
RTree rankings are hypotheses, not voxel performance evidence.

Parallel/GPU/NUMA/huge-page/prefetch candidates have no supporting point-read
mechanism at this scope; they remain not applicable until a measured clue
changes that assessment. Width-specific parsing and hardware paths require
actual code plus disabled-intrinsics correctness.

## Prospective initial experiment

CoreCLR x64 10.0.13, Release, ordinary tiering/PGO, workstation GC, no debugger,
logical CPU 2 (mask 4), one-second per-variant prime outside measurement.
Unrelated machine load, SMT-sibling work, temperature and frequency remain
uncontrolled. Samples and code do not establish PMU cache/branch/cycle facts.

Independent dense-value and aligned-cube LOD oracles validate source and both
implementations. Exact encoding parity and expected storage kind are asserted.
Read batches consume identical value/LOD checksums; variant dispatch is outside
the measured read loop. Inputs use deterministic coordinates with explicit
first/last points; random and sequential contrasts. Include compressed low
values, coarser leaves, long values, uniform and dense controls, owned/span and
compiled callers, generic storage-width contrasts and malformed tests.

Exploration: each frozen selected scenario gets 12 paired blocks, four warmup
batches, 16,384 reads/run (creation/lifecycle use their separately declared
operation counts), deterministic randomized order, seed 20261022, quiet profile.
Same-process blocks are dependent exploratory observations. All accepted
operations, failures and results are retained; no extra samples or favorable
run selection. A different source/fixture is a named new epoch.

Initial decision thresholds: useful time ratio <=0.95, regression >=1.05;
equivalence interval 0.95..1.05, family alpha 0.05, family size equals all
inferential scenario contrasts (allocation included during confirmation).
Correctness is mandatory; allocation must not increase. Unchanged controls
must be considered before selecting a mechanism. Diagnostic timing is separate.

Selected-source confirmation will be frozen before new data: distinct normal
builds with identical fixtures, matched dependencies/runtime, 12 pairs of fresh
joined processes, eight warmup batches, 65,536 reads per session, same one-second
prime and affinity, seed 20261023, time and allocation policies above. Retain
model intervals and failed/zero-variance guards without converting them to pass.
Full caller and create/read lifecycle checks are required for representation
changes. No individual-call percentile claims from batch averages.

## Current gate

Scope and retained-evidence review complete. Next: bind the new harness and
control identities, obtain baseline generated code, and test P1 independently.
Other public query, conversion, editing, neighbor, world and streaming families
retain the previous report's coverage limits; no inherited point-read gain.

### Control finding and confirmation refinement (before candidate timing)

The P0 unchanged-source namespace controls already show asymmetric caller/JIT
costs (first two exploratory ratios 1.176x and 0.793x). Preserve the full scheduled
41-case control study; do not repair it by excluding unfavorable observations.
The initial CPU capture is diagnostic, not a speedup estimate. Its Tier1 parser
reserves 56 stack bytes and saves eight registers (816/821 native bytes in the
two namespaces); it still checks/decodes preceding tokens. Sampling includes
harness waiting and priming, so no elapsed-time fraction is inferred.

Freeze normal-build confirmation with `candidate` as the executable variant
in BOTH builds. The baseline entry compiles f0772c8 in the ordinary Tedd.Voxtree
namespace; the treatment compiles the selected implementation there. Both
execute the same AfterBatch caller and consumer. Snapshot helpers remain
correctness/exploration controls only. This removes namespace/caller differences
from the normal-build contrast. Preserve the 12 fresh-pair budget and policies;
same-process candidate results remain screening evidence.

### P3a next intervention (before its results)

Generic skipped siblings currently call the full value parser, including a
128-bit value accumulator. Test a validation-only skip loop that checks the same
maximum width, final payload width, nonzero termination for multi-byte tokens,
and bounds without constructing the unused value. The primary contrast is
generic long-value point/LOD access; low-value and dense cases are guards.
The candidate is named P3a (`p2` build), with P1 as its source control, using
the complete six Wide and four Huge owned scenarios and two Wide span cases.
Same exploratory budget/policies apply. The final baseline remains f0772c8.

### Format authorization and P5a (before implementation/timing)

The user explicitly permits file or memory format changes. Preserve compatibility
unless an actual measured gain justifies a new serialized version. First test a
private compiled-grid layout for regular trees with one common leaf LOD >0.
An 8-ary node-count candidate is verified against every node's masks/depth before
compilation. Use one value per stored leaf, not one per original voxel. Reuse
existing object fields for the representation discriminator to avoid adding
allocation to unchanged constructors. Full-depth dense and uniform paths stay
separate; mixed leaf topology keeps the existing node index.

Add compiled coarse/long read contrasts and complete CreateLookup and
CreateLookup+65,536-read scenarios for full/coarse/sparse trees. The constructor
must remain correct; report its separate cost even if it trades work for reads.
For adoption require useful coarse-read and complete coarse-lifecycle benefit,
no payload or allocation increase for changed fixtures, and no >5% meaningful
regression in full/sparse compiled read/lifecycle guards. Constructor-only
regression <=25% is a prospectively accepted access-oriented tradeoff; any
larger result is not silently adopted. Same 12-pair confirmation budget applies.
This is P5a (`p3` build), isolated against P1+P3a (`p2`) source.

### Selected source and final freeze

Reject generic P1 for selection: multiple Wide long-token screening cases lose
cost while native-code growth and the fallback check remain. Same-process
controls prohibit interpreting those ratios as isolated causal effects; this
is a conservative source selection, not proof of a hardware cause. Keep P1 only
in the non-generic UInt32 reader. Keep P3a's validation-only generic skip and
P5a's exact regular-leaf grid for final verification.

The 128-bit skip Tier1 body falls from 250 to 172 bytes while retaining a
40-byte fixed reservation. Generic traversal still reserves 72 bytes; neither
fact proves a total stack reduction. Grid GetUnchecked grows 374 to 421 bytes
with the same 56-byte reservation in the inspected diagnostic epoch. Code
changes corroborate mechanisms; quiet fresh-build evidence remains decisive.

Fixture version 2 includes explicit lifecycle-read count in its input identity.
P0/P1/P2 version-1 results remain a separate screening epoch; do not pool them.
The p3 build was validation-only; p3b binds the final version-2 compiled screen.

Final source builds `n0` (f0772c8) and `n1` (selected source) compile the exact
same version-2 fixtures. Frozen `Final.ps1` enumerates 24 complete scenarios,
including serialized APIs and representation/long-token contrasts, constructor
and lifecycle, and unchanged full/sparse compiled, uniform and dense controls.
Execute all 24 selected-source exploratory plans, followed by all 24 independent
confirmation plans without source or policy changes or favorable selection.
All final normal sessions use the candidate variant and identical AfterBatch
caller; 12 pairs = 576 fresh joined sessions. Constructor regression policy is
1.25; other time policies remain 1.05. Preserve allocation outcomes and any
automatic-promotion limitations. If a mandatory timing guard fails, return to
source selection with a separately named source/confirmation epoch.

The first Final driver stopped before any timing plan submission: the added
selected-scenario parameter collided case-insensitively with a local variable.
ResumePrepared verifies every n0/n1 bundle hash and reuses those exact builds;
the corrected parameter name changes no executable fixture, source or budget.
The failed setup and original log are retained, not excluded timing data.

P4 closure study is separately frozen before observation: a task-local source
fork of n1 computes the existing Morton library key once (`Encode(z,y,x)`) and
selects one three-bit child group per level in the non-generic serialized
reader. It does not change n1 or its confirmation. Use all 12 Legacy owned
get/LOD storage contrasts (full/coarse/long/sparse/uniform/dense), with n1 as
control and the same 12-block screening protocol. Require >=5% useful benefit
on full reads and no >5% adverse guard. Inspect actual Tier1 key generation,
range checks, spills and fixed stack reservation. A supported source would
require its own identical-caller fresh confirmation before integration.
