# Ordered incremental cache maintenance: feasibility gates

Integration branch main; starting commit0d122da. P36
`hyp-5819573ab9534be1bdac10805ecbfe0c` is **supported for algorithm/source/
semantic/native feasibility only**. No comparative timing, source adoption,
package or10x claim is made. The complete control is published f0772c8,
excluding P24–P35; the library remains unchanged.

AddRecent preserves its victim scan and cache-entry assignment. A replacement
now removes the old lookup index by backshifting entries whose probe interval
crosses the hole, then inserts the new index in priority order. Lower recent
indexes displace higher ones, matching RebuildLookup's increasing-index order.
Non-full insertion extends the same arrangement. Remove keeps its original
full rebuild after swapping entries. All fields, capacities, read bodies,
access sequences, dictionaries, ownership and byte formats are unchanged.

Preserving the canonical arrangement is intentional: ordinary append-style
incremental insertion can make a formerly cheap hot key probe through other
entries. Here exact table equality protects per-key probe counts. It is a
performance invariant for this candidate, not a public API contract.

The independent model passes149,476 exhaustive replacements across reduced
tables and128,000 fixed-seed actual-size replacements, including full tables,
collisions and wraparound. In96,000 capacity10 stress cases, candidate logical
slot assignments average8.390 and never exceed20, versus26 for the published
16-slot clear plus ten insertions. This sample deliberately emphasizes
collisions; it is not an application distribution. Logical assignments exclude
other loads, victim scans, hashing, dictionaries and cache-entry stores, and
are neither machine traffic/instructions nor latency.

The source audit reverses only AddRecent's two call changes and the two new
helpers, recovering the complete published WorldEntity.cs after newline
normalization. All52 other files are byte-identical. Compiled candidate and
namespace-mapped control sources match their inputs; no P34/P35 state remains.

The complete suite passes408 tests on .NET8,409 on .NET10 and410 on .NET11;
netstandard2.1 also builds. Existing exact cache/residency tests remain. New
tests exercise three actual collision families with8,000 events each across
classic/generic worlds, preserving values, timestamps, lookup slots and probe
reachability. Another4,000 events per capacity1/10/16 cover full-table removal,
wraparound, replacement, Clear and access-counter rollover. First-ever-layer
storage, implicit empties and public/internal LOD boundary tests also pass.
The existing xUnit2009 path-assertion warnings remain; no assertions fail.

All48 version21 caller cases pass both arms against independent hit/value/
channel prefixes. This is a new epoch: Get,Lod,Chunk andTopology execute in
separate batch methods, with repeated,blocks32,alternating,cycle10,cycle12 and
missing contrasts. No P34/P35 timing or shared large operation body is reused.
The data remains synthetic side1/two-channel UInt32/UInt16, not application
frequency or end-to-end byte-channel game timing.

The isolated cycling12 diagnostic produces complete final Tier1 maintenance
helpers and16 callers. All eight control callers contain static clear sites;
all eight candidate callers remove them. AddRecent inlines maintenance, so
the gate follows emitted clear operations rather than requiring a named
RebuildLookup call that the compiler already eliminates by inlining.

| Complete Tier1 method | Control bytes / fixed rsp subtraction | P36 |
|---|---:|---:|
| AddRecent | 578 / 128 | 656 / 120 |
| UInt32 Get caller | 3693 / 408 | 3862 / 440 |
| UInt16 Get caller | 3889 / 424 | 4029 / 456 |
| UInt32 LOD caller | 4146 / 424 | 4284 / 456 |
| UInt16 LOD caller | 4324 / 440 | 4474 / 472 |

Standalone removal/insertion helpers are262/111 bytes with fixed rsp32/40.
All eight complete callers grow138–176 bytes and reserve16–32 more fixed rsp
bytes. Source-level hot reads remain unchanged, but miss-path inlining can
change layout/register allocation and affect hits. Static reference/no-reference
clear alternatives are not two executed clears. Fixed rsp is not total stack
usage; no native-size, write-count or hardware-causal speed claim follows.

Phase26 retains all sources, model/semantic results, native capture/identity,
paired executable/dependencies, original test modules/TRX and hypothesis
revision:3,672,338 bytes,266 paths,228 blobs,one catalog,zero comparative metric
rows; SHA256
`7f15bfc8cd6a35974ead7edd4f94225308da99cdcfa47763d0745e06424e7a30`.
Every blob, mapping, CRC, catalog and required binary path verifies.

Next, freeze distinct fresh normal builds and complete timing/guard policies
before new data. Keep ordinary hits, misses, mutation, construction, storage,
allocation and realistic caller qualification. Retain degenerate allocation
flags; neither observed zeros nor unchanged source automatically waive a
mandatory statistical guard. Private AddRecent outlining is a separate
compiler-boundary hypothesis, prompted by the larger inlined callers; do not
silently combine it with P36 or multiply component ratios. Compact R validator
terminal-level specialization also remains an independent unimplemented lead.

No application, user world, database, package or remote branch is written.
No temporary branch/worktree is created. Main contains the research; unrelated
docs/articles remains untouched. The retained workspace
`D:\Workspaces\AI\voxtree-point-lod-20261020` is still required by the active
full public-method10x objective.
