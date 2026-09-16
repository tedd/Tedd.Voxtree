```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9445/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 67.35 GB Available
.NET SDK 11.0.100-preview.7.26381.103
  [Host]     : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  Job-BZNPUE : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

IterationCount=5  IterationTime=200ms  LaunchCount=1
WarmupCount=3

```
| Method               | Levels | Strided | Mean         | Error        | StdDev       | Allocated |
|--------------------- |------- |-------- |-------------:|-------------:|-------------:|----------:|
| **MaskedCount**          | **3**      | **False**   |     **67.29 ns** |     **8.441 ns** |     **2.192 ns** |         **-** |
| GenericMaskedCount   | 3      | False   |     73.61 ns |     2.256 ns |     0.349 ns |         - |
| EqualityCount        | 3      | False   |     59.60 ns |     4.453 ns |     1.156 ns |         - |
| GenericEqualityCount | 3      | False   |     57.22 ns |    14.291 ns |     2.212 ns |         - |
| AnyMissing           | 3      | False   |     78.57 ns |    14.891 ns |     3.867 ns |         - |
| GenericAnyMissing    | 3      | False   |     77.91 ns |    23.856 ns |     6.195 ns |         - |
| AnyFirst             | 3      | False   |     32.82 ns |     2.407 ns |     0.372 ns |         - |
| GenericAnyFirst      | 3      | False   |     35.18 ns |     4.770 ns |     1.239 ns |         - |
| **MaskedCount**          | **3**      | **True**    |    **730.04 ns** |    **94.397 ns** |    **24.515 ns** |         **-** |
| GenericMaskedCount   | 3      | True    |  1,085.04 ns |    15.505 ns |     2.399 ns |         - |
| EqualityCount        | 3      | True    |    389.15 ns |    51.482 ns |     7.967 ns |         - |
| GenericEqualityCount | 3      | True    |    293.29 ns |    55.721 ns |     8.623 ns |         - |
| AnyMissing           | 3      | True    |  1,061.14 ns |   111.141 ns |    28.863 ns |         - |
| GenericAnyMissing    | 3      | True    |    475.41 ns |    39.699 ns |     6.143 ns |         - |
| AnyFirst             | 3      | True    |     44.09 ns |    13.139 ns |     3.412 ns |         - |
| GenericAnyFirst      | 3      | True    |     35.32 ns |     8.684 ns |     1.344 ns |         - |
| **MaskedCount**          | **5**      | **False**   |  **2,853.86 ns** |   **493.397 ns** |   **128.134 ns** |         **-** |
| GenericMaskedCount   | 5      | False   |  2,785.78 ns |   153.055 ns |    39.748 ns |         - |
| EqualityCount        | 5      | False   |  2,187.17 ns |   140.972 ns |    36.610 ns |         - |
| GenericEqualityCount | 5      | False   |  2,198.97 ns |   268.820 ns |    69.812 ns |         - |
| AnyMissing           | 5      | False   |  2,907.51 ns |   293.248 ns |    76.156 ns |         - |
| GenericAnyMissing    | 5      | False   |  2,979.21 ns |   446.499 ns |   115.954 ns |         - |
| AnyFirst             | 5      | False   |     32.43 ns |     5.439 ns |     1.412 ns |         - |
| GenericAnyFirst      | 5      | False   |     33.42 ns |     3.563 ns |     0.925 ns |         - |
| **MaskedCount**          | **5**      | **True**    | **11,179.71 ns** |    **18.593 ns** |     **4.828 ns** |         **-** |
| GenericMaskedCount   | 5      | True    | 18,987.69 ns |    76.180 ns |    11.789 ns |         - |
| EqualityCount        | 5      | True    |  7,729.53 ns |   630.336 ns |   163.696 ns |         - |
| GenericEqualityCount | 5      | True    |  6,712.83 ns |   696.485 ns |   180.875 ns |         - |
| AnyMissing           | 5      | True    | 21,699.23 ns | 4,487.618 ns | 1,165.420 ns |         - |
| GenericAnyMissing    | 5      | True    | 12,670.46 ns | 1,976.791 ns |   513.366 ns |         - |
| AnyFirst             | 5      | True    |     44.83 ns |    11.499 ns |     2.986 ns |         - |
| GenericAnyFirst      | 5      | True    |     39.35 ns |     7.313 ns |     1.899 ns |         - |
