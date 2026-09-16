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
| Method | Strided | Mean      | Error    | StdDev    | Ratio | Allocated | Alloc Ratio |
|------- |-------- |----------:|---------:|----------:|------:|----------:|------------:|
| **Scalar** | **False**   | **50.011 μs** | **1.526 μs** | **0.2362 μs** |  **1.00** |         **-** |          **NA** |
| Query  | False   |  5.287 μs | 1.279 μs | 0.3321 μs |  0.11 |         - |          NA |
|        |         |           |          |           |       |           |             |
| **Scalar** | **True**    | **55.544 μs** | **9.731 μs** | **2.5270 μs** |  **1.00** |         **-** |          **NA** |
| Query  | True    |  9.303 μs | 1.522 μs | 0.3953 μs |  0.17 |         - |          NA |
