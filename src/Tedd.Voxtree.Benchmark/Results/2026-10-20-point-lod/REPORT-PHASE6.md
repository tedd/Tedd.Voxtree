# Released-format linear builder specialization

Original integration branch: main. Starting research commit 0bee9b6; production
library remains f0772c8. P22 is an isolated fork of that release, without packed
format, count or prior unqualified changes. The full API objective remains active.

P22 registers hypothesis hyp-0e191f331bc64e918e816f504b9ef0c0, A09/M25/C18.
At linear level one it reads eight Z-first values and directly collapses or
writes their existing tokens. Higher recursion, Morton, storage selection,
ownership and all wire constants remain unchanged. The frozen prediction and
complete primary/guard family are in LINEAR-LEAF-PROTOCOL.md.

Tests passed 396/397/398 on .NET 8/10/11, plus all 397 .NET 10 tests with
intrinsics disabled. The external release oracle passed 252 depth/storage/input
cases: 1,572,858 cells including LODs and 1,879 buffer capacities. It verifies
exact owned/rebuild/caller/Morton bytes, sizes and failed TryBuild mutations.
It includes all five generic storage widths plus legacy UInt32, depths 0..5,
uniform, first/last sparse, per-leaf, fragmented and wide-value distributions.
These are synthetic semantic cases, not an observed access trace.

All 48 point and 88 bulk oracles passed. The frozen version-13 bulk screen
completed all 88 cases and 2,112 correct/quiescent records; target PID 123300,
start ticks 639281383230086043, and its controller joined cleanly. These are
exploratory same-process blocks, not independent confirmation.

| Dominant mixed-u16-air caller | UInt32 speedup | UInt16 speedup |
|---|---:|---:|
| Owned constructor | 3.166 | 2.462 |
| Owned Build | 2.625 | 2.609 |
| Caller-buffer Build | 2.837 | 2.676 |
| TryBuild | 2.761 | 2.690 |
| GetRequiredSize | 2.752 | 2.598 |

All ten primary estimates exceed the frozen 1.25 speedup target. Eight of the
38 mandatory guards are adverse beyond the 5% estimate threshold: mixed-u7
UInt32 buildread 0.937; mixed-u8 UInt32/UInt16 construction 0.951/0.908,
UInt32 sizing 0.899 and buildread 0.810; uniform UInt32 callerbuild 0.945,
UInt32/UInt16 trybuild 0.931/0.888. The full audit retains all 88 effects,
including other unchanged-consumer losses. No observed gain is a tenfold or
universal result, and no epoch is multiplied by prior prototype gains.

Actual selected-bundle parent BuildLinearSubtree bodies grow from 895/885 to
954/944 bytes (UInt32/UInt16, Tier0-FullOpts). The listed rsp subtractions remain
152+96 and 136+64. The new leaf helpers are Tier1, 1687/2304 bytes, with fixed
subtractions 32/160. The level-one branch bypasses the eight-summary allocation,
but this is not a universal reduction in native bytes or total stack usage.
These isolated native diagnostics do not establish exact timed PGO bodies,
front-end/cache events or a causal time share.

Full immutable-corpus validation passed all 1,286 chunks and 42,139,648 cells,
retaining duplicates and the original 686 unique arrays. All three encoded APIs
match release bytes exactly; independent dense LOD partitions, owned/span/
lookup/FromEncoded reads, copy, validation and Count/Any pass. UInt32 encoded
plus distinct lookup payload stays 48,861,892 bytes. The census result SHA-256
is 1e60cfdc8fdf9f7514782f2beb7f54a42003fb0e608f40280cf7f3749a1c4430.
Its copied decoder retains three nullable warnings and no build errors.

The hypothesis is revised to inconclusive, preserving its original prediction
and all adverse guards. Ordinary fresh caller confirmation and original P18
failure localization remain separate gates. No source is adopted.
The inspected 9c23369 confirmation source writes its launch record only after
staging returns. Its finally cleanup can throw and replace an earlier exception;
the outer handler retains only a generic code for non-LabException failures.
Partial remaining launch files therefore do not identify staging, startup or
cleanup as the original cause. This narrows interpretation, not the actual fault.
Task scratch remains D:\Workspaces\AI\voxtree-point-lod-20261020 while active
source/control and immutable region inputs are required. No worktree was created.

The closed phase-six archive retains 36,796 logical paths as 30,442 unique
blobs, 36 catalog exports and 962 cumulative metric rows. Every mapping,
length, hash, CRC and catalog table passed verification, including required
P22 source/oracle/corpus/shutdown/revision records. The archive is 64,696,118
bytes with SHA-256 f63492bb100f55beff49fa9fa614e544dd247270283122bf35590bff032b5dac.
Verification is retained in evidence-phase6-verified.json. Cumulative rows are
not independent experiments. Static PowerShell/Python and whitespace checks
pass; production library source still matches f0772c8.
