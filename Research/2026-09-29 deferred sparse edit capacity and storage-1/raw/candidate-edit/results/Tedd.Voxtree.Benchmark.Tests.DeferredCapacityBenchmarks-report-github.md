```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 71.64 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1
WarmupCount=3

```
| Method              | Case             | Pattern | Mean          | Error            | StdDev         | Gen0   | Allocated |
|-------------------- |----------------- |-------- |--------------:|-----------------:|---------------:|-------:|----------:|
| **DeferredEditSession** | **C1024-W1024-1of2** | **Uniform** |  **28,917.62 ns** |       **655.256 ns** |      **35.917 ns** |      **-** |     **368 B** |
| **DeferredEditSession** | **C1024-W1024-1of2** | **Terrain** |  **29,309.07 ns** |     **2,860.035 ns** |     **156.768 ns** |      **-** |     **368 B** |
| **DeferredEditSession** | **C1024-W512-1of8**  | **Uniform** |   **9,427.19 ns** |       **177.103 ns** |       **9.708 ns** | **0.0305** |     **568 B** |
| **DeferredEditSession** | **C1024-W512-1of8**  | **Terrain** |   **9,507.73 ns** |        **43.286 ns** |       **2.373 ns** | **0.0305** |     **568 B** |
| **DeferredEditSession** | **C20-W1-1of2**      | **Uniform** |      **77.57 ns** |        **15.531 ns** |       **0.851 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C20-W1-1of2**      | **Terrain** |      **84.19 ns** |        **15.997 ns** |       **0.877 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C20-W20-1of2**     | **Uniform** |     **289.75 ns** |        **41.808 ns** |       **2.292 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C20-W20-1of2**     | **Terrain** |     **260.81 ns** |         **1.441 ns** |       **0.079 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C20-W21-1of8**     | **Uniform** |   **2,324.35 ns** |        **52.791 ns** |       **2.894 ns** | **0.0153** |     **304 B** |
| **DeferredEditSession** | **C20-W21-1of8**     | **Terrain** |  **26,157.10 ns** |        **61.586 ns** |       **3.376 ns** |      **-** |     **304 B** |
| **DeferredEditSession** | **C2048-W2048-1of2** | **Uniform** |  **99,551.27 ns** |       **401.976 ns** |      **22.034 ns** |      **-** |     **408 B** |
| **DeferredEditSession** | **C2048-W2048-1of2** | **Terrain** |  **99,650.25 ns** |     **2,925.099 ns** |     **160.335 ns** |      **-** |     **408 B** |
| **DeferredEditSession** | **C256-W20-1of2**    | **Uniform** |     **279.46 ns** |        **46.427 ns** |       **2.545 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C256-W20-1of2**    | **Terrain** |     **281.68 ns** |        **47.284 ns** |       **2.592 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C256-W257-1of8**   | **Uniform** |   **8,558.21 ns** |     **1,747.618 ns** |      **95.793 ns** | **0.0305** |     **568 B** |
| **DeferredEditSession** | **C256-W257-1of8**   | **Terrain** |  **32,422.44 ns** |     **4,619.891 ns** |     **253.232 ns** |      **-** |     **568 B** |
| **DeferredEditSession** | **C256-W257-8of8**   | **Uniform** |  **14,987.00 ns** |     **2,117.988 ns** |     **116.094 ns** | **0.0305** |     **568 B** |
| **DeferredEditSession** | **C256-W257-8of8**   | **Terrain** |  **39,535.96 ns** |     **4,990.314 ns** |     **273.536 ns** |      **-** |     **568 B** |
| **DeferredEditSession** | **C256-W32-1of2**    | **Uniform** |     **412.83 ns** |         **5.341 ns** |       **0.293 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C256-W32-1of2**    | **Terrain** |     **406.36 ns** |         **4.703 ns** |       **0.258 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C256-W64-1of2**    | **Uniform** |     **852.80 ns** |     **1,153.884 ns** |      **63.248 ns** | **0.0124** |     **208 B** |
| **DeferredEditSession** | **C256-W64-1of2**    | **Terrain** |     **952.64 ns** |       **264.143 ns** |      **14.479 ns** | **0.0124** |     **208 B** |
| **DeferredEditSession** | **C32-W20-1of2**     | **Uniform** |     **325.70 ns** |       **472.847 ns** |      **25.918 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C32-W20-1of2**     | **Terrain** |     **411.68 ns** |       **763.467 ns** |      **41.848 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C32-W32-1of2**     | **Uniform** |     **453.94 ns** |       **313.097 ns** |      **17.162 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C32-W32-1of2**     | **Terrain** |     **462.29 ns** |       **142.312 ns** |       **7.801 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C4096-W4096-1of2** | **Uniform** | **488,605.92 ns** | **1,423,978.191 ns** |  **78,053.050 ns** |      **-** |     **448 B** |
| **DeferredEditSession** | **C4096-W4096-1of2** | **Terrain** | **555,961.87 ns** | **2,506,800.814 ns** | **137,406.212 ns** |      **-** |     **448 B** |
| **DeferredEditSession** | **C512-W512-1of8**   | **Uniform** |  **16,133.95 ns** |    **23,955.208 ns** |   **1,313.066 ns** | **0.0305** |     **568 B** |
| **DeferredEditSession** | **C512-W512-1of8**   | **Terrain** |  **15,960.88 ns** |    **11,249.393 ns** |     **616.617 ns** | **0.0305** |     **568 B** |
| **DeferredEditSession** | **C64-W20-1of2**     | **Uniform** |     **431.52 ns** |       **438.144 ns** |      **24.016 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C64-W20-1of2**     | **Terrain** |     **408.04 ns** |       **221.096 ns** |      **12.119 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C64-W64-1of2**     | **Uniform** |   **1,097.22 ns** |       **292.167 ns** |      **16.015 ns** | **0.0124** |     **208 B** |
| **DeferredEditSession** | **C64-W64-1of2**     | **Terrain** |   **1,150.33 ns** |       **106.698 ns** |       **5.848 ns** | **0.0124** |     **208 B** |
