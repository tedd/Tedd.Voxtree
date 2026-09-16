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
| **Scalar** | **False**   | **49.671 μs** | **1.0412 μs** | **0.1611 μs** |  **1.00** |         **-** |          **NA** |
| Query  | False   |  2.762 μs | 0.1599 μs | 0.0415 μs |  0.06 |         - |          NA |
|        |         |           |           |           |       |           |             |
| **Scalar** | **True**    | **49.531 μs** | **3.1602 μs** | **0.4890 μs** |  **1.00** |         **-** |          **NA** |
| Query  | True    | 19.789 μs | 2.4036 μs | 0.3720 μs |  0.40 |         - |          NA |
