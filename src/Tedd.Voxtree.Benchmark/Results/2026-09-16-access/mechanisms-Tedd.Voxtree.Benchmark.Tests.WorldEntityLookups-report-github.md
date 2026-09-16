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
| Method               | Categories | Mean      | Error     | StdDev    | Ratio | RatioSD | Allocated | Alloc Ratio |
|--------------------- |----------- |----------:|----------:|----------:|------:|--------:|----------:|------------:|
| DictionaryMiss       | Miss       |  7.155 ns | 1.5447 ns | 0.2390 ns |  1.00 |    0.00 |         - |          NA |
| RecentCacheMiss      | Miss       | 10.053 ns | 1.7453 ns | 0.4533 ns |  1.41 |    0.07 |         - |          NA |
|                      |            |           |           |           |       |         |           |             |
| DictionarySameChunk  | SameChunk  |  8.157 ns | 0.8542 ns | 0.2218 ns |  1.00 |    0.00 |         - |          NA |
| RecentCacheSameChunk | SameChunk  |  7.505 ns | 1.0909 ns | 0.2833 ns |  0.92 |    0.04 |         - |          NA |
|                      |            |           |           |           |       |         |           |             |
| DictionaryTenChunks  | TenChunks  |  8.183 ns | 0.5248 ns | 0.1363 ns |  1.00 |    0.00 |         - |          NA |
| RecentCacheTenChunks | TenChunks  |  8.320 ns | 0.1412 ns | 0.0218 ns |  1.02 |    0.02 |         - |          NA |
