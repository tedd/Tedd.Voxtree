```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.54 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method              | Pattern   | Queries    | Mean     | Error     | StdDev    | Ratio | RatioSD | Code Size | Allocated | Alloc Ratio |
|-------------------- |---------- |----------- |---------:|----------:|----------:|------:|--------:|----------:|----------:|------------:|
| **CheckedProduction**   | **Sparse**    | **Sequential** | **8.213 ns** | **1.9300 ns** | **0.2987 ns** |  **1.00** |    **0.00** |     **558 B** |         **-** |          **NA** |
| UncheckedProduction | Sparse    | Sequential | 8.200 ns | 0.7527 ns | 0.1955 ns |  1.00 |    0.04 |     544 B |         - |          NA |
|                     |           |            |          |           |           |       |         |           |           |             |
| **CheckedProduction**   | **Sparse**    | **Random**     | **7.446 ns** | **0.1817 ns** | **0.0281 ns** |  **1.00** |    **0.00** |     **558 B** |         **-** |          **NA** |
| UncheckedProduction | Sparse    | Random     | 8.298 ns | 1.2819 ns | 0.1984 ns |  1.11 |    0.02 |     544 B |         - |          NA |
|                     |           |            |          |           |           |       |         |           |           |             |
| **CheckedProduction**   | **Clustered** | **Sequential** | **3.150 ns** | **0.4559 ns** | **0.1184 ns** |  **1.00** |    **0.00** |     **540 B** |         **-** |          **NA** |
| UncheckedProduction | Clustered | Sequential | 3.126 ns | 0.2472 ns | 0.0642 ns |  0.99 |    0.04 |     526 B |         - |          NA |
|                     |           |            |          |           |           |       |         |           |           |             |
| **CheckedProduction**   | **Clustered** | **Random**     | **4.256 ns** | **2.9094 ns** | **0.7556 ns** |  **1.00** |    **0.00** |     **540 B** |         **-** |          **NA** |
| UncheckedProduction | Clustered | Random     | 4.252 ns | 3.4654 ns | 0.9000 ns |  1.02 |    0.26 |     526 B |         - |          NA |
