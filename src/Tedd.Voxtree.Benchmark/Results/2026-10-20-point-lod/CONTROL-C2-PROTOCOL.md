# C2: longer fresh-process unchanged-library controls

C1's complete 144-session confirmation did not establish 5% equivalence. Its
separate clock diagnostic showed that preemption alone did not explain the
variance. Freeze C2 as a different observer/workload regime before observing
data, preserving all earlier results and not adding samples to old plans.

Before any C2 execution, the user identified the actual central Windows mutex,
`Global\Tedd.DotNetLab.Measurement.v1`. Inspection of installed revision 9c23369
confirms that DotNetLab owns it on a dedicated thread for measurements and fresh
normal sessions. External builds, tests and JIT diagnostics now wait on that
same mutex. Coordinating drivers keep the two legacy pipeline locks, release
the central mutex after each external phase, and delegate timed admission to
DotNetLab. Never hold the central mutex while awaiting its controller.

The unexecuted core-selection proposal is superseded. Keep original affinity
4 (logical CPU 2); no load-based core selection, application suspension, priority
or power change. The topology/probe sources are retained as unexecuted research.
Earlier DotNetLab timings already used the central mutex; its correction for
external work does not establish the cause of earlier variance.

Version 9 keeps the same checked public calls, values, checksums and random
points, uses original fixed affinity 4, and primes each variant for 5,000 ms.
Both primary namespaces compile f0772c8. One control build maps the baseline
label to AfterBatch outside the loop; treatment uses the candidate label and
the same AfterBatch. Verify all raw AfterBatch IL hashes match before timing.
Retain the actual project/configuration diff as the source-equivalence artifact,
not unrelated production worktree changes. Dependencies/runtime must match.

Frozen cases remain the original six: Legacy full owned Get and LOD, Legacy
full/sparse compiled Get, Wide long owned LOD and Huge long owned LOD. A short
256-operation same-process preflight completes the exact registered plans for
tool identity/evidence binding; it is not a precision result and is not pooled
with confirmation. Selection does not depend on those ratios.

Fresh confirmation: 12 pairs per case, one warmup batch per session, quiet
profile, seed 20261023, family size 12 for time/allocation, 0.95..1.05 time
equivalence, no exclusions or favorable stopping. Fixed operations per batch:
1,073,741,824 compiled reads; 134,217,728 full serialized reads; 67,108,864 Wide
long-token reads; 33,554,432 Huge long-token reads. Prior C1 medians were about
4.2, 69, 88 and 184 ns/read respectively; these counts predict roughly 4.5..9.3
second measured windows rather than fractions of a second. Maximum complete
plan duration is 1,200 seconds. The 144 joined fresh sessions are expected to
take approximately 45 minutes. Existing exact task-scoped grants expire after
3,600 seconds and admit 24 launches per plan; errors remain explicit.

All six controls must establish the prespecified time equivalence before the
regime qualifies latency guards. Zero observed thread allocation remains
distinct from degenerate-variance model promotion. If precision still fails,
return to diagnosis without relabeling an inconclusive guard as passed. No
optimization gains, SMT attribution or universal 10x result are claimed from C2.
