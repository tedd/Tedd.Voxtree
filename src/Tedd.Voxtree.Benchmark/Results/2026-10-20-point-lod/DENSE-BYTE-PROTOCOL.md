# Dense-byte candidate (P6)

Objective: move serialized UInt32 point and LOD APIs toward 10x by removing
traversal, while accelerating size calculation, encoding, decode and bulk/query
consumers where measurements support it. This is a new algorithm and wire-format
study, not additional samples of P1. The user expressly permits file/memory
format changes. Full public-method target and .NET 10 steady-state priority
remain unchanged.

Control is f0772c8, including all legacy format support. Develop P6 in a separate
task-local source fork; do not change production files while prior candidates'
guard work is incomplete. Use the existing shared host locks across dependent
builds, validation, diagnostics and measurements.

## Representation and semantic proof obligations

- Select a one-byte-per-voxel linear payload only when every input value is in
  0..255 and no aligned 2³ cube is uniform. The latter proves that the canonical
  tree has no stored leaf above LOD zero: every larger uniform aligned cube
  contains a uniform aligned 2³ cube. Test linear and Morton input layouts.
- All fully expanded trees have (N−1)/7 internal nodes and at least nine bytes
  per node plus header/root-length. For N>=8, N+3 packed bytes are strictly less
  than the minimal legacy tree and less than four-byte dense storage. Preserve
  old choices for level zero, uniform, coarse and wide-valued inputs.
- Prospective wire: version 3, storage kind 3, three-byte header (magic, existing
  depth/version/kind fields, UInt32 type code 2), then exactly N raw bytes.
  Keep version-1 UInt32 formats readable. Explicitly document the latest and
  legacy version constants only after finalizing the format contract.
- TryGet, Get, GetLod and indexers preserve value, stored LOD, exception order,
  failure outputs and borrowed-buffer observation. Length/type/version/kind
  validation is mandatory; arbitrary payload bytes are valid values.
- Required size, owned encoding and caller-buffer encoding must choose the same
  representation. Respect capacity, overlap and Morton conversion contracts.
  Eligibility should reject uniform/coarse/wide controls cheaply.
- Update every dense consumer: whole decode, copy/region/neighborhood, filters,
  count/Any, collection, nearest, emptiness, compiled snapshots, chunk/world and
  streaming paths. A faster point path alone does not qualify format adoption.
- Compiled snapshots may expand packed values into the existing four-byte dense
  snapshot to preserve its current read path and allocation/payload contract.
  The source remains immutable and owns/publishes independent snapshots.

## Candidates and risks

P6a eligibility plus dense-byte point/decode layout (A03/A04/M01/M21/M24).
P6b bulk equality/masked filtering over packed bytes (C12/V03/V08), with exact
eight-bit lane arithmetic and a portable fallback. P6c vector widening/narrowing
only after scalar implementation and actual code identify a useful cost.

Risks: eligibility scan regresses sparse/dense builds; changing serialized kind
silently sends consumers down a tree path; discarding coarser LOD; old malformed
tests accidentally exercising only the new format; per-query allocation; code
growth or fallback regression; widening/narrowing changes raw values. Preserve
all failures and test old and new encodings independently.

## Evidence gate

First establish correctness of every affected public consumer, old-format
reading, boundary/truncated/malformed headers, all 256 values, heterogeneous
regions, raw wire lengths, ownership and concurrent publication. Then use actual
default-tiered x64 code and stack evidence to select scalar/SIMD candidates.

Use the precision epoch's longer windows after its unchanged-source controls
qualify. Freeze actual scenario/version/input identities, complete caller work,
guard matrix and fresh-process budgets before P6 timing. Cover 8³/32³/64³ full
low-byte volumes; random/sequential/clipped reads; 127/128/255/256 boundaries;
uniform/coarse/sparse/wide/dense adversaries; all query kinds; constructors,
encoding/decode and compile/read lifecycle; allocation and payload. Baseline
bytes may differ intentionally; independent value/LOD oracles replace byte
parity for the changed format, while unchanged-format controls retain parity.

No point-only ratio, source-level instruction count, theoretical memory saving
or version bump proves the whole-API objective. Keep the goal active until its
full verification requirements are met.
