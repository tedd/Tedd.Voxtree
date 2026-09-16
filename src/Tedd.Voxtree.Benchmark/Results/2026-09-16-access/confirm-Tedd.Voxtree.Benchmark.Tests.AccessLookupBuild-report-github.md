```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.29 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method          | Pattern   | Mean          | Error         | StdDev       | Gen0    | Gen1    | Gen2    | Allocated |
|---------------- |---------- |--------------:|--------------:|-------------:|--------:|--------:|--------:|----------:|
| **CompileBorrowed** | **Uniform**   |      **12.70 ns** |      **2.677 ns** |     **0.695 ns** |  **0.0028** |       **-** |       **-** |      **48 B** |
| Compile         | Uniform   |      18.50 ns |      1.904 ns |     0.494 ns |  0.0028 |       - |       - |      48 B |
| Decode          | Uniform   |  55,877.09 ns | 11,544.274 ns | 2,998.011 ns | 41.4980 | 41.4980 | 41.4980 |  131122 B |
| **CompileBorrowed** | **Sparse**    |  **78,130.89 ns** | **22,201.962 ns** | **5,765.779 ns** |  **1.8064** |       **-** |       **-** |   **30352 B** |
| Compile         | Sparse    |  75,797.22 ns | 15,968.075 ns | 4,146.858 ns |  1.7756 |       - |       - |   30352 B |
| Decode          | Sparse    | 224,659.20 ns | 18,856.787 ns | 2,918.109 ns | 40.9091 | 40.9091 | 40.9091 |  131122 B |
| **CompileBorrowed** | **Random**    |  **54,785.73 ns** |  **9,997.105 ns** | **2,596.217 ns** | **41.5784** | **41.5784** | **41.5784** |  **131178 B** |
| Compile         | Random    |      13.83 ns |      1.286 ns |     0.334 ns |  0.0029 |       - |       - |      48 B |
| Decode          | Random    |  55,446.59 ns |  2,889.337 ns |   750.352 ns | 41.5795 | 41.5795 | 41.5795 |  131122 B |
| **CompileBorrowed** | **Clustered** |     **246.06 ns** |     **36.193 ns** |     **9.399 ns** |  **0.0104** |       **-** |       **-** |     **184 B** |
| Compile         | Clustered |     250.80 ns |     39.069 ns |     6.046 ns |  0.0106 |       - |       - |     184 B |
| Decode          | Clustered |  59,200.35 ns | 10,964.595 ns | 2,847.471 ns | 41.4747 | 41.4747 | 41.4747 |  131122 B |
