```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 82.64 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1
WarmupCount=3

```
| Method                 | Case           | Pattern | Mean       | Error       | StdDev   | Gen0     | Gen1     | Gen2     | Allocated |
|----------------------- |--------------- |-------- |-----------:|------------:|---------:|---------:|---------:|---------:|----------:|
| **DeferredEditSession**    | **C20-W21-1of8**   | **Uniform** |   **132.3 μs** |     **4.30 μs** |  **0.24 μs** | **170.1660** | **170.1660** | **170.1660** |      **1 MB** |
| DeferredCompleteCycle  | C20-W21-1of8   | Uniform |   175.9 μs |    46.07 μs |  2.53 μs | 211.4258 | 211.1816 | 211.1816 |      1 MB |
| DeferredSerializeCycle | C20-W21-1of8   | Uniform |   175.4 μs |    43.38 μs |  2.38 μs | 212.8906 | 212.6465 | 212.6465 |      1 MB |
| DeferredMakeHotCycle   | C20-W21-1of8   | Uniform |   136.5 μs |    52.39 μs |  2.87 μs | 177.0020 | 177.0020 | 177.0020 |      1 MB |
| **DeferredEditSession**    | **C20-W21-1of8**   | **Terrain** |   **363.4 μs** |    **87.96 μs** |  **4.82 μs** | **249.5117** | **249.5117** | **249.5117** |      **1 MB** |
| DeferredCompleteCycle  | C20-W21-1of8   | Terrain |   874.1 μs |   169.91 μs |  9.31 μs | 250.9766 | 249.0234 | 249.0234 |   1.03 MB |
| DeferredSerializeCycle | C20-W21-1of8   | Terrain |   855.7 μs |   255.82 μs | 14.02 μs | 250.9766 | 249.0234 | 249.0234 |   1.03 MB |
| DeferredMakeHotCycle   | C20-W21-1of8   | Terrain |   362.4 μs |   140.25 μs |  7.69 μs | 249.5117 | 249.5117 | 249.5117 |      1 MB |
| **DeferredEditSession**    | **C256-W257-1of8** | **Uniform** |   **146.7 μs** |    **27.55 μs** |  **1.51 μs** | **178.9551** | **178.9551** | **178.9551** |      **1 MB** |
| DeferredCompleteCycle  | C256-W257-1of8 | Uniform |   269.3 μs |   240.70 μs | 13.19 μs | 250.0000 | 249.5117 | 249.5117 |   1.01 MB |
| DeferredSerializeCycle | C256-W257-1of8 | Uniform |   264.2 μs |   108.32 μs |  5.94 μs | 250.0000 | 249.5117 | 249.5117 |   1.01 MB |
| DeferredMakeHotCycle   | C256-W257-1of8 | Uniform |   145.2 μs |    56.55 μs |  3.10 μs | 180.6641 | 180.6641 | 180.6641 |      1 MB |
| **DeferredEditSession**    | **C256-W257-1of8** | **Terrain** |   **364.5 μs** |   **102.13 μs** |  **5.60 μs** | **249.5117** | **249.5117** | **249.5117** |      **1 MB** |
| DeferredCompleteCycle  | C256-W257-1of8 | Terrain |   909.7 μs |   286.77 μs | 15.72 μs | 250.9766 | 249.0234 | 249.0234 |   1.04 MB |
| DeferredSerializeCycle | C256-W257-1of8 | Terrain | 1,051.6 μs | 1,534.52 μs | 84.11 μs | 250.9766 | 249.0234 | 249.0234 |   1.04 MB |
| DeferredMakeHotCycle   | C256-W257-1of8 | Terrain |   367.8 μs |    87.97 μs |  4.82 μs | 249.5117 | 249.5117 | 249.5117 |      1 MB |
| **DeferredEditSession**    | **C256-W257-8of8** | **Uniform** |   **144.2 μs** |    **30.24 μs** |  **1.66 μs** | **178.7109** | **178.7109** | **178.7109** |      **1 MB** |
| DeferredCompleteCycle  | C256-W257-8of8 | Uniform |   335.9 μs |    24.37 μs |  1.34 μs | 250.0000 | 249.5117 | 249.5117 |   1.01 MB |
| DeferredSerializeCycle | C256-W257-8of8 | Uniform |   327.7 μs |    51.11 μs |  2.80 μs | 250.0000 | 249.5117 | 249.5117 |   1.01 MB |
| DeferredMakeHotCycle   | C256-W257-8of8 | Uniform |   146.2 μs |    87.37 μs |  4.79 μs | 179.9316 | 179.9316 | 179.9316 |      1 MB |
| **DeferredEditSession**    | **C256-W257-8of8** | **Terrain** |   **382.8 μs** |   **192.41 μs** | **10.55 μs** | **249.5117** | **249.5117** | **249.5117** |      **1 MB** |
| DeferredCompleteCycle  | C256-W257-8of8 | Terrain | 1,034.5 μs |   762.94 μs | 41.82 μs | 250.9766 | 249.0234 | 249.0234 |   1.04 MB |
| DeferredSerializeCycle | C256-W257-8of8 | Terrain | 1,212.6 μs |   132.80 μs |  7.28 μs | 250.9766 | 249.0234 | 249.0234 |   1.04 MB |
| DeferredMakeHotCycle   | C256-W257-8of8 | Terrain |   427.5 μs |    38.20 μs |  2.09 μs | 249.5117 | 249.5117 | 249.5117 |      1 MB |
