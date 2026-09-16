```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.2 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method        | Categories | Mean      | Error     | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|-------------- |----------- |----------:|----------:|----------:|------:|--------:|----------:|------------:|
| ReadEach      | Read       | 38.248 ns | 5.1775 ns | 1.3446 ns |  1.00 |    0.00 |         - |          NA |
| ReadBatch     | Read       | 30.770 ns | 7.5457 ns | 1.9596 ns |  0.81 |    0.05 |         - |          NA |
| RetainedChunk | Read       |  2.851 ns | 0.3527 ns | 0.0916 ns |  0.07 |    0.00 |         - |          NA |
|               |            |           |           |           |       |         |           |             |
| WriteEach     | Write      | 39.693 ns | 1.9848 ns | 0.5155 ns |  1.00 |    0.00 |         - |          NA |
| WriteBatch    | Write      | 30.013 ns | 4.5962 ns | 1.1936 ns |  0.76 |    0.03 |         - |          NA |
