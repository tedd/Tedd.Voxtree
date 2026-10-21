"""Single-library normal fixture: no namespace arm or alternate implementation."""
from pathlib import Path
research=Path(__file__).resolve().parent;p=research/'Scenarios-world-normal.cs.txt';assert not p.exists()
prototype=(research/'Scenarios-cache-maintenance.cs.txt').read_text()
def closing(text,start):
 depth=0
 for pos in range(start,len(text)):
  if text[pos]=='{':depth+=1
  elif text[pos]=='}':
   depth-=1
   if depth==0:return pos
 raise AssertionError('Unclosed caller')
s='''using System.Diagnostics;
using System.Runtime.CompilerServices;
using Tedd.DotNetLab.Contracts;
using Tedd.DotNetLab.Harness;
using Tedd.Voxtree;
if(OperatingSystem.IsWindows())Process.GetCurrentProcess().ProcessorAffinity=(nint)4;
WorldNormalMode.Validation=args[0]=="--validate";
var registry=new ScenarioRegistry();
foreach(var op in new[]{"get","lod","chunk","topology"})
foreach(var pattern in new[]{"repeated","blocks32","alternating","cycle10","cycle12","miss"}){
 registry.Register(new WorldUInt32(op,pattern));registry.Register(new WorldUInt16(op,pattern));
}
if(args[0] is "--validate" or "--code"){
 foreach(var d in registry.Describe()){
  if(args.Length>1&&!d.Id.Contains(args[1]))continue;
  var scenario=(ISynchronousScenario)registry.Get(d.Id);
  foreach(var arm in new[]{"baseline","candidate"}){
   scenario.Prepare(new ScenarioContext(arm,CancellationToken.None));
   scenario.Reset(new ResetContext(ResetLevel.LogicalState));
   scenario.ExecuteBatch(args[0]=="--code"?2097152:16384);
   if(!scenario.Validate().Correct)throw new Exception(d.Id+arm);scenario.Cleanup();
  }Console.WriteLine(d.Id+" valid");
 }return;
}
var host=new HarnessHost(registry,args[1]);
if(args[0]=="--harness-owned"||Environment.GetEnvironmentVariable("DOTNET_EnableDiagnostics")=="0")await host.RunOwnedAsync();
else{Console.WriteLine(Wire.Serialize(host.Target));using var c=new CancellationTokenSource();_=Task.Run(async()=>{await Console.In.ReadLineAsync();c.Cancel();});await host.ListenAsync(c.Token);}
public static class WorldNormalMode{public static bool Validation;}
'''
template='''
public sealed class WorldWIDTH : ISynchronousScenario{
 private readonly string op,pattern;
 private readonly int[] points=new int[1024];private readonly long[] prefix=new long[1025];
 private WorldTYPE world=null!;private bool initialized,primed;private int position;private long sum,completed;
 public WorldWIDTH(string op,string pattern){this.op=op;this.pattern=pattern;}
 public ScenarioDescriptor Describe()=>new($"normal-world-WIDTH-{op}-{pattern}","22",
  Wire.Hash(new{op,pattern,width="WIDTH",channels=2,side=1,chunks=12,lod=3,points=1024,affinity=4,primeMs=1000,callerShape="single-library-separate-operation-methods",consumer="exact-prefix-values-plus-hit"}),
  ResetLevel.LogicalState,ThreadAffinity.Any,false,op=="topology"?"One complete topology level search":"One complete public world lookup",["baseline","candidate"]);
 private void Initialize(){if(initialized)return;world=new WorldTYPE(1,2);
  for(int i=0;i<12;i++){
   var values=new VALUE[]{(VALUE)(i+1),(VALUE)(i+101)};var chunk=ChunkTYPE.FromDense(0,2,values);
   if(op!="topology")world.SetChunk(i-6,0,0,chunk);world.SetLodChunk(3,i-6,0,0,chunk);
  }
  for(int j=0;j<points.Length;j++){
   int index=pattern switch{"repeated"=>0,"blocks32"=>(j>>5)&7,"alternating"=>j&1,"cycle10"=>j%10,"cycle12"=>j%12,_=>30};points[j]=index-6;
   prefix[j+1]=prefix[j]+(index>=12?0:65536+(op=="chunk"?2:index+1+((j>>1)&1)*100));
  }initialized=true;
 }
 public void Prepare(ScenarioContext c){if(c.Variant is not("baseline" or "candidate"))throw new Exception("Unknown variant");Initialize();
  if(!WorldNormalMode.Validation&&!primed){var sw=Stopwatch.StartNew();do{ExecuteBatch(8192);}while(sw.ElapsedMilliseconds<1000);primed=true;}
 }
 public void Reset(ResetContext c){position=0;sum=completed=0;}
 public long ExecuteBatch(int count){switch(op){case "get":AfterGet(count);break;case "lod":AfterLod(count);break;case "chunk":AfterChunk(count);break;case "topology":AfterTopology(count);break;default:throw new Exception();}completed+=count;return count;}
 METHODS
 public ValidationResult Validate()=>new(sum==unchecked(completed/1024*prefix[1024]+prefix[(int)(completed%1024)]));
 public void Cleanup(){}
}
'''
for width,world,chunk,value in [('UInt32','WorldEntity','OctreeChunk','uint'),('UInt16','WorldEntity<ushort>','OctreeChunk<ushort>','ushort')]:
 methods=[];start=prototype.index('public sealed class World'+width)
 for op in ['Get','Lod','Chunk','Topology']:
  marker=f'[MethodImpl(MethodImplOptions.NoInlining)] private void After{op}(int count)';a=prototype.index(marker,start);b=prototype.index('{',a);end=closing(prototype,b)
  methods.append(prototype[a:end+1])
 s+=template.replace('METHODS','\n'.join(methods)).replace('WIDTH',width).replace('WorldTYPE',world).replace('ChunkTYPE',chunk).replace('VALUE',value)
assert 'Snapshot.' not in s and 'Before.' not in s and 'BeforeBatch' not in s
p.write_text(s);print(p)
