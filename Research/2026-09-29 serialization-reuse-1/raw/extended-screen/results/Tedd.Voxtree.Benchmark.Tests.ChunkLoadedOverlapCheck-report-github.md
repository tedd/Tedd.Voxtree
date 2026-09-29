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
| Method                   | Mean     | Error    | StdDev   | Ratio | RatioSD | Allocated | Alloc Ratio |
|------------------------- |---------:|---------:|---------:|------:|--------:|----------:|------------:|
| PerChannelOverlapChecks  | 92.37 μs | 1.982 μs | 0.515 μs |  1.00 |    0.00 |         - |          NA |
| SinglePacketOverlapCheck | 66.46 μs | 5.778 μs | 1.501 μs |  0.72 |    0.02 |         - |          NA |
