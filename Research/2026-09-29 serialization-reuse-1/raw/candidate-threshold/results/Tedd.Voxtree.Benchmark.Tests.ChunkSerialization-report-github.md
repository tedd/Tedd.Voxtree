```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 95.85 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1  
WarmupCount=3  

```
| Method                              | ChannelCount | Pattern | Mean      | Error     | StdDev    | Ratio | Allocated | Alloc Ratio |
|------------------------------------ |------------- |-------- |----------:|----------:|----------:|------:|----------:|------------:|
| **SerializeToReusedBuffer**             | **1**            | **Random**  |  **6.069 μs** | **0.1573 μs** | **0.0086 μs** |  **2.24** |         **-** |          **NA** |
| SerializeLoadedPacketToReusedBuffer | 1            | Random  |  6.144 μs | 0.4383 μs | 0.0240 μs |  2.27 |         - |          NA |
| SerializeLoadedPerChannelControl    | 1            | Random  |  2.705 μs | 0.3042 μs | 0.0167 μs |  1.00 |         - |          NA |
|                                     |              |         |           |           |           |       |           |             |
| **SerializeToReusedBuffer**             | **4**            | **Random**  | **18.898 μs** | **1.3012 μs** | **0.0713 μs** |  **1.45** |         **-** |          **NA** |
| SerializeLoadedPacketToReusedBuffer | 4            | Random  | 13.831 μs | 0.9891 μs | 0.0542 μs |  1.06 |         - |          NA |
| SerializeLoadedPerChannelControl    | 4            | Random  | 13.016 μs | 0.6658 μs | 0.0365 μs |  1.00 |         - |          NA |
|                                     |              |         |           |           |           |       |           |             |
| **SerializeToReusedBuffer**             | **16**           | **Random**  | **55.121 μs** | **2.7321 μs** | **0.1498 μs** |  **0.85** |         **-** |          **NA** |
| SerializeLoadedPacketToReusedBuffer | 16           | Random  | 92.163 μs | 1.3700 μs | 0.0751 μs |  1.41 |         - |          NA |
| SerializeLoadedPerChannelControl    | 16           | Random  | 65.184 μs | 5.9131 μs | 0.3241 μs |  1.00 |         - |          NA |
