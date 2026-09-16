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
| Method | Strided | Mean      | Error     | StdDev    | Ratio | Allocated | Alloc Ratio |
|------- |-------- |----------:|----------:|----------:|------:|----------:|------------:|
| **Scalar** | **False**   | **78.628 μs** | **7.5872 μs** | **1.9704 μs** |  **1.00** |         **-** |          **NA** |
| Query  | False   |  1.550 μs | 0.2793 μs | 0.0432 μs |  0.02 |         - |          NA |
|        |         |           |           |           |       |           |             |
| **Scalar** | **True**    | **67.448 μs** | **3.5760 μs** | **0.9287 μs** |  **1.00** |         **-** |          **NA** |
| Query  | True    | 23.510 μs | 0.1619 μs | 0.0250 μs |  0.35 |         - |          NA |
