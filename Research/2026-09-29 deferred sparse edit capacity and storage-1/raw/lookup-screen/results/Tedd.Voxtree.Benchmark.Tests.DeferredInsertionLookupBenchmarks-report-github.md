```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 90.48 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1
WarmupCount=3

```
| Method          | Count | Mean        | Error        | StdDev      | Ratio | RatioSD | Allocated | Alloc Ratio |
|---------------- |------ |------------:|-------------:|------------:|------:|--------:|----------:|------------:|
| **LinearBuild**     | **20**    |    **160.2 ns** |      **1.45 ns** |     **0.08 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DictionaryBuild | 20    |    128.7 ns |      1.84 ns |     0.10 ns |  0.80 |    0.00 |         - |          NA |
|                 |       |             |              |             |       |         |           |             |
| **LinearBuild**     | **32**    |    **252.3 ns** |      **3.83 ns** |     **0.21 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DictionaryBuild | 32    |    197.8 ns |      1.75 ns |     0.10 ns |  0.78 |    0.00 |         - |          NA |
|                 |       |             |              |             |       |         |           |             |
| **LinearBuild**     | **64**    |    **564.6 ns** |      **4.18 ns** |     **0.23 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DictionaryBuild | 64    |    457.9 ns |      9.48 ns |     0.52 ns |  0.81 |    0.00 |         - |          NA |
|                 |       |             |              |             |       |         |           |             |
| **LinearBuild**     | **128**   |  **1,205.6 ns** |      **8.72 ns** |     **0.48 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DictionaryBuild | 128   |    820.1 ns |     16.62 ns |     0.91 ns |  0.68 |    0.00 |         - |          NA |
|                 |       |             |              |             |       |         |           |             |
| **LinearBuild**     | **256**   |  **2,578.0 ns** |    **593.99 ns** |    **32.56 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DictionaryBuild | 256   |  1,656.1 ns |     23.15 ns |     1.27 ns |  0.64 |    0.01 |         - |          NA |
|                 |       |             |              |             |       |         |           |             |
| **LinearBuild**     | **512**   |  **6,056.4 ns** |    **920.62 ns** |    **50.46 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DictionaryBuild | 512   |  3,766.8 ns | 15,507.12 ns |   850.00 ns |  0.62 |    0.12 |         - |          NA |
|                 |       |             |              |             |       |         |           |             |
| **LinearBuild**     | **1024**  | **23,188.4 ns** | **21,378.80 ns** | **1,171.84 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DictionaryBuild | 1024  |  8,233.5 ns | 16,836.34 ns |   922.86 ns |  0.36 |    0.04 |         - |          NA |
