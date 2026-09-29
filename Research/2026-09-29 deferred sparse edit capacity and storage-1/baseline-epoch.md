# Baseline epoch

- Investigation: deferred sparse edit capacity, lookup, ownership, and channel-local promotion.
- Exploratory baseline revision: `85d7a99ff87ce04c455e8c8ede5f938b9ed5e211`; exploratory results are retained for hypothesis history only.
- Causal comparison baseline revision: `f9d9b366ede89050800bc97df9fca2a086ab1ce2` (`origin/main` when the matched rerun began).
- Causal comparison candidate revision: `4006838`; its product tree equals the final channel-local implementation after the caller-provider prototype and revert.
- Baseline state: product files exactly match `f9d9b36`; only the candidate benchmark fixture was copied as an untracked file.
- Candidate state: product and benchmark files match `4006838`; only Research artifacts were untracked or modified during measurement.
- Target: Windows x64, .NET 10, AMD Ryzen 9 5950X, AVX2, concurrent workstation GC.
- Benchmark package: BenchmarkDotNet 0.16.0-preview.1.
- Seeded position sequence: `(index * 977 + 1234) & 32767`.
- Primary workload: a 32^3 chunk, one to twenty distinct point writes between publications.
- Secondary workloads: 21, 64, 256, 257, and 512 distinct writes; one changed channel versus all channels; uniform and terrain encodings.
- Primary metrics: owner edit-session time and complete edit-plus-repackage time.
- Secondary metrics: read hit/miss time, allocated bytes, logical and rented buffer capacity, and encoded checksum.
- Retention threshold: at least 10% repeatable improvement in the affected caller workload, no correctness failure, and no regression above 5% in the one-to-twenty-write priority workloads.
- Default-capacity threshold: change only if the full caller path improves beyond noise and the memory tradeoff remains bounded.
- Application boundary: no representative game trace is available; conclusions are library-caller results, not frame-time claims.
- Timed-run exclusion: every timed command must hold `D:\Temp\BenchmarkLock.txt` exclusively and must start only when no other benchmark or build/test worker is active.

## Invariants

- Read-your-writes, including explicit zero and repeated overwrite.
- Independent channels may share a position without aliasing.
- Immutable source and previously returned snapshots remain unchanged.
- Sparse, channel-materialized, fully hot, repackaged, and serialized states are bit-equivalent to the dense reference.
- Unchanged channel encodings remain shared until serialization copies them.
- Narrow and wide keys, generic values of 1/2/4/8/16 bytes, and disabled hardware intrinsics remain correct.
- Every rented or caller-supplied buffer is returned exactly once to its origin.

## Epoch changes

Record source commits, fixture changes, runtime changes, and material background-load changes here before comparing measurements.

- Baseline storage-acquisition screen: .NET 10 ShortRun, recorded under `raw/baseline-storage`.
- Baseline deferred edit-session matrix: .NET 10 ShortRun, 34 cases, recorded under `raw/baseline-edit`; exclusive lease held for the full 4m56s run.
- Source-matched 20-write comparison: .NET 10 MediumRun, baseline in `raw/matched-main-base`, candidate in `raw/matched-current-final`.
- Source-matched overflow comparison: .NET 10 ShortRun, baseline in `raw/main-base-overflow`, candidate in `raw/current-final-overflow`.
- Integrated caller-provider prototype: .NET 10 MediumRun at `0838be1`, recorded in `raw/integrated-provider`; the prototype was removed by `4006838`.
