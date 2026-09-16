```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.29 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method           | Pattern   | Queries    | Mean      | Error     | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|----------------- |---------- |----------- |----------:|----------:|----------:|------:|--------:|----------:|------------:|
| **Encoded**          | **Sparse**    | **Sequential** | **26.319 ns** | **6.8049 ns** | **1.7672 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| CompiledSnapshot | Sparse    | Sequential |  8.207 ns | 1.2377 ns | 0.3214 ns |  0.31 |    0.02 |         - |          NA |
|                  |           |            |           |           |           |       |         |           |             |
| **Encoded**          | **Sparse**    | **Random**     | **46.517 ns** | **6.4179 ns** | **1.6667 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| CompiledSnapshot | Sparse    | Random     |  8.061 ns | 1.0623 ns | 0.2759 ns |  0.17 |    0.01 |         - |          NA |
|                  |           |            |           |           |           |       |         |           |             |
| **Encoded**          | **Clustered** | **Sequential** |  **7.704 ns** | **1.1254 ns** | **0.1742 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| CompiledSnapshot | Clustered | Sequential |  3.282 ns | 0.6952 ns | 0.1076 ns |  0.43 |    0.02 |         - |          NA |
|                  |           |            |           |           |           |       |         |           |             |
| **Encoded**          | **Clustered** | **Random**     | **10.712 ns** | **1.9699 ns** | **0.5116 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| CompiledSnapshot | Clustered | Random     |  3.733 ns | 0.8797 ns | 0.2285 ns |  0.35 |    0.03 |         - |          NA |
