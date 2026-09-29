```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 92.42 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1
WarmupCount=3

```
| Method                 | Case           | Pattern | Mean       | Error      | StdDev     | Gen0     | Gen1     | Gen2     | Allocated |
|----------------------- |--------------- |-------- |-----------:|-----------:|-----------:|---------:|---------:|---------:|----------:|
| **DeferredEditSession**    | **C20-W21-1of8**   | **Uniform** |   **2.707 μs** |   **1.943 μs** |  **0.1065 μs** |   **0.0191** |        **-** |        **-** |     **328 B** |
| DeferredCompleteCycle  | C20-W21-1of8   | Uniform |  17.900 μs |  17.472 μs |  0.9577 μs |   0.0610 |        - |        - |    1256 B |
| DeferredSerializeCycle | C20-W21-1of8   | Uniform |  17.635 μs |   7.038 μs |  0.3858 μs |   0.0610 |        - |        - |    1256 B |
| DeferredMakeHotCycle   | C20-W21-1of8   | Uniform | 137.331 μs |  21.309 μs |  1.1680 μs | 176.7578 | 176.7578 | 176.7578 | 1050138 B |
| **DeferredEditSession**    | **C20-W21-1of8**   | **Terrain** |  **31.431 μs** |  **35.380 μs** |  **1.9393 μs** |        **-** |        **-** |        **-** |     **328 B** |
| DeferredCompleteCycle  | C20-W21-1of8   | Terrain |  95.232 μs |  38.213 μs |  2.0946 μs |   0.2441 |        - |        - |    5408 B |
| DeferredSerializeCycle | C20-W21-1of8   | Terrain | 103.196 μs |   4.946 μs |  0.2711 μs |   0.2441 |        - |        - |    5408 B |
| DeferredMakeHotCycle   | C20-W21-1of8   | Terrain | 365.408 μs |  35.537 μs |  1.9479 μs | 249.5117 | 249.5117 | 249.5117 | 1049385 B |
| **DeferredEditSession**    | **C256-W257-1of8** | **Uniform** |   **8.792 μs** |   **5.723 μs** |  **0.3137 μs** |   **0.0153** |        **-** |        **-** |     **328 B** |
| DeferredCompleteCycle  | C256-W257-1of8 | Uniform |  83.694 μs |  13.548 μs |  0.7426 μs |   0.2441 |        - |        - |    5472 B |
| DeferredSerializeCycle | C256-W257-1of8 | Uniform |  84.382 μs |  22.222 μs |  1.2181 μs |   0.2441 |        - |        - |    5472 B |
| DeferredMakeHotCycle   | C256-W257-1of8 | Uniform | 162.741 μs | 103.516 μs |  5.6741 μs | 185.3027 | 185.3027 | 185.3027 | 1050194 B |
| **DeferredEditSession**    | **C256-W257-1of8** | **Terrain** |  **34.369 μs** |   **5.053 μs** |  **0.2770 μs** |        **-** |        **-** |        **-** |     **328 B** |
| DeferredCompleteCycle  | C256-W257-1of8 | Terrain | 161.835 μs |  61.231 μs |  3.3563 μs |   0.4883 |        - |        - |    9176 B |
| DeferredSerializeCycle | C256-W257-1of8 | Terrain | 159.338 μs |  40.535 μs |  2.2219 μs |   0.4883 |        - |        - |    9176 B |
| DeferredMakeHotCycle   | C256-W257-1of8 | Terrain | 370.090 μs |  59.358 μs |  3.2536 μs | 249.5117 | 249.5117 | 249.5117 | 1049385 B |
| **DeferredEditSession**    | **C256-W257-8of8** | **Uniform** |  **15.933 μs** |  **13.145 μs** |  **0.7205 μs** |   **0.0153** |        **-** |        **-** |     **328 B** |
| DeferredCompleteCycle  | C256-W257-8of8 | Uniform | 205.110 μs |  81.819 μs |  4.4848 μs |   0.4883 |        - |        - |    9928 B |
| DeferredSerializeCycle | C256-W257-8of8 | Uniform | 192.212 μs |  46.129 μs |  2.5285 μs |   0.4883 |        - |        - |    9928 B |
| DeferredMakeHotCycle   | C256-W257-8of8 | Uniform | 163.436 μs |  44.635 μs |  2.4466 μs | 191.8945 | 191.8945 | 191.8945 | 1050262 B |
| **DeferredEditSession**    | **C256-W257-8of8** | **Terrain** |  **41.355 μs** |  **15.730 μs** |  **0.8622 μs** |        **-** |        **-** |        **-** |     **328 B** |
| DeferredCompleteCycle  | C256-W257-8of8 | Terrain | 837.245 μs | 423.565 μs | 23.2170 μs |   1.9531 |        - |        - |   42952 B |
| DeferredSerializeCycle | C256-W257-8of8 | Terrain | 811.241 μs | 195.453 μs | 10.7134 μs |   1.9531 |        - |        - |   42952 B |
| DeferredMakeHotCycle   | C256-W257-8of8 | Terrain | 385.990 μs |  32.698 μs |  1.7923 μs | 249.5117 | 249.5117 | 249.5117 | 1049385 B |
