# P36 ordered incremental cache maintenance

Scope: .NET10 steady-state WorldEntity point/LOD access and its cache-miss
maintenance; complete published f0772c8 control, excluding P24–P35. The full
public-method10x objective remains active. Previous world stages expose costly
cycling12 reads and AddRecent source rebuilds the16-slot table after changing
one of ten entries. Its elapsed critical-path share is unmeasured.

One mechanism: replace AddRecent's full RebuildLookup with backshift deletion
of the old index and ordered insertion of the new index. Insertion displaces
larger recent indexes, reproducing the old increasing-index rebuild exactly.
Retain victim selection, all fields/layout/capacities, complete read method
bodies, state/access updates, dictionary/storage behavior and byte formats.
Remove continues using the original rebuild after swapping entries. No hints,
new fields, per-read branch, admission policy or approximate LRU is introduced.

Registry: A03 eliminate repeated work, A08 maintain the existing compact index,
A04 incremental updates; M01 account for touched slots; C02 lookup dependencies,
C18 actual helper/caller code and R03 caller history. Alternatives: unordered
insertion, replacing the cache, changing victim policy and negative filters.
Those can change hit probe counts, allocation or residency behavior and are
excluded. Exact private table equality is a deliberate performance invariant
here, not a public API contract.

This first phase proves feasibility before timing. Freeze these gates before
candidate results: independent reference rebuild vs incremental model over all
home assignments for sizes2/4 and all capacities, size8/capacities1..4; every
victim/new home; fixed-seed128,000 actual-size replacements including full and
collision/wraparound tables. Retain a counterexample on failure and stop that
producer. Count logical slot assignments only; they are neither timing nor
machine traffic/instructions. No favorable subset, model repair in place or
measurement-based threshold is permitted.

If the model passes, prepare one fresh source identity. Verify exact bounded
source delta and unchanged reads/fields, full published-format multi-runtime
regressions, exact recent/residency/lookup differential tests and generated
adversarial collisions/wraparound/removal/Clear/access-counter rollover. Bind
compiled source and executable hashes. All48 version21 two-arm world callers
must pass independent value/hit/channel prefix oracles.

Version21 is a new caller epoch: separate Get/Lod/Chunk/Topology batch methods,
not P34/P35's shared large operation body; UInt32/UInt16,two channels,side1,
repeated/blocks32/alternating/cycle10/cycle12/missing contrasts. No prior timing
is reused. Separate locked native capture on cycling12 must show AddRecent no
longer calls RebuildLookup or clears the full lookup table. Preserve optimized
helper/caller listings, sizes/fixed frames and unchanged hot read source; do
not infer latency, total stack usage, PMU causes or application frequency.

All scratch/builds/catalogs are task-local. Hold shared host admission and
Global\Tedd.DotNetLab.Measurement.v1 across execution prerequisites. No app,
database, user world, package or remote write. Preserve originals and accepted
IDs; no blind retry, overwritten producer identity or timed rerun.

This phase has no comparative timing and cannot select adoption. After all
feasibility gates pass, freeze a separate fresh-normal protocol, complete
workload/metric/guardrail family,budget,order,independence assumptions and source
selection before new timing. It must include positive cache-churn targets and
hit/miss/constructor/mutation/storage/allocation/caller guards. Do not use a
four-pair point estimate to assert5% equivalence or waive degenerate allocation
models. Full confirmation and original public10x qualification remain required.
