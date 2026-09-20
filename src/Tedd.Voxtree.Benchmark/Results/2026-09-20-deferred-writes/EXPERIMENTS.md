# Deferred sparse chunk writes: preregistered experiments

Status: experiments completed. This file preserves the hypotheses and budgets;
executed results and decisions are in [README.md](README.md).

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

## H4: integrated short-list SIMD candidate

After the lookup screen, test a production hybrid: direct comparison for one
position, padded Vector256 equality for 2–32 short keys, and Span.IndexOf for
larger/wide-key lists. These thresholds are experimental, not claimed optimal.
Use byte mask extraction and divide the first matching bit index by two, since
each ushort contributes two adjacent equal bytes. Initialize a newly searchable
16-position block with an invalid ushort sentinel before publishing its first
key. The pooled key rental explicitly reserves the rounded size. Keep the
netstandard/nonaccelerated fallback and initialized logical-length bounds.

Prediction: reduce 20-position hit-read time by at least 10% compared with the
initial Span.IndexOf implementation while worsening no prioritized write or
read case by more than 10% beyond run variation. Charge padding initialization,
pool rental, insertion, and dispatch in complete edit sessions. Compare the same
H1/H3 inputs, retain only after an independent confirmation, and reject the
candidate if integrated measurements do not support the lookup microbenchmark.

## H5: preserve Morton order during sparse repackaging

The initial complete-cycle measurement rejects linear-buffer repackaging for
terrain: 402–451 us versus 232–240 us for MarkHot+Commit (1.73–1.87x).
Foreground sparse edits still take only 129–323 ns versus 77–126 us. Before
changing lookup, isolate layout: decode changed channels into a pooled Morton
buffer, convert only edited position keys, and encode directly from Morton order.
Prediction: eliminate the full-volume layout conversion and reduce terrain
complete-cycle time enough to satisfy H1's 15% regression budget. Preserve
unchanged-channel sharing, pooling, values and snapshot semantics. Compare all
six full-cycle cells against the same baseline; keep SIMD unchanged for this run.

## H6: synchronized store total cost

On warm two-channel 32³ terrain chunks, deferred editing should retain at least
20% foreground benefit through DeferredChunkStore and stay within the 15%
complete-cycle regression budget versus immediate store.MakeHot. Include
replacement/disposal, locks, dictionary lookup, pending tracking, writes and
checksum reads. Complete cycles also drain one queued chunk and obtain a
snapshot. Store construction and initial containers are excluded equally.
Use 1/20 positions with the same repeated second-channel overwrite. This tests
single-thread, single-address throughput; contention and scheduler latency
remain unmeasured. Run only after choosing the owner implementation.

## H7: default-enabled runtime switch

Add a construction-time switch to the owner and store, enabled by default. The
enabled-path check belongs only in the first-write path that already allocates
the sparse overlay; subsequent sparse writes and all reads must not test the
option. Disabling it must preserve lazy ownership, then promote on the first
write and after each repackage.

Prediction: the default-enabled 1/5/20-write sessions remain within 5% of the
same benchmark at `d37da0c`, with identical allocation. Repeat a noisy run and
retain every raw result. Reject or redesign a repeatable regression above 5%.
