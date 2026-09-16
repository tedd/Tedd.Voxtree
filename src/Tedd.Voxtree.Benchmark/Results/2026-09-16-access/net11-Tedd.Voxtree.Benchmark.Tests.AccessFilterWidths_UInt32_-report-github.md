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
| Method | Strided | Mean      | Error     | StdDev    | Ratio | Allocated | Alloc Ratio |
|------- |-------- |----------:|----------:|----------:|------:|----------:|------------:|
| **Scalar** | **False**   | **49.558 μs** | **0.3934 μs** | **0.0609 μs** |  **1.00** |         **-** |          **NA** |
| Query  | False   |  2.849 μs | 0.2078 μs | 0.0540 μs |  0.06 |         - |          NA |
|        |         |           |           |           |       |           |             |
| **Scalar** | **True**    | **49.238 μs** | **6.6101 μs** | **1.0229 μs** |  **1.00** |         **-** |          **NA** |
| Query  | True    |  9.518 μs | 1.8317 μs | 0.2835 μs |  0.19 |         - |          NA |
