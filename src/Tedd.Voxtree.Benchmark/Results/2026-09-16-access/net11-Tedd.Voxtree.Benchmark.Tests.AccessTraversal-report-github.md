```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 66.85 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method           | Pattern   | Queries    | Mean      | Error      | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|----------------- |---------- |----------- |----------:|-----------:|----------:|------:|--------:|----------:|------------:|
| **Encoded**          | **Sparse**    | **Sequential** | **26.430 ns** |  **1.1715 ns** | **0.1813 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| CompiledSnapshot | Sparse    | Sequential |  8.144 ns |  0.8889 ns | 0.2308 ns |  0.31 |    0.01 |         - |          NA |
|                  |           |            |           |            |           |       |         |           |             |
| **Encoded**          | **Sparse**    | **Random**     | **54.837 ns** | **12.7768 ns** | **3.3181 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| CompiledSnapshot | Sparse    | Random     |  7.885 ns |  1.5300 ns | 0.3973 ns |  0.14 |    0.01 |         - |          NA |
|                  |           |            |           |            |           |       |         |           |             |
| **Encoded**          | **Clustered** | **Sequential** |  **6.596 ns** |  **0.0989 ns** | **0.0153 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| CompiledSnapshot | Clustered | Sequential |  3.282 ns |  0.4157 ns | 0.0643 ns |  0.50 |    0.01 |         - |          NA |
|                  |           |            |           |            |           |       |         |           |             |
| **Encoded**          | **Clustered** | **Random**     | **10.408 ns** |  **2.3262 ns** | **0.6041 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| CompiledSnapshot | Clustered | Random     |  3.699 ns |  0.1867 ns | 0.0289 ns |  0.36 |    0.02 |         - |          NA |
