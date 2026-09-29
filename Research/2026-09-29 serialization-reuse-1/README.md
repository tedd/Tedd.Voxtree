# Chunk serialization and deserialization investigation

## Scientific question

For versioned level-5 multi-channel chunk packets, can packet serialization and
validated deserialization reduce median steady-state latency by at least 15%
without changing the wire format, validation behavior, channel ownership, or
query results on .NET 10 x64?

The secondary objective is an allocation-free caller-memory path for repeated
packet access. Existing owned APIs may retain their documented object and
descriptor allocations. Candidate changes must not regress representative
serialization or deserialization scenarios by more than 5% beyond measurement
noise.

## Workloads

- One, four, and sixteen channels.
- Uniform, sparse, spatially clustered, and random level-5 `UInt32` volumes.
- Serialization into a preallocated, reusable `byte[]`.
- Validation/deserialization from a stable borrowed packet.
- Boundary and malformed packets remain correctness tests rather than timed data.

## Semantic invariants

- Chunk packet versions 1 and 2 remain byte-compatible.
- Malformed headers, lengths, channel encodings, element widths, and trailing
  bytes retain their rejection behavior.
- Owned chunks remain immutable; borrowed packet memory must remain alive and
  immutable for every aliasing API.
- `IsEmpty`, channel count, levels, channel bytes, and decoded values remain exact.
- Insufficient caller capacity must not write outside the logical destination.

## Benchmark coordination

The `/root` coordinator exclusively owns timed runs. Investigators may inspect
source but may not run builds, tests, profilers, or benchmarks. Before every
timed run the coordinator checks for other BenchmarkDotNet or performance-probe
processes and waits until the host is quiescent.

## Excluded exploratory epoch E-001

- Source: commit `85d7a99`; initial working-tree delta is the benchmark fixture
  only.
- Runtime target: .NET 10, optimized Release build, BenchmarkDotNet 0.16.0-preview.1.
- Benchmark source: `src/Tedd.Voxtree.Benchmark/Tests/ChunkSerializationBenchmarks.cs`.
- Command and environment data are retained under `raw/baseline/`.
- Primary metric: BenchmarkDotNet mean nanoseconds per operation (with reported
  error/stddev); allocated bytes are secondary.

E-001 is retained but excluded from acceptance decisions. Its final measurements
overlapped the timestamp at which another repository claimed the subsequently
introduced host-wide benchmark lock, and its multi-channel fixture perturbed
channels after channel zero. The fixture was corrected after observing that this
made nominal uniform/clustered labels misleading.

## Controlled epoch E-002

- Uses `D:\Temp\BenchmarkLock.txt` as an atomic host-wide mutex for builds,
  tests, profilers, and benchmarks.
- Uses identical channel contents for each named distribution and includes a
  sparse tree workload explicitly.
- Compares loaded-packet single-copy serialization against a contemporaneous
  per-channel reconstruction control in the same BenchmarkDotNet process.
- Compares owned validated deserialization, allocation-free envelope parsing,
  and allocation-free full validation over the same packet.
- Command and results are stored under `raw/candidate/`; all 72 scenarios
  completed under the exclusive lock.

Envelope-only `OctreeChunkSpan` parsing allocated 0 B and took 6.97-71.75 ns,
versus 26.11 ns-1.117 ms and 96-336 B for owned deserialization. Full structural
validation through the view also allocated 0 B; it was faster in nine of twelve
scenarios, with sparse 16-channel validation falling from 1.117 ms to 587.16 us.

The initial retained-packet single-copy candidate was rejected for large dense
packets: 16-channel random serialization regressed from 66.35 us for the
per-channel control to 1.917 ms. A 64 KiB fallback reduced that candidate to
92.16 us. Post-run audit found that this manual control omitted the legacy
overlap checks and reused the candidate's cached length; those serialization
comparisons are therefore screening evidence, not acceptance evidence. The
subsequent bounded segmented-copy hypothesis was measured against the corrected
legacy-safe control and rejected: it regressed random packets by 127.2%, 1.6%,
and 53.8% at one, four, and sixteen channels. The retained policy uses a single
copy only for packets at or below 64 KiB and preserves the original per-channel
path above that limit.

## Commands

```powershell
dotnet build src\Tedd.Voxtree.sln -c Release --nologo
dotnet test src\Tedd.Voxtree.Tests\Tedd.Voxtree.Tests.csproj -c Release --nologo
dotnet run -c Release -f net10.0 --no-build --project Tedd.Voxtree.Benchmark.csproj -- --filter '*ChunkSerialization*' '*ChunkDeserialization*' --job short --artifacts '<run>\raw\candidate'
dotnet run -c Release -f net10.0 --no-build --project Tedd.Voxtree.Benchmark.csproj -- --filter '*ChunkSerialization*Random*' --job short --artifacts '<run>\raw\candidate-threshold'
dotnet run -c Release -f net10.0 --no-build --project Tedd.Voxtree.Benchmark.csproj -- --filter '*SerializeLoaded*Random*' --job short --artifacts '<run>\raw\final-segmented'
```

## Initial hypothesis ledger

| ID | Claim | Prediction and falsification | State |
| --- | --- | --- | --- |
| H-001 | Recomputing `SerializedLength` traverses channel descriptors immediately before serialization traverses them again. | Cache the immutable length; retain only if serialization improves beyond noise without construction regression. | retained |
| H-002 | Deserialization's structural validation and subsequent `IsEmpty` query traverse tree encodings twice. | Derive empty state from validated storage metadata; retain only with exact `IsEmpty` parity. | retained for correctness and reduced traversal; isolated timing inconclusive |
| H-003 | Per-channel packet writes add avoidable slicing, bounds checks, and header stores. | Use one validated destination slice and narrower helpers; retain only with generated-code or timing evidence. | rejected as a general mechanism |
| H-004 | A stack-bound packet view can provide allocation-free deserialization over caller-owned reusable memory. | Add a validated ref-struct view; it must allocate 0 B and materially outperform owned deserialization. | retained |
| H-005 | A packet loaded by `FromEncoded` can be copied as one contiguous span instead of reconstructing headers and copying each channel separately. | Retain the original packet identity and use a single copy; retain if loaded-chunk serialization improves at least 15%. | rejected for large packets; segmented successor pending |
| H-006 | Descriptors are the irreducible managed allocation in owned deserialization. | Compare caller-provided descriptor storage or a stack-only view; reject any design with unsafe lifetime or ambiguous ownership. | retained as stack-only view |
| H-007 | Dense channel validation/nonzero detection is memory-bandwidth bound and may be fused. | One dense scan must both validate fixed length and detect zero content; retain if end-to-end deserialization benefits. | retained for empty-state derivation; timing mixed |
| H-008 | Generic and `UInt32` chunk paths share the same packet overhead and should use one proven parsing structure. | Equivalent improvements and identical malformed-input results on both paths; reject divergence that increases maintenance risk. | retained |
| H-009 | Segmenting retained-packet copies at 64 KiB avoids the runtime's slow large-copy regime without reintroducing per-channel packet reconstruction. | Random packet serialization must remain within 5% of the control at 1, 4, and 16 channels while preserving small-packet gains. | rejected: +53.8% at 16 channels |

## Initial catalogue coverage

- M1: applicable to descriptor/object allocation and caller-owned reuse.
- M2: potentially applicable only to bounded temporary parsing state; no candidate
  may scale stack use with channel count.
- M3: applicable to packet loops and repeated slicing; generated code required if
  retained on this mechanism.
- M4: not presently justified; safe spans are the control.
- M5/M6: not applicable to contiguous packet parsing.
- M7: applicable to packet reconstruction, copies, and borrowed slices.
- C1/C3: no arithmetic or lane-wise hot kernel identified.
- C2: potentially applicable to storage-kind validation distributions.
- C4: applicable only to existing endian primitives/header stores.
- S1-S5: not applicable to packet serialization.
- R1: no dispatch table candidate established.
- R2: applicable to small parser/writer helpers and descriptor copies.
- R3/T1-T4: not applicable; operations are synchronous and instance-local.
