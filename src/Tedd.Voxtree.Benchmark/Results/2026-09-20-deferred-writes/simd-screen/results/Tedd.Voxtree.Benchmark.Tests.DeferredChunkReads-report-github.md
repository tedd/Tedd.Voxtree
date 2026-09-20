```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 97.62 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-GJBZFV : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=7  IterationTime=150ms  LaunchCount=1  
WarmupCount=3  

```
| Method         | Categories | PendingCount | Pattern | Mean      | Error     | StdDev    | Code Size | Allocated |
|--------------- |----------- |------------- |-------- |----------:|----------:|----------:|----------:|----------:|
| **DeferredHits**   | **Hit**        | **1**            | **Uniform** |  **4.445 ns** | **0.4766 ns** | **0.2116 ns** |   **7,116 B** |         **-** |
| **DeferredHits**   | **Hit**        | **1**            | **Terrain** |  **5.039 ns** | **1.3682 ns** | **0.6075 ns** |   **7,161 B** |         **-** |
| **DeferredHits**   | **Hit**        | **20**           | **Uniform** |  **5.961 ns** | **1.0403 ns** | **0.4619 ns** |   **7,134 B** |         **-** |
| **DeferredHits**   | **Hit**        | **20**           | **Terrain** |  **6.820 ns** | **3.2915 ns** | **1.4614 ns** |   **7,182 B** |         **-** |
|                |            |              |         |           |           |           |           |           |
| **DeferredMisses** | **Miss**       | **1**            | **Uniform** | **16.078 ns** | **1.9912 ns** | **0.7101 ns** |   **5,866 B** |         **-** |
| **DeferredMisses** | **Miss**       | **1**            | **Terrain** | **30.865 ns** | **5.9794 ns** | **2.1323 ns** |   **5,951 B** |         **-** |
| **DeferredMisses** | **Miss**       | **20**           | **Uniform** | **17.865 ns** | **3.0398 ns** | **1.3497 ns** |   **5,891 B** |         **-** |
| **DeferredMisses** | **Miss**       | **20**           | **Terrain** | **30.912 ns** | **0.3070 ns** | **0.1095 ns** |   **5,976 B** |         **-** |
