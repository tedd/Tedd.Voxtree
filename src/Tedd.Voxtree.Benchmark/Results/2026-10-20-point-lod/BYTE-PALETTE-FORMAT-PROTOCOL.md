# P27 design selection after J1; implementation and timings pending

Keep the full public-method10x objective. J1 supports a bounded joint-state
palette for the dominant sample and measures a maximum83 states per real
chunk. Select this representation direction, not the rejected P25/P26 writers.
Start from complete P24 and preserve its point-reader separation; do not combine
unselected count, sizing or builder forks. Review all affected consumers.

Registry A12/A14/M01/M05/M25: one byte per voxel indexes a small table containing
the full raw value and exact stored-leaf LOD. Two dependent loads may cost more
than one word load, or improve locality relative to P24's larger grid. Neither
J1 byte counts nor the earlier private lookup timings decide this contrast.

Proposed magic0x51('Q'), version3/kind3 in the existing second-byte fields.
No Q declaration was found in production or retained source before selection.
Keep released O/version1/2 support and byte-identical fallback. Unreleased
P/version3 word prototypes are rejected, not silently reinterpreted. Preserve
legacy public FormatVersion constants; expose a clearly named palette version.
Header H is2 bytes classicUInt32 or3 generic, with the original generic size
code. Then little-endian UInt16 count C in1..256, N linear byte indexes, then
C table words. UInt16 entries are4 bytes: raw16 in low16, LOD in high16;
UInt32 entries are8 bytes: raw32 in low32, LOD in high32. All high LOD bits
must be zero beyond the valid LOD; compare unsigned before converting to int.
Full numeric value bits are preserved. Table order is strict (raw value,LOD),
deterministic, with no duplicate or unused states. Table offset is H+2+N;
the hot reader needs no per-read count-field load to locate it.

Encoder selection: widths2/4, depths3..6, released tree representation,
C<=256, exact new bytes<=released GetMaximumSize and4*newBytes<=5*oldBytes.
Uniform/dense/sparse/unsupported-width/over-cardinality/nonfitting cases retain
released output. On the full depth5 corpus, selection must exactly reproduce
J1's132/142/132 eligible counts and14371418/14419428/14372704 projected totals.
Do not search thresholds after timings. Source layout may be linear or Morton;
wire indexes remain linear. Charge all measurement/state collection, sorting,
writing and allocation to complete build/lifecycle callers.

Bound temporary state storage to256 keys and a bounded hash-index structure;
no per-point dictionary, implicit query cache or unbounded stack allocation.
Sorting key ((ulong)rawValue<<4)|LOD fits UInt64 for full UInt32 values. Rebuild any
lookup mapping after sorting. Preserve existing source-overlap, extra-input,
capacity-failure and snapshot/publication contracts. Never emit partial new
format output before capacity/eligibility is resolved. Keep existing maximum
capacity bounds. Do not introduce unchecked data-driven reads: capture and
range-check each byte index before loading its table word, including borrowed
buffers; concurrent mutation cannot justify an out-of-range read.

Implement all point, LOD, lookup, copy, validation, emptiness and query paths.
Full validation checks header/count/length, strict table states, index bounds,
all states used and canonical aligned LOD partitions. Basic creation and local
reads need explicit malformed-data tests, including invalid index, count0/257,
wrong width/magic/version/kind, truncated table, high unsigned LOD bits, unused/
duplicate states and mutable borrowed buffers. Preserve all published legacy
and raw numeric-bit behavior. Independent exact value/LOD oracle precedes timing.

Before observations: framework8/10/11 and intrinsics-off, all existing point
and complete-caller oracles plus new wire tests, complete original corpus with
released control and exact J1 selection/bytes, matched dependency/runtime and
canonical measured-caller checks. Inspect actual x64 owned/borrowed Get/LOD
callers and table readers, fixed frame reservations and producer/query code in
separate diagnostics. No PMU/cache/latency claim from source or static counts.

Freeze actual executable scenario IDs, versions, hashes, source treatment,
complete exploratory families and original regression policies after semantic
validation and before performance. Primary remains every prioritized owned/span
UInt16/UInt32 Get/LOD speedup>=10 against f0772c8. Any selected source requires
new direct release normal-build confirmation; P24 data cannot fill its budget
or be multiplied into a new ratio. Retain original allocation-model outcomes,
constructor/query/fallback/compiled/lifecycle and actual memory tradeoffs.
Prospective normal budget: all8 plans frozen before data,12 fresh pairs,
100000000 public reads/run,1 warmup,3-second primes, affinity4, runtime10.0.13,
600 seconds/case, quiet profile and family16; freeze a new seed and exact plans.
No failed-session replacement, favorable extra observations or old-family resume.

All mutable work stays in the existing dedicated task workspace, using shared
Windows host admission. No application/world/shared-tool writes. No production
source/package promotion from projections, point-only success or unresolved
mandatory guards. This document authorizes no measured result in advance.
