# Deferred sparse chunk writes: preregistered experiments

Status: hypotheses and fixtures prepared; no performance results recorded yet.

## Contract and cost model

The source is an immutable 32³ chunk with two uint channels. An exclusively owned
deferred editor records sparse positions and channel values, provides immediate
read-your-writes semantics, and eventually materializes or repackages its state.
Repeated writes must replace the existing value; unchanged channels must preserve
their source values. Timing construction, pool rental, writes and disposal is
mandatory. The complete cycle also includes materialization and encoding.

The existing comparison is `source.MarkHot()`, writes through its indexer, and
`Commit()` when an immutable result is required. Input construction is excluded
equally for both approaches. Source chunks and the array pool are warm; this is
not a cold CPU-cache or process-startup experiment. Pool retention is not reported
by BenchmarkDotNet's allocation count and must be accounted for separately.

## H1: defer materialization for 1–20 writes

Suspected cost: allocating and decoding 65,536 uint values (256 KiB) to change a
few positions. A pooled sparse overlay should reduce foreground edit latency and
allocation by avoiding this work until a complete chunk is required.

Priority: 1, 5 and 20 unique writes on uniform and deterministic terrain chunks.
Each edit operation subsequently overwrites its first position in the second
channel, exercising shared position bookkeeping. Compare complete edit sessions,
including editor construction, checksum reads and disposal. Separately compare
the same writes followed immediately by repackaging, with serialization length
and an edited value contributing to the observable return value.

Acceptance: at least 20% lower edit-session mean in all six sparse workloads,
repeatable in an independent confirmation. Full write-plus-repackage mean must
remain within 15% of MarkHot-plus-Commit in representative workloads. Gains below
the larger of 5% and observed run variation are inconclusive. If the full-cycle
budget fails, retain only with a documented scheduling/latency tradeoff, not as
a total-throughput improvement. Preserve all regressions in the results.

## H2: ushort search and SIMD

A 32³ position needs 15 bits, but ordinary SIMD equality requires lane-aligned
values: 256 bits holds 16 ushort positions, not 23. One 64-byte cache line can
hold 32 ushort positions; managed pool arrays have no guaranteed cache-line
alignment. Tightly packing 15-bit values would require extra extraction/shuffle
work and is not included in this experiment.

Compare an ordinary scalar scan, `ReadOnlySpan<ushort>.IndexOf`, an explicit
Vector256 search with scalar tails, and a padded Vector256 search. The padded
buffer is rounded up to 16 positions and initialized to ushort.MaxValue, which
cannot represent a valid 32³ position. Each equal ushort contributes one bit
through `ExtractMostSignificantBits`; the first set bit is the matching lane.
Zero masks are tested before `TrailingZeroCount`. The explicit routines have a
scalar fallback when Vector256 is not accelerated.

Workloads: counts 1, 5, 20 and 256; each invocation searches a fixed seeded mix
of early hits, late hits and misses. Keys and requested positions are prepared
outside lookup timing because this experiment isolates lookup; H1 accounts for
preparation and maintenance. Setup differentially validates all keys and misses
against the scalar reference, including empty, tail and padding cases.

Acceptance: choose the simplest implementation within 5% of the fastest across
the prioritized 1–20 counts. Retain explicit SIMD complexity only for repeatable
improvement exceeding 10% over Span.IndexOf without a >10% regression in any
prioritized count. The 256-entry result informs capacity choice rather than
overriding sparse-write priorities. Inspect disassembly before asserting an ISA
mechanism; a zero-length report is explicitly inconclusive.

## H3: overlay read cost

Measure batch reads at 1 and 20 pending positions on both data patterns. All-hit
probes compare deferred with an already-hot chunk; all-miss probes compare
deferred with the compressed source. Setup costs are excluded for this isolated
read experiment and included in H1. Both channels participate. A miss must search
the overlay and then decode the source; some overhead is expected.

The editor is opt-in. Reject any proposal to transparently wrap all immutable
reads without application workload evidence. Record hit/miss overhead in ns and
ratios, then derive workload break-even from the measured edit saving and miss
penalty. No global frame-rate or application-throughput claim follows from these
microbenchmarks.

## Execution and evidence

Run Release BenchmarkDotNet workers serially on the shared machine. Record git
revision plus uncommitted candidate identity, runtime/SDK/CPU/OS/ISA, GC/JIT/PGO
defaults and uncontrolled power/background-load conditions. Keep full logs,
CSV/Markdown reports and nonempty lookup disassembly under this directory.

Initial screening (from repository root; net10.0 is the stable runtime):

```powershell
dotnet run -c Release -f net10.0 --project src/Tedd.Voxtree.Benchmark -- --filter '*DeferredPositionLookup*' --job short --artifacts src/Tedd.Voxtree.Benchmark/Results/2026-09-20-deferred-writes/lookup-screen
dotnet run -c Release -f net10.0 --project src/Tedd.Voxtree.Benchmark -- --filter '*DeferredChunkWrites*' '*DeferredChunkReads*' --job short --artifacts src/Tedd.Voxtree.Benchmark/Results/2026-09-20-deferred-writes/chunks-screen
```

Confirm retained choices in a second independent launch, increasing iteration
count where variability obscures the preregistered thresholds. .NET 8, .NET 11,
ARM64, hardware counters, concurrent readers/writers, world scheduling overhead,
working sets beyond cache and real game captures are outside this first matrix;
do not imply they have been measured.
