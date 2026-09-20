```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 98.32 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-MIBMUQ : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=9  IterationTime=250ms  LaunchCount=1  
WarmupCount=5  

```
| Method                    | Categories    | WriteCount | Mean         | Error        | StdDev       | Ratio | RatioSD | Gen0    | Gen1    | Gen2    | Allocated | Alloc Ratio |
|-------------------------- |-------------- |----------- |-------------:|-------------:|-------------:|------:|--------:|--------:|--------:|--------:|----------:|------------:|
| **ImmediateHotCompleteCycle** | **CompleteCycle** | **1**          | **288,918.0 ns** | **32,621.10 ns** | **19,412.29 ns** |  **1.00** |    **0.00** | **82.3864** | **82.3864** | **82.3864** |  **271206 B** |        **1.00** |
| DeferredCompleteCycle     | CompleteCycle | 1          | 198,304.6 ns | 29,498.51 ns | 17,554.09 ns |  0.69 |    0.07 |       - |       - |       - |    9040 B |        0.03 |
|                           |               |            |              |              |              |       |         |         |         |         |           |             |
| **ImmediateHotCompleteCycle** | **CompleteCycle** | **20**         | **302,564.5 ns** | **27,628.84 ns** | **14,450.42 ns** |  **1.00** |    **0.00** | **83.0078** | **83.0078** | **83.0078** |  **271631 B** |        **1.00** |
| DeferredCompleteCycle     | CompleteCycle | 20         | 214,586.8 ns | 43,690.22 ns | 25,999.35 ns |  0.71 |    0.09 |       - |       - |       - |    9464 B |        0.03 |
|                           |               |            |              |              |              |       |         |         |         |         |           |             |
| **ImmediateHotEdits**         | **Edit**          | **1**          | **148,264.4 ns** | **11,126.55 ns** |  **4,940.26 ns** | **1.000** |    **0.00** | **83.0000** | **83.0000** | **83.0000** |  **262407 B** |       **1.000** |
| DeferredEdits             | Edit          | 1          |     419.9 ns |     63.45 ns |     37.76 ns | 0.003 |    0.00 |  0.0081 |       - |       - |     152 B |       0.001 |
|                           |               |            |              |              |              |       |         |         |         |         |           |             |
| **ImmediateHotEdits**         | **Edit**          | **20**         | **149,164.3 ns** |  **9,657.96 ns** |  **5,051.30 ns** | **1.000** |    **0.00** | **82.8373** | **82.8373** | **82.8373** |  **262407 B** |       **1.000** |
| DeferredEdits             | Edit          | 20         |   1,392.5 ns |    237.93 ns |    141.59 ns | 0.009 |    0.00 |  0.0084 |       - |       - |     152 B |       0.001 |
