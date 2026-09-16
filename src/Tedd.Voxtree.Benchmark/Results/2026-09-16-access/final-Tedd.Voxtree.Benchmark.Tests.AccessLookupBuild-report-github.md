```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.35 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method  | Pattern   | Mean          | Error         | StdDev       | Gen0    | Gen1    | Gen2    | Allocated |
|-------- |---------- |--------------:|--------------:|-------------:|--------:|--------:|--------:|----------:|
| **Compile** | **Uniform**   |      **27.87 ns** |      **3.665 ns** |     **0.952 ns** |  **0.0028** |       **-** |       **-** |      **48 B** |
| Decode  | Uniform   |  54,818.78 ns | 11,884.136 ns | 3,086.272 ns | 41.5816 | 41.5816 | 41.5816 |  131122 B |
| **Compile** | **Sparse**    |  **76,535.49 ns** |  **4,013.008 ns** | **1,042.166 ns** |  **1.8064** |       **-** |       **-** |   **30352 B** |
| Decode  | Sparse    | 193,508.08 ns |  7,355.387 ns | 1,138.254 ns | 41.3462 | 41.3462 | 41.3462 |  131122 B |
| **Compile** | **Random**    |      **18.63 ns** |      **4.403 ns** |     **0.681 ns** |  **0.0028** |       **-** |       **-** |      **48 B** |
| Decode  | Random    |  54,293.67 ns | 14,185.483 ns | 2,195.219 ns | 41.3996 | 41.3996 | 41.3996 |  131122 B |
| **Compile** | **Clustered** |     **226.39 ns** |     **33.096 ns** |     **5.122 ns** |  **0.0106** |       **-** |       **-** |     **184 B** |
| Decode  | Clustered |  63,256.54 ns | 11,903.577 ns | 3,091.321 ns | 41.5711 | 41.5711 | 41.5711 |  131122 B |
