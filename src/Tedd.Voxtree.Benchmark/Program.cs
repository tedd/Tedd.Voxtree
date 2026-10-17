using BenchmarkDotNet.Running;

namespace Tedd.Voxtree.Benchmark;

internal static class Program
{
    private static void Main(string[] args)
    {
        if (args.Length > 0 && args[0] == "--simulation-loop")
        {
            SimulationLoop.Run(args);
            return;
        }
        BenchmarkSwitcher.FromAssembly(typeof(Program).Assembly).Run(args);
    }
}
