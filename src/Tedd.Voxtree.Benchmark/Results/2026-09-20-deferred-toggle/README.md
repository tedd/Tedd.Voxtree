# Deferred-write toggle

This experiment measures whether a default-enabled construction switch changes
the sparse owner edit path. It uses `DeferredChunkWrites.DeferredEdits` on .NET
10.0.12, AVX2, 5 warmups, 12 iterations and 250 ms iterations. Each operation
constructs and disposes an owner, performs 1, 5 or 20 unique writes plus two
same-position channel overwrites, and reads the edited position.

The baseline is commit `d37da0c`. The final candidate checks the option only
while the sparse edit buffer is absent, then keeps the buffer in a local for the
existing lookup/write path.

| Writes | Pattern | Before | Final | Change |
|---:|---|---:|---:|---:|
| 1 | Uniform | 130.6 ns | 129.0 ns | -1.2% |
| 1 | Terrain | 129.2 ns | 129.9 ns | +0.5% |
| 5 | Uniform | 165.3 ns | 160.7 ns | -2.8% |
| 5 | Terrain | 161.7 ns | 160.9 ns | -0.5% |
| 20 | Uniform | 301.2 ns | 298.4 ns | -0.9% |
| 20 | Terrain | 311.4 ns | 312.6 ns | +0.4% |

All cells remain within the preregistered 5% noise threshold and allocation is
unchanged at 152 bytes per operation. The switch is retained.

`after` is a disturbed run with 20.2 ns standard deviation in one cell and broad
slowdown across every workload. `after-confirm` repeated cleanly but preceded a
minor local-reference rewrite. Both are preserved rather than selected as final
evidence. Full logs and BenchmarkDotNet CSV, Markdown and HTML reports are kept
under each run directory.

Command:

```powershell
dotnet run -c Release -f net10.0 --project src/Tedd.Voxtree.Benchmark -- --filter '*DeferredChunkWrites.DeferredEdits*' --warmupCount 5 --iterationCount 12 --iterationTime 250 --artifacts <run-directory>
```
