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
| **Scalar** | **False**   | **49.990 μs** | **2.8684 μs** | **0.4439 μs** |  **1.00** |         **-** |          **NA** |
| Query  | False   |  5.493 μs | 0.1922 μs | 0.0499 μs |  0.11 |         - |          NA |
|        |         |           |           |           |       |           |             |
| **Scalar** | **True**    | **48.330 μs** | **0.7631 μs** | **0.1181 μs** |  **1.00** |         **-** |          **NA** |
| Query  | True    | 21.069 μs | 1.1710 μs | 0.3041 μs |  0.44 |         - |          NA |
