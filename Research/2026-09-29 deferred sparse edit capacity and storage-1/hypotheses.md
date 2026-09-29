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
- State: pending.

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
- State: pending.

## H-007 — exact owned arrays

- Claim: exact owned arrays outperform shared pooling for long-lived owners by avoiding rent/return and bucket inflation.
- Mechanism: trade GC allocation and zeroing for exact capacity and direct ownership.
- Prediction: long-lived edit/repackage sessions improve by at least 10% with acceptable allocation and GC cost.
- Falsification: construction, zeroing, or GC regresses the complete caller path.
- State: pending.

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
- State: pending.

## H-012 — geometric physical growth

- Claim: retaining the logical capacity while initially renting 32 key/value slots and growing geometrically removes default-capacity over-reservation from the one-to-twenty-write workload.
- Mechanism: allocate physical storage at `min(32, Capacity)` and double only when the populated count reaches the physical limit; keep `Capacity` as the externally visible promotion threshold.
- Prediction: default-capacity pooled payload for one modified `uint` channel falls from approximately 1,664 bytes to approximately 320 bytes at up to twenty writes, while caller time changes by less than 5%; any speed improvement is secondary.
- Falsification: growth causes more than 5% regression in priority workloads, introduces pool-return or validity defects, or retained memory does not fall as predicted.
- State: pending.
