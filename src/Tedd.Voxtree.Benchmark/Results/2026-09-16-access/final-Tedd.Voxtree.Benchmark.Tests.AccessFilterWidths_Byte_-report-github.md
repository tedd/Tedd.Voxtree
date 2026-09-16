```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.35 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method | Strided | Mean        | Error       | StdDev    | Ratio | Allocated | Alloc Ratio |
|------- |-------- |------------:|------------:|----------:|------:|----------:|------------:|
| **Scalar** | **False**   | **86,942.7 ns** | **1,960.89 ns** | **303.45 ns** |  **1.00** |         **-** |          **NA** |
| Query  | False   |    909.8 ns |    10.63 ns |   1.65 ns |  0.01 |         - |          NA |
|        |         |             |             |           |       |           |             |
| **Scalar** | **True**    | **79,380.7 ns** | **4,500.93 ns** | **696.52 ns** |  **1.00** |         **-** |          **NA** |
| Query  | True    | 24,074.8 ns |   276.12 ns |  42.73 ns |  0.30 |         - |          NA |
