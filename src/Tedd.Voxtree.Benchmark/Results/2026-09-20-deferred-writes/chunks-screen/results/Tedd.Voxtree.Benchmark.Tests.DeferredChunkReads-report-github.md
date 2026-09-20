```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 98.27 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-ZNVNAZ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=100ms  LaunchCount=1  
WarmupCount=3  

```
| Method           | Categories | PendingCount | Pattern | Mean      | Error     | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|----------------- |----------- |------------- |-------- |----------:|----------:|----------:|------:|--------:|----------:|------------:|
| **HotHits**          | **Hit**        | **1**            | **Uniform** |  **4.530 ns** | **0.1415 ns** | **0.0367 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredHits     | Hit        | 1            | Uniform |  5.530 ns | 0.1552 ns | 0.0403 ns |  1.22 |    0.01 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **HotHits**          | **Hit**        | **1**            | **Terrain** |  **4.554 ns** | **0.0328 ns** | **0.0051 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredHits     | Hit        | 1            | Terrain |  5.520 ns | 0.1874 ns | 0.0290 ns |  1.21 |    0.01 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **HotHits**          | **Hit**        | **20**           | **Uniform** |  **4.512 ns** | **0.0258 ns** | **0.0040 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredHits     | Hit        | 20           | Uniform |  6.417 ns | 0.1427 ns | 0.0371 ns |  1.42 |    0.01 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **HotHits**          | **Hit**        | **20**           | **Terrain** |  **4.537 ns** | **0.1126 ns** | **0.0292 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredHits     | Hit        | 20           | Terrain |  6.400 ns | 0.0927 ns | 0.0144 ns |  1.41 |    0.01 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **CompressedMisses** | **Miss**       | **1**            | **Uniform** |  **4.566 ns** | **0.0385 ns** | **0.0060 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredMisses   | Miss       | 1            | Uniform | 12.054 ns | 0.0148 ns | 0.0023 ns |  2.64 |    0.00 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **CompressedMisses** | **Miss**       | **1**            | **Terrain** | **18.314 ns** | **0.4435 ns** | **0.0686 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredMisses   | Miss       | 1            | Terrain | 25.361 ns | 0.4843 ns | 0.0749 ns |  1.38 |    0.01 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **CompressedMisses** | **Miss**       | **20**           | **Uniform** |  **4.505 ns** | **0.0362 ns** | **0.0056 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredMisses   | Miss       | 20           | Uniform | 12.359 ns | 0.0354 ns | 0.0055 ns |  2.74 |    0.00 |         - |          NA |
|                  |            |              |         |           |           |           |       |         |           |             |
| **CompressedMisses** | **Miss**       | **20**           | **Terrain** | **19.133 ns** | **1.9275 ns** | **0.2983 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| DeferredMisses   | Miss       | 20           | Terrain | 26.257 ns | 0.5340 ns | 0.1387 ns |  1.37 |    0.02 |         - |          NA |
