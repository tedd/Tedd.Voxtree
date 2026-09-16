```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.35 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method           | Pattern   | Queries    | Mean     | Error     | StdDev    | Allocated |
|----------------- |---------- |----------- |---------:|----------:|----------:|----------:|
| **CompiledSnapshot** | **Sparse**    | **Sequential** | **8.165 ns** | **0.7878 ns** | **0.2046 ns** |         **-** |
| **CompiledSnapshot** | **Sparse**    | **Random**     | **7.924 ns** | **1.8567 ns** | **0.4822 ns** |         **-** |
| **CompiledSnapshot** | **Clustered** | **Sequential** | **3.272 ns** | **0.5064 ns** | **0.0784 ns** |         **-** |
| **CompiledSnapshot** | **Clustered** | **Random**     | **3.653 ns** | **0.3755 ns** | **0.0581 ns** |         **-** |
