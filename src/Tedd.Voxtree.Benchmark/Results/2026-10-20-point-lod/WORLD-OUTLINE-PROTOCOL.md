# P37: isolate cache-maintenance code from lookup callers

Scope remains the complete public-method10x objective, prioritizing .NET10
steady-state point/LOD access. This phase tests feasibility of one compiler
boundary; it cannot authorize adoption or establish a speedup.

Control: complete published f0772c8. Candidate: that source plus exactly
MethodImplOptions.NoInlining on private RecentChunkMap<TChunk>.AddRecent.
Exclude P36 incremental maintenance, P34/P35 state and all format prototypes.
No fields, data layout, source method bodies, access sequences, residency,
ownership, capacity, formats or APIs change. AddRecent is reached on insertion
or on a successful dictionary fallback after a recent-cache miss; cache-hit
source paths return before it. Constructor/mutation/churn can pay an additional
call boundary and remain mandatory subsequent performance guards.

Evidence motivating this separate hypothesis: P36 actual normal Tier1 callers
inline maintenance and grow125–201 bytes/fixed rsp16–32 versus published source;
all six churn confidence intervals cross1.10 and several hit guards remain
unresolved. That is not evidence that outlining will improve time. Published
source also inlines its clear/rebuild work in all eight diagnostic callers.
RTree supplies the method of inspecting complete callers; its gains and runtime
configuration are not transferred here.

Registry C18 selective inlining and its code-growth tradeoff; R03 representative
PGO history as a qualification constraint. Competing explanation: larger code
is not on the critical path, or the separate miss-path call outweighs any hit
benefit. No hardware cache, spill, branch or time attribution follows from
native size. A broader algorithm/layout change is a separate hypothesis.

Before timing, require exact source reversal to published f0772c8, byte equality
of all other52 files, unchanged public surface and all IL method bodies after
metadata resolution. Only AddRecent implementation flags may differ. Build two
fresh WorldNormal modules, one actual implementation each, with identical
version22 fixture, assembly name, project, dependencies and runtime settings.
Runtime10.0.13 x64, pinned SDK11.0.100-rc.2.26504.105, roll-forward disabled,
Release optimization and normal tiering/PGO. Original P36 observations and
artifacts are retained and cannot be pooled or replaced.

Reuse the complete published-format regression suite plus existing exact map,
collision, wraparound, full-table, rollover and storage tests. New tests that
merely restate the attribute are unnecessary. Preserve original results on
net8/net10/net11 and netstandard2.1 build; all48 independent synthetic prefix
cases must pass for each module. These side1/two-channel UInt32/UInt16 fixtures
are not a real byte/one-channel application workload or a request trace.

Separately capture both exact modules' cycling12 diagnostics. Require eight
complete final Tier1 callers per module, standalone candidate AddRecent, no
inlined clear sites in candidate callers, and a smaller native body plus no
larger fixed rsp reservation for every candidate caller versus control.
Require actual calls to AddRecent in candidate callers and record their native
context; this isolates maintenance, not deletion of required work. Retain all
Tier1/OSR listings and joined diagnostic identities. A failed gate stops this
producer; do not change the caller, flags, workload or source in place.
Fixed rsp is not total stack usage and diagnostic processes are not quiet
timing samples or every eventual timed code version.

No comparative timing is authorized by this phase's protocol. If all native
and semantic gates pass, freeze a separate complete prospective normal timing
family before new data, including positive hit targets and constructor,
mutation, churn, absence, storage, allocation and realistic consumer guards.
Use justified fresh-process budgets and interval rules. Preserve allocation
quality flags; no observed-zero waiver, four-pair5% equivalence, posthoc margin,
sample expansion or historical ratio multiplication. A new combination with
P36 needs its own selected source and original-control/full-caller qualification.

Hold legacy host admission plus Global\Tedd.DotNetLab.Measurement.v1 for builds,
tests and diagnostics. A controller acquires the central mutex itself for timed
runs; never hold it externally while awaiting that controller. All scratch,
catalogs, build output and IPC remain under the dedicated task directory.
Startup/callback effects are synthetic in-memory worlds and task-owned test
storage/IPC only; no application, user-world, production database, remote branch
or package write. Preserve accepted IDs, original producer labels and failures.
Research integrates into original main; active workspace remains required.
