```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 97.62 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-GJBZFV : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=7  IterationTime=150ms  LaunchCount=1  
WarmupCount=3  Categories=Edits  

```
| Method        | WriteCount | Pattern | Mean     | Error    | StdDev   | Code Size | Gen0   | Allocated |
|-------------- |----------- |-------- |---------:|---------:|---------:|----------:|-------:|----------:|
| **DeferredEdits** | **1**          | **Uniform** | **154.9 ns** | **40.63 ns** | **18.04 ns** |  **35,840 B** | **0.0087** |     **152 B** |
| **DeferredEdits** | **1**          | **Terrain** | **173.5 ns** | **84.76 ns** | **37.63 ns** |  **35,873 B** | **0.0086** |     **152 B** |
| **DeferredEdits** | **5**          | **Uniform** | **205.0 ns** | **35.87 ns** | **12.79 ns** |  **37,201 B** | **0.0084** |     **152 B** |
| **DeferredEdits** | **5**          | **Terrain** | **206.7 ns** | **70.07 ns** | **31.11 ns** |  **37,064 B** | **0.0087** |     **152 B** |
| **DeferredEdits** | **20**         | **Uniform** | **351.9 ns** | **34.76 ns** | **15.43 ns** |  **37,128 B** | **0.0089** |     **152 B** |
| **DeferredEdits** | **20**         | **Terrain** | **377.9 ns** | **67.28 ns** | **29.87 ns** |  **37,153 B** | **0.0069** |     **152 B** |
