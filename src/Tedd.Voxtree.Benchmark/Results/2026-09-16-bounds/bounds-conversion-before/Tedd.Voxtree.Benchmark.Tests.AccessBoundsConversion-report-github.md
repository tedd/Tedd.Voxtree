```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 65.56 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method           | Levels | SourceLayout | Mean        | Error        | StdDev      | Ratio | RatioSD | Code Size | Allocated | Alloc Ratio |
|----------------- |------- |------------- |------------:|-------------:|------------:|------:|--------:|----------:|----------:|------------:|
| **Production**       | **3**      | **Linear**       |    **934.3 ns** |    **255.35 ns** |    **39.52 ns** |  **1.00** |    **0.00** |   **2,383 B** |         **-** |          **NA** |
| PrevalidatedRows | 3      | Linear       |  1,040.4 ns |    661.31 ns |   171.74 ns |  1.12 |    0.17 |     912 B |         - |          NA |
| ManagedReference | 3      | Linear       |    480.0 ns |    124.32 ns |    19.24 ns |  0.51 |    0.03 |     779 B |         - |          NA |
|                  |        |              |             |              |             |       |         |           |           |             |
| **Production**       | **3**      | **Morton**       |    **505.6 ns** |    **115.59 ns** |    **30.02 ns** |  **1.00** |    **0.00** |   **2,383 B** |         **-** |          **NA** |
| PrevalidatedRows | 3      | Morton       |    457.8 ns |     90.04 ns |    13.93 ns |  0.91 |    0.06 |     912 B |         - |          NA |
| ManagedReference | 3      | Morton       |    463.6 ns |    175.94 ns |    45.69 ns |  0.92 |    0.10 |     779 B |         - |          NA |
|                  |        |              |             |              |             |       |         |           |           |             |
| **Production**       | **5**      | **Linear**       | **27,383.0 ns** |  **6,438.41 ns** | **1,672.03 ns** |  **1.00** |    **0.00** |   **2,383 B** |         **-** |          **NA** |
| PrevalidatedRows | 5      | Linear       | 25,553.7 ns |  3,086.98 ns |   801.68 ns |  0.94 |    0.06 |     912 B |         - |          NA |
| ManagedReference | 5      | Linear       | 29,823.9 ns |  9,291.70 ns | 2,413.02 ns |  1.09 |    0.10 |     779 B |         - |          NA |
|                  |        |              |             |              |             |       |         |           |           |             |
| **Production**       | **5**      | **Morton**       | **28,577.3 ns** |  **4,490.11 ns** | **1,166.07 ns** |  **1.00** |    **0.00** |   **2,383 B** |         **-** |          **NA** |
| PrevalidatedRows | 5      | Morton       | 31,793.0 ns | 10,167.38 ns | 2,640.44 ns |  1.11 |    0.09 |     912 B |         - |          NA |
| ManagedReference | 5      | Morton       | 36,881.7 ns | 12,546.00 ns | 3,258.16 ns |  1.29 |    0.11 |     779 B |         - |          NA |
