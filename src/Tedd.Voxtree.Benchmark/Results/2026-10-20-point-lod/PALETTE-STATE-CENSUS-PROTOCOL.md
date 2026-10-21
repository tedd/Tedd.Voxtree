# J1: full-corpus joint value/LOD state cardinality

The 10x public-method goal and .NET10 point/LOD priority remain unchanged.
P24 passes its selected point time primary but expands encoded UInt32 payload
5.02x and encoded-plus-distinct-lookup payload 46.5%. Earlier P9/P10 private
lookups use byte state indexes and compact joint value/LOD tables. That source
and point evidence motivate a public wire-layout candidate; they do not prove
new serialized getters are fast or that all real chunks fit a byte palette.

Before selecting or implementing a new encoding, perform one offline semantic
and cardinality census of all 1286 immutable chunks/42139648 cells, preserving
duplicates and the 686-unique-array distinction. Use the exact archived
p24census bundle: f0772c8 Snapshot is the released control; primary namespace
contains P24. Verify bundle and six region-copy hashes before execution. No
game/application startup, world write, production server or performance samples.
Builds/scan hold the original shared host admission behind the P26 pipeline.

For classic UInt32, generic UInt16 and generic UInt32 independently, collect
exact (raw value, released stored-leaf LOD) states from every cell, checking
returned values against decoded input and LOD in0..5. Do not infer LOD from
value alone or treat unique values as joint states. Retain released storage
kind/bytes, existing P24 bytes and maximum raw value for each row.

Prospective projection, not an implemented format: old header width H (2 or3),
two-byte palette count, N one-byte cell indexes, then a palette of C fixed-width
words. UInt16 state entries occupy4 bytes (raw16+LOD); UInt32 entries occupy8
(raw32+LOD). Projected length H+2+N+C*entryWidth. Indexes precede the table so
hot table offset depends on H and N, without reading palette count per access.
This preserves every raw value bit, unlike P24's reserved value bits.

Eligibility is frozen for this census: released tree storage, depth5,
1<=C<=256, projected length<=released GetMaximumSize, and projected bytes no
more than1.25 times released encoded bytes. No selected-format output is emitted.
Report all eligible counts and projected corpus payload using released bytes
for ineligible chunks. Also retain cardinalities and uncapped projection so
excluded/adverse chunks are visible; no post-result threshold search or claims
that the25% policy was user-mandated. For existing owned compiled lookup,
project sharing the encoding only as a separate explicit assumption. Measure
actual old/current lookup sharing, rather than double-counting borrowed arrays.
The preselected mixed-u16-air sample must satisfy the frozen eligibility rule
before this direction can be selected; no substitute sample is chosen afterward.

Selection would require prospective magic/version/discrimination, deterministic
state ordering, capacities, malformed-index/table/LOD tests, exact released LOD
partitions, complete queries/copy/lookup and fresh matched x64 point/LOD/build
measurements. Header arithmetic and two dependent loads do not establish
latency, cache behavior, allocation or application memory. A projection cannot
resolve allocation guard models or qualify production/NuGet adoption.
