# Compact-word format prerequisites

Integration branch main, parent commit 06ad1d6. Production remains f0772c8,
NuGet 2.0.28. P31 hypothesis hyp-d50b2aa2043b4f68b5cb8d0b8a649761
implements the prospectively specified R/version3 format on complete P30.
P30 remains an unpromoted control; P29 is excluded. The public-method 10x
objective remains active. No timing or allocation benefit is established.

The private candidate encodes one little-endian UInt16 per selected cell:
13 raw value bits and 3 canonical leaf-LOD bits. It retains Q's bounded
selection heuristic, then enforces raw <=8191 and encoded <=2.5 released bytes.
Higher values retain exact published O/v1/v2 fallback bytes. Unpublished P/Q
formats are rejected. No additional lookup array, cache, object field or
first-read work is introduced. Count consumers validate visited LOD fields
and apply word masks using vector loops and safe scalar tails. Other query
ordering, ownership and error contracts are retained.

Paired source review checks the complete P30 control independently of candidate
filenames. The first build exposed a rig bug: deleting the candidate's palette
helper also omitted that helper from the control snapshot. The failed build is
retained; Build-Rig now snapshots each complete arm independently. Fresh
p31setup2, p31bulk and release-controlled p31census builds pass.

Independent byte/partition tests and original regressions pass 410/411/412 on
.NET 8/10/11; 411 pass on .NET 10 with intrinsics disabled. The first fixture
had a depth-2 out-of-range index; that isolated failure is retained alongside
the corrected fresh test identity. All 48 point and 96 bulk semantic scenarios
pass. A separate writer oracle checks 378 cases, 16,178,022 cells and 2,920
capacities, including Morton/linear, widths 1/2/4/8/16, depths 0..6, exact bytes,
fallback bits, short-buffer prefixes and destination tails.

The immutable full-world census checks all 1,286 chunks, 686 distinct arrays
and 42,139,648 cells. Each compact payload word is independently reconstructed
from dense values and maximal uniform cubes. Published release controls verify
value/LOD semantics and exact fallback bytes; an aliased complete P30 witness
verifies selection. Every selected length matches the frozen K2 projection.
The first census preflight used the wrong provenance source path and stopped
before compilation/scanning; its prepared sources are retained. The corrected
run uses a fresh evidence identity with the original paired bundle unchanged.

| Logical API | Selected chunks | Release encoded bytes | Candidate encoded bytes |
|---|---:|---:|---:|
| Classic UInt32 | 132 | 13,693,396 | 18,659,626 |
| Generic UInt16 | 142 | 13,694,682 | 19,052,144 |
| Generic UInt32 | 132 | 13,694,682 | 18,660,912 |

Actual classic encoded-plus-distinct-lookup payload is 44,613,886 bytes versus
48,861,892 released (-8.69%). Encoded bytes alone grow 36.3%. All selected
chunks fit existing maximum capacities and the prospective 2.5 growth bound.
These are payload measurements; they exclude CLR headers, GC retention,
compressed bytes, allocation and game access-frequency inference.

Nine isolated native captures index 148 optimized listings, including OSR.
All eight final Tier1 owned/span Get/LOD callers contain the compact word
load, LOD shift/check and value mask. The count helper contains vector word
loads, LOD comparison, equality masks/popcount and bounded scalar tails.
Builder and canonical validator code is retained. Eighteen relevant complete
Tier1 methods are separately audited with code sizes and fixed rsp reservations.
Multi-operation caller listings do not identify every dynamic hot branch;
fixed reservations exclude pushes, recursion and callees. No PMU, total-stack,
causal-share or exact quiet-code identity claim follows.

Phase16 preserves prerequisites only: 2,706,107 bytes, SHA256
a31722614537fed9bf649e91aead773ec35b9b56fa512bf018806f7d8d6287d1,
664 paths, 343 unique blobs, one catalog and zero metric rows. The verifier
explicitly distinguishes a prerequisite-only archive from missing measurements.

Next gate: frozen .NET 10.0.13 quiet point48/bulk96 screens, original budgets,
seeds20261103/20261104, source unchanged and shared host admission. Each family
plans all cases before data. Fresh direct-release normal confirmation remains
mandatory for the eight 10x endpoints, followed by all API/memory/consumer
guards. Prerequisite results do not qualify source promotion or release.

The task workspace D:\Workspaces\AI\voxtree-point-lod-20261020 remains needed
for the active investigation. No temporary worktree or branch was created.
