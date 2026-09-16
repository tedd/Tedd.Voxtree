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
| Method        | Count | Mean      | Error     | StdDev    | Ratio | RatioSD | Code Size | Allocated | Alloc Ratio |
|-------------- |------ |----------:|----------:|----------:|------:|--------:|----------:|----------:|------------:|
| **FieldLength**   | **4096**  |  **2.653 μs** | **0.1320 μs** | **0.0343 μs** |  **1.00** |    **0.00** |      **64 B** |         **-** |          **NA** |
| LocalLength   | 4096  |  1.531 μs | 0.3149 μs | 0.0487 μs |  0.58 |    0.02 |      30 B |         - |          NA |
| CheckedPrefix | 4096  |  1.533 μs | 0.1417 μs | 0.0368 μs |  0.58 |    0.01 |     122 B |         - |          NA |
| SlicedPrefix  | 4096  |  1.434 μs | 0.3100 μs | 0.0805 μs |  0.54 |    0.03 |      70 B |         - |          NA |
| RefPrefix     | 4096  |  1.230 μs | 0.0111 μs | 0.0017 μs |  0.46 |    0.01 |      73 B |         - |          NA |
|               |       |           |           |           |       |         |           |           |             |
| **FieldLength**   | **32768** | **20.211 μs** | **2.6025 μs** | **0.6759 μs** |  **1.00** |    **0.00** |      **64 B** |         **-** |          **NA** |
| LocalLength   | 32768 | 11.330 μs | 1.9278 μs | 0.5006 μs |  0.56 |    0.03 |      30 B |         - |          NA |
| CheckedPrefix | 32768 | 12.059 μs | 3.9214 μs | 1.0184 μs |  0.60 |    0.05 |     122 B |         - |          NA |
| SlicedPrefix  | 32768 | 13.735 μs | 4.1733 μs | 0.6458 μs |  0.68 |    0.04 |      70 B |         - |          NA |
| RefPrefix     | 32768 | 14.721 μs | 4.3024 μs | 1.1173 μs |  0.73 |    0.06 |      73 B |         - |          NA |
