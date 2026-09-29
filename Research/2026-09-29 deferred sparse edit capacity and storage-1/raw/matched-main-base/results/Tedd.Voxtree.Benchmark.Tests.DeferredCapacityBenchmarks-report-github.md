```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 89.29 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]    : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  MediumRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=MediumRun  IterationCount=15  LaunchCount=2
WarmupCount=10

```
| Method              | Case          | Pattern | Mean     | Error   | StdDev  | Gen0   | Allocated |
|-------------------- |-------------- |-------- |---------:|--------:|--------:|-------:|----------:|
| **DeferredEditSession** | **C256-W20-1of2** | **Uniform** | **294.3 ns** | **6.50 ns** | **8.89 ns** | **0.0091** |     **152 B** |
| **DeferredEditSession** | **C256-W20-1of2** | **Terrain** | **299.9 ns** | **3.57 ns** | **5.13 ns** | **0.0091** |     **152 B** |
