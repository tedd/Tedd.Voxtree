```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 98.32 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-MIBMUQ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=9  IterationTime=250ms  LaunchCount=1  
WarmupCount=5  

```
| Method           | Categories | PendingCount | Pattern | Mean      | Error     | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|----------------- |----------- |------------- |-------- |----------:|----------:|----------:|------:|--------:|----------:|------------:|
| **HotHits**          | **Hit**        | **1**            | **Uniform** |  **5.445 ns** | **0.9676 ns** | **0.4296 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredHits     | Hit        | 1            | Uniform |  7.771 ns | 1.7071 ns | 1.0159 ns |  1.44 |    0.21 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **HotHits**          | **Hit**        | **1**            | **Terrain** |  **4.511 ns** | **0.0073 ns** | **0.0038 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredHits     | Hit        | 1            | Terrain |  7.167 ns | 1.0249 ns | 0.6099 ns |  1.59 |    0.13 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **HotHits**          | **Hit**        | **20**           | **Uniform** |  **6.004 ns** | **1.3679 ns** | **0.8140 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredHits     | Hit        | 20           | Uniform |  7.979 ns | 0.8853 ns | 0.4630 ns |  1.35 |    0.19 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **HotHits**          | **Hit**        | **20**           | **Terrain** |  **5.498 ns** | **0.3318 ns** | **0.1736 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredHits     | Hit        | 20           | Terrain |  8.404 ns | 0.9731 ns | 0.5791 ns |  1.53 |    0.11 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **CompressedMisses** | **Miss**       | **1**            | **Uniform** |  **5.627 ns** | **0.6041 ns** | **0.3160 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredMisses   | Miss       | 1            | Uniform | 14.316 ns | 1.3125 ns | 0.5828 ns |  2.55 |    0.17 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **CompressedMisses** | **Miss**       | **1**            | **Terrain** | **22.090 ns** | **1.0538 ns** | **0.4679 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredMisses   | Miss       | 1            | Terrain | 34.567 ns | 6.6991 ns | 3.9865 ns |  1.57 |    0.17 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **CompressedMisses** | **Miss**       | **20**           | **Uniform** |  **5.006 ns** | **0.2313 ns** | **0.1027 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredMisses   | Miss       | 20           | Uniform | 15.382 ns | 2.4178 ns | 1.4388 ns |  3.07 |    0.28 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **CompressedMisses** | **Miss**       | **20**           | **Terrain** | **22.917 ns** | **3.0839 ns** | **1.8352 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredMisses   | Miss       | 20           | Terrain | 33.583 ns | 5.5127 ns | 3.2805 ns |  1.47 |    0.17 |         - |          NA |
