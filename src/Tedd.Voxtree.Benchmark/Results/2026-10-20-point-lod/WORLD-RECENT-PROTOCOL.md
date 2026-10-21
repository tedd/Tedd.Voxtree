# P34 exact last-entry shortcut

Control: complete published f0772c8; no P24–P33 prototype is included.
Objective: .NET 10.0.13 x64 steady-state public WorldEntity point and world
resolution LOD access. This is an exploratory work-elimination intervention;
the hash/probe share and application access frequencies remain unmeasured.

Change only RecentChunkMap: retain the index of its last successful recent
entry, compare full coordinate and LOD before hashing, then perform the same
access-sequence updates. Update the hint on successful lookups and insertion;
invalidate on removal of a cached entry or Clear. Misses do not mutate the
hint, access sequence, dictionaries, or storage behavior. No negative cache,
approximate LRU, changed bytes, ownership, synchronization or format.

Registry: algorithm/repeated work, dependency/hash chain, locality, branch
prediction, hot/cold state and generated caller visibility. Alternatives are
hash replacement, move-to-front cache, channel caching and approximate LRU;
they entail independent collision/order/invalidation costs and are excluded.
The shortcut adds an integer and a conditional branch; alternating/churn/miss
patterns explicitly falsify an assumed universal benefit.

Frozen version19 fixture: classic UInt32 and generic UInt16, two channels,
chunk side1 (the Forcecraft topology index uses this geometry), 12 signed
coordinates, base and LOD3 layers. Uniform value i+1 in channel0 and i+101 in
channel1; empty/missing returns the public default. Each useful operation is
one TryGet, TryGetLod(3), TryGetChunk(address LOD3), or complete topology query
(levels0..7, only level3 populated). Patterns: repeated, blocks32 over eight
chunks, alternating two chunks, cycling12 beyond the ten-entry cache, and
miss. These are contrasts, not application frequency weights. Full independent
prefix-sum oracle includes values, channel selection and hit flags; residency
and mutation parity are tested outside timing against published source.

Gate before timing: complete source review, differential mutation/LRU tests,
existing multi-runtime tests, both-arm fixture validation and actual optimized
caller disassembly. Native evidence must show the full-address shortcut avoids
hashing/probing and retains timestamp stores; report fixed stack reservation
and code size, without inferring latency, PMU behavior or total stack usage.

First rejection stage: all40 cases, four paired blocks, two warmup batches,
2,097,152 useful operations per arm/run, seed20261113, affinity4, three-second
per-arm priming, quiet-validation and 120-second per-case limit. Shared host
mutex Global\Tedd.DotNetLab.Measurement.v1 is mandatory. Existing Measure.ps1
minimum ten blocks policy remains: four pairs are descriptive rejection data,
not independent confirmation. Six repeated get/lod/chunk primaries require
baseline/candidate adjusted time >=1.10; all34 other cases require >=1/1.05.
Every planned case runs after a miss. Require correct, quiescent, joined runs
and zero observed per-read allocations. No sample expansion, rerun, pooling,
favorable exclusion or multiplication with earlier ratios.

If every gate passes, freeze separate fresh normal-build confirmation against
published source, including mutation/storage/LRU and caller workload guards,
before new confirmation data. Otherwise reject or retain inconclusive evidence;
do not adopt. Timing cannot establish application speedup or the full10x goal.
