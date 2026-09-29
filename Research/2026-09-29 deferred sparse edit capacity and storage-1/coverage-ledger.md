# Optimization catalogue coverage

| Catalogue category | Applicability | Evidence / hypotheses | Disposition |
|---|---|---|---|
| M1 Allocation and initialization | Direct | H-001, H-006, H-007, H-011, H-012 | Short-lived exact arrays, geometric growth, and the caller-provider speed prototype were rejected. Shared pools remain. Deterministic-memory utility was not measured. |
| M2 Stack storage | Not applicable | Pending overlays outlive one call and may reach chunk volume | Lifetime and size preclude stack storage. |
| M3 Arrays and bounds checks | Inspected | Sparse arrays use bounded spans; no measured bounds-check hotspot | No candidate established. |
| M4 Managed references and raw pointers | Inspected | Managed pooled arrays already provide stable ownership | No pointer candidate justified by profiling. |
| M5 Layout and working set | Direct | H-001, H-002, H-012, H-018 | Partial dense state retained; geometric growth rejected; cache-line grouping remains inconclusive. |
| M6 Addressing, prefetch, and alignment | Conditional | H-016, H-017 | Prefetch is not applicable to the measured warm sequential decoder; direct mapping remains inconclusive. |
| M7 Copies and buffer traffic | Direct | H-002, H-008, H-011, H-014, H-015 | Channel-local publication retained; caller scratch rejected as a speed feature; bitmap iteration remains inconclusive. |
| S1 Bitmaps and bulk updates | Conditional | H-014; direct-map validity would require additional metadata | Presence-word iteration remains inconclusive. |
| S2 Lookups and hashing | Direct | H-004, H-005, H-009, H-013, H-017, H-022 | `Span.IndexOf` SIMD retained; last-key caching and a direct map remain inconclusive; the integrated pooled index was rejected. |
| S3 Frozen collections | Not applicable | Per-chunk overlays mutate until publication | Frozen storage cannot serve the mutation path. |
| S4 Storage and query preparation | Inspected | No query-preparation phase exists in this path | No candidate established. |
| S5 Compression and runs | Direct | H-002, H-008, H-015 | Channel-local decode and encode retained. |
| C1 Dependency latency and throughput | Direct | H-008, H-014, H-020 | Secondary sparse-application and stencil loops remain inconclusive without representative traces. |
| C2 Branches, prediction, and layout | Direct | H-004, H-010 | Last-key caching remains inconclusive; startup-frozen feature flag rejected. |
| C3 SIMD | Direct | H-009 and generated-code evidence | Handwritten SIMD rejected; runtime `Span.IndexOf` retained. |
| C4 Intrinsics and strength reduction | Inspected | H-009, H-013, H-016 | Explicit intrinsics did not establish a suitable candidate. |
| T1 False sharing | Not applicable | H-019 | Chunk editors have exclusive ownership; no concurrently written cache line was identified. |
| T2 Ownership and publication | Direct | H-002, H-006, H-011 | Immutable encoded channels and exclusive pooled buffers preserved. |
| T3 Locks and waiting | Inspected | Store publication already serializes ownership transfer | No contention profile established a lock bottleneck. |
| T4 Scheduling, batching, and I/O | Conditional | H-020 and the pending-address store API | Representative client scheduling traces were unavailable. |
| R1 Dispatch and lookup tables | Direct | H-005, H-017, H-022 | Integrated pooled index rejected; alternative index and direct-map forms remain inconclusive. |
| R2 Inlining, specialization, and copies | Inspected | Generic and `uint` paths benchmarked separately | No remaining measured dispatch or copy hotspot. |
| R3 Startup-frozen feature flags | Direct | H-010 | Rejected after mixed -2.8% to +0.5% measurements. |
