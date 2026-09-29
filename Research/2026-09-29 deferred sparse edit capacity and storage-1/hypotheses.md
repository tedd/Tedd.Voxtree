# Hypothesis ledger

## H-001 — capacity and pool buckets

- Claim: the default capacity of 256 over-reserves pooled key/value storage for the priority one-to-twenty-write workload; a capacity at a lower `ArrayPool` bucket boundary reduces acquisition and cache cost without forcing premature promotion.
- Mechanism: requested capacity controls pool bucket size and promotion threshold, while lookup scans only populated entries.
- Prediction: one-to-twenty-write caller medians improve by at least 10% or retained payload falls by at least 4x with less than 5% time regression.
- Falsification: timings remain within noise and memory is not operationally material, or lower capacity regresses complete cycles above 5%.
- State: pending.

## H-002 — channel-local promotion

- Claim: when a sparse overlay reaches capacity, decoding only the written channel removes work proportional to unchanged channel count.
- Mechanism: preserve unchanged channel encodings; materialize one Morton-order channel; re-encode only materialized or sparsely edited channels during repackage.
- Prediction: capacity-plus-one edit sessions with one changed channel improve by at least 50% for eight-channel chunks and by at least 20% for two-channel chunks, without more than 5% regression below capacity.
- Falsification: caller gains miss those thresholds, serialization ceases to share/copy unchanged channels correctly, or memory/lifetime costs dominate.
- Change: on sparse overflow, materialize the channel that frees the most exclusive positions into a pooled Morton-order buffer, compact residual shared keys, and retain untouched channel encodings. Explicit `MakeHot()` still expands all channels.
- State: implemented; validation and candidate measurement pending.

## H-003 — smaller default enabled by channel-local promotion

- Claim: after channel-local promotion, capacity 32 is a better default than 256 for sparse environmental edits because it occupies the same common pool buckets as capacity 20 while bounding quadratic insertion scans.
- Mechanism: promote one channel at 33 distinct positions instead of retaining increasingly expensive linear searches to 256.
- Prediction: the weighted 1/5/20/32/64/256 caller matrix improves by at least 10% overall, with no priority-case regression above 5%.
- Falsification: capacity 32 causes more than 5% regression in realistic complete cycles or multi-channel workloads.
- State: pending.

## H-004 — repeated-key cache

- Claim: caching the last resolved key index accelerates repeated writes and same-position multi-channel updates.
- Mechanism: bypass `Span.IndexOf` when the next key equals the preceding key.
- Prediction: repeated-position sessions improve by at least 10% with less than 2% regression for distinct random writes.
- Falsification: branch cost offsets the saved lookup or predictor-sensitive regressions exceed 2%.
- State: pending.

## H-005 — large-count index

- Claim: a hybrid hash or direct index becomes faster than vectorized linear search at sufficiently large populated counts.
- Mechanism: replace cumulative O(n^2) insertion searches with expected O(1) lookup after a threshold.
- Prediction: at 256 or more distinct positions, insertion-session time improves by at least 20% after including index construction and maintenance.
- Falsification: crossover occurs outside justified occupancies, or memory and small-count regressions exceed the benefit.
- State: pending.

## H-006 — caller-provided typed buffer provider

- Claim: a caller-owned typed provider with shared-pool fallback materially reduces acquisition/return cost or retained process memory for repeated owners.
- Mechanism: reuse heterogeneous key, presence, value, and dense scratch segments while preserving lazy channel allocation.
- Prediction: repeated caller sessions improve by at least 10% or retained-memory behavior improves materially without a hot-path virtual/interface call.
- Falsification: warm shared-pool caller timings remain within 5%, or the API/lifetime burden exceeds the measured benefit.
- Evidence: an isolated caller-reused array kernel cost 3.399–5.194 ns, versus 42.705–53.039 ns for warm shared-pool rent/clear/return. This establishes an approximately 40–50 ns acquisition ceiling, but it excludes provider dispatch, ownership bookkeeping, lazy heterogeneous segments, and the complete owner path.
- State: deferred. The maximum isolated saving does not yet justify a persistent public ownership API; reopen only if an integrated provider clears the 10% caller threshold or an application memory budget requires deterministic external storage.

## H-007 — exact owned arrays

- Claim: exact owned arrays outperform shared pooling for long-lived owners by avoiding rent/return and bucket inflation.
- Mechanism: trade GC allocation and zeroing for exact capacity and direct ownership.
- Prediction: long-lived edit/repackage sessions improve by at least 10% with acceptable allocation and GC cost.
- Falsification: construction, zeroing, or GC regresses the complete caller path.
- Evidence: exact allocation cost 15.730 ns/208 B at capacity 20, 58.978 ns/1,672 B at 256, and 111.654 ns/3,272 B at 512. Warm shared-pool rent/clear/return cost 42.705–53.039 ns with no managed allocation.
- State: rejected. Exact arrays become slower than pooling at the default and larger capacities and add per-session GC allocation.

## H-008 — channel-specific sparse iteration

- Claim: tracking channel edit counts and iterating only present values reduces edit application cost during promotion and repackage.
- Mechanism: avoid scanning every shared position for sparsely touched channels.
- Prediction: many-position, few-edits-per-channel repackaging improves by at least 10% after maintenance cost.
- Falsification: bookkeeping cost offsets application savings in caller benchmarks.
- State: pending.

## H-009 — explicit SIMD lookup

- Claim: handwritten SIMD improves position lookup over `Span.IndexOf`.
- Prior evidence: rejected; .NET 10 already emits `vpcmpeqw`/`vptest`, and the integrated handwritten variant regressed owner/read workloads.
- State: rejected. Reopen only if the representation or target ISA changes materially.

## H-010 — startup-frozen deferred-write flag

- Claim: replacing the per-instance enable branch with a startup-frozen switch materially improves point writes.
- Prior evidence: rejected for this investigation; measured effect was -2.8% to +0.5%, inside the declared 5% noise band.
- State: rejected.

## H-011 — repackage scratch ownership

- Claim: retaining or caller-supplying the full-channel scratch buffer reduces repackage overhead versus one shared-pool rent/return per call.
- Mechanism: remove one large buffer acquisition per publication.
- Prediction: complete cycles improve by at least 10% without raising idle memory disproportionately.
- Falsification: encoding/decoding dominates and the effect remains within 5%.
- Evidence: warm shared-pool acquisition and return of the measured buffers cost at most 53.039 ns, while existing complete sparse cycles cost at least 15.2 µs. Even eliminating the entire measured acquisition kernel has an Amdahl ceiling below 0.4%; a call-bound scratch API cannot meet the 10% speed criterion on this evidence.
- State: rejected as a speed feature. A caller workspace may still be justified by a separate deterministic-memory requirement, which has not been supplied.

## H-012 — geometric physical growth

- Claim: retaining the logical capacity while initially renting 32 key/value slots and growing geometrically removes default-capacity over-reservation from the one-to-twenty-write workload.
- Mechanism: allocate physical storage at `min(32, Capacity)` and double only when the populated count reaches the physical limit; keep `Capacity` as the externally visible promotion threshold.
- Prediction: default-capacity pooled payload for one modified `uint` channel falls from approximately 1,664 bytes to approximately 320 bytes at up to twenty writes, while caller time changes by less than 5%; any speed improvement is secondary.
- Falsification: growth causes more than 5% regression in priority workloads, introduces pool-return or validity defects, or retained memory does not fall as predicted.
- Change: sparse key and value buffers begin at `min(32, Capacity)` and double to the unchanged logical limit; presence metadata grows only when its word stride changes.
- State: implemented; validation and candidate measurement pending.

## H-013 — AVX2 batched key probes

- Claim: probing several requested positions together can amortize key-vector loads when callers issue spatially clustered reads or writes.
- Mechanism: compare one loaded `Vector256<ushort>` key block against several broadcast keys before advancing to the next block.
- Prediction: a new batch lookup kernel improves 8–32-position batches by at least 20% at overlay counts of 64–256 without regressing scalar access.
- Falsification: callers cannot supply batches, key broadcasts dominate, or the integrated batch remains within 10% of repeated `Span.IndexOf`.
- State: pending; requires a batch API workload and is not applicable to the existing scalar indexer by itself.

## H-014 — presence-bitmask sparse application

- Claim: iterating set bits for each channel is faster than scanning every shared key during materialization and repackaging.
- Mechanism: read each channel's `ulong` presence words, use trailing-zero count to enumerate present indexes, and skip absent positions in groups of 64.
- Prediction: applying sparse edits improves by at least 10% when one channel owns at most 25% of a shared table, with less than 2% regression at full occupancy.
- Falsification: bit enumeration and word indexing cost at least as much as the current predictable scan.
- State: pending; specialization of H-008.

## H-015 — contiguous block copy for partial channels

- Claim: copying an already materialized Morton channel into explicit full-hot storage is materially faster than reconstructing it from encoded data.
- Mechanism: use one contiguous span copy for each partial channel while `MakeHot()` decodes only channels still encoded.
- Prediction: partial-state `MakeHot()` improves by at least 10% per materialized channel relative to decoding every channel.
- Falsification: the remaining channel decodes dominate or the JIT fails to lower `Span.CopyTo` to efficient block copy.
- Change: the channel-local candidate already uses `Span.CopyTo`; measurement remains pending.
- State: implemented; measurement pending.

## H-016 — software prefetch before channel decode

- Claim: prefetching encoded channel bytes before overflow materialization reduces decode stalls for large nonuniform encodings.
- Mechanism: issue target-specific prefetches several cache lines ahead of the decoder.
- Prediction: terrain-channel materialization improves by at least 10% with stable uniform-channel performance.
- Falsification: hardware prefetch already covers sequential decode, managed intrinsic support is unsuitable, or added instructions regress warm-cache operation.
- State: pending; target-specific and lower priority than measured channel-count work.

## H-017 — direct position bitmask/index map

- Claim: a direct map from voxel position to sparse slot outperforms linear key search at high occupancy.
- Mechanism: maintain a generation-tagged slot table indexed by packed voxel position; use a bitmask when the volume is a power of two.
- Prediction: insertion and hit/miss lookup improve by at least 25% above the measured crossover while total retained memory remains below one dense channel.
- Falsification: the 32³ map's 64–128 KiB footprint or reset cost outweighs the saved search time.
- State: pending; compare with H-005 and H-022.

## H-018 — cache-line grouped overlay layout

- Claim: grouping key, channel-presence summary, and commonly written values into cache-line-sized blocks improves locality over separate arrays.
- Mechanism: use an array-of-small-structures layout while preserving vector-searchable key lanes.
- Prediction: mixed write/read sessions at 64–256 positions improve by at least 10% without increasing one-channel retained payload by more than 25%.
- Falsification: gather/scatter and generic value width defeat vectorized key search or inflate sparse memory excessively.
- State: pending; representation prototype required.

## H-019 — false-sharing-resistant store scheduling

- Claim: separating frequently updated pending-state metadata from chunk-owner references improves concurrent store throughput.
- Mechanism: shard the store or pad independently mutated queue metadata so worker threads do not invalidate the same cache line.
- Prediction: a contended multi-thread store benchmark improves throughput or p99 latency by at least 15%.
- Falsification: the store's single lock dominates, no cache line is concurrently mutated, or isolated owners remain the actual workload.
- State: pending but outside the single-owner primary path; requires a contention trace.

## H-020 — stencil-aware run overlay

- Claim: spatially coherent edits from growth or simulation stencils can be stored and applied as short Morton runs more efficiently than independent keys.
- Mechanism: coalesce adjacent Morton positions with identical channel/value operations and block-copy or fill them during materialization.
- Prediction: clustered 3x3x3 and planar-stencil workloads improve by at least 20% in time or halve overlay payload, while random edits retain the scalar representation.
- Falsification: coordinate-to-Morton ordering fragments the stencil or run maintenance costs more than individual entries.
- State: pending; requires representative clustered traces.

## H-021 — adaptive capacity by channel and source cost

- Claim: a fixed default threshold is inferior to a threshold derived from channel count, value width, and measured encoded-channel decode cost.
- Mechanism: keep the public maximum as an upper bound but materialize a channel when its estimated sparse search/application cost exceeds one decode.
- Prediction: a weighted multi-channel workload improves by at least 10% with bounded retained memory and deterministic behavior.
- Falsification: estimation overhead or source variability causes unstable promotion and more than 5% regression in priority cases.
- State: pending; no application distribution currently supplies valid weights.

## H-022 — pooled open-addressed index above a threshold

- Claim: building a pooled open-addressed key-to-slot table only after 256–512 entries removes the observed quadratic insertion growth without taxing small overlays.
- Mechanism: retain SIMD linear search below the crossover, then build a power-of-two integer slot table and update it on append or compaction.
- Prediction: 1,024–4,096 distinct-write sessions improve by at least 30%, with less than 2% regression below 256 and lower retained memory than a volume-sized direct map.
- Falsification: build cost, pool clearing, collisions, or compaction maintenance eliminates the high-count gain.
- State: pending; threshold must be selected from H-005 kernel measurements.
