```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 89.92 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1
WarmupCount=3

```
| Method              | Case          | Pattern | Mean     | Error     | StdDev   | Gen0   | Allocated |
|-------------------- |-------------- |-------- |---------:|----------:|---------:|-------:|----------:|
| **DeferredEditSession** | **C20-W20-1of2**  | **Uniform** | **334.6 ns** |  **24.67 ns** |  **1.35 ns** | **0.0095** |     **160 B** |
| **DeferredEditSession** | **C20-W20-1of2**  | **Terrain** | **293.9 ns** |  **65.52 ns** |  **3.59 ns** | **0.0095** |     **160 B** |
| **DeferredEditSession** | **C256-W20-1of2** | **Uniform** | **284.4 ns** | **236.66 ns** | **12.97 ns** | **0.0095** |     **160 B** |
| **DeferredEditSession** | **C256-W20-1of2** | **Terrain** | **297.7 ns** |  **51.30 ns** |  **2.81 ns** | **0.0095** |     **160 B** |
| **DeferredEditSession** | **C32-W20-1of2**  | **Uniform** | **288.2 ns** |  **44.40 ns** |  **2.43 ns** | **0.0095** |     **160 B** |
| **DeferredEditSession** | **C32-W20-1of2**  | **Terrain** | **351.3 ns** |  **57.65 ns** |  **3.16 ns** | **0.0095** |     **160 B** |
| **DeferredEditSession** | **C64-W20-1of2**  | **Uniform** | **297.8 ns** |  **21.93 ns** |  **1.20 ns** | **0.0095** |     **160 B** |
| **DeferredEditSession** | **C64-W20-1of2**  | **Terrain** | **334.9 ns** |   **6.35 ns** |  **0.35 ns** | **0.0095** |     **160 B** |
