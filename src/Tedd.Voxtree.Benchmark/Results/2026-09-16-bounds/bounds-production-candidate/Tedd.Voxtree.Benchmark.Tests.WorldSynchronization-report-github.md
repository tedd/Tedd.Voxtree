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
| Method        | Categories | Mean      | Error     | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|-------------- |----------- |----------:|----------:|----------:|------:|--------:|----------:|------------:|
| ReadEach      | Read       | 39.399 ns | 0.7583 ns | 0.8114 ns |  1.00 |    0.00 |         - |          NA |
| ReadBatch     | Read       | 31.693 ns | 0.8179 ns | 0.9091 ns |  0.80 |    0.03 |         - |          NA |
| RetainedChunk | Read       |  3.184 ns | 0.1164 ns | 0.1294 ns |  0.08 |    0.00 |         - |          NA |
|               |            |           |           |           |       |         |           |             |
| WriteEach     | Write      | 38.800 ns | 1.5843 ns | 1.6952 ns |  1.00 |    0.00 |         - |          NA |
| WriteBatch    | Write      | 24.428 ns | 0.8648 ns | 0.9253 ns |  0.63 |    0.04 |         - |          NA |
