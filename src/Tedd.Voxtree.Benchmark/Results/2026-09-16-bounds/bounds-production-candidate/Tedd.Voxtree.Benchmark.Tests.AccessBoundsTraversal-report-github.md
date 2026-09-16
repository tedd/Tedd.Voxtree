```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 66.81 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-GDKDLG : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=10  IterationTime=300ms  LaunchCount=2
WarmupCount=5

```
| Method     | Pattern   | Queries    | Mean     | Error     | StdDev    | Code Size | Allocated |
|----------- |---------- |----------- |---------:|----------:|----------:|----------:|----------:|
| **Production** | **Sparse**    | **Sequential** | **8.570 ns** | **0.2931 ns** | **0.3258 ns** |     **552 B** |         **-** |
| **Production** | **Sparse**    | **Random**     | **8.457 ns** | **0.2630 ns** | **0.3029 ns** |     **552 B** |         **-** |
| **Production** | **Clustered** | **Sequential** | **3.278 ns** | **0.0971 ns** | **0.1039 ns** |     **533 B** |         **-** |
| **Production** | **Clustered** | **Random**     | **3.720 ns** | **0.1178 ns** | **0.1260 ns** |     **530 B** |         **-** |
