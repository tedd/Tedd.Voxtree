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
| Method         | Workers | WritePercent | Mean       | Error       | StdDev     | Ratio | RatioSD | Allocated | Alloc Ratio |
|--------------- |-------- |------------- |-----------:|------------:|-----------:|------:|--------:|----------:|------------:|
| **Slim**           | **1**       | **0**            |  **19.200 ns** |   **1.0672 ns** |  **0.1651 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| MonitorLock    | 1       | 0            |  11.945 ns |   1.0853 ns |  0.1679 ns |  0.62 |    0.01 |         - |          NA |
| ModernLock     | 1       | 0            |   8.136 ns |   0.2327 ns |  0.0360 ns |  0.42 |    0.00 |         - |          NA |
| SpinLock       | 1       | 0            |   7.499 ns |   0.0814 ns |  0.0211 ns |  0.39 |    0.00 |         - |          NA |
| SpinBeforeSlim | 1       | 0            |  17.356 ns |   2.2384 ns |  0.3464 ns |  0.90 |    0.02 |         - |          NA |
|                |         |              |            |             |            |       |         |           |             |
| **Slim**           | **1**       | **10**           |  **20.603 ns** |   **1.8907 ns** |  **0.2926 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| MonitorLock    | 1       | 10           |  11.776 ns |   0.1812 ns |  0.0280 ns |  0.57 |    0.01 |         - |          NA |
| ModernLock     | 1       | 10           |   8.225 ns |   0.0934 ns |  0.0242 ns |  0.40 |    0.01 |         - |          NA |
| SpinLock       | 1       | 10           |   7.662 ns |   0.0883 ns |  0.0229 ns |  0.37 |    0.00 |         - |          NA |
| SpinBeforeSlim | 1       | 10           |  17.033 ns |   0.1944 ns |  0.0301 ns |  0.83 |    0.01 |         - |          NA |
|                |         |              |            |             |            |       |         |           |             |
| **Slim**           | **4**       | **0**            |  **27.030 ns** |   **2.3741 ns** |  **0.6165 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| MonitorLock    | 4       | 0            |  60.033 ns |  26.0643 ns |  6.7688 ns |  2.22 |    0.23 |         - |          NA |
| ModernLock     | 4       | 0            |  66.473 ns |   7.0589 ns |  1.8332 ns |  2.46 |    0.08 |         - |          NA |
| SpinLock       | 4       | 0            | 272.864 ns | 200.4525 ns | 31.0202 ns | 10.10 |    1.04 |         - |          NA |
| SpinBeforeSlim | 4       | 0            |  22.756 ns |   5.8018 ns |  1.5067 ns |  0.84 |    0.05 |         - |          NA |
|                |         |              |            |             |            |       |         |           |             |
| **Slim**           | **4**       | **10**           |  **33.747 ns** |   **0.8142 ns** |  **0.2114 ns** |  **1.00** |    **0.00** |         **-** |          **NA** |
| MonitorLock    | 4       | 10           |  62.734 ns |  24.4765 ns |  6.3565 ns |  1.86 |    0.17 |         - |          NA |
| ModernLock     | 4       | 10           |  66.674 ns |   2.3491 ns |  0.6101 ns |  1.98 |    0.02 |         - |          NA |
| SpinLock       | 4       | 10           | 287.060 ns | 172.1381 ns | 44.7037 ns |  8.51 |    1.21 |         - |          NA |
| SpinBeforeSlim | 4       | 10           |  25.806 ns |   2.4059 ns |  0.3723 ns |  0.76 |    0.01 |         - |          NA |
