```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 90.44 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1
WarmupCount=3

```
| Method              | Case          | Pattern | Mean     | Error     | StdDev   | Gen0   | Allocated |
|-------------------- |-------------- |-------- |---------:|----------:|---------:|-------:|----------:|
| **DeferredEditSession** | **C20-W20-1of2**  | **Uniform** | **308.2 ns** |  **34.64 ns** |  **1.90 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C20-W20-1of2**  | **Terrain** | **375.7 ns** |  **72.63 ns** |  **3.98 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C256-W20-1of2** | **Uniform** | **330.6 ns** | **220.80 ns** | **12.10 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C256-W20-1of2** | **Terrain** | **324.4 ns** | **197.03 ns** | **10.80 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C32-W20-1of2**  | **Uniform** | **363.9 ns** | **267.04 ns** | **14.64 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C32-W20-1of2**  | **Terrain** | **353.6 ns** |  **39.18 ns** |  **2.15 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C64-W20-1of2**  | **Uniform** | **357.6 ns** |  **51.21 ns** |  **2.81 ns** | **0.0100** |     **168 B** |
| **DeferredEditSession** | **C64-W20-1of2**  | **Terrain** | **366.2 ns** |  **11.36 ns** |  **0.62 ns** | **0.0100** |     **168 B** |
