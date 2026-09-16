```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.56 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method               | Levels | Strided | Mean          | Error         | StdDev       | Allocated |
|--------------------- |------- |-------- |--------------:|--------------:|-------------:|----------:|
| **MaskedCount**          | **3**      | **False**   |   **1,027.22 ns** |    **162.267 ns** |    **42.140 ns** |         **-** |
| GenericMaskedCount   | 3      | False   |   2,117.66 ns |    130.742 ns |    33.953 ns |         - |
| EqualityCount        | 3      | False   |     304.69 ns |     37.245 ns |     5.764 ns |         - |
| GenericEqualityCount | 3      | False   |     889.26 ns |    144.973 ns |    22.435 ns |         - |
| AnyMissing           | 3      | False   |   1,094.86 ns |    130.535 ns |    20.200 ns |         - |
| GenericAnyMissing    | 3      | False   |     873.42 ns |     55.218 ns |    14.340 ns |         - |
| AnyFirst             | 3      | False   |      36.88 ns |      5.007 ns |     1.300 ns |         - |
| GenericAnyFirst      | 3      | False   |      49.24 ns |      1.134 ns |     0.294 ns |         - |
| **MaskedCount**          | **3**      | **True**    |     **962.74 ns** |     **85.782 ns** |    **22.277 ns** |         **-** |
| GenericMaskedCount   | 3      | True    |   1,879.24 ns |    170.420 ns |    44.258 ns |         - |
| EqualityCount        | 3      | True    |     318.23 ns |     58.038 ns |     8.981 ns |         - |
| GenericEqualityCount | 3      | True    |     778.46 ns |     30.893 ns |     4.781 ns |         - |
| AnyMissing           | 3      | True    |     820.73 ns |     77.532 ns |    20.135 ns |         - |
| GenericAnyMissing    | 3      | True    |     811.72 ns |    190.463 ns |    49.463 ns |         - |
| AnyFirst             | 3      | True    |      37.24 ns |      3.490 ns |     0.906 ns |         - |
| GenericAnyFirst      | 3      | True    |      49.74 ns |      5.216 ns |     1.354 ns |         - |
| **MaskedCount**          | **5**      | **False**   |  **83,743.41 ns** |  **3,176.724 ns** |   **491.602 ns** |         **-** |
| GenericMaskedCount   | 5      | False   | 129,228.23 ns | 32,367.653 ns | 8,405.777 ns |         - |
| EqualityCount        | 5      | False   |   5,707.52 ns |    489.820 ns |   127.205 ns |         - |
| GenericEqualityCount | 5      | False   |  46,725.04 ns |  7,082.638 ns | 1,839.339 ns |         - |
| AnyMissing           | 5      | False   |  74,503.18 ns | 23,352.500 ns | 3,613.825 ns |         - |
| GenericAnyMissing    | 5      | False   |  44,283.27 ns |  2,815.276 ns |   435.667 ns |         - |
| AnyFirst             | 5      | False   |      36.54 ns |      2.944 ns |     0.765 ns |         - |
| GenericAnyFirst      | 5      | False   |      49.38 ns |      1.977 ns |     0.513 ns |         - |
| **MaskedCount**          | **5**      | **True**    |  **71,243.35 ns** |  **3,821.318 ns** |   **591.353 ns** |         **-** |
| GenericMaskedCount   | 5      | True    | 119,250.40 ns | 11,051.320 ns | 2,869.993 ns |         - |
| EqualityCount        | 5      | True    |   5,686.04 ns |    640.819 ns |   166.419 ns |         - |
| GenericEqualityCount | 5      | True    |  42,602.26 ns |    866.327 ns |   134.065 ns |         - |
| AnyMissing           | 5      | True    |  59,015.13 ns |  1,520.954 ns |   235.369 ns |         - |
| GenericAnyMissing    | 5      | True    |  52,285.32 ns |  8,378.248 ns | 2,175.804 ns |         - |
| AnyFirst             | 5      | True    |      40.71 ns |      6.507 ns |     1.690 ns |         - |
| GenericAnyFirst      | 5      | True    |      52.84 ns |      7.633 ns |     1.982 ns |         - |
