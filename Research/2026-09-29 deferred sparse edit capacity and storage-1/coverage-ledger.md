# Optimization catalogue coverage

This ledger records applicability to the deferred sparse-edit path. Measurements and final dispositions are added without deleting rejected hypotheses.

| Catalogue area | Applicability | Hypotheses / evidence | Disposition |
|---|---|---|---|
| M1 Allocation and pooling | Direct | H-001, H-006, H-007, H-011, H-012 | Pending integrated measurement. |
| M2 Copies and lifetime | Direct | H-002; immutable snapshots and borrowed hot storage | Pending channel-promotion experiment. |
| M3 Bounds and slicing | Direct | Existing `Span.IndexOf`; key/presence/value bounds | Generated code already vectorizes lookup; no independent bounds hypothesis yet. |
| M4 Stack allocation | Not applicable | Pending overlays outlive one call and may hold up to chunk volume | Rejected by lifetime and size. |
| M5 Layout and working set | Direct | H-001, H-002, H-012 | Pending geometric-growth and partial-dense measurements. |
| M6 Structure representation | Direct | Shared keys plus channel bitmaps | Retain unless channel-specific redesign demonstrates a caller gain. |
| M7 Memory traffic | Direct | H-002, H-008, H-011 | Pending. |
| S1 Bitmaps/direct maps | Conditional | A direct 32^3 position map costs at least 64 KiB with `ushort` slots before validity metadata | Defer unless occupancy trace justifies large-count indexing. |
| S2 Lookup/indexing | Direct | H-004, H-005, H-009 | `Span.IndexOf` SIMD is the incumbent; large-count alternative pending. |
| S3 Ordering/sorting | Not applicable | Sorting would shift shared values and validity metadata on insertion | Rejected structurally for the priority append/overwrite path. |
| S4 String/text processing | Not applicable | No text in the hot path | Not applicable. |
| S5 Compression/encoding | Direct | H-002, H-008, H-011 | Existing sparse repackage already encodes changed channels only; overflow remains pending. |
| C1 Loop shape | Direct | H-008 | Pending channel-specific edit iteration. |
| C2 Branch behavior | Direct | H-004 and the instance enable branch | Last-key branch pending; enable branch previously measured within noise. |
| C3 SIMD/vectorization | Direct | H-009 and existing generated code | Handwritten SIMD rejected; runtime `Span.IndexOf` retained. |
| C4 Intrinsics | Conditional | Existing AVX2 code generation | No new intrinsic candidate without a representation change. |
| C5 Arithmetic | Minor | Coordinate-to-key and Morton conversion | No measured attribution; defer. |
| C6 Spatial/Morton | Minor | Dense channels are Morton ordered | Existing prior investigation selected Morton order; no new evidence to reopen. |
| R1 Dispatch/inlining | Direct | Integrated lookup and any provider call | Inspect generated code for retained candidates. |
| R2 Specialization | Direct | `ushort` keys through level 5; `int` above | Existing specialization retained. |
| R3 Startup/static flags | Direct | H-010 | Rejected by prior toggle measurement. |
| R4 Tiering/PGO/AOT | Control | BenchmarkDotNet .NET 10 Tiered PGO environment | Controlled as an epoch variable; no product candidate. |
| T1 Shared mutation | Not applicable to owner | `DeferredOctreeChunk` is exclusively owned and not thread-safe | Store synchronization remains separate. |
| T2 Ownership and leasing | Direct | H-006, H-011 | Caller scratch is the lowest-risk candidate; persistent provider pending evidence. |
| T3 Locks/contention | Conditional | `DeferredChunkStore` holds one lock through repackaging | No representative contention trace; outside primary local experiment. |
| T4 Batching | Direct | H-011; store batch can reuse one channel scratch buffer | Pending. |
| T5 False sharing | Not applicable | Owner is not concurrently mutated | Not applicable. |

## Existing generated-code evidence

The .NET 10 `Span<ushort>.IndexOf` path used by `SparseVoxelEdits.Find` emitted AVX2 `vpcmpeqw` and `vptest` in the prior investigation. Explicit `Vector256` and padded searches did not improve the integrated owner/read caller and remain rejected unless the representation changes.

## External-validity boundary

No Forcecraft edit trace has yet supplied the distribution of distinct positions per publication, repeated-write ratio, channels touched, or read hit/miss frequency. Capacity conclusions therefore apply to the documented synthetic library workloads. An application default should be revisited when that trace exists.
