```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 98.15 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-ZNVNAZ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=100ms  LaunchCount=1  
WarmupCount=3  

```
| Method            | Count | Mean       | Error     | StdDev    | Ratio | RatioSD | Code Size | Allocated | Alloc Ratio |
|------------------ |------ |-----------:|----------:|----------:|------:|--------:|----------:|----------:|------------:|
| **Scalar**            | **1**     |  **0.6328 ns** | **0.0094 ns** | **0.0024 ns** |  **1.00** |    **0.00** |     **127 B** |         **-** |          **NA** |
| SpanIndexOf       | 1     |  2.5641 ns | 0.0687 ns | 0.0178 ns |  4.05 |    0.03 |   1,725 B |         - |          NA |
| ExplicitVector256 | 1     |  0.9329 ns | 0.0319 ns | 0.0083 ns |  1.47 |    0.01 |     272 B |         - |          NA |
| PaddedVector256   | 1     |  1.5574 ns | 0.0344 ns | 0.0053 ns |  2.46 |    0.01 |     254 B |         - |          NA |
|                   |       |            |           |           |       |         |           |           |             |
| **Scalar**            | **5**     |  **2.1252 ns** | **0.2184 ns** | **0.0567 ns** |  **1.00** |    **0.00** |     **127 B** |         **-** |          **NA** |
| SpanIndexOf       | 5     |  3.3529 ns | 0.0134 ns | 0.0021 ns |  1.58 |    0.04 |   1,187 B |         - |          NA |
| ExplicitVector256 | 5     |  2.3866 ns | 0.1066 ns | 0.0277 ns |  1.12 |    0.03 |     259 B |         - |          NA |
| PaddedVector256   | 5     |  1.5528 ns | 0.0596 ns | 0.0155 ns |  0.73 |    0.02 |     257 B |         - |          NA |
|                   |       |            |           |           |       |         |           |           |             |
| **Scalar**            | **20**    |  **6.3646 ns** | **0.2222 ns** | **0.0344 ns** |  **1.00** |    **0.00** |     **127 B** |         **-** |          **NA** |
| SpanIndexOf       | 20    |  3.5187 ns | 0.0741 ns | 0.0193 ns |  0.55 |    0.00 |   1,314 B |         - |          NA |
| ExplicitVector256 | 20    |  2.6794 ns | 0.0407 ns | 0.0106 ns |  0.42 |    0.00 |     270 B |         - |          NA |
| PaddedVector256   | 20    |  2.4031 ns | 0.2049 ns | 0.0532 ns |  0.38 |    0.01 |     266 B |         - |          NA |
|                   |       |            |           |           |       |         |           |           |             |
| **Scalar**            | **256**   | **53.6614 ns** | **2.3073 ns** | **0.5992 ns** |  **1.00** |    **0.00** |     **130 B** |         **-** |          **NA** |
| SpanIndexOf       | 256   |  8.7398 ns | 0.6214 ns | 0.1614 ns |  0.16 |    0.00 |   1,300 B |         - |          NA |
| ExplicitVector256 | 256   | 11.1323 ns | 0.2180 ns | 0.0566 ns |  0.21 |    0.00 |     264 B |         - |          NA |
| PaddedVector256   | 256   | 10.8925 ns | 0.3103 ns | 0.0806 ns |  0.20 |    0.00 |     280 B |         - |          NA |
