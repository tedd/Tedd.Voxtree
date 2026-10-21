# Conservative seen-layer filter: source, storage and native gates

Integration branch main; starting commit e259bfb. P35
`hyp-f22abb61904f4f32adfb6d12f5ba99d0` starts independently from complete
published f0772c8, excluding P24–P34. The library remains unchanged. These are
prerequisites for a fixed timing stage, not a speedup or adoption result.

RecentChunkMap gains one UInt64 field and two early missing-layer returns.
Set records the corresponding bit immediately after dictionary insertion;
Clear resets it. Remove leaves conservative false positives. This avoids
per-layer counters, arrays or removal scans. It preserves exact timestamps,
LRU, ownership, validation and all encoded/file bytes.

The invariant is inductive: construction/Clear have no items; each insertion
sets its layer bit; removal cannot introduce an item. Therefore a zero bit
proves absence. Large internal levels can share a shift bit, but insertion
and lookup share the same mapping, so aliasing adds only false positives.
Supported public levels still pass the original validation before map access.
A map miss still reaches the public caller's storage load or implicit-empty
path. No negative address is cached.

The source audit reverses precisely these changes and recovers the complete
published WorldEntity.cs after newline normalization. All52 other files are
byte-identical. Compiled candidate and namespace-mapped control sources match
their inputs. All dictionary mutation paths are inspected: Set,Remove,Clear.
No P34 last-entry field is present.

The full published-format suite passes402 tests on .NET8,403 on .NET10 and404
on .NET11; the library also builds for netstandard2.1. Existing differential
tests retain6,000 mutation/read events per width, immediate repeats, exact
recent order/lookup indexes and residency/access-counter parity. New tests
cover first-ever layer loads from task-local direct storage, clean implicit
empties, trimming/reloading, Clear, every public LOD level including byte
values, validation order, and internal shift aliases through int.MaxValue.
Two xUnit2009 warnings recommend Assert.StartsWith for effective task-root
path assertions; they do not indicate failed assertions. Original test
modules/dependencies and TRX are retained without rebuild or rerun.

All60 version20 caller cases pass both-arm independent prefix validation.
The fixture adds absent-layer TryGetLod2 and saturated history to the previous
synthetic world contrasts. Saturation populates then removes every other
searched layer, retaining base/LOD3; it disables useful early rejection and
guards populated-layer branch overhead. Actual game frequency, byte-channel
application timing and lock cost remain unmeasured.

The isolated repeated-case Get-first diagnostic has ten mapped zero-bit
branches across complete final Tier1 callers. Address routes emit BT followed
by the missing branch; the base route tests bit0. Each missing target reaches
map-miss/null state before hashing or access stores. Populated branches retain
the original hash path. Public storage fallthrough is independently tested.

| Complete Tier1 method | Control bytes / fixed rsp subtraction | P35 |
|---|---:|---:|
| UInt32 scenario caller | 8185 / 1256 | 8206 / 1224 |
| UInt16 scenario caller | 8377 / 1256 | 8396 / 1224 |
| Shared coordinate cache lookup | 581 / 136 | 600 / 144 |

These are complete five-operation caller bodies, not per-operation sizes.
Fixed stack reservation is not total stack usage. The diagnostic history is
not the quiet family's code identity. Neither BT, code size nor stack changes
establish elapsed gains, PMU behavior or causal fractions.

WORLD-LAYER-PROTOCOL.md fixes all60 cases/four pairs/two warmups and480 records,
seed20261114,2,097,152 operations per run, affinity4,three-second priming and
quiet validation. Ten never-seen-layer primaries require2x; four repeated/
blocks32 topology primaries require1.20x; all46 guards require cost<=1.05.
The entire stage runs after a miss. Minimum ten-block quality/dependence flags
remain; no independent confirmation or favorable selection is permitted.
Only an all-gates pass selects a separately frozen fresh normal confirmation
and complete constructor/mutation/storage/memory/caller guards.

Phase24 preserves the exact paired executable/dependencies, source/control,
tests and original modules, native capture/identity, semantic outputs, source
reversal proof and hypothesis catalog, with no comparative timing records.
It contains3,492,284 bytes,259 paths,224 blobs and one catalog; SHA256
`fa63ecb6b6c726668ef5cae18c5f6fee1cf0ed9a653b05435eeea0a8afc3d961`.
The verifier checks every blob, mapping, CRC, catalog and required binary path.
No application, user world, database, package or remote branch is written.
No temporary branch/worktree is created. The active goal still needs
`D:\Workspaces\AI\voxtree-point-lod-20261020`; unrelated docs/articles stays
untouched. The full public-method10x objective remains active.
