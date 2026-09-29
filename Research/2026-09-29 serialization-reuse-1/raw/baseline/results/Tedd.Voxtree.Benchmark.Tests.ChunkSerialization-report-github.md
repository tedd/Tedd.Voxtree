```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 66.42 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1  
WarmupCount=3  

```
| Method                  | ChannelCount | Pattern   | Mean         | Error         | StdDev     | Allocated |
|------------------------ |------------- |---------- |-------------:|--------------:|-----------:|----------:|
| **SerializeToReusedBuffer** | **1**            | **Uniform**   |     **13.89 ns** |      **0.774 ns** |   **0.042 ns** |         **-** |
| **SerializeToReusedBuffer** | **1**            | **Random**    |  **6,210.49 ns** |  **1,297.739 ns** |  **71.133 ns** |         **-** |
| **SerializeToReusedBuffer** | **1**            | **Clustered** |     **12.58 ns** |      **1.846 ns** |   **0.101 ns** |         **-** |
| **SerializeToReusedBuffer** | **4**            | **Uniform**   |    **133.02 ns** |     **55.028 ns** |   **3.016 ns** |         **-** |
| **SerializeToReusedBuffer** | **4**            | **Random**    | **18,956.01 ns** |  **6,484.739 ns** | **355.450 ns** |         **-** |
| **SerializeToReusedBuffer** | **4**            | **Clustered** |    **131.57 ns** |     **53.227 ns** |   **2.918 ns** |         **-** |
| **SerializeToReusedBuffer** | **16**           | **Uniform**   |  **1,092.50 ns** |    **538.948 ns** |  **29.542 ns** |         **-** |
| **SerializeToReusedBuffer** | **16**           | **Random**    | **57,833.80 ns** | **18,117.808 ns** | **993.098 ns** |         **-** |
| **SerializeToReusedBuffer** | **16**           | **Clustered** |  **1,074.97 ns** |    **211.257 ns** |  **11.580 ns** |         **-** |
