```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 91.88 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1  
WarmupCount=3  

```
| Method              | Capacity | Mean       | Error       | StdDev    | Ratio | RatioSD | Gen0   | Gen1   | Allocated | Alloc Ratio |
|-------------------- |--------- |-----------:|------------:|----------:|------:|--------:|-------:|-------:|----------:|------------:|
| **SharedPoolRoundTrip** | **20**       |  **46.105 ns** |   **2.4820 ns** | **0.1360 ns** |  **1.00** |    **0.00** |      **-** |      **-** |         **-** |          **NA** |
| ExactOwnedArrays    | 20       |  15.730 ns |   4.8839 ns | 0.2677 ns |  0.34 |    0.01 | 0.0124 |      - |     208 B |          NA |
| CallerReusedArrays  | 20       |   3.421 ns |   0.3256 ns | 0.0178 ns |  0.07 |    0.00 |      - |      - |         - |          NA |
|                     |          |            |             |           |       |         |        |        |           |             |
| **SharedPoolRoundTrip** | **32**       |  **53.039 ns** |   **2.6074 ns** | **0.1429 ns** |  **1.00** |    **0.00** |      **-** |      **-** |         **-** |          **NA** |
| ExactOwnedArrays    | 32       |  18.731 ns |  15.3548 ns | 0.8416 ns |  0.35 |    0.01 | 0.0167 |      - |     280 B |          NA |
| CallerReusedArrays  | 32       |   3.399 ns |   0.2325 ns | 0.0127 ns |  0.06 |    0.00 |      - |      - |         - |          NA |
|                     |          |            |             |           |       |         |        |        |           |             |
| **SharedPoolRoundTrip** | **64**       |  **46.326 ns** |   **5.7763 ns** | **0.3166 ns** |  **1.00** |    **0.00** |      **-** |      **-** |         **-** |          **NA** |
| ExactOwnedArrays    | 64       |  24.165 ns |  18.7306 ns | 1.0267 ns |  0.52 |    0.02 | 0.0282 |      - |     472 B |          NA |
| CallerReusedArrays  | 64       |   3.670 ns |   0.2009 ns | 0.0110 ns |  0.08 |    0.00 |      - |      - |         - |          NA |
|                     |          |            |             |           |       |         |        |        |           |             |
| **SharedPoolRoundTrip** | **256**      |  **46.249 ns** |   **5.3334 ns** | **0.2923 ns** |  **1.00** |    **0.00** |      **-** |      **-** |         **-** |          **NA** |
| ExactOwnedArrays    | 256      |  58.978 ns |  17.2372 ns | 0.9448 ns |  1.28 |    0.02 | 0.1000 | 0.0002 |    1672 B |          NA |
| CallerReusedArrays  | 256      |   4.127 ns |   1.7896 ns | 0.0981 ns |  0.09 |    0.00 |      - |      - |         - |          NA |
|                     |          |            |             |           |       |         |        |        |           |             |
| **SharedPoolRoundTrip** | **512**      |  **42.705 ns** |  **16.3378 ns** | **0.8955 ns** |  **1.00** |    **0.00** |      **-** |      **-** |         **-** |          **NA** |
| ExactOwnedArrays    | 512      | 111.654 ns | 116.5000 ns | 6.3858 ns |  2.62 |    0.14 | 0.1955 | 0.0007 |    3272 B |          NA |
| CallerReusedArrays  | 512      |   5.194 ns |   1.6140 ns | 0.0885 ns |  0.12 |    0.00 |      - |      - |         - |          NA |
