```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 98.19 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-ZNVNAZ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=100ms  LaunchCount=1  
WarmupCount=3  Categories=Repackage  

```
| Method               | WriteCount | Pattern | Mean      | Error    | StdDev   | Ratio | Gen0    | Gen1    | Gen2    | Allocated | Alloc Ratio |
|--------------------- |----------- |-------- |----------:|---------:|---------:|------:|--------:|--------:|--------:|----------:|------------:|
| **MarkHotAndCommit**     | **1**          | **Uniform** |  **84.78 μs** | **3.108 μs** | **0.481 μs** |  **1.00** | **82.7703** | **82.7703** | **82.7703** |  **262599 B** |       **1.000** |
| DeferredAndRepackage | 1          | Uniform |  14.55 μs | 0.036 μs | 0.006 μs |  0.17 |       - |       - |       - |     480 B |       0.002 |
|                      |            |         |           |          |          |       |         |         |         |           |             |
| **MarkHotAndCommit**     | **1**          | **Terrain** | **232.33 μs** | **7.402 μs** | **1.145 μs** |  **1.00** | **81.0185** | **81.0185** | **81.0185** |  **271100 B** |        **1.00** |
| DeferredAndRepackage | 1          | Terrain | 160.32 μs | 3.220 μs | 0.836 μs |  0.69 |       - |       - |       - |    8984 B |        0.03 |
|                      |            |         |           |          |          |       |         |         |         |           |             |
| **MarkHotAndCommit**     | **5**          | **Uniform** |  **84.62 μs** | **1.949 μs** | **0.506 μs** |  **1.00** | **82.7465** | **82.7465** | **82.7465** |  **262687 B** |       **1.000** |
| DeferredAndRepackage | 5          | Uniform |  13.36 μs | 0.058 μs | 0.009 μs |  0.16 |       - |       - |       - |     568 B |       0.002 |
|                      |            |         |           |          |          |       |         |         |         |           |             |
| **MarkHotAndCommit**     | **5**          | **Terrain** | **233.60 μs** | **3.035 μs** | **0.788 μs** |  **1.00** | **81.0185** | **81.0185** | **81.0185** |  **271180 B** |        **1.00** |
| DeferredAndRepackage | 5          | Terrain | 162.06 μs | 8.536 μs | 2.217 μs |  0.69 |       - |       - |       - |    9064 B |        0.03 |
|                      |            |         |           |          |          |       |         |         |         |           |             |
| **MarkHotAndCommit**     | **20**         | **Uniform** |  **95.30 μs** | **2.027 μs** | **0.314 μs** |  **1.00** | **82.3864** | **82.3864** | **82.3864** |  **263118 B** |       **1.000** |
| DeferredAndRepackage | 20         | Uniform |  20.97 μs | 0.271 μs | 0.042 μs |  0.22 |       - |       - |       - |    1000 B |       0.004 |
|                      |            |         |           |          |          |       |         |         |         |           |             |
| **MarkHotAndCommit**     | **20**         | **Terrain** | **233.97 μs** | **5.570 μs** | **0.862 μs** |  **1.00** | **81.0185** | **81.0185** | **81.0185** |  **271524 B** |        **1.00** |
| DeferredAndRepackage | 20         | Terrain | 161.56 μs | 1.553 μs | 0.403 μs |  0.69 |       - |       - |       - |    9408 B |        0.03 |
