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
| Method                     | ChannelCount | Pattern | Mean          | Error         | StdDev       | Ratio | RatioSD | Allocated | Alloc Ratio |
|--------------------------- |------------- |-------- |--------------:|--------------:|-------------:|------:|--------:|----------:|------------:|
| **EnvelopeThenValidate**       | **1**            | **Uniform** |      **15.34 ns** |      **0.114 ns** |     **0.029 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| ValidateInSinglePacketPass | 1            | Uniform |      11.35 ns |      0.037 ns |     0.006 ns |  0.74 |    0.00 |         - |          NA |
|                            |              |         |               |               |              |       |         |           |             |
| **EnvelopeThenValidate**       | **1**            | **Sparse**  |  **35,738.46 ns** |    **356.988 ns** |    **92.709 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| ValidateInSinglePacketPass | 1            | Sparse  |  33,896.77 ns |  1,291.199 ns |   199.814 ns |  0.95 |    0.01 |         - |          NA |
|                            |              |         |               |               |              |       |         |           |             |
| **EnvelopeThenValidate**       | **1**            | **Random**  |      **14.91 ns** |      **0.113 ns** |     **0.017 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| ValidateInSinglePacketPass | 1            | Random  |      11.80 ns |      0.453 ns |     0.070 ns |  0.79 |    0.00 |         - |          NA |
|                            |              |         |               |               |              |       |         |           |             |
| **EnvelopeThenValidate**       | **4**            | **Uniform** |      **45.87 ns** |      **1.015 ns** |     **0.157 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| ValidateInSinglePacketPass | 4            | Uniform |      27.79 ns |      0.467 ns |     0.121 ns |  0.61 |    0.00 |         - |          NA |
|                            |              |         |               |               |              |       |         |           |             |
| **EnvelopeThenValidate**       | **4**            | **Sparse**  | **142,594.72 ns** |  **1,635.426 ns** |   **424.715 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| ValidateInSinglePacketPass | 4            | Sparse  | 136,281.86 ns |  1,990.603 ns |   308.048 ns |  0.96 |    0.00 |         - |          NA |
|                            |              |         |               |               |              |       |         |           |             |
| **EnvelopeThenValidate**       | **4**            | **Random**  |      **42.46 ns** |      **0.480 ns** |     **0.074 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| ValidateInSinglePacketPass | 4            | Random  |      29.59 ns |      1.123 ns |     0.292 ns |  0.70 |    0.01 |         - |          NA |
|                            |              |         |               |               |              |       |         |           |             |
| **EnvelopeThenValidate**       | **16**           | **Uniform** |     **172.02 ns** |      **1.874 ns** |     **0.487 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| ValidateInSinglePacketPass | 16           | Uniform |      92.03 ns |      1.005 ns |     0.155 ns |  0.54 |    0.00 |         - |          NA |
|                            |              |         |               |               |              |       |         |           |             |
| **EnvelopeThenValidate**       | **16**           | **Sparse**  | **558,941.98 ns** | **22,640.609 ns** | **5,879.694 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| ValidateInSinglePacketPass | 16           | Sparse  | 552,460.62 ns | 29,087.710 ns | 7,553.986 ns |  0.99 |    0.02 |         - |          NA |
|                            |              |         |               |               |              |       |         |           |             |
| **EnvelopeThenValidate**       | **16**           | **Random**  |     **160.58 ns** |      **7.951 ns** |     **2.065 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| ValidateInSinglePacketPass | 16           | Random  |     103.91 ns |      0.787 ns |     0.204 ns |  0.65 |    0.01 |         - |          NA |
