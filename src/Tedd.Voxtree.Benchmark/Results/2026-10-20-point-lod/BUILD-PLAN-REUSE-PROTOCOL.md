# P30: reuse the owned builder's validated plan

Prospective, not yet executed. Parent is complete P27, independently of P29's
read intervention. Production remains f0772c8 and integration branch main.

Registry A03/A11: BuildOwned already computes an immutable BuildPlan. On legacy
tree fallback, it then calls TryBuild, which computes that plan again for widths
2/4 at depths3..6. Extract the existing planned write portion as a private core.
BuildOwned passes its existing plan; public TryBuild performs its original ordered
validation/planning and invokes the same core. No cross-call input cache, altered
selection, speculative write policy, writer fields or layout changes. Widths/depths
that did not replan before are not claimed to eliminate a measurement pass.

Do not write a whole speculative legacy tree before selecting a variable-size
palette output. The retained corpus has a concrete counterexample: region
DefaultWorld/r.4.488.1.region slot5447, hash
DBC87DF99E06B3E001A3BFB1C37958BF2AC36B3415EF27EDE6883FF6FF261DBB,
legacy34116 versus palette33300 bytes. Writing legacy first could modify816
bytes beyond a successful palette output. The selected plan-reuse intervention
avoids that issue by retaining the entire existing planned write body.

Invariants: exact encoded bytes, format choice, source/layout/range validation
order, complete initialization, no destination-tail changes, same capacity-failure
outcomes and all destination mutations, raw value/LOD semantics, atomic owned
publication, allocation and every existing reader. The private core receives a
plan created for the same stable source/depth/layout during the same call. Existing
source stability requirements apply; it accepts no unvalidated public input.

Prediction: complete constructor-plus-first-Get and owned Build callers improve
at least20% for both UInt16/UInt32 mixed-u7-air and mixed-u8-air fixtures, eight
primary contrasts. Verify their P27 storage is legacy tree before timing; otherwise
stop and revisit this prerequisite, without silently selecting other primaries.
All other80 original complete-operation time guards retain cost<=1.05. No10x
claim from this incremental contrast or multiplication with previous studies.

Prerequisites: register hypothesis before generating source; bind both complete
source snapshots and prove the planned write body and other codec bodies remain
unchanged. Full original/palette/contract tests .NET8/10/11 and .NET10 hardware-off;
all48 point/88 complete-operation oracles; the differential writer oracle across
levels0..6, all widths, Morton/linear and exact/short/oversized capacities. Recheck
all1286 immutable chunks/42139648 cells with a separate release-control bundle
and an explicitly aliased exact P27 byte witness. Include the counterexample above.

Before quiet timing, inspect the selected-bundle builder caller and planned core
for both widths. Confirm the owned tree path uses its existing plan and the
public caller path still creates one. Retain tiers, optimized call sites, code
sizes and fixed stack reservations. Source/code call removal supplies no measured
time share, total recursive stack bound or PMU cause.

Fixed screen: all88 unchanged version13 Scenarios-bulk cases,12 paired blocks,
four warmups, seed20261102, family88 time contrasts, quiet-validation,120s/case.
Bounded-consumer counts16 construction/build/size/fromencoded,64 copy/validation/
count/miss,2 build-plus65536-reads operations. .NET10.0.13 x64, affinity4, ordinary
tiering/PGO and three-second primes. Freeze all plans before first observation.
Full budget and every adverse result retained; no extra samples, replacements,
old-family resumption, source changes or pooled earlier observations.

Use the shared Windows host admission over preparation and dependent windows;
controllers acquire Global\Tedd.DotNetLab.Measurement.v1 themselves for timing.
All scratch/catalogs/builds are task-local; no app/world/database writes.

Primary failure is not_supported; primary pass with unresolved guards is
inconclusive for adoption. Namespace/PGO effects, same-process dependence and
allocation-model limitations remain explicit. Fresh direct-release normal
confirmation and full point/query/fallback/memory/API guards remain required.
P30 does not imply adoption of P27 or P29, or completion of the full10x goal.
