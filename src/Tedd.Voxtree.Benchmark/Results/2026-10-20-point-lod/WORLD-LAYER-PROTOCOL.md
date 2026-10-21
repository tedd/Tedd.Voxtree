# P35 conservative seen-layer filter

Control: complete published f0772c8, excluding P24–P34. Objective: .NET10.0.13
x64 steady-state point and world-resolution LOD access. P34 native control
callers hash/probe every missing layer; the Forcecraft topology caller searches
levels in ascending order. Their elapsed critical-path share and application
frequencies are unmeasured. This is a falsifiable work-elimination intervention.

Only RecentChunkMap changes: one UInt64 seen-layer mask, set immediately after
dictionary insertion/replacement; Clear resets it. Remove does not clear bits.
Both TryGetValue overloads return null/false before hashing when the layer bit
is absent. The coordinate overload uses bit0. C# shift aliases conservatively
share bits for large internal levels; matching Set and lookup aliases cannot
produce false negatives. Public validation remains outside the map and unchanged.
All existing cache/LRU/timestamp/ownership/format/storage behavior remains. A
false resident lookup must still fall through to configured storage or implicit
empty materialization in its existing public caller.

Registry: A03 repeated computation, A09 common-case specialization, A08 compact
index; M01 working-set accounting; C02 dependency chain, C19 branch skew, C18/R03
actual caller visibility and PGO history. Excluded alternatives: per-layer
counters/additional arrays, removal scans, exact negative-address caching,
P34 hint combinations, replacement hashing, approximate LRU and global hints.
Costs: an eight-byte field, Set/Clear stores and an extra branch on populated
layers. Saturated history explicitly falsifies an assumed universal gain.

Version20 fixture extends P34's deterministic two-channel side1 UInt32/UInt16
world callers. Operations: TryGet, TryGetLod3, TryGetChunk(addressLOD3), complete
level0..7 topology search, and absent-layer TryGetLod2. Patterns: repeated,
blocks32, alternating, cycling12, missing coordinate, saturated history. The
last pattern populates then removes levels1,2,4,5,6,7, retains base/LOD3 and
repeats one coordinate: every queried layer was seen, so the new filter cannot
help. Prefix oracles independently include values/channels/hit flags. These
contrasts are synthetic, not frequency weighting or application timing.

Before timing: prove exact bounded source delta and map-write coverage; full
published-format multi-runtime regression suite; independent mutation/recency
oracle; first-ever-layer storage load and implicit-empty tests; level aliases
and Clear/Remove transitions; all60 two-arm caller cases; emitted missing-layer
route bypassing hash/probe with no access timestamp stores. Capture Get-first
repeated-case optimized callers separately from quiet timing. Report complete
method size/fixed stack reservation, without causal timing/PMU inference.

Fixed rejection stage: all60 cases, four pairs/two warmups,2,097,152 operations
per arm/run, seed20261114, affinity4, three-second arm priming, quiet-validation,
120-second per-case limit. Hold existing shared host admission and central
Global\Tedd.DotNetLab.Measurement.v1. Keep minimum ten-block analysis policy;
four same-process pairs provide descriptive rejection evidence only. All ten
absent-layer cases other than saturated history require adjusted speedup>=2;
both repeated and blocks32 topology cases require>=1.20 (four cases). All46
remaining guards require>=1/1.05. All cases run after a miss. Require correct,
quiescent, joined records and zero observed read allocations. Freeze order,
budget, thresholds, quality flags and all exclusions before candidate results;
no sample expansion, favorable selection, pooling or earlier-ratio multiplication.

Only if every gate passes, prospectively freeze fresh normal-build confirmation
against published source and complete constructor/Set/Remove/Clear/storage/
memory/caller guards before further data. Otherwise retain rejection or
inconclusive evidence, without adoption, application or full10x claims.
