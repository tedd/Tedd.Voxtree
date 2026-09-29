```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 80.49 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1  
WarmupCount=3  

```
| Method                              | ChannelCount | Pattern | Mean       | Error       | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|------------------------------------ |------------- |-------- |-----------:|------------:|----------:|------:|--------:|----------:|------------:|
| **SerializeLoadedPacketToReusedBuffer** | **1**            | **Random**  |   **6.096 μs** |   **0.3494 μs** | **0.0192 μs** |  **2.27** |    **0.01** |         **-** |          **NA** |
| SerializeLoadedPerChannelControl    | 1            | Random  |   2.683 μs |   0.1392 μs | 0.0076 μs |  1.00 |    0.00 |         - |          NA |
|                                     |              |         |            |             |           |       |         |           |             |
| **SerializeLoadedPacketToReusedBuffer** | **4**            | **Random**  |  **14.178 μs** |   **8.2398 μs** | **0.4516 μs** |  **1.02** |    **0.03** |         **-** |          **NA** |
| SerializeLoadedPerChannelControl    | 4            | Random  |  13.952 μs |   1.1365 μs | 0.0623 μs |  1.00 |    0.00 |         - |          NA |
|                                     |              |         |            |             |           |       |         |           |             |
| **SerializeLoadedPacketToReusedBuffer** | **16**           | **Random**  | **106.564 μs** | **114.8905 μs** | **6.2975 μs** |  **1.54** |    **0.11** |         **-** |          **NA** |
| SerializeLoadedPerChannelControl    | 16           | Random  |  69.281 μs |  72.1893 μs | 3.9569 μs |  1.00 |    0.00 |         - |          NA |
