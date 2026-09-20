```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 98.08 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-MIBMUQ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=9  IterationTime=250ms  LaunchCount=1  
WarmupCount=5  

```
| Method                    | Categories    | WriteCount | Mean         | Error        | StdDev       | Ratio | RatioSD | Gen0    | Gen1    | Gen2    | Allocated | Alloc Ratio |
|-------------------------- |-------------- |----------- |-------------:|-------------:|-------------:|------:|--------:|--------:|--------:|--------:|----------:|------------:|
| **ImmediateHotCompleteCycle** | **CompleteCycle** | **1**          | **297,469.2 ns** | **36,684.30 ns** | **19,186.60 ns** |  **1.00** |    **0.00** | **82.3864** | **82.3864** | **82.3864** |  **271206 B** |        **1.00** |
| DeferredCompleteCycle     | CompleteCycle | 1          | 186,481.9 ns | 31,723.84 ns | 16,592.18 ns |  0.63 |    0.07 |       - |       - |       - |    9040 B |        0.03 |
|                           |               |            |              |              |              |       |         |         |         |         |           |             |
| **ImmediateHotCompleteCycle** | **CompleteCycle** | **20**         | **291,687.1 ns** | **45,370.03 ns** | **26,998.98 ns** |  **1.00** |    **0.00** | **82.3864** | **82.3864** | **82.3864** |  **271630 B** |        **1.00** |
| DeferredCompleteCycle     | CompleteCycle | 20         | 197,922.5 ns | 30,055.73 ns | 17,885.68 ns |  0.68 |    0.08 |       - |       - |       - |    9464 B |        0.03 |
|                           |               |            |              |              |              |       |         |         |         |         |           |             |
| **ImmediateHotEdits**         | **Edit**          | **1**          | **149,464.2 ns** | **15,302.53 ns** |  **8,003.52 ns** | **1.000** |    **0.00** | **83.0000** | **83.0000** | **83.0000** |  **262407 B** |       **1.000** |
| DeferredEdits             | Edit          | 1          |     399.0 ns |     42.45 ns |     25.26 ns | 0.003 |    0.00 |  0.0082 |       - |       - |     152 B |       0.001 |
|                           |               |            |              |              |              |       |         |         |         |         |           |             |
| **ImmediateHotEdits**         | **Edit**          | **20**         | **145,505.9 ns** |  **8,296.20 ns** |  **4,339.07 ns** | **1.000** |    **0.00** | **82.8373** | **82.8373** | **82.8373** |  **262407 B** |       **1.000** |
| DeferredEdits             | Edit          | 20         |   1,306.7 ns |    205.78 ns |    122.46 ns | 0.009 |    0.00 |  0.0085 |       - |       - |     152 B |       0.001 |
