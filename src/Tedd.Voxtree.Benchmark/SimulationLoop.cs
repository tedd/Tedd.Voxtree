using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text.Json;
using Tedd.Voxtree.Simulations;

namespace Tedd.Voxtree.Benchmark;

internal static class SimulationLoop
{
    public static void Run(string[] args)
    {
        var seconds = args.Length > 1 ? int.Parse(args[1]) : 0;
        if (seconds < 0 || seconds > 600) throw new ArgumentOutOfRangeException(nameof(seconds));
        Console.WriteLine(JsonSerializer.Serialize(new
        {
            process = Environment.ProcessId, start = Process.GetCurrentProcess().StartTime.ToUniversalTime(),
            runtime = RuntimeInformation.FrameworkDescription, architecture = RuntimeInformation.ProcessArchitecture.ToString(),
            clockFrequency = Stopwatch.Frequency, processors = Environment.ProcessorCount
        }));
        var workloads = (from levels in new[] { 3, 5 }
                         from kind in Enum.GetValues<SimulationKind>()
                         from access in Enum.GetValues<SimulationAccess>()
                         select (levels, kind, access, work: new SimulationWorkload(levels, kind, access))).ToArray();
        foreach (var item in workloads)
            for (var i = 0; i < 3; i++) { item.work.Reset(); item.work.Run(8); }
        var deadline = Stopwatch.StartNew();
        do
        {
            foreach (var item in workloads)
            {
                var iterations = item.levels == 3 ? 16 : 2;
                for (var sample = 0; sample < 5; sample++)
                {
                    var allocated = GC.GetAllocatedBytesForCurrentThread();
                    var start = Stopwatch.GetTimestamp();
                    ulong checksum = 0;
                    for (var i = 0; i < iterations; i++) { item.work.Reset(); checksum = item.work.Run(8); }
                    var elapsed = Stopwatch.GetTimestamp() - start;
                    var bytes = GC.GetAllocatedBytesForCurrentThread() - allocated;
                    Console.WriteLine(JsonSerializer.Serialize(new
                    {
                        item.levels, kind = item.kind.ToString(), access = item.access.ToString(), sample, iterations,
                        nanoseconds = elapsed * (1e9 / Stopwatch.Frequency) / iterations,
                        allocatedBytes = bytes, checksum
                    }));
                }
            }
        } while (deadline.Elapsed.TotalSeconds < seconds);
    }
}
