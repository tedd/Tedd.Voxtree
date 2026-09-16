# Access-pattern experiments — 2026-09-16

Baseline library: `be2bf3b6d29142317b7dedecfd92b9f7bd5a89b3`.
Measurements use BenchmarkDotNet 0.16.0-preview.1, Windows 11, Ryzen 9 5950X,
and .NET 10.0.12. Supplementary results use .NET 11 preview.
The final implementation is identified by `source-hashes.json`.

These are screening measurements: one launch, three warmups, five measured
iterations targeting 200 ms each, with default tiering/PGO. Benchmark processes
ran sequentially; tests and builds did not overlap measurement. Reports preserve
runtime/CPU metadata, 99.9% confidence intervals, and allocations. They establish
benefits for the specified workloads, not universal speedups or tail-latency guarantees.

## Implemented

- Vectorized masked counting and existence scans for 1-, 2-, 4-, and 8-byte
  generic values, using unsigned storage so custom structs, NaN payloads, and
  signed zero retain exact-bit semantics. Exact equality uses runtime span
  intrinsics. The 16-byte generic path remains scalar.
- Dense count/any dispatch once per query, with complete rows combined into
  contiguous slabs. Narrow UInt32 rows retain scalar handling and branchless
  count accumulation. Small filter wrappers carry targeted inline hints.
- Optional immutable UInt32 `OctreeLookup`, using 32-bit array indexes and
  predecoded tokens. Nodes occupy 36 bytes, without native pointers, pinning,
  unsafe library code, or a serialized-format change.

```csharp
var lookup = tree.CreateLookup();                 // Captures one owned Octree snapshot.
var channelLookup = chunk.GetChannel(0).CreateLookup(); // Independently owned span snapshot.
uint material = lookup.Get(x, y, z);              // Lock-free repeated point reads.
```

Compilation is explicit. Rebuilding/replacing the source does not refresh an
existing lookup. Owned dense trees share their immutable encoding; borrowed
dense spans are copied so callers can reuse their storage. Uniform lookups retain
one value. This compiled API currently covers UInt32, not `Octree<T>`.

## Query results

| Operation | Volume / shape | Before | After | Speedup |
| --- | --- | ---: | ---: | ---: |
| MaskedCount | 32³ / full | 83,743.41 ns | 3,079.29 ns | 27.20× |
| GenericMaskedCount | 32³ / full | 129,228.23 ns | 2,638.70 ns | 48.97× |
| GenericEqualityCount | 32³ / full | 46,725.04 ns | 2,241.05 ns | 20.85× |
| AnyMissing | 32³ / full | 74,503.18 ns | 2,831.22 ns | 26.32× |
| GenericMaskedCount | 32³ / strided | 119,250.40 ns | 9,065.46 ns | 13.15× |
| MaskedCount | 8³ / strided | 962.74 ns | 595.67 ns | 1.62× |
| EqualityCount | 8³ / strided | 318.23 ns | 217.25 ns | 1.47× |
| AnyFirst | 32³ / full | 36.54 ns | 31.61 ns | 1.16× |

Inputs are deterministic dense random 8³/32³ volumes. Full queries include the
whole volume; strided queries omit the last Z column of every row. Counts return
checksums; setup validates all methods against a scalar oracle. Immediate-hit
and absent-hit cases are included to detect early-exit regressions. All measured
query and point-lookup operations allocate zero managed bytes after setup.

The `AccessFilterWidths<T>` scalar controls scan the source array directly and
exclude tree validation/dispatch. They test byte, ushort, uint, and ulong on
full and strided 32³ volumes. These are scalar controls, not archived public-API
baselines. See the width-specific reports for their results.

## Compiled point lookup

Same-run production API comparison (`confirm-*AccessTraversal*`):

| Pattern / access | Encoded span | Compiled snapshot | Speedup |
| --- | ---: | ---: | ---: |
| Sparse / sequential | 26.319 ns | 8.207 ns | 3.21× |
| Sparse / random | 46.517 ns | 8.061 ns | 5.77× |
| Clustered / sequential | 7.704 ns | 3.282 ns | 2.35× |
| Clustered / random | 10.712 ns | 3.733 ns | 2.87× |

These use level-5 trees and a repeated 1,024-coordinate sequence. They are warm
single-chunk tests, not cold random access across an entire streamed world.

| Payload | Encoded bytes | 36-byte index bytes | 64-byte padded index bytes | Dense bytes |
| --- | ---: | ---: | ---: | ---: |
| Sparse | 9,450 | 30,276 | 53,824 | 131,072 |
| Clustered | 30 | 108 | 192 | 131,072 |

Owned compilation measured about 75.8 µs / 30,352 B allocated for sparse data,
and 251 ns / 184 B for clustered data, including validation. The approximate
sparse random-read break-even is 2,000 reads: compilation time divided by the
38.5 ns saved per lookup. This ignores cache competition and future source
replacement, and is not a universal threshold.

An owned dense lookup allocates only its 48-byte wrapper; borrowed dense
compilation copies the encoding and measured about 54.8 µs / 131,178 B.
`StorageBytes` reports retained payload, not total CLR allocation; dense
payload can be shared. The source tree's memory remains additional if retained.

The direct dense-array control reads in roughly 1.4–1.6 ns, excluding decode and
allocation and bypassing the public coordinate checks. Existing dense channel
spans remain appropriate for intensive editing or scans. Compiled indexes occupy
less space than a dense expansion for these compressed workloads.

The supplementary .NET 11 preview run also favored compiled lookups:
54.84 → 7.89 ns for sparse random reads and 10.41 → 3.70 ns for clustered
random reads. All four SIMD widths beat their scalar controls for both shapes;
strided speedups ranged from approximately 5.2× to 6.5×. These compare the final
implementation against same-run controls, not an archived .NET 11 library.

## Other hypotheses and decisions

| Hypothesis | Evidence / decision |
| --- | --- |
| Remove branches through calculation | Existing octant selection and power-of-two routing already use shifts/masks. Specialized count/any loops remove per-row operation dispatch; scalar count tails use arithmetic. Keep validation and leaf/branch decisions where required. |
| Inline varint decoding | Benchmark-only single-byte fast readers, with and without forced inlining, were generally slower than current traversal. No codec change retained. Small filter inlining is part of the measured query implementation; no isolated universal inlining claim is made. |
| Prefetch future addresses | `Sse.Prefetch0` with 16/64-read lookahead reduced 128 MiB random reads from 8.17 ns to 6.64/6.40 ns. Sequential access became 63–81% slower. No default prefetch: ordinary point calls lack a known future address stream; consider only a measured future bulk-query API. |
| Cache-line alignment | The 64-byte aligned/padded prototype had no consistent advantage over 36-byte nodes and used 78% more index space. The prototype also changes managed bounds checks/native ownership, so it does not isolate alignment alone. No padding retained. |
| 32-bit addresses | World branch links already use 32-bit integers; encoded trees use compact relative offsets. Compiled lookups use 32-bit array indexes. Native 64-bit pointers and GC references are never truncated. |
| New `Lock` versus slim lock | One-worker reads: 8.14 ns versus 19.20 ns. Four-worker reads: 66.47 ns versus 27.03 ns. Preserve shared-reader/exclusive-writer world semantics; no default replacement. |
| Spin instead of locking | `SpinLock` was 7.50 ns with one reader but 272.86 ns with four, versus 27.03 ns for slim. Short operations still require exclusion and memory ordering. No spin-only world lock. |
| Adaptive spinning / lock type | Four bounded spins before the same slim lock improved this counter microbenchmark, but writer tail latency, long scans, fairness, and CPU consumption were not measured. No production change. Choosing independent lock types based on timing would not preserve mutual exclusion. |
| Lock-free access | Immutable chunks, captured spans, and compiled snapshots support it. Live world topology/free lists/revisions still mutate together. Current batches measured reads 38.25 → 30.77 ns and writes 39.69 → 30.01 ns; retained uniform chunk reads were 2.85 ns with historical-snapshot semantics. |
| RLE / compression | The format collapses homogeneous octree regions and varint-encodes leaves/offsets; it is not a linear RLE stream. Measured size and traversal costs support compact cold storage plus optional indexed/dense hot data. An alternative RLE format and disk codecs were not benchmarked. |
| Hashing | The existing hash-indexed recent cache measured 7.51 ns for one repeated chunk versus 8.16 ns for a dictionary, near parity across ten chunks, and 10.05 versus 7.15 ns on misses. World access additionally updates exact residency metadata; dictionary controls omit that work. No hash-function replacement justified. |
| Precompiled queries | Reusable `VoxelFilter` already stores normalized mask/expected bits without delegates. The compiled lookup predecodes topology once. Arbitrary expression compilation, result memoization, and new query languages were not benchmarked. |
| ECS locality | Preserve channel-major storage and process batches against retained snapshots or per-worker dense spans. Reuse local coordinate/Morton indexes where the caller repeats positions. This is an access strategy supported by current APIs, not a separately measured ECS scheduler. |

The prefetch intrinsic is documented in
[Microsoft's Sse.Prefetch0 reference](https://learn.microsoft.com/en-us/dotnet/api/system.runtime.intrinsics.x86.sse.prefetch0?view=net-10.0).
The lock alternatives have different exclusion semantics; see
[Microsoft's synchronization overview](https://learn.microsoft.com/en-us/dotnet/standard/threading/overview-of-synchronization-primitives).

Lock experiments use persistent workers with 65,536 accesses per invocation and
0%/10% writes. Thread creation is excluded; barriers, result checking, branching,
and a tiny counter access are included. They measure aggregate throughput, not
latency percentiles or complete world transactions. Native prefetch buffers are
1/128 MiB and the address stream rotates between invocations. Native setup memory
is not included in BenchmarkDotNet's managed-allocation column.

## Validation and reproduction

- Release tests: 260 on .NET 8 (the .NET Standard library asset), 261 on .NET 10,
  and 262 on .NET 11 preview.
- Eleven focused tests also pass with all hardware intrinsics disabled, and
  again with AVX2 disabled to exercise the 128-bit path.
- Coverage includes full/slab/strided/empty boxes, vector tails, absent matches,
  raw floating-point bits, all supported voxel sizes, every voxel in compiled
  test trees, coordinate errors, source replacement, borrowed-buffer reuse,
  and concurrent snapshot access.

Run from `src/Tedd.Voxtree.Benchmark`, avoiding duplicate project names in
unrelated artifact directories:

```powershell
dotnet run -c Release -f net10.0 -- --filter '*AccessQueries*' '*AccessFilterWidths*' '*AccessLookupBuild*' '*AccessTraversal*' '*AccessPrefetch*' '*AccessLocks*' '*WorldSynchronization*' '*WorldEntityLookups*' --job short --warmupCount 3 --iterationCount 5 --iterationTime 200 --artifacts ../../BenchmarkDotNet.Artifacts/access-repro
dotnet run -c Release -f net11.0 -- --filter '*AccessFilterWidths*' '*AccessTraversal.Encoded*' '*AccessTraversal.CompiledSnapshot*' --job short --warmupCount 3 --iterationCount 5 --iterationTime 200 --artifacts ../../BenchmarkDotNet.Artifacts/access-net11-repro
```

For the before comparison, use the baseline library revision with the
`AccessQueries.cs` and `BenchmarkData.cs` harnesses. No old library copy or
runtime switch is embedded in the production library.

Report prefixes:
`before` = baseline; `after` = initial SIMD/slab screening (includes rejected
short-row regressions); `final` = intermediate filter-width and first compiled
API screening; `confirm` = specialized scan and production index confirmation;
`any-final` = immediate-hit guard confirmation; `net11` = supplementary runtime.
Count results come from `confirm`; final existence results come from `any-final`.
The final guard affects the Any path only. Prototype reports exclude setup and
must not be mistaken for end-to-end public API measurements.
