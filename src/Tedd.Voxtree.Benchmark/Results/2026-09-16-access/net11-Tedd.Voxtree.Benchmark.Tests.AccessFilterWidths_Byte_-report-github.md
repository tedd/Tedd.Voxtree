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
| Method | Strided | Mean        | Error        | StdDev      | Ratio | Allocated | Alloc Ratio |
|------- |-------- |------------:|-------------:|------------:|------:|----------:|------------:|
| **Scalar** | **False**   | **90,849.7 ns** |  **9,159.71 ns** | **2,378.75 ns** | **1.000** |         **-** |          **NA** |
| Query  | False   |    904.0 ns |    201.26 ns |    52.27 ns | 0.010 |         - |          NA |
|        |         |             |              |             |       |           |             |
| **Scalar** | **True**    | **82,773.5 ns** | **26,363.54 ns** | **6,846.53 ns** |  **1.00** |         **-** |          **NA** |
| Query  | True    | 12,646.1 ns |     79.60 ns |    20.67 ns |  0.15 |         - |          NA |
