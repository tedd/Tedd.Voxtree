```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 66.19 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method           | Pattern   | Queries    | Mean      | Error     | StdDev    | Ratio | RatioSD | Code Size | Allocated | Alloc Ratio |
|----------------- |---------- |----------- |----------:|----------:|----------:|------:|--------:|----------:|----------:|------------:|
| **FieldChecked**     | **Sparse**    | **Sequential** | **10.107 ns** | **2.9796 ns** | **0.7738 ns** |  **1.04** |    **0.08** |     **330 B** |         **-** |          **NA** |
| LocalChecked     | Sparse    | Sequential |  9.736 ns | 1.0649 ns | 0.2766 ns |  1.00 |    0.00 |     322 B |         - |          NA |
| SliceChecked     | Sparse    | Sequential | 10.194 ns | 1.0026 ns | 0.2604 ns |  1.05 |    0.04 |     341 B |         - |          NA |
| ManagedReference | Sparse    | Sequential | 10.348 ns | 3.4672 ns | 0.9004 ns |  1.06 |    0.09 |     318 B |         - |          NA |
| Production       | Sparse    | Sequential |  8.257 ns | 0.4354 ns | 0.0674 ns |  0.85 |    0.02 |     558 B |         - |          NA |
|                  |           |            |           |           |           |       |         |           |           |             |
| **FieldChecked**     | **Sparse**    | **Random**     | **10.641 ns** | **3.3301 ns** | **0.8648 ns** |  **1.08** |    **0.08** |     **330 B** |         **-** |          **NA** |
| LocalChecked     | Sparse    | Random     |  9.860 ns | 0.7159 ns | 0.1859 ns |  1.00 |    0.00 |     322 B |         - |          NA |
| SliceChecked     | Sparse    | Random     |  9.833 ns | 2.1581 ns | 0.3340 ns |  1.00 |    0.03 |     341 B |         - |          NA |
| ManagedReference | Sparse    | Random     |  9.639 ns | 1.5761 ns | 0.2439 ns |  0.98 |    0.03 |     318 B |         - |          NA |
| Production       | Sparse    | Random     |  8.230 ns | 1.4240 ns | 0.2204 ns |  0.83 |    0.02 |     558 B |         - |          NA |
|                  |           |            |           |           |           |       |         |           |           |             |
| **FieldChecked**     | **Clustered** | **Sequential** |  **4.483 ns** | **1.2013 ns** | **0.3120 ns** |  **0.92** |    **0.08** |     **330 B** |         **-** |          **NA** |
| LocalChecked     | Clustered | Sequential |  4.881 ns | 1.1157 ns | 0.2897 ns |  1.00 |    0.00 |     322 B |         - |          NA |
| SliceChecked     | Clustered | Sequential |  4.199 ns | 0.1829 ns | 0.0283 ns |  0.86 |    0.05 |     341 B |         - |          NA |
| ManagedReference | Clustered | Sequential |  4.496 ns | 0.9650 ns | 0.2506 ns |  0.92 |    0.07 |     318 B |         - |          NA |
| Production       | Clustered | Sequential |  3.259 ns | 0.5259 ns | 0.1366 ns |  0.67 |    0.05 |     543 B |         - |          NA |
|                  |           |            |           |           |           |       |         |           |           |             |
| **FieldChecked**     | **Clustered** | **Random**     |  **5.296 ns** | **0.4685 ns** | **0.0725 ns** |  **0.98** |    **0.03** |     **330 B** |         **-** |          **NA** |
| LocalChecked     | Clustered | Random     |  5.425 ns | 0.6220 ns | 0.1615 ns |  1.00 |    0.00 |     322 B |         - |          NA |
| SliceChecked     | Clustered | Random     |  5.286 ns | 0.6384 ns | 0.1658 ns |  0.98 |    0.04 |     341 B |         - |          NA |
| ManagedReference | Clustered | Random     |  5.027 ns | 0.4769 ns | 0.0738 ns |  0.93 |    0.03 |     318 B |         - |          NA |
| Production       | Clustered | Random     |  3.787 ns | 0.5076 ns | 0.1318 ns |  0.70 |    0.03 |     540 B |         - |          NA |
