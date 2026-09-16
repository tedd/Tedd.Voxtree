```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.05 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method            | Levels | Strided | Mean         | Error        | StdDev     | Allocated |
|------------------ |------- |-------- |-------------:|-------------:|-----------:|----------:|
| **AnyMissing**        | **3**      | **False**   |     **74.85 ns** |    **13.908 ns** |   **3.612 ns** |         **-** |
| GenericAnyMissing | 3      | False   |     84.83 ns |    35.315 ns |   9.171 ns |         - |
| AnyFirst          | 3      | False   |     32.70 ns |     1.878 ns |   0.488 ns |         - |
| GenericAnyFirst   | 3      | False   |     35.10 ns |     1.536 ns |   0.399 ns |         - |
| **AnyMissing**        | **3**      | **True**    |    **411.57 ns** |     **7.210 ns** |   **1.116 ns** |         **-** |
| GenericAnyMissing | 3      | True    |    419.28 ns |    23.669 ns |   6.147 ns |         - |
| AnyFirst          | 3      | True    |     32.51 ns |     5.248 ns |   1.363 ns |         - |
| GenericAnyFirst   | 3      | True    |     33.05 ns |    10.153 ns |   2.637 ns |         - |
| **AnyMissing**        | **5**      | **False**   |  **2,831.22 ns** |   **175.632 ns** |  **27.179 ns** |         **-** |
| GenericAnyMissing | 5      | False   |  2,882.54 ns |   210.434 ns |  54.649 ns |         - |
| AnyFirst          | 5      | False   |     31.61 ns |     2.720 ns |   0.706 ns |         - |
| GenericAnyFirst   | 5      | False   |     34.31 ns |     5.091 ns |   0.788 ns |         - |
| **AnyMissing**        | **5**      | **True**    | **10,192.97 ns** | **1,709.573 ns** | **443.971 ns** |         **-** |
| GenericAnyMissing | 5      | True    | 10,448.39 ns | 2,568.030 ns | 666.909 ns |         - |
| AnyFirst          | 5      | True    |     32.29 ns |     4.313 ns |   1.120 ns |         - |
| GenericAnyFirst   | 5      | True    |     39.47 ns |    15.116 ns |   3.926 ns |         - |
