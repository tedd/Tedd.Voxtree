# P38 this-only rebuild boundary: one frozen stack guard failed

Original/integration branch: main; startingf9fff5a. P38
hyp-f44d61a6291742dc92bc7ac217aad42c is not_supported under its prospective
all-callers feasibility gate. P37 remains rejected. Neither source is adopted;
no comparative timing or public-method10x claim is made.

P38 adds only NoInlining to private RecentChunkMap<TChunk>.RebuildLookup on
complete published f0772c8. AddRecent retains its original flag/body. All52
other files are byte-identical; exact reversal recovers WorldEntity.cs. All1203
raw/resolved library IL bodies, the47-type public surface, eight fixture caller
bodies/flags and both modules' Program/project/dependencies/runtime/deps JSON
match. The only changed implementation flag belongs to RebuildLookup.

Both fresh WorldNormal modules build with zero warnings/errors using pinned
SDK11.0.100-rc.2.26504.105, CoreCLR10.0.13 x64, roll-forward disabled and normal
tiering/PGO. Original408/409/410 tests pass on .NET8/10/11; netstandard2.1 builds.
Existing xUnit2009 path-assertion warnings remain. All48 independent prefix
cases pass per module, including both widths and all six access patterns.
All callbacks/storage use task-owned synthetic data/TEMP; no database, user
world or application is started.

The single original driver holds shared legacy/central host admission through
builds, metadata, regressions, semantic checks and native capture. Its PID,
start/completion markers and pre-execution dependency snapshots are retained;
the audit matches each frozen script/fixture/protocol hash. No producer was
replaced or rerun. Both native diagnostic targets join successfully and bind
the exact normal binaries. Their52 indexed Tier1/OSR listings include sixteen
complete final Tier1 callers.

| Actual normal Tier1 caller | Control bytes / fixed rsp subtraction | P38 |
|---|---:|---:|
| UInt32 Get | 3731 / 408 | 3412 / 408 |
| UInt32 LOD | 4195 / 424 | 3872 / 424 |
| UInt32 Chunk | 2700 / 264 | 2376 / 264 |
| UInt32 Topology | 4433 / 456 | 4099 / 440 |
| UInt16 Get | 3923 / 424 | 3603 / 424 |
| UInt16 LOD | 4367 / 440 | 4047 / 440 |
| UInt16 Chunk | 2700 / 264 | 2377 / 264 |
| UInt16 Topology | 4600 / 456 | 4287 / 472 |

Every candidate caller shrinks313–334 bytes, removes inlined clear sites and
calls RebuildLookup directly. Its standalone helper is278 bytes/fixed rsp32 and
retains the required clear/reinsertion work. Reference/non-reference clear
alternatives are static sites, not two executed clears. Six caller reservations
are unchanged, UInt32 Topology reserves16 fewer bytes, and UInt16 Topology
reserves16 more. Seven of eight callers pass the frozen combined gate; the last
fails its no-larger-frame requirement. This rejects continuation under that
prospective rule; it does not establish a timing regression or an externally
required stack limit.

Outlining the this-only helper avoids P37's selected large-address/fifth-argument
boundary, but it does not guarantee a smaller complete caller frame. Register
allocation and code shape still require actual inspection. These isolated
diagnostic PGO snapshots are separate from quiet performance evidence, may
differ from eventual timed versions, and do not prove cache/spill/branch causes
or total stack usage. P37/P38 native controls belong to their own fresh captures;
they are not substituted to select a favorable size delta.

Phase30 retains the original source/binary/metadata/test/native evidence,
complete original test modules/dependencies, revised hypothesis and frozen driver
snapshots:4,374,930 bytes,419 mapped paths,207 unique blobs,one catalog,zero
comparative metric rows. SHA256:
`b0827efba0e4c806e928194ed3bdc127ecd4a7dfcf7329e7442b918968ff4f66`.
CRC, every length/hash/mapping, catalog and required original binary/driver path
verify. The archive exporter now retains Python/PowerShell/protocol files in
task-owned driver-source snapshots; existing archives remain immutable.

The next higher-level lead is terminal validation in the separate P31 compact
R format. Its level1/nonuniform path currently invokes eight level0 validations
and reloads their origins. A candidate may inspect four bounded two-word rows
and validate zero LOD bits directly. It must also reject a redundant eight-equal
level0 cube: zero high bits alone is insufficient for canonical validation.
Prove equivalence and malformed-input/bounds behavior before implementation,
retain all original uniform/coarser paths, byte format, writer selection and
parent-source identity. Do not combine P32/P33 or these rejected annotations.
Freeze the independent model, complete corpus/regression/native gates and timing
question before data. No new candidate exists at this checkpoint.

Both compiler-boundary probes remain rejected records. P36 remains inconclusive.
Actual byte/one-channel consumers and full affected API/construction/mutation/
storage/allocation qualifications, independent confirmation and the complete10x
objective remain open. Production library is still f0772c8; no package or remote
branch is written.

Research integrates directly into main; unrelated docs/articles remains
untouched. No temporary branch/worktree exists. The active task retains
D:\Workspaces\AI\voxtree-point-lod-20261020 for immutable samples and required
source/binary inputs; cleanup follows completion and verified shutdown.
