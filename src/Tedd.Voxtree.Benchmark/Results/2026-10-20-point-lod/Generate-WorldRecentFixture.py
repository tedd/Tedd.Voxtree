"""Generate symmetric callers from one template. Output is durable research."""
from pathlib import Path
p=Path(__file__).with_name('Scenarios-world-recent.cs.txt')
assert not p.exists()
text='''using System.Diagnostics;
using System.Runtime.CompilerServices;
using Tedd.DotNetLab.Contracts;
using Tedd.DotNetLab.Harness;
using Tedd.Voxtree;
using Before = Snapshot.Voxtree;
if (OperatingSystem.IsWindows()) Process.GetCurrentProcess().ProcessorAffinity=(nint)4;
WorldFixture.Validation=args[0]=="--validate";
var registry=new ScenarioRegistry();
foreach(var op in new[]{"get","lod","chunk","topology"})
foreach(var pattern in new[]{"repeated","blocks32","alternating","cycle12","miss"}) {
 registry.Register(new WorldUInt32(op,pattern));registry.Register(new WorldUInt16(op,pattern));
}
if(args[0] is "--validate" or "--code") {
 foreach(var d in registry.Describe()) {
  if(args.Length>1&&!d.Id.Contains(args[1]))continue;
  var s=(ISynchronousScenario)registry.Get(d.Id);
  foreach(var arm in new[]{"baseline","candidate"}) {
   s.Prepare(new ScenarioContext(arm,CancellationToken.None));
   s.Reset(new ResetContext(ResetLevel.LogicalState));
   s.ExecuteBatch(args[0]=="--code"?2097152:16384);
   if(!s.Validate().Correct)throw new Exception(d.Id+arm);
   s.Cleanup();
  }
  Console.WriteLine(d.Id+" valid");
 }return;
}
var host=new HarnessHost(registry,args[1]);
if(args[0]=="--harness-owned"||Environment.GetEnvironmentVariable("DOTNET_EnableDiagnostics")=="0")await host.RunOwnedAsync();
else {Console.WriteLine(Wire.Serialize(host.Target));using var c=new CancellationTokenSource();_=Task.Run(async()=>{await Console.In.ReadLineAsync();c.Cancel();});await host.ListenAsync(c.Token);}
public static class WorldFixture {public static bool Validation;}
'''
template='''
public sealed class WorldWIDTH : ISynchronousScenario {
 private readonly string op,pattern;
 private readonly int[] points=new int[1024];
 private readonly long[] prefix=new long[1025];
 private WorldTYPE world=null!;private Before.WorldTYPE before=null!;
 private bool initialized,baseline,beforePrimed,afterPrimed;
 private int position;private long sum,completed;
 public WorldWIDTH(string op,string pattern){this.op=op;this.pattern=pattern;}
 public ScenarioDescriptor Describe()=>new($"world-WIDTH-{op}-{pattern}","19",
  Wire.Hash(new{op,pattern,width="WIDTH",channels=2,side=1,chunks=12,lod=3,points=1024,affinity=4,primeMs=3000,consumer="exact-prefix-values-plus-hit"}),
  ResetLevel.LogicalState,ThreadAffinity.Any,false,op=="topology"?"One complete topology level search":"One complete public world lookup",["baseline","candidate"]);
 private void Initialize(){
  if(initialized)return;
  world=new WorldTYPE(1,2);before=new Before.WorldTYPE(1,2);
  for(int i=0;i<12;i++){
   var values=new VALUE[]{(VALUE)(i+1),(VALUE)(i+101)};
   var a=ChunkTYPE.FromDense(0,2,values);var b=Before.ChunkTYPE.FromDense(0,2,values);
   if(op!="topology"){world.SetChunk(i-6,0,0,a);before.SetChunk(i-6,0,0,b);}
   world.SetLodChunk(3,i-6,0,0,a);before.SetLodChunk(3,i-6,0,0,b);
  }
  for(int j=0;j<points.Length;j++){
   int index=pattern switch {"repeated"=>0,"blocks32"=>(j>>5)&7,"alternating"=>j&1,"cycle12"=>j%12,_=>30};
   points[j]=index-6;
   long expected=index>=12?0:65536+(op=="chunk"?2:index+1+((j>>1)&1)*100);
   prefix[j+1]=prefix[j]+expected;
  }
  initialized=true;
 }
 public void Prepare(ScenarioContext c){Initialize();baseline=c.Variant=="baseline";
  if(!WorldFixture.Validation&&(baseline?!beforePrimed:!afterPrimed)){
   var sw=Stopwatch.StartNew();do{ExecuteBatch(8192);}while(sw.ElapsedMilliseconds<3000);
   if(baseline)beforePrimed=true;else afterPrimed=true;
  }
 }
 public void Reset(ResetContext c){position=0;sum=completed=0;}
 public long ExecuteBatch(int count){if(baseline)BeforeBatch(count);else AfterBatch(count);completed+=count;return count;}
 METHODS
 public ValidationResult Validate()=>new(sum==unchecked(completed/1024*prefix[1024]+prefix[(int)(completed%1024)]));
 public void Cleanup(){}
}
'''
for width,world,chunk,value in [('UInt32','WorldEntity','OctreeChunk','uint'),('UInt16','WorldEntity<ushort>','OctreeChunk<ushort>','ushort')]:
 methods=[]
 for arm,w,ns in [('Before','before','Before.'),('After','world','')]:
  body=''
  for op in ['get','lod','chunk','topology']:
   call={'get':f'found={w}.TryGet(channel,x,0,0,out result);',
         'lod':f'found={w}.TryGetLod(3,channel,(long)x<<3,0,0,out result);',
         'chunk':f'found={w}.TryGetChunk(new {ns}ChunkAddress(3,x,0,0),out var chunk);result=({value})(found?chunk!.ChannelCount:0);',
         'topology':f'found=false;result=0;for(int level=0;level<8;level++){{if({w}.TryGetLod(level,channel,(long)x<<3,0,0,out result)){{found=true;break;}}}}'}[op]
   body+=f'''if(op=="{op}"){{for(int i=0;i<count;i++){{int j=position++&1023,x=points[j],channel=(j>>1)&1;bool found;{value} result;{call}sum=unchecked(sum+(long)result+(found?65536:0));}}return;}}\n'''
  methods.append(f'[MethodImpl(MethodImplOptions.NoInlining)] private void {arm}Batch(int count){{{body}throw new Exception();}}')
 t=template.replace('METHODS','\n'.join(methods)).replace('WIDTH',width).replace('WorldTYPE',world).replace('ChunkTYPE',chunk).replace('VALUE',value)
 text+=t
p.write_text(text)
print(p)
