```

BenchmarkDotNet v0.16.0-preview.1, Windows 11 (10.0.26200.9457/25H2/2025Update/HudsonValley2)
AMD Ryzen 9 5950X 3.40GHz, 1 CPU, 32 logical and 16 physical cores
Memory: 127.91 GB Total, 65.91 GB Available
.NET SDK 11.0.100-rc.1.26425.128
  [Host]   : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3
  ShortRun : .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3

Job=ShortRun  IterationCount=3  LaunchCount=1  
WarmupCount=3  

```
| Method                     | ChannelCount | Pattern   | Mean             | Error           | StdDev        | Gen0   | Allocated |
|--------------------------- |------------- |---------- |-----------------:|----------------:|--------------:|-------:|----------:|
| **DeserializeBorrowedPacket**  | **1**            | **Uniform**   |        **26.106 ns** |       **1.3330 ns** |     **0.0731 ns** | **0.0057** |      **96 B** |
| ParseBorrowedPacketView    | 1            | Uniform   |         6.971 ns |       0.3952 ns |     0.0217 ns |      - |         - |
| ValidateBorrowedPacketView | 1            | Uniform   |        15.377 ns |       2.2067 ns |     0.1210 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **1**            | **Sparse**    |    **36,040.684 ns** |   **2,525.0645 ns** |   **138.4073 ns** |      **-** |      **96 B** |
| ParseBorrowedPacketView    | 1            | Sparse    |         8.137 ns |       0.6450 ns |     0.0354 ns |      - |         - |
| ValidateBorrowedPacketView | 1            | Sparse    |    34,827.822 ns |   9,724.6507 ns |   533.0409 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **1**            | **Random**    |        **29.559 ns** |       **3.1099 ns** |     **0.1705 ns** | **0.0057** |      **96 B** |
| ParseBorrowedPacketView    | 1            | Random    |         7.912 ns |       0.4060 ns |     0.0223 ns |      - |         - |
| ValidateBorrowedPacketView | 1            | Random    |        15.246 ns |      10.8120 ns |     0.5926 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **1**            | **Clustered** |       **132.721 ns** |      **20.5478 ns** |     **1.1263 ns** | **0.0057** |      **96 B** |
| ParseBorrowedPacketView    | 1            | Clustered |         8.130 ns |       0.1048 ns |     0.0057 ns |      - |         - |
| ValidateBorrowedPacketView | 1            | Clustered |       114.861 ns |       5.0457 ns |     0.2766 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **4**            | **Uniform**   |        **57.179 ns** |      **18.1931 ns** |     **0.9972 ns** | **0.0086** |     **144 B** |
| ParseBorrowedPacketView    | 4            | Uniform   |        15.981 ns |       1.3524 ns |     0.0741 ns |      - |         - |
| ValidateBorrowedPacketView | 4            | Uniform   |        46.597 ns |       5.9666 ns |     0.3271 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **4**            | **Sparse**    |   **138,654.867 ns** |  **12,510.7745 ns** |   **685.7578 ns** |      **-** |     **144 B** |
| ParseBorrowedPacketView    | 4            | Sparse    |        18.270 ns |       2.0051 ns |     0.1099 ns |      - |         - |
| ValidateBorrowedPacketView | 4            | Sparse    |   142,850.236 ns |   2,132.9985 ns |   116.9168 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **4**            | **Random**    |        **57.329 ns** |       **5.0125 ns** |     **0.2748 ns** | **0.0086** |     **144 B** |
| ParseBorrowedPacketView    | 4            | Random    |        16.798 ns |       0.4358 ns |     0.0239 ns |      - |         - |
| ValidateBorrowedPacketView | 4            | Random    |        42.836 ns |       1.4733 ns |     0.0808 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **4**            | **Clustered** |       **488.739 ns** |     **408.8349 ns** |    **22.4096 ns** | **0.0086** |     **144 B** |
| ParseBorrowedPacketView    | 4            | Clustered |        20.573 ns |      34.6506 ns |     1.8993 ns |      - |         - |
| ValidateBorrowedPacketView | 4            | Clustered |       531.816 ns |   1,595.0585 ns |    87.4305 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **16**           | **Uniform**   |       **217.460 ns** |     **573.0568 ns** |    **31.4112 ns** | **0.0200** |     **336 B** |
| ParseBorrowedPacketView    | 16           | Uniform   |        53.811 ns |       9.3998 ns |     0.5152 ns |      - |         - |
| ValidateBorrowedPacketView | 16           | Uniform   |       175.719 ns |      52.1073 ns |     2.8562 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **16**           | **Sparse**    | **1,116,950.651 ns** |  **45,388.1498 ns** | **2,487.8777 ns** |      **-** |     **336 B** |
| ParseBorrowedPacketView    | 16           | Sparse    |        61.794 ns |      33.8461 ns |     1.8552 ns |      - |         - |
| ValidateBorrowedPacketView | 16           | Sparse    |   587,158.496 ns | 172,063.5226 ns | 9,431.3823 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **16**           | **Random**    |       **207.073 ns** |     **103.4829 ns** |     **5.6722 ns** | **0.0200** |     **336 B** |
| ParseBorrowedPacketView    | 16           | Random    |        71.754 ns |      22.6034 ns |     1.2390 ns |      - |         - |
| ValidateBorrowedPacketView | 16           | Random    |       167.234 ns |      54.9062 ns |     3.0096 ns |      - |         - |
| **DeserializeBorrowedPacket**  | **16**           | **Clustered** |     **1,870.006 ns** |     **345.5907 ns** |    **18.9430 ns** | **0.0191** |     **336 B** |
| ParseBorrowedPacketView    | 16           | Clustered |        56.949 ns |       3.1497 ns |     0.1726 ns |      - |         - |
| ValidateBorrowedPacketView | 16           | Clustered |     1,948.696 ns |   1,540.1399 ns |    84.4203 ns |      - |         - |
