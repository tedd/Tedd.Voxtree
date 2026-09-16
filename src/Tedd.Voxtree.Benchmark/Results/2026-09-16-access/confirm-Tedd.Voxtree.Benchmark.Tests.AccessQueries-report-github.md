```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.29 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method               | Levels | Strided | Mean         | Error        | StdDev     | Allocated |
|--------------------- |------- |-------- |-------------:|-------------:|-----------:|----------:|
| **MaskedCount**          | **3**      | **False**   |     **75.84 ns** |    **11.129 ns** |   **2.890 ns** |         **-** |
| GenericMaskedCount   | 3      | False   |     66.06 ns |    11.544 ns |   2.998 ns |         - |
| EqualityCount        | 3      | False   |     67.05 ns |     3.461 ns |   0.536 ns |         - |
| GenericEqualityCount | 3      | False   |     57.41 ns |    11.491 ns |   1.778 ns |         - |
| AnyMissing           | 3      | False   |     74.20 ns |    17.073 ns |   2.642 ns |         - |
| GenericAnyMissing    | 3      | False   |     81.55 ns |    18.087 ns |   2.799 ns |         - |
| AnyFirst             | 3      | False   |     45.61 ns |     1.682 ns |   0.437 ns |         - |
| GenericAnyFirst      | 3      | False   |     42.88 ns |     2.821 ns |   0.437 ns |         - |
| **MaskedCount**          | **3**      | **True**    |    **595.67 ns** |    **20.626 ns** |   **3.192 ns** |         **-** |
| GenericMaskedCount   | 3      | True    |    384.23 ns |    33.329 ns |   5.158 ns |         - |
| EqualityCount        | 3      | True    |    217.25 ns |    33.238 ns |   5.144 ns |         - |
| GenericEqualityCount | 3      | True    |    249.21 ns |    33.515 ns |   8.704 ns |         - |
| AnyMissing           | 3      | True    |    418.40 ns |    39.303 ns |  10.207 ns |         - |
| GenericAnyMissing    | 3      | True    |    429.99 ns |    16.116 ns |   2.494 ns |         - |
| AnyFirst             | 3      | True    |     44.24 ns |     5.531 ns |   1.436 ns |         - |
| GenericAnyFirst      | 3      | True    |     40.55 ns |     6.786 ns |   1.762 ns |         - |
| **MaskedCount**          | **5**      | **False**   |  **3,079.29 ns** |   **264.685 ns** |  **68.738 ns** |         **-** |
| GenericMaskedCount   | 5      | False   |  2,638.70 ns |   386.849 ns | 100.464 ns |         - |
| EqualityCount        | 5      | False   |  2,838.91 ns |   199.153 ns |  30.819 ns |         - |
| GenericEqualityCount | 5      | False   |  2,241.05 ns |   135.662 ns |  20.994 ns |         - |
| AnyMissing           | 5      | False   |  3,513.92 ns |   214.150 ns |  55.614 ns |         - |
| GenericAnyMissing    | 5      | False   |  3,480.75 ns | 2,424.946 ns | 629.751 ns |         - |
| AnyFirst             | 5      | False   |     45.36 ns |     3.156 ns |   0.820 ns |         - |
| GenericAnyFirst      | 5      | False   |     42.87 ns |     4.872 ns |   1.265 ns |         - |
| **MaskedCount**          | **5**      | **True**    | **10,226.02 ns** | **3,224.311 ns** | **837.343 ns** |         **-** |
| GenericMaskedCount   | 5      | True    |  9,065.46 ns |   289.253 ns |  75.118 ns |         - |
| EqualityCount        | 5      | True    |  4,254.27 ns | 1,618.911 ns | 420.426 ns |         - |
| GenericEqualityCount | 5      | True    |  4,478.97 ns | 2,793.807 ns | 432.345 ns |         - |
| AnyMissing           | 5      | True    |  9,696.03 ns | 1,607.973 ns | 417.586 ns |         - |
| GenericAnyMissing    | 5      | True    |  9,586.88 ns |    38.457 ns |   5.951 ns |         - |
| AnyFirst             | 5      | True    |     45.04 ns |     6.529 ns |   1.695 ns |         - |
| GenericAnyFirst      | 5      | True    |     40.87 ns |     4.487 ns |   1.165 ns |         - |
