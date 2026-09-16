```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.14 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method               | Levels | Strided | Mean         | Error        | StdDev     | Allocated |
|--------------------- |------- |-------- |-------------:|-------------:|-----------:|----------:|
| **MaskedCount**          | **3**      | **False**   |     **69.74 ns** |     **2.865 ns** |   **0.443 ns** |         **-** |
| GenericMaskedCount   | 3      | False   |     73.28 ns |    13.032 ns |   3.384 ns |         - |
| EqualityCount        | 3      | False   |     58.06 ns |     5.048 ns |   1.311 ns |         - |
| GenericEqualityCount | 3      | False   |     62.88 ns |     5.988 ns |   1.555 ns |         - |
| AnyMissing           | 3      | False   |     86.12 ns |    31.924 ns |   8.290 ns |         - |
| GenericAnyMissing    | 3      | False   |     77.87 ns |     8.870 ns |   1.373 ns |         - |
| AnyFirst             | 3      | False   |     38.32 ns |     1.380 ns |   0.214 ns |         - |
| GenericAnyFirst      | 3      | False   |     32.85 ns |     2.044 ns |   0.531 ns |         - |
| **MaskedCount**          | **3**      | **True**    |  **1,219.72 ns** |    **36.051 ns** |   **9.362 ns** |         **-** |
| GenericMaskedCount   | 3      | True    |  1,074.57 ns |    86.996 ns |  22.592 ns |         - |
| EqualityCount        | 3      | True    |  1,033.15 ns |    15.234 ns |   3.956 ns |         - |
| GenericEqualityCount | 3      | True    |    299.05 ns |    17.553 ns |   4.558 ns |         - |
| AnyMissing           | 3      | True    |  1,056.17 ns |    22.376 ns |   3.463 ns |         - |
| GenericAnyMissing    | 3      | True    |    481.41 ns |    57.434 ns |  14.916 ns |         - |
| AnyFirst             | 3      | True    |     43.04 ns |     6.876 ns |   1.786 ns |         - |
| GenericAnyFirst      | 3      | True    |     36.25 ns |    14.600 ns |   3.791 ns |         - |
| **MaskedCount**          | **5**      | **False**   |  **3,817.73 ns** | **1,830.534 ns** | **475.384 ns** |         **-** |
| GenericMaskedCount   | 5      | False   |  2,722.55 ns |   237.266 ns |  61.617 ns |         - |
| EqualityCount        | 5      | False   |  2,375.86 ns |   316.564 ns |  48.989 ns |         - |
| GenericEqualityCount | 5      | False   |  2,237.44 ns |   293.459 ns |  76.210 ns |         - |
| AnyMissing           | 5      | False   |  2,851.44 ns |   399.755 ns |  61.863 ns |         - |
| GenericAnyMissing    | 5      | False   |  3,015.99 ns |   464.395 ns | 120.602 ns |         - |
| AnyFirst             | 5      | False   |     33.34 ns |     3.386 ns |   0.879 ns |         - |
| GenericAnyFirst      | 5      | False   |     32.97 ns |     1.758 ns |   0.457 ns |         - |
| **MaskedCount**          | **5**      | **True**    | **22,669.01 ns** | **1,146.632 ns** | **297.777 ns** |         **-** |
| GenericMaskedCount   | 5      | True    | 20,131.35 ns | 2,216.172 ns | 575.533 ns |         - |
| EqualityCount        | 5      | True    | 17,457.56 ns |   383.820 ns |  59.397 ns |         - |
| GenericEqualityCount | 5      | True    |  5,555.54 ns |   999.018 ns | 259.442 ns |         - |
| AnyMissing           | 5      | True    | 19,448.93 ns | 2,084.987 ns | 541.465 ns |         - |
| GenericAnyMissing    | 5      | True    | 11,154.86 ns |   841.292 ns | 130.191 ns |         - |
| AnyFirst             | 5      | True    |     40.20 ns |     5.226 ns |   0.809 ns |         - |
| GenericAnyFirst      | 5      | True    |     37.31 ns |     2.300 ns |   0.597 ns |         - |
