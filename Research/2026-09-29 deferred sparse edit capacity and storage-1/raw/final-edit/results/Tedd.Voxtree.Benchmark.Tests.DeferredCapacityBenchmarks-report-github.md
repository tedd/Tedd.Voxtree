```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 89.74 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1
WarmupCount=3

```
| Method              | Case             | Pattern | Mean         | Error         | StdDev       | Gen0   | Allocated |
|-------------------- |----------------- |-------- |-------------:|--------------:|-------------:|-------:|----------:|
| **DeferredEditSession** | **C1024-W1024-1of2** | **Uniform** | **10,832.21 ns** |    **433.082 ns** |    **23.739 ns** |      **-** |     **176 B** |
| **DeferredEditSession** | **C1024-W1024-1of2** | **Terrain** | **10,604.35 ns** |    **348.080 ns** |    **19.079 ns** |      **-** |     **176 B** |
| **DeferredEditSession** | **C1024-W512-1of8**  | **Uniform** |  **6,127.38 ns** |  **1,358.820 ns** |    **74.482 ns** | **0.0076** |     **224 B** |
| **DeferredEditSession** | **C1024-W512-1of8**  | **Terrain** |  **6,041.69 ns** |    **126.404 ns** |     **6.929 ns** | **0.0076** |     **224 B** |
| **DeferredEditSession** | **C20-W1-1of2**      | **Uniform** |     **80.64 ns** |     **10.922 ns** |     **0.599 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C20-W1-1of2**      | **Terrain** |     **80.69 ns** |      **9.484 ns** |     **0.520 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C20-W20-1of2**     | **Uniform** |    **316.85 ns** |      **1.652 ns** |     **0.091 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C20-W20-1of2**     | **Terrain** |    **302.53 ns** |    **250.746 ns** |    **13.744 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C20-W21-1of8**     | **Uniform** |  **2,309.03 ns** |    **133.672 ns** |     **7.327 ns** | **0.0153** |     **312 B** |
| **DeferredEditSession** | **C20-W21-1of8**     | **Terrain** | **31,608.06 ns** | **35,498.402 ns** | **1,945.787 ns** |      **-** |     **312 B** |
| **DeferredEditSession** | **C2048-W2048-1of2** | **Uniform** | **23,631.27 ns** | **10,885.272 ns** |   **596.659 ns** |      **-** |     **176 B** |
| **DeferredEditSession** | **C2048-W2048-1of2** | **Terrain** | **22,984.77 ns** |  **9,987.067 ns** |   **547.425 ns** |      **-** |     **176 B** |
| **DeferredEditSession** | **C256-W20-1of2**    | **Uniform** |    **327.97 ns** |    **195.941 ns** |    **10.740 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C256-W20-1of2**    | **Terrain** |    **347.20 ns** |     **85.685 ns** |     **4.697 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C256-W257-1of8**   | **Uniform** |  **8,928.49 ns** |  **5,950.022 ns** |   **326.141 ns** | **0.0153** |     **312 B** |
| **DeferredEditSession** | **C256-W257-1of8**   | **Terrain** | **38,364.79 ns** | **77,762.311 ns** | **4,262.415 ns** |      **-** |     **312 B** |
| **DeferredEditSession** | **C256-W257-8of8**   | **Uniform** | **15,827.87 ns** | **15,426.788 ns** |   **845.594 ns** | **0.0153** |     **312 B** |
| **DeferredEditSession** | **C256-W257-8of8**   | **Terrain** | **46,207.65 ns** | **75,637.092 ns** | **4,145.924 ns** |      **-** |     **312 B** |
| **DeferredEditSession** | **C256-W32-1of2**    | **Uniform** |    **472.28 ns** |    **357.824 ns** |    **19.614 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C256-W32-1of2**    | **Terrain** |    **459.23 ns** |     **75.148 ns** |     **4.119 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C256-W64-1of2**    | **Uniform** |    **837.64 ns** |    **316.823 ns** |    **17.366 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C256-W64-1of2**    | **Terrain** |    **876.65 ns** |     **80.765 ns** |     **4.427 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C32-W20-1of2**     | **Uniform** |    **362.00 ns** |    **591.200 ns** |    **32.406 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C32-W20-1of2**     | **Terrain** |    **335.93 ns** |    **549.470 ns** |    **30.118 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C32-W32-1of2**     | **Uniform** |    **464.12 ns** |    **210.524 ns** |    **11.540 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C32-W32-1of2**     | **Terrain** |    **473.81 ns** |     **72.303 ns** |     **3.963 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C4096-W4096-1of2** | **Uniform** | **45,023.73 ns** |  **7,808.999 ns** |   **428.038 ns** |      **-** |     **176 B** |
| **DeferredEditSession** | **C4096-W4096-1of2** | **Terrain** | **44,222.06 ns** |  **7,611.519 ns** |   **417.213 ns** |      **-** |     **176 B** |
| **DeferredEditSession** | **C512-W512-1of8**   | **Uniform** |  **6,889.34 ns** |    **337.050 ns** |    **18.475 ns** | **0.0076** |     **224 B** |
| **DeferredEditSession** | **C512-W512-1of8**   | **Terrain** |  **6,794.44 ns** |  **2,391.316 ns** |   **131.076 ns** | **0.0076** |     **224 B** |
| **DeferredEditSession** | **C64-W20-1of2**     | **Uniform** |    **348.18 ns** |    **358.264 ns** |    **19.638 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C64-W20-1of2**     | **Terrain** |    **324.77 ns** |     **88.916 ns** |     **4.874 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C64-W64-1of2**     | **Uniform** |    **835.81 ns** |    **373.700 ns** |    **20.484 ns** | **0.0105** |     **176 B** |
| **DeferredEditSession** | **C64-W64-1of2**     | **Terrain** |    **900.36 ns** |    **133.954 ns** |     **7.342 ns** | **0.0105** |     **176 B** |
