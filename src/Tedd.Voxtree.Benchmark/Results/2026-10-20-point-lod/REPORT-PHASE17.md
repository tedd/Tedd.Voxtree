# Compact-word measurement disposition

Integration branch main; prerequisite commit 59032e4. Production remains
f0772c8 / NuGet 2.0.28. P31 is **not_supported** against its prospectively
specified joint performance criteria. No candidate source or package is promoted.
The complete public-method 10x objective remains active.

The original frozen driver completed both .NET 10.0.13 x64 quiet families:
48 point cases / 1,152 records and 96 complete-operation cases / 2,304 records.
Every case was correct and quiescent; both targets, controllers and the outer
measurement driver joined and exited successfully. Plans preceded observations,
with 12 paired blocks, four warmups and seeds20261103/20261104. Sources, callers,
input metadata and budgets remained frozen. The shared host locks were held;
timed controller operations used Global\Tedd.DotNetLab.Measurement.v1.

The control is complete, unpromoted P30. This is a new source/format epoch,
not a comparison with published release. Same-process pairs are explicitly
non-independent exploratory observations. No old ratios are multiplied and
no fresh normal-build or universal API speed claim follows.

Only one of eight dominant-chunk point estimates meets the frozen >=1.20
threshold; 12 of the other 40 point guards exceed the allowed 1.05 time cost.

| Dominant chunk endpoint | UInt32 speedup vs P30 | UInt16 |
|---|---:|---:|
| Owned Get | 1.201 | 0.986 |
| Owned Get with LOD | 1.143 | 1.010 |
| Span Get | 1.193 | 1.097 |
| Span Get with LOD | 1.069 | 1.035 |

The complete-operation family has 25 adverse guards out of 96. Representative
dominant-chunk results show why isolated gains cannot qualify this format:

| Complete operation | UInt32 speedup vs P30 | UInt16 |
|---|---:|---:|
| Constructor plus first Get | 1.324 | 1.333 |
| Owned Build | 1.276 | 1.136 |
| FromEncoded | 0.769 | 0.763 |
| CopyTo | 0.938 | 0.893 |
| IsWellFormed | 0.831 | 0.785 |
| Full count | 57.228 | 151.905 |
| Full miss count | 55.687 | 165.567 |
| Seven-cell clipped count | 2.763 | 3.185 |
| Seventeen-cell clipped count | 10.497 | 10.849 |
| Constructor plus 65,536 reads | 1.084 | 1.309 |

The point family's separate compiled lookup creation and lifecycle cases are
0.715 and 0.913 for this chunk. Smaller-tree and uniform cases also include
regressions. Every case, interval, quality flag, allocation observation and
adverse result is retained in the audits, CSV and original catalog exports.

Every observed candidate allocation is zero in all 40 steady-read cases.
This is an observation/accounting check, not a variance-based equivalence claim
or waiver of degenerate allocation model flags. Constructor/build/fromencoded
allocation relative to release is not independently qualified by these
P30-controlled timings. That unresolved guard is explicit; performance failures
already preclude adoption. The independently checked corpus payload remains
44,613,886 combined bytes versus 48,861,892 released (-8.69%), with encoded
bytes alone +36.3%; see REPORT-PHASE16 for exact scope and byte oracles.

The separate diagnostic evidence exposes two narrower follow-up questions:
the compact point path still emits voxel-count, byte-range and slice bounds
checks before its word load; the canonical validator retains general row
validation at one-cell leaves. Its complete Tier1 UInt32/UInt16 bodies are
1,300/1,303 bytes with fixed 168-byte rsp reservations. These observations
justify prechecks of redundant checked-read work and terminal validation;
they do not establish dynamic cost shares, total recursive stack, cache causes
or the effectiveness of either proposed intervention. Register and test each
mechanism separately before combining source changes. P31 remains unpromoted.

Phase17 preserves all 144 comparisons and the revised hypothesis disposition:
7,109,579 bytes, SHA256
57dc0528d1de640a25b1aae0293c410b4e936cb115e4a10750102ee3d960a1b3,
4,793 paths, 4,642 unique blobs, three catalogs and 144 CSV rows. CRC, every
blob hash/length, unique mappings, required records and catalog tables pass
verification. Phase16 retains the complete source/native/corpus prerequisites;
neither archive is overwritten.

The active workspace D:\Workspaces\AI\voxtree-point-lod-20261020 remains needed
for the next investigation. No temporary worktree or branch was created.
