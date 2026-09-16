```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.2 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method     | MiB | Queries    | Mean      | Error     | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|----------- |---- |----------- |----------:|----------:|----------:|------:|--------:|----------:|------------:|
| **Demand**     | **1**   | **Sequential** | **0.7126 ns** | **0.1755 ns** | **0.0456 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| Prefetch16 | 1   | Sequential | 1.1551 ns | 0.0519 ns | 0.0135 ns |  1.63 |    0.10 |         - |          NA |
| Prefetch64 | 1   | Sequential | 1.2081 ns | 0.0391 ns | 0.0101 ns |  1.70 |    0.10 |         - |          NA |
|            |     |            |           |           |           |       |         |           |             |
| **Demand**     | **1**   | **Random**     | **1.2594 ns** | **0.0652 ns** | **0.0169 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| Prefetch16 | 1   | Random     | 1.3222 ns | 0.2192 ns | 0.0569 ns |  1.05 |    0.04 |         - |          NA |
| Prefetch64 | 1   | Random     | 1.3514 ns | 0.3441 ns | 0.0894 ns |  1.07 |    0.07 |         - |          NA |
|            |     |            |           |           |           |       |         |           |             |
| **Demand**     | **128** | **Sequential** | **0.6800 ns** | **0.1773 ns** | **0.0460 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| Prefetch16 | 128 | Sequential | 1.1853 ns | 0.2074 ns | 0.0321 ns |  1.75 |    0.11 |         - |          NA |
| Prefetch64 | 128 | Sequential | 1.2293 ns | 0.2755 ns | 0.0715 ns |  1.81 |    0.14 |         - |          NA |
|            |     |            |           |           |           |       |         |           |             |
| **Demand**     | **128** | **Random**     | **8.1691 ns** | **0.8318 ns** | **0.2160 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| Prefetch16 | 128 | Random     | 6.6427 ns | 0.9735 ns | 0.2528 ns |  0.81 |    0.03 |         - |          NA |
| Prefetch64 | 128 | Random     | 6.4012 ns | 0.2805 ns | 0.0728 ns |  0.78 |    0.02 |         - |          NA |
