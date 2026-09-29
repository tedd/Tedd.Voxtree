```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 66.42 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1  
WarmupCount=3  

```
| Method                    | ChannelCount | Pattern   | Mean          | Error          | StdDev       | Gen0   | Allocated |
|-------------------------- |------------- |---------- |--------------:|---------------:|-------------:|-------:|----------:|
| **DeserializeBorrowedPacket** | **1**            | **Uniform**   |      **47.33 ns** |      **11.218 ns** |     **0.615 ns** | **0.0043** |      **72 B** |
| **DeserializeBorrowedPacket** | **1**            | **Random**    |      **57.56 ns** |      **64.688 ns** |     **3.546 ns** | **0.0043** |      **72 B** |
| **DeserializeBorrowedPacket** | **1**            | **Clustered** |     **217.35 ns** |     **146.450 ns** |     **8.027 ns** | **0.0043** |      **72 B** |
| **DeserializeBorrowedPacket** | **4**            | **Uniform**   |  **33,254.52 ns** |   **2,118.843 ns** |   **116.141 ns** |      **-** |     **120 B** |
| **DeserializeBorrowedPacket** | **4**            | **Random**    |      **83.18 ns** |       **4.375 ns** |     **0.240 ns** | **0.0072** |     **120 B** |
| **DeserializeBorrowedPacket** | **4**            | **Clustered** |  **33,853.35 ns** |   **1,067.821 ns** |    **58.531 ns** |      **-** |     **120 B** |
| **DeserializeBorrowedPacket** | **16**           | **Uniform**   | **175,376.36 ns** |   **4,515.182 ns** |   **247.492 ns** |      **-** |     **312 B** |
| **DeserializeBorrowedPacket** | **16**           | **Random**    |     **209.22 ns** |      **74.205 ns** |     **4.067 ns** | **0.0186** |     **312 B** |
| **DeserializeBorrowedPacket** | **16**           | **Clustered** | **191,062.94 ns** | **177,208.167 ns** | **9,713.378 ns** |      **-** |     **312 B** |
