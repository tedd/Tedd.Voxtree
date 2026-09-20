```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 104.28 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-TVLPUQ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=12  IterationTime=250ms  WarmupCount=5  
Categories=Edits  

```
| Method        | WriteCount | Pattern | Mean     | Error   | StdDev  | Gen0   | Allocated |
|-------------- |----------- |-------- |---------:|--------:|--------:|-------:|----------:|
| **DeferredEdits** | **1**          | **Uniform** | **134.4 ns** | **0.39 ns** | **0.28 ns** | **0.0086** |     **152 B** |
| **DeferredEdits** | **1**          | **Terrain** | **131.9 ns** | **0.34 ns** | **0.24 ns** | **0.0090** |     **152 B** |
| **DeferredEdits** | **5**          | **Uniform** | **170.9 ns** | **1.06 ns** | **0.70 ns** | **0.0089** |     **152 B** |
| **DeferredEdits** | **5**          | **Terrain** | **162.2 ns** | **0.51 ns** | **0.37 ns** | **0.0091** |     **152 B** |
| **DeferredEdits** | **20**         | **Uniform** | **315.6 ns** | **0.27 ns** | **0.18 ns** | **0.0088** |     **152 B** |
| **DeferredEdits** | **20**         | **Terrain** | **323.1 ns** | **0.54 ns** | **0.36 ns** | **0.0090** |     **152 B** |
