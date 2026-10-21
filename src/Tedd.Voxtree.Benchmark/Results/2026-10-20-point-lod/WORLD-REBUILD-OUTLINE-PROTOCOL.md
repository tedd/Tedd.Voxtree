# P38: outline only the this-only rebuild boundary

The full public-method10x objective remains active. Prioritize .NET10 steady-state
point/LOD reads, with complete original API/caller qualification required.
P37 failed its frozen stack gate despite smaller callers. Preserve that rejection.

Control: complete published f0772c8. Candidate: exactly NoInlining on private
RecentChunkMap<TChunk>.RebuildLookup. AddRecent retains its published flag/body;
no P36 algorithm, P37 annotation, layout, field, format or public API changes.
RebuildLookup's only argument is this. P37's AddRecent boundary materialized a
32-byte address plus a fifth argument in a complete normal Chunk caller. Avoiding
that particular boundary may separate clear/rehash work with less caller stack
cost. This predicts neither a hardware cause nor latency improvement.

Registry C18 selective inlining/code growth; R03 representative PGO history.
Alternative: an extra call adds cost without any useful hot-path reduction, or
the compiler still needs a larger frame. Source callers invoke rebuild only
after cache-entry maintenance/removal; ordinary successful cache probes return
before it. Required clear and increasing-index reinsertion work is unchanged.
Constructor, mutation/removal and cache-churn costs remain future timing guards.

Before any timing, prove byte-exact source reversal and52 other files unchanged,
all1203 raw and resolved library IL bodies plus47-type public surface identical,
with only RebuildLookup implementation flags differing. Both fresh WorldNormal
modules contain a single actual library, identical version22 Program/project,
assembly name, dependency DLLs and runtime/deps JSON. CoreCLR10.0.13 x64,
roll-forward disabled, pinned SDK11.0.100-rc.2.26504.105, Release, normal PGO.

Reuse original published-format regressions and existing exact map/residency,
collision/full-table/wraparound/rollover/storage/LOD tests. Preserve new original
net8/net10/net11 results and netstandard2.1 output. Require all48 independent
prefix cases per normal module before interpreting native code.

Capture separate cycling12 diagnostics for each exact normal module. Freeze
eight complete final Tier1 callers/module, standalone candidate RebuildLookup,
no clear sites in candidate callers, and direct calls to RebuildLookup there
(published AddRecent remains inline). Every candidate caller must be smaller
with no larger fixed rsp reservation than its fresh matched control. A failed
gate stops this source before timing; no annotation/caller/margin changes or
replacement producer under the same identity. Preserve all Tier1/OSR listings,
identities and joined exits. Fixed rsp is not total stack usage; diagnostic
snapshots are neither quiet timing nor all eventual code versions.

This phase collects no comparative timing and cannot authorize adoption.
If feasible, freeze a new complete prospective normal timing family before data:
positive hit targets and all affected miss/churn/constructor/mutation/storage/
allocation/real-byte-one-channel-consumer guards. Use justified fresh process
budgets and interval rules; retain zero-variance allocation flags. Do not expand,
pool, multiply or reinterpret P36/P37 observations. Full10x remains unverified.

All startup/test writes are synthetic worlds, task-owned file storage/IPC and
private catalogs below D:\Workspaces\AI\voxtree-point-lod-20261020. Hold legacy
admission and Global\Tedd.DotNetLab.Measurement.v1 through builds/tests/native
work. A timed controller owns the central mutex itself, if later selected.
No database, application, user world, package or remote branch is written.
Research integrates into original main; retain the required active workspace.
