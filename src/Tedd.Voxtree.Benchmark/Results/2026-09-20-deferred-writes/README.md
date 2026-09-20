# Deferred sparse chunk writes

Sparse edits avoid decoding a complete chunk for each editing session. The
retained implementation uses pooled position/value arrays, `Span.IndexOf`, and
Morton-order repackaging. Screening and independent confirmation show substantial foreground savings for
1–20 changed positions. The first linear-order repackaging implementation and a
custom SIMD lookup were rejected. Claims below concern these library fixtures;
they do not establish game-frame, storage-I/O or concurrent-scheduler gains.

## Source and evidence identity

| Revision or artifact | Role |
|---|---|
| `c3b2ca8` | Repository baseline, existing `MarkHot`/`Commit` implementation |
| `00271ff` | Lookup, owner edit/read benchmarks and preregistered hypotheses |
| [source-screen](source-screen) | Exact initial owner and lookup source used for initial screening; linear repackaging |
| [source-rejected-simd](source-rejected-simd) | Rejected production SIMD candidate source |
| `257cb78` | Retained deferred owner, pooling, promotion and Morton repackaging |
| `a7a57fc` | Synchronized store and pending-repackage tracking |
| `577bdb5` | Synchronized store benchmark |

[EXPERIMENTS.md](EXPERIMENTS.md) records hypotheses and regression budgets before
each associated run. Run directories retain complete BenchmarkDotNet logs,
CSV/Markdown reports and available disassembly. The source snapshots distinguish
experimental working-tree versions from later committed implementations.
The large rejected-candidate disassembly exports in `simd-screen/results` are
retained losslessly as `.md.gz` files; decompression was SHA-256 verified.

## Storage, ownership and operation paths

| Operation | Path and cost |
|---|---|
| First sparse write | Retain immutable source; rent shared position keys, validity bits and the changed channel's values |
| Further point write | Search initialized keys; overwrite an existing position or append one; each channel has independent validity |
| Point read | Validate coordinates; check sparse edit for that channel; otherwise read compressed source |
| `MakeHot` or capacity overflow | Decode all channels into dense Morton storage, apply edits, return sparse buffers |
| Sparse `Repackage` | Rent one dense Morton buffer; decode and encode changed channels sequentially; share unchanged channel encodings; return buffers |
| Snapshot, block or serialized access | Apply pending edits before returning current content |
| Store mutation | Lock, resolve address, reserve pending-set membership, edit owner; remove membership if no dirty state remains |
| Scheduled store repackaging | Process a bounded pending batch while holding the store lock; remove completed addresses |

Keys are shared across channels. For 32³ chunks each key needs 15 bits and is
stored as `ushort`; larger chunks use integer keys. Capacity defaults to 256
distinct positions and is configurable. The owner is exclusively held and is
not thread-safe; `DeferredChunkStore` synchronizes access. Borrowed hot storage
must obey the owner's lifetime contract. Immutable snapshots remain unchanged.

The store is opt-in. `GetPendingRepackageChunks()` returns an advisory snapshot
of pending addresses; a client can schedule `Repackage(maxChunks)`. Existing
worlds retain previously published immutable chunks until the client explicitly
installs a new snapshot. There is no background thread created by the library.

## Initial screening and rejected alternatives

H1 targeted at least 20% lower foreground edit time and no more than 15%
complete-cycle regression. In [chunks-screen](chunks-screen), deferred edit
sessions took 129–323 ns versus 76.5–125.5 μs for immediate `MarkHot`, including
editor construction, writes, checksum reads and sparse-buffer disposal. Warm
allocated bytes were 152 B versus approximately 262,359 B. These sessions change
1, 5 or 20 distinct positions and additionally overwrite the first position's
second channel twice; the parameter counts unique positions, not setter calls.

The original linear-order full cycle failed the acceptance budget on terrain:
402–451 μs versus 232–240 μs, a 1.73–1.87× cost. The foreground improvement alone
did not justify retaining that repackaging path.

H5 isolated layout conversion. Sparse repackaging now decodes and encodes Morton
order, converting only edited keys. [morton-screen](morton-screen) measured:

| Unique positions | Uniform hot / deferred, μs | Terrain hot / deferred, μs |
|---:|---:|---:|
| 1 | 84.78 / 14.55 | 232.33 / 160.32 |
| 5 | 84.62 / 13.36 | 233.60 / 162.06 |
| 20 | 95.30 / 20.97 | 233.97 / 161.56 |

Those complete-cycle measurements include deferred preparation, edits,
materialization, encoding and disposal. They support preserving Morton order;
they are short screening measurements, with independent confirmation below.

### SIMD lookup

One Vector256 comparison has 16 ushort lanes. A 64-byte cache line can hold 32
ushort positions, but pooled managed arrays do not guarantee cache-line
alignment. A packed 15-bit representation cannot directly use ordinary lane
equality; no such packed representation was implemented.

[lookup-screen](lookup-screen) measured nanoseconds per lookup:

| Positions | Scalar | Span.IndexOf | Explicit Vector256 | Padded Vector256 |
|---:|---:|---:|---:|---:|
| 1 | 0.633 | 2.564 | 0.933 | 1.557 |
| 5 | 2.125 | 3.353 | 2.387 | 1.553 |
| 20 | 6.365 | 3.519 | 2.679 | 2.403 |
| 256 | 53.661 | 8.740 | 11.132 | 10.893 |

Nonempty disassembly verifies AVX2 `vpcmpeqw` and `vpbroadcastw`. The generic
ushort mask extraction emits `vpshufb`, `vpermq` and `vpmovmskb`; it is not a
single instruction. The runtime's nonpacked Span search uses `vptest` to avoid
extracting a mask for nonmatching vectors. Its packed/nonpacked dispatch and
tail handling also appear in the export. This is generated-code evidence, not
hardware-counter attribution.

H4 then tested an integrated hybrid: direct comparison for one key, padded
Vector256 for 2–32 short keys and Span search beyond that range. The candidate
used a byte mask, dividing the first set-bit index by two, and charged padding
initialization and insertion costs. [simd-screen](simd-screen) retained its
disassembly and measurements. Candidate owner edits measured 155–378 ns; miss
reads measured 16.1–30.9 ns compared with the initial 12.1–26.3 ns. Twenty-position hit reads
were 5.96–6.82 ns versus 6.40–6.42 ns, with substantial variability in candidate
cells. Several candidate means were worse, but noisy separate runs do not
establish a causal slowdown. The predicted reliable integrated improvement was
not demonstrated, so the extra implementation and maintenance were not retained.
The custom lookup was rejected; production retains
`Span.IndexOf`. This does not claim that Span is the fastest isolated kernel for
every list length.

### Read overhead

Initial Span-based hit reads cost 5.52–6.42 ns versus 4.51–4.55 ns for an already
hot chunk. Misses cost 12.05–12.36 ns on uniform data and 25.36–26.26 ns on
terrain, compared with 4.51–4.57 ns and 18.31–19.13 ns for compressed-source reads.
An opt-in overlay therefore has a measurable cost for read-heavy workloads.

For a complete workload, the break-even read count is the total edit/repackage
saving divided by the extra read cost under the same publication policy.
The isolated read fixtures compare with the original compressed source or with
hot edited positions; neither measures a complete mixed read/write session
against immediate immutable publication. A numerical workload threshold is
therefore not established. Its measurement needs hit/miss frequency, repackaging
cadence, source locality and the competing dense or immutable publication policy.

## Final independent confirmation

The [confirmation](confirm) completed 48 cases: 24 owner edit/full-cycle cases, 16 owner read
cases and 8 synchronized-store cases. It uses five warmups, nine measured
iterations of 250 ms and one launch, independently of the screening runs.
The table reports means; full reports retain standard deviations and confidence
intervals. Absolute times increased with background activity; conclusions depend
on the large, repeated differences rather than small nanosecond deltas.

| Workload | Baseline | Retained implementation | Decision |
|---|---:|---:|---|
| Owner foreground edits, 1/5/20 positions | 85.8–157.9 μs | 0.174–0.416 μs | Retain; 243–872x faster across matching cases |
| Owner complete cycle, uniform | 103.6–116.1 μs | 15.2–26.9 μs | Retain; 77–85% less time |
| Owner complete cycle, terrain | 296.4–329.1 μs | 190.4–228.4 μs | Retain; 30–42% less time |
| Owner hit reads | 4.51–6.00 ns, already hot | 7.17–8.40 ns | Overhead retained as opt-in tradeoff |
| Owner miss reads, uniform | 5.01–5.63 ns, compressed | 14.32–15.38 ns | Roughly 9–10 ns extra in matched cases |
| Owner miss reads, terrain | 22.09–22.92 ns, compressed | 33.58–34.57 ns | Roughly 11–12 ns extra in matched cases |
| Synchronized store edits, 1/20 positions | 148.3 / 149.2 μs | 0.420 / 1.393 μs | Foreground gain survives locking and queue tracking |
| Synchronized store complete cycle, 1/20 positions | 288.9 / 302.6 μs | 198.3 / 214.6 μs | 29–31% less time in this run |

H1 and H5 meet the preregistered budgets in both retained-layout runs. H3
confirms that deferred reads have a cost; this is not a universally faster read
representation. H2 verifies available SIMD mechanisms, while H4 does not justify
custom production SIMD. The store run supports H6; its independent repeat is
recorded in [store-confirm](store-confirm).

That repeat also passes H6. For 1/20 positions respectively, synchronized
foreground edits were 0.399/1.307 μs versus 149.5/145.5 μs; complete cycles were
186.5/197.9 μs versus 297.5/291.7 μs. Across both store runs, complete-cycle
means improved 29–37%. The repeated result supports this uncontended workload,
not a contention or background-worker latency claim.

The store comparison uses the same synchronized API on both sides, with
immediate `MakeHot` as baseline. Replacement, previous-editor disposal, locks,
address lookup, pending tracking, writes and checksum reads are timed. Complete
cycles also drain one scheduled chunk and obtain its immutable snapshot. Store
construction and initial container allocation are excluded equally.

## Memory accounting

The measured 152 B warm allocation per sparse owner session excludes retained
pool arrays and the immutable source. At the default 256-position capacity:

| Storage | Payload requirement |
|---|---:|
| Shared ushort keys | 512 B |
| Values for each modified uint channel | 1,024 B |
| Validity for two channels | Eight ulong words, 64 B logically; the pool can return a larger bucket |
| Sparse repackaging scratch | 131,072 B pooled dense buffer, reused across changed channels |
| Promoted hot storage | 262,144 B dense values for two channels, plus array/object overhead |

Array/object headers, pool bucket rounding and retention, dictionaries, the
pending set and immutable encoded results are additional costs. Unmodified
channels do not rent value arrays. Returning a pooled array releases ownership,
not necessarily its process memory. No retained-heap limit or process-memory
reduction was measured.

## Correctness and environment

The coordinator ran the full test suites: .NET 8, 300 tests; .NET 10, 301 tests;
.NET 11, 302 tests: 903 total passed. Forty focused deferred-chunk/store tests
also passed with `DOTNET_EnableHWIntrinsic=0`. Fixtures check scalar/vector
differential results, edited-value parity and pending-work behavior before
timing. Tests cover value/channel semantics, promotion, pooled reuse, snapshot
lifetime and store scheduling; passing tests are not a concurrency throughput
measurement.

Performance workers ran .NET 10.0.12, x64 RyuJIT, on an AMD Ryzen 9 5950X
(16 physical/32 logical cores), Windows 11 build 26200.9457. Build SDK was
11.0.100-preview.7.26381.103; BenchmarkDotNet was 0.16.0-preview.1. Logs report
Concurrent Workstation GC, AVX2 and a 256-bit vector size. BenchmarkDotNet selected
the High performance power scheme. JIT/PGO and GC were left at runtime defaults;
background load, frequency/thermal variation and thread migration were not
controlled. A background-load audit at 10:26:52–53 local time recorded total CPU
utilization of 11.24% and 14.31%, including system-utility and antivirus activity.
No CPU affinity or machine isolation was imposed. Timed benchmark jobs were
serialized, but that did not exclude other processes. The confirmation showed
more nanosecond-scale variability than the initial screen; small differences
remain uncertain even when a rounded mean or ratio appears favorable.

Sources and pool state are warm. Data is deterministic: uniform values or a
height-varying terrain surface, two uint channels, 32³ voxels, unique positions
generated by an odd stride. Reads use seed 419; lookup probes use seed 947 and a
repeating mix of first/last/random hits and misses. Fixed warm sequences can
favor branch prediction. Initial screens used three warmups and five 100 ms
iterations; the integrated SIMD screen used seven 150 ms iterations. Full logs
preserve variability, minimum-iteration warnings and default outlier removal.

No hardware counters, ARM64 measurements, real-game captures, cold-start runs,
large resident chunk populations, storage-I/O timings or contended store
benchmarks were collected. Performance on .NET 8/.NET 11 was not measured;
their correctness results do not establish performance parity. The configurable
capacity's application-specific optimum remains unmeasured.

## Reproduction commands

Run from the repository root, serially. Source snapshots above identify the
working-tree variants needed to reproduce rejected candidates. Logs retain
worker commands and effective job settings; these commands reproduce each
fixture/job selection and write artifacts under this directory.

```powershell
dotnet run -c Release -f net10.0 --project src/Tedd.Voxtree.Benchmark -- --filter '*DeferredPositionLookup*' --job short --warmupCount 3 --iterationCount 5 --iterationTime 100 --artifacts src/Tedd.Voxtree.Benchmark/Results/2026-09-20-deferred-writes/lookup-screen
dotnet run -c Release -f net10.0 --project src/Tedd.Voxtree.Benchmark -- --filter '*DeferredChunkWrites*' '*DeferredChunkReads*' --job short --warmupCount 3 --iterationCount 5 --iterationTime 100 --artifacts src/Tedd.Voxtree.Benchmark/Results/2026-09-20-deferred-writes/chunks-screen
dotnet run -c Release -f net10.0 --project src/Tedd.Voxtree.Benchmark -- --filter '*DeferredChunkWrites*' --anyCategories Repackage --job short --warmupCount 3 --iterationCount 5 --iterationTime 100 --artifacts src/Tedd.Voxtree.Benchmark/Results/2026-09-20-deferred-writes/morton-screen
dotnet run -c Release -f net10.0 --project src/Tedd.Voxtree.Benchmark -- --filter '*DeferredChunkWrites.DeferredEdits*' '*DeferredChunkReads.Deferred*' --job short --warmupCount 3 --iterationCount 7 --iterationTime 150 --disasm --disasmDepth 4 --artifacts src/Tedd.Voxtree.Benchmark/Results/2026-09-20-deferred-writes/simd-screen
dotnet run -c Release -f net10.0 --project src/Tedd.Voxtree.Benchmark -- --filter '*DeferredChunkWrites*' '*DeferredChunkReads*' '*DeferredStoreBenchmarks*' --job short --warmupCount 5 --iterationCount 9 --iterationTime 250 --artifacts src/Tedd.Voxtree.Benchmark/Results/2026-09-20-deferred-writes/confirm
dotnet run -c Release -f net10.0 --project src/Tedd.Voxtree.Benchmark -- --filter '*DeferredStoreBenchmarks*' --job short --warmupCount 5 --iterationCount 9 --iterationTime 250 --artifacts src/Tedd.Voxtree.Benchmark/Results/2026-09-20-deferred-writes/store-confirm
dotnet test src/Tedd.Voxtree.Tests -c Release
$env:DOTNET_EnableHWIntrinsic = '0'
dotnet test src/Tedd.Voxtree.Tests -c Release -f net10.0 --filter 'FullyQualifiedName~Deferred'
Remove-Item Env:DOTNET_EnableHWIntrinsic
```
