# P15: inline value and exact leaf LOD

The real corpus has mixed leaf depths and values above 255. P6 cannot encode
it, while private palette lookup experiments improve already compiled reads
only modestly. Investigate a separate format that replaces dependent token
walks for existing owned and borrowed public reads. Control remains f0772c8;
do not combine P1/P3/P5 or earlier format prototypes in this causal fork.

Hypothesis A02/A12/A14/M05: put value and stored leaf LOD in one indexed word.
For UInt16 reserve the high four bits for LOD and admit values <=4095. For
UInt32 reserve four bits and admit values <=268435455. Preserve the complete
raw value; reject eligibility when any reserved bit is used. Depth <=9 fits
four bits. Initial selection is limited to depths 3..6, legacy tree storage,
and legacy encoded bytes at least one eighth of dense bytes. Uniform, legacy
dense, sparse, wider-value and larger-depth representations retain old formats.

Wire version 3, kind 3, existing header widths: two bytes for legacy UInt32,
three bytes with exact size code for generic UInt16/UInt32. Body is one little
endian packed word per voxel in linear order; low bits are value, high four
are exact original tree leaf LOD. Length equals the old dense maximum, so
GetMaximumSize and caller capacities remain valid. This is an alternative to
P6, not a claim that its version-3 byte layout is already interchangeable.
Any eventual combination needs explicit disambiguation and cross-format tests.

Writer derives canonical leaves from source, preserving Morton input, and
fills each leaf with its value/LOD word. Read is one indexed load plus masks.
Full validation recursively verifies that every represented coarse leaf is
aligned, has constant value and LOD, and fits the volume. Local point reads
must reject out-of-range LOD. Every query/filter/copy/nearest/lookup consumer
must decode the value bits; no packed bits may leak into returned voxels.
Old version-1/2 reading and malformed-input behavior remain independently tested.

Tradeoffs: up to eight times legacy encoded payload for admitted inputs;
extra eligibility/format selection work; direct query scans can lose compressed
subtree skipping. Record actual corpus eligibility, encoded bytes, complete
build/copy/query cost, allocations, ownership, publication, all values/LODs,
invalid headers/lengths/LOD partitions, boundary values and adverse layouts.
No adoption or speedup from source-level load counts. Correctness precedes
timing; freeze actual scenario identities and lifecycle/guard budgets after
implementation and before observations. Fresh unchanged-source precision must
qualify the guard regime. Inspect actual default-tiered x64 callers and fixed
stack reservations; neither proves a hardware bottleneck or elapsed gain.

## Frozen exploratory family, before timing

P15 passed 404/405/406 framework tests (.NET 8/10/11) and all 48 version-12
terrain oracles. Selection admits only the dominant mixed-u16-air stratum in
the four retained samples. Its UInt32 encoding is 131,074 vs 27,550 bytes;
UInt16 is 65,539 vs 27,551. Owned UInt32 lookup payload shares those encoded
bytes; five diagnostic constructors allocated 48 vs 66,240 thread bytes.
The new UInt32 array was observed in generation 2, with source/lookup sharing
verified; this is a footprint diagnostic, not latency evidence.

C3 completed all 144 fresh sessions but no case established 5% time equivalence.
Do not qualify guards, promote a candidate, or pool epochs from that outcome.
An exploratory P15 screen is permitted to localize the much larger algorithmic
effect while guard precision remains unresolved. Freeze all 48 registered
version-12 cases, including every sparse/empty unchanged-format case, before
observations: twelve same-process paired blocks, four warmups, seed 20261022,
quiet profile, .NET 10.0.13, affinity 4, three-second primes, 120-second plan
limit. Counts are the existing bounded-lifecycle policy: 33,554,432 compiled
reads, 256 constructors, 16 compile/read operations; other reads 2,097,152
except named sparse cases 4,194,304. Family size is 48, no exclusions.

Native inspection uses the same bundle, default tiering/PGO and dominant
UInt32 owned LOD caller, collecting TryGetUnchecked/TryGet/ReadWord listings.
Diagnostic and quiet regimes stay separate. Every ratio remains exploratory;
the screen omits original encoding from its compile/read lifecycle. A separate
complete build/read and bulk-consumer family is mandatory before adoption.
