```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 105.14 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-TVLPUQ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=12  IterationTime=250ms  WarmupCount=5  
Categories=Edits  

```
| Method        | WriteCount | Pattern | Mean     | Error   | StdDev  | Gen0   | Allocated |
|-------------- |----------- |-------- |---------:|--------:|--------:|-------:|----------:|
| **DeferredEdits** | **1**          | **Uniform** | **130.6 ns** | **0.63 ns** | **0.46 ns** | **0.0088** |     **152 B** |
| **DeferredEdits** | **1**          | **Terrain** | **129.2 ns** | **0.50 ns** | **0.33 ns** | **0.0088** |     **152 B** |
| **DeferredEdits** | **5**          | **Uniform** | **165.3 ns** | **0.87 ns** | **0.57 ns** | **0.0086** |     **152 B** |
| **DeferredEdits** | **5**          | **Terrain** | **161.7 ns** | **0.79 ns** | **0.57 ns** | **0.0091** |     **152 B** |
| **DeferredEdits** | **20**         | **Uniform** | **301.2 ns** | **0.61 ns** | **0.44 ns** | **0.0084** |     **152 B** |
| **DeferredEdits** | **20**         | **Terrain** | **311.4 ns** | **0.42 ns** | **0.30 ns** | **0.0087** |     **152 B** |
