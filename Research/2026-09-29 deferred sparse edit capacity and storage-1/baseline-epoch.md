# Baseline epoch

- Investigation: deferred sparse edit capacity, lookup, ownership, and channel-local promotion.
- Product baseline revision: `85d7a99ff87ce04c455e8c8ede5f938b9ed5e211`.
- Benchmark epoch revision: `337cf2b` plus the high-occupancy case extension committed before measurement (`codex/deferred-capacity`).
- Initial product state: clean; only research and benchmark fixtures differ from the product baseline before measurement.
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
