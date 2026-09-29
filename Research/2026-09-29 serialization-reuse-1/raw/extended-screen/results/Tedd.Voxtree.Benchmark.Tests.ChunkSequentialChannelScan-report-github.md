```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 94.93 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-ZNVNAZ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=100ms  LaunchCount=1  
WarmupCount=3  

```
| Method               | ChannelCount | Mean        | Error     | StdDev    | Ratio | Allocated | Alloc Ratio |
|--------------------- |------------- |------------:|----------:|----------:|------:|----------:|------------:|
| **RepeatedIndexedScan**  | **16**           |   **197.04 ns** |  **5.299 ns** |  **1.376 ns** |  **1.00** |         **-** |          **NA** |
| SingleSequentialScan | 16           |    73.28 ns |  0.534 ns |  0.083 ns |  0.37 |         - |          NA |
|                      |              |             |           |           |       |           |             |
| **RepeatedIndexedScan**  | **64**           | **3,291.62 ns** | **90.054 ns** | **23.387 ns** |  **1.00** |         **-** |          **NA** |
| SingleSequentialScan | 64           |   304.75 ns | 13.840 ns |  2.142 ns |  0.09 |         - |          NA |
