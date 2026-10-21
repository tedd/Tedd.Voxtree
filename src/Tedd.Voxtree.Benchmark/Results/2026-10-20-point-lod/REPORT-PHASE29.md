# P37 AddRecent outlining: frozen stack gate failed

Original/integration branch: main, starting97321e4. P37
hyp-543d7b71d3e0442b903fdfc5b599d5df is not_supported under its prospective
feasibility rule. No timing was collected, no source was adopted, and the full
public-method10x objective remains active. P36's inconclusive family is retained
unchanged and is not combined with P37.

P37 changes only private RecentChunkMap<TChunk>.AddRecent's implementation flag
to NoInlining on complete published f0772c8. Exact byte-level reversal recovers
the original file; all other52 files are byte-identical. Both normal modules
compile the exact selected sources and identical version22 Program/project,
assembly name, dependency closure and runtime/deps JSON. They contain one actual
implementation each. Normal builds succeed with zero warnings/errors, using
CoreCLR10.0.13 x64, roll-forward disabled, SDK11.0.100-rc.2.26504.105 and normal
tiering/PGO. All execution holds shared host admission and the central mutex.

The self-tested metadata decoder now supports all library IL methods and a
public-surface inventory. It does not execute library or fixture methods. All
1,203 raw and metadata-resolved IL bodies match exactly, including constructors;
the47 exported-type public surface matches. Exactly one implementation flag
differs: AddRecent IL to NoInlining. The eight fixture caller bodies/flags also
match. The original decoder falsifiers still reject changed calls/literals and
distinguish implementation flags.

All original regression producers complete without replacements:408 tests on
.NET8,409 on .NET10,410 on .NET11; netstandard2.1 builds. Existing map/residency
order, actual hash collisions, full capacity, wraparound, access rollover,
first-layer storage, implicit-empty and LOD alias cases remain included. The
existing xUnit2009 path-assertion warnings remain. All48 independent prefix cases
pass on each normal module. File persistence resolves below task-owned TEMP;
no application, user-world or database configuration is used.

Separate joined cycling12 diagnostic processes produce52 indexed Tier1/OSR
listings, including sixteen complete final Tier1 callers. Every candidate caller
removes its inlined clear sites and calls standalone AddRecent. That helper is
566 native bytes/fixed rsp128 and retains the required clear/rebuild work;
reference/non-reference clear alternatives are static sites, not two executed
clears. The native observation is code separation, not work elimination.

| Actual normal Tier1 caller | Control bytes / fixed rsp subtraction | P37 |
|---|---:|---:|
| UInt32 Get | 3733 / 408 | 3261 / 424 |
| UInt32 LOD | 4180 / 424 | 3643 / 440 |
| UInt32 Chunk | 2681 / 264 | 2234 / 280 |
| UInt32 Topology | 4435 / 456 | 3967 / 488 |
| UInt16 Get | 3931 / 424 | 3444 / 440 |
| UInt16 LOD | 4352 / 440 | 3857 / 456 |
| UInt16 Chunk | 2682 / 264 | 2235 / 280 |
| UInt16 Topology | 4609 / 456 | 4121 / 504 |

Every body shrinks447–537 bytes, but every fixed rsp reservation grows16–48
bytes. The frozen rule required a smaller body and no larger fixed reservation
in all eight callers; all eight fail its second condition. The protocol is not
relaxed after observing this tradeoff. P37 is rejected for continuation to time
qualification under that rule; this is not evidence of elapsed-time regression.

The actual UInt32 Chunk call site materializes its32-byte ChunkAddress at
rsp+D0..E8, places ResidencyState at rsp+20, passes the address pointer in rdx
and calls AddRecent. This is an observed ABI/caller context, not proof of the
entire frame-growth cause or total stack usage. Source cache-hit paths still
return before AddRecent; constructor/mutation/churn paths would pay the extra
call. Native size, stack reservation and diagnostic PGO histories do not prove
latency, spills, instruction-cache misses or a hardware bottleneck.

A separate minimal lead is outlining RebuildLookup instead. Its only argument
is this, so it does not introduce AddRecent's large-key/fifth-argument call
boundary into read callers. This is a hypothesis, not an established fix. Keep
AddRecent's flag at published behavior, exclude P36/P37, freeze a new source
identity and native/correctness rule before any results. Private by-reference
address passing is another possible experiment but carries alias/struct-promotion
risks and is not selected here. No new timing follows from this rejected gate.

Phase29 retains original sources, binaries, metadata inventories/tool/self-test,
TRX, exact original test modules/dependencies including netstandard2.1, semantic
prefixes, native listings/identities/joins and the revised private hypothesis.
Archive:4,348,739 bytes,404 mapped paths,196 blobs,one catalog,zero comparative
metric rows; SHA256:
`546d41a24d744f21cab1495f6868f3dd3782642497c7c3d6c6ece4bf8d8f73a9`.
Every CRC, blob length/hash, mapping, required binary path and catalog verifies.

Production library remains f0772c8; no package, remote branch, application,
database or user world is written. Research is integrated directly into main;
unrelated docs/articles remains untouched. No temporary branch/worktree exists.
The active task retains D:\Workspaces\AI\voxtree-point-lod-20261020 for required
sample/source/binary inputs; cleanup follows completion and verified shutdown.
