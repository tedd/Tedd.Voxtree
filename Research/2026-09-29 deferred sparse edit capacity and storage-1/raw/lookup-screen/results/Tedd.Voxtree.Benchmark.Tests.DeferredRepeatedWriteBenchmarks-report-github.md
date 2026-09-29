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
| Method            | WriteCount | Mean       | Error     | StdDev   | Gen0   | Allocated |
|------------------ |----------- |-----------:|----------:|---------:|-------:|----------:|
| **RepeatedPosition**  | **20**         |   **297.6 ns** | **105.84 ns** |  **5.80 ns** | **0.0100** |     **168 B** |
| DistinctPositions | 20         |   318.3 ns | 415.09 ns | 22.75 ns | 0.0100 |     168 B |
| **RepeatedPosition**  | **256**        | **2,112.8 ns** | **643.77 ns** | **35.29 ns** | **0.0095** |     **168 B** |
| DistinctPositions | 256        | 3,317.1 ns |  24.15 ns |  1.32 ns | 0.0076 |     168 B |
