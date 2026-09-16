```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.08 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-GDKDLG : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=10  IterationTime=300ms  LaunchCount=2
WarmupCount=5

```
| Method            | Pattern   | Queries    | Mean     | Error     | StdDev    | Ratio | RatioSD | Code Size | Allocated | Alloc Ratio |
|------------------ |---------- |----------- |---------:|----------:|----------:|------:|--------:|----------:|----------:|------------:|
| **Production**        | **Sparse**    | **Sequential** | **8.490 ns** | **0.2111 ns** | **0.2347 ns** |  **0.96** |    **0.09** |     **552 B** |         **-** |          **NA** |
| CheckedProduction | Sparse    | Sequential | 8.875 ns | 0.8161 ns | 0.9071 ns |  1.00 |    0.00 |     558 B |         - |          NA |
|                   |           |            |          |           |           |       |         |           |           |             |
| **Production**        | **Sparse**    | **Random**     | **8.408 ns** | **0.2774 ns** | **0.3083 ns** |  **1.03** |    **0.06** |     **552 B** |         **-** |          **NA** |
| CheckedProduction | Sparse    | Random     | 8.192 ns | 0.3210 ns | 0.3568 ns |  1.00 |    0.00 |     558 B |         - |          NA |
|                   |           |            |          |           |           |       |         |           |           |             |
| **Production**        | **Clustered** | **Sequential** | **3.279 ns** | **0.0901 ns** | **0.0925 ns** |  **0.98** |    **0.05** |     **533 B** |         **-** |          **NA** |
| CheckedProduction | Clustered | Sequential | 3.347 ns | 0.1249 ns | 0.1388 ns |  1.00 |    0.00 |     540 B |         - |          NA |
|                   |           |            |          |           |           |       |         |           |           |             |
| **Production**        | **Clustered** | **Random**     | **3.736 ns** | **0.1870 ns** | **0.2001 ns** |  **1.00** |    **0.07** |     **530 B** |         **-** |          **NA** |
| CheckedProduction | Clustered | Random     | 3.746 ns | 0.1460 ns | 0.1562 ns |  1.00 |    0.00 |     573 B |         - |          NA |
