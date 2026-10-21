# P25: construct exact packed leaves bottom-up

Parent: complete selected P24, never P19..P23 or a new combined query layout.
Registry A02/A03/A06/M05. The current packed writer repeatedly scans dense
source cubes for uniformity and revisits each nonuniform child. The output
already reserves one word per voxel. Use that destination as temporary leaf
metadata, without a new array, source pass for each level or changed wire bytes.

Initialize all linear destination words with raw values and LOD zero. For
levels 1..N, inspect only the eight child anchors: collapse a parent precisely
when every anchor has LOD level-1 and the same value. Store its new LOD at the
parent anchor. Finally traverse marked nodes and fill only canonical uniform
leaves. A collapsed parent is the only writer of its first-child anchor after
the child level completes. Noncollapsed nodes preserve every child anchor.
No reader observes intermediate output; caller buffers retain existing failure
and overlap rules. Preserve byte order, headers, selection, sizing, fallback,
old-reader rejection, all values and exact canonical LOD partitions.

Prediction: reduce complete dominant packed constructors/caller-buffer builds
by at least twofold against P24 by eliminating repeated uniformity scans.
Counterprediction: initialization, anchor indirection and final fill outweigh
those scans on fragmented or highly uniform regions. Static source complexity
or fewer comparisons does not establish measured speedup or hardware misses.

Before timing: exact P24/P25 differential bytes for linear/Morton, depths 0..6,
empty/uniform/alternating/random/terrain, all supported widths, reserved-bit
boundaries and capacities; full .NET8/10/11 and intrinsics-off suite; all 48
point/88 bulk oracles; full 1286-chunk census against release, plus exact P24
payload equality. Inspect actual selected-bundle writer/build x64 bodies and
frame reservations separately from quiet measurements. No database/app startup.

Freeze the existing complete version-13 88-case bulk family against P24, twelve
same-process pairs, original bounded counts and four warmups, seed 20261027,
quiet profile, .NET10.0.13, affinity4 and three-second primes. Family88; retain
all other public-operation guards and original allocation observations. Stop
on failures; no replacement, rerun or pooled epochs. Primary constructor and
caller-buffer Build/TryBuild for dominant UInt16/UInt32 must all reach the
twofold point estimate; every other time ratio must be >=0.95. This is an
exploratory mechanism screen, not independent promotion or a universal 10x claim.
Do not multiply P24 ratios by this screen. Any source selection needs direct
release comparison, fresh complete confirmation and broader memory/API guards.
