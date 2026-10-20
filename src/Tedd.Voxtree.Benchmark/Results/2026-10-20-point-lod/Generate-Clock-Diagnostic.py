"""Add clocks outside unchanged control callers, not inside read loops."""
from pathlib import Path
here = Path(__file__).resolve().parent
source = (here / 'Scenarios-precision.cs.txt').read_text()
cut = source.index('if (args[0] == "--inventory")')
driver = r'''
if(args[0]=="--clocks") {
    var process=Process.GetCurrentProcess();
    process.PriorityClass=args[1]=="high"?ProcessPriorityClass.High:ProcessPriorityClass.Normal;
    Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(new{kind="identity",pid=process.Id,start=process.StartTime.ToUniversalTime(),priority=process.PriorityClass.ToString(),affinity=(long)process.ProcessorAffinity,runtime=System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription,frequency=Stopwatch.Frequency,entrySha256=Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(System.Reflection.Assembly.GetExecutingAssembly().Location)))}));
    foreach(var id in new[]{"point-Legacy-L5-full-owned-get","point-Legacy-L5-full-compiled-get"}) {
        var scenario=(ISynchronousScenario)registry.Get(id);
        foreach(var variant in new[]{"baseline","candidate"}) scenario.Prepare(new ScenarioContext(variant,CancellationToken.None));
        for(var block=0;block<4;block++)foreach(var variant in block%2==0?new[]{"baseline","candidate"}:new[]{"candidate","baseline"}) {
            scenario.Prepare(new ScenarioContext(variant,CancellationToken.None));scenario.Reset(new ResetContext(ResetLevel.LogicalState));
            var count=id.Contains("compiled")?33554432:2097152;
            var start=DiagnosticClocks.Start();var completed=scenario.ExecuteBatch(count);var observation=DiagnosticClocks.Stop(start);
            var correct=completed==count&&scenario.Validate().Correct;
            Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(new{kind="block",scenario=id,block,variant,count,correct,observation}));
            if(!correct)throw new Exception("Clock diagnostic validation");
        }
        scenario.Cleanup();
    }
    return;
}
'''
source = source[:cut] + driver + source[cut:]
source += r'''
static class DiagnosticClocks {
    [System.Runtime.InteropServices.DllImport("kernel32.dll",SetLastError=true)]
    [return:System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.Bool)]
    static extern bool GetThreadTimes(nint thread,out long created,out long exited,out long kernel,out long user);
    static readonly Process Process=Process.GetCurrentProcess();
    internal readonly record struct Stamp(long Process,long Thread,int G0,int G1,int G2,long Wall);
    internal readonly record struct Observation(double WallMs,double ThreadMs,double ProcessMs,int Gen0,int Gen1,int Gen2);
    static long ThreadTicks(){if(!GetThreadTimes(-2,out _,out _,out var kernel,out var user))throw new System.ComponentModel.Win32Exception();return kernel+user;}
    internal static Stamp Start(){var p=Process.TotalProcessorTime.Ticks;var t=ThreadTicks();var g0=GC.CollectionCount(0);var g1=GC.CollectionCount(1);var g2=GC.CollectionCount(2);return new(p,t,g0,g1,g2,Stopwatch.GetTimestamp());}
    internal static Observation Stop(Stamp start){var wall=Stopwatch.GetTimestamp();var t=ThreadTicks();var p=Process.TotalProcessorTime.Ticks;return new((wall-start.Wall)*1000.0/Stopwatch.Frequency,(t-start.Thread)/10000.0,(p-start.Process)/10000.0,GC.CollectionCount(0)-start.G0,GC.CollectionCount(1)-start.G1,GC.CollectionCount(2)-start.G2);}
}
'''
(here / 'Scenarios-clock.cs.txt').write_text(source, encoding='utf-8')
