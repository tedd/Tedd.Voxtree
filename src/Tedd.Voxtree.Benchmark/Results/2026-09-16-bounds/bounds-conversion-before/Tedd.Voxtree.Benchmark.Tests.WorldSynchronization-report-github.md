```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 65.56 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method        | Categories | Mean      | Error      | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|-------------- |----------- |----------:|-----------:|----------:|------:|--------:|----------:|------------:|
| ReadEach      | Read       | 42.612 ns | 23.9560 ns | 6.2213 ns |  1.00 |    0.00 |         - |          NA |
| ReadBatch     | Read       | 32.644 ns | 13.9197 ns | 3.6149 ns |  0.78 |    0.13 |         - |          NA |
| RetainedChunk | Read       |  3.000 ns |  0.4535 ns | 0.0702 ns |  0.07 |    0.01 |         - |          NA |
|               |            |           |            |           |       |         |           |             |
| WriteEach     | Write      | 43.014 ns | 12.1927 ns | 3.1664 ns |  1.00 |    0.00 |         - |          NA |
| WriteBatch    | Write      | 31.742 ns |  7.4254 ns | 1.9284 ns |  0.74 |    0.07 |         - |          NA |
