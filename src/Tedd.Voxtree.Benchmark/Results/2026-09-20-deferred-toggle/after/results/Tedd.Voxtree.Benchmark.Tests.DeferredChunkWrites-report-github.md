```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 104.46 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-TVLPUQ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=12  IterationTime=250ms  WarmupCount=5  
Categories=Edits  

```
| Method        | WriteCount | Pattern | Mean     | Error    | StdDev   | Gen0   | Allocated |
|-------------- |----------- |-------- |---------:|---------:|---------:|-------:|----------:|
| **DeferredEdits** | **1**          | **Uniform** | **195.3 ns** | **25.82 ns** | **20.16 ns** | **0.0087** |     **152 B** |
| **DeferredEdits** | **1**          | **Terrain** | **158.7 ns** | **10.68 ns** |  **7.72 ns** | **0.0091** |     **152 B** |
| **DeferredEdits** | **5**          | **Uniform** | **196.5 ns** |  **6.83 ns** |  **4.52 ns** | **0.0086** |     **152 B** |
| **DeferredEdits** | **5**          | **Terrain** | **199.9 ns** | **11.82 ns** |  **8.55 ns** | **0.0085** |     **152 B** |
| **DeferredEdits** | **20**         | **Uniform** | **371.8 ns** | **16.79 ns** | **12.14 ns** | **0.0083** |     **152 B** |
| **DeferredEdits** | **20**         | **Terrain** | **371.9 ns** | **14.56 ns** | **10.53 ns** | **0.0087** |     **152 B** |
