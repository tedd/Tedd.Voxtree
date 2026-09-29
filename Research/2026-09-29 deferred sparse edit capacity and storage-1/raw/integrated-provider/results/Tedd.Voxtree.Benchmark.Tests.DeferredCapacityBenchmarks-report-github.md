```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 80.09 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]    : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  MediumRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=MediumRun  IterationCount=15  LaunchCount=2
WarmupCount=10

```
| Method                    | Case          | Pattern | Mean     | Error    | StdDev   | Gen0   | Allocated |
|-------------------------- |-------------- |-------- |---------:|---------:|---------:|-------:|----------:|
| **DeferredEditSession**       | **C256-W20-1of2** | **Uniform** | **305.1 ns** |  **4.79 ns** |  **7.02 ns** | **0.0134** |     **224 B** |
| CallerProvidedEditSession | C256-W20-1of2 | Uniform | 277.9 ns |  6.50 ns |  9.33 ns | 0.0134 |     224 B |
| **DeferredEditSession**       | **C256-W20-1of2** | **Terrain** | **342.4 ns** | **24.82 ns** | **37.15 ns** | **0.0134** |     **224 B** |
| CallerProvidedEditSession | C256-W20-1of2 | Terrain | 347.8 ns |  5.25 ns |  7.85 ns | 0.0134 |     224 B |
