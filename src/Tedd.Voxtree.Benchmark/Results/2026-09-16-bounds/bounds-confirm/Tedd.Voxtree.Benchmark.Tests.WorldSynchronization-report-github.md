```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.08 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-GDKDLG : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=10  IterationTime=300ms  LaunchCount=2
WarmupCount=5

```
| Method        | Categories | Mean      | Error     | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|-------------- |----------- |----------:|----------:|----------:|------:|--------:|----------:|------------:|
| ReadEach      | Read       | 41.235 ns | 1.0960 ns | 1.1727 ns |  1.00 |    0.00 |         - |          NA |
| ReadBatch     | Read       | 31.143 ns | 0.6404 ns | 0.6577 ns |  0.76 |    0.03 |         - |          NA |
| RetainedChunk | Read       |  3.068 ns | 0.1826 ns | 0.2030 ns |  0.07 |    0.01 |         - |          NA |
|               |            |           |           |           |       |         |           |             |
| WriteEach     | Write      | 42.633 ns | 0.9675 ns | 0.9936 ns |  1.00 |    0.00 |         - |          NA |
| WriteBatch    | Write      | 31.548 ns | 1.0309 ns | 1.1031 ns |  0.74 |    0.03 |         - |          NA |
