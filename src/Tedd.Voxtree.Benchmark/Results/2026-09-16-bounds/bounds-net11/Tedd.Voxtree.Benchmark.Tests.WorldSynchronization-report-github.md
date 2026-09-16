```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.54 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method        | Categories | Mean      | Error     | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|-------------- |----------- |----------:|----------:|----------:|------:|--------:|----------:|------------:|
| ReadEach      | Read       | 35.255 ns | 0.2412 ns | 0.0626 ns |  1.00 |    0.00 |         - |          NA |
| ReadBatch     | Read       | 27.917 ns | 0.4093 ns | 0.1063 ns |  0.79 |    0.00 |         - |          NA |
| RetainedChunk | Read       |  2.342 ns | 0.0856 ns | 0.0132 ns |  0.07 |    0.00 |         - |          NA |
|               |            |           |           |           |       |         |           |             |
| WriteEach     | Write      | 32.767 ns | 1.7231 ns | 0.2666 ns |  1.00 |    0.00 |         - |          NA |
| WriteBatch    | Write      | 22.504 ns | 2.7893 ns | 0.7244 ns |  0.69 |    0.02 |         - |          NA |
