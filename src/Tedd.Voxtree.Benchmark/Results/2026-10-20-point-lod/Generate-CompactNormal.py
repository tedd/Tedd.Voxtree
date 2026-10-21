"""Generate one-library version25 callers and explicit complete-operation units."""
from pathlib import Path
research=Path(__file__).resolve().parent
output=research/'Scenarios-compact-normal-storage.cs.txt'
assert not output.exists(), 'Preserve original fixture identity'
header=r'''using System.Diagnostics;
using System.Buffers.Binary;
using System.Runtime.CompilerServices;
using System.Security.Cryptography;
using System.Text.Json;
using Tedd.DotNetLab.Contracts;
using Tedd.DotNetLab.Harness;
using Tedd.Voxtree;
if(!OperatingSystem.IsWindows())throw new PlatformNotSupportedException("Selected Windows fixture");
Process.GetCurrentProcess().ProcessorAffinity=(nint)4;
NormalMode.Validation=args[0]=="--validate";
var cases=CaseCatalog.Create();
if(args[0]=="--inventory"){
 Console.WriteLine(JsonSerializer.Serialize(cases.Select(c=>{var d=c.Describe();return new{id=d.Id,version=d.Version,input_hash=d.InputHash,spec=c.Spec,operations=c.Spec.Operations,primary=c.Spec.Primary};})));return;
}
if(args[0] is "--validate" or "--code"){
 foreach(var c in cases){
  if(args.Length>1&&c.Describe().Id!=args[1])continue;
  c.Prepare(new ScenarioContext("candidate",CancellationToken.None));
  if(args[0]=="--code"){c.Reset(new ResetContext(ResetLevel.LogicalState));c.ExecuteBatch(c.Spec.Operations);if(!c.Validate().Correct)throw new Exception("Warmup oracle");}
  c.Reset(new ResetContext(ResetLevel.LogicalState));c.ExecuteBatch(args[0]=="--code"?c.Spec.Operations:c.Spec.ValidationCount);
  if(!c.Validate().Correct)throw new Exception(c.Describe().Id+" oracle");
  var fingerprint=c.Fingerprint();c.Cleanup();Console.WriteLine(JsonSerializer.Serialize(fingerprint));
 }return;
}
var registry=new ScenarioRegistry();foreach(var c in cases)registry.Register(c);
var host=new HarnessHost(registry,args[1]);
if(args[0]=="--harness-owned"||Environment.GetEnvironmentVariable("DOTNET_EnableDiagnostics")=="0")await host.RunOwnedAsync();
else{Console.WriteLine(Wire.Serialize(host.Target));using var stop=new CancellationTokenSource();_=Task.Run(async()=>{await Console.In.ReadLineAsync();stop.Cancel();});await host.ListenAsync(stop.Token);}
public static class NormalMode{public static bool Validation;}
public sealed record NormalSpec(string Dataset,string Mode,string Op){
 public int Levels=>Dataset=="S"?3:5;
 public string Id=>$"compact-normal-{Mode}-{Dataset}-{Op}";
 public bool Primary=>(Dataset is "D" or "S")&&(Op is "validate" or "from" or "create")||Dataset=="D"&&(Op is "chunk-new" or "chunk-from" or "chunk-validate");
 public int ValidationCount=>Op is "get" or "lod" or "lookup-get" or "lookup-lod"?2051:2;
 public int Operations=>Op switch{
  "get" or "lod" or "lookup-get" or "lookup-lod"=>4194304,
  "lifecycle"=>8,"load"=>64,
  "construct" or "build" or "chunk-update" or "chunk-dense"=>128,
  "copy"=>Dataset=="F"?4096:256,"count" or "any"=>2048,
  "validate"=>Dataset is "E" or "F" or "ME"?4194304:Dataset is "S" or "C"?8192:256,
  "from" or "create"=>Dataset=="E"?262144:Dataset is "S" or "C"?8192:Dataset=="F"?1024:256,
  "chunk-new" or "chunk-from" or "chunk-validate"=>256,_=>throw new ArgumentException(Op)};
 public string Source=>Dataset=="D"?ForcecraftCorpus.Hash("mixed-u16-air"):Dataset switch{"S"=>"checker8-z-parity-v1","C"=>"uniform-R32-value7-lod5-v1","E"=>"uniform-O32-value0-lod5-v1","F"=>"dense-O32-z-parity-0-65535-v1","ME"=>"checker-R32-firstword-lod7-v1","ML"=>"checker-R32-lastword-lod7-v1",_=>throw new ArgumentException()};
 public string Lifecycle=>Mode=="Classic32"?"CreateLookup +65536 compiled value/LOD reads":"FromEncoded +65536 owned value/LOD reads";
}
public interface INormalCase:ISynchronousScenario{NormalSpec Spec{get;}object Fingerprint();}
public static class CaseCatalog{
 public static INormalCase[] Create(){var result=new List<INormalCase>();
  foreach(var data in new[]{"D","S","C","E","F","ME","ML"})foreach(var mode in new[]{"Classic32","Generic16","Generic32"}){
   var ops=data switch{
    "D"=>new[]{"validate","from","create","lifecycle","get","lod","construct","build","copy","count","any","load","chunk-new","chunk-from","chunk-validate","chunk-update","chunk-dense"},
    "S"=>new[]{"validate","from","create","get","lod"},"C"=>new[]{"validate","from","create","lifecycle"},"E"=>new[]{"validate","from","create"},
    "F"=>new[]{"validate","from","get","lod","build","copy"},_=>new[]{"validate"}};
   foreach(var op in ops.Concat(mode=="Classic32"&&(data is "D" or "S")?new[]{"lookup-get","lookup-lod"}:Array.Empty<string>())){
    if(op=="create"&&mode!="Classic32")continue;
    var s=new NormalSpec(data,mode,op);result.Add(mode=="Classic32"?new ClassicCase(s):mode=="Generic16"?new GenericCase<ushort>(s):new GenericCase<uint>(s));
   }
  }if(result.Count!=107||result.Count(c=>c.Spec.Primary)!=23)throw new Exception("Fixed family drift");return result.ToArray();
 }
}
public static class InputData{
 public static ushort[] Values(NormalSpec s){int n=1<<(s.Levels*3);if(s.Dataset=="D")return ForcecraftCorpus.Load("mixed-u16-air");
  return Enumerable.Range(0,n).Select(i=>s.Dataset switch{"C"=>(ushort)7,"E"=>(ushort)0,"F"=>(ushort)((i&1)==0?0:65535),_=>(ushort)(i&1)}).ToArray();}
 public static byte[] Lods(ushort[] values,int levels){int side=1<<levels;var result=new byte[values.Length];
  void Visit(int x,int y,int z,int level){int size=1<<level;ushort first=values[(x*side+y)*side+z];bool same=true;
   for(int xx=x;xx<x+size&&same;xx++)for(int yy=y;yy<y+size&&same;yy++)for(int zz=z;zz<z+size;zz++)if(values[(xx*side+yy)*side+zz]!=first){same=false;break;}
   if(same){for(int xx=x;xx<x+size;xx++)for(int yy=y;yy<y+size;yy++)Array.Fill(result,(byte)level,(xx*side+yy)*side+z,size);return;}
   int half=size>>1;for(int c=0;c<8;c++)Visit(x+((c>>2)&1)*half,y+((c>>1)&1)*half,z+(c&1)*half,level-1);
  }Visit(0,0,0,levels);return result;
 }
 public static byte[] Compact(ushort[] raw,byte[] lods,int levels,int mode){int h=mode==0?2:3;var data=new byte[h+raw.Length*2];data[0]=0x52;data[1]=(byte)(0xc3|(levels<<2));if(h==3)data[2]=(byte)(mode==1?1:2);
  for(int i=0;i<raw.Length;i++){if(raw[i]>8191)throw new Exception("R range");BinaryPrimitives.WriteUInt16LittleEndian(data.AsSpan(h+i*2,2),(ushort)(raw[i]|(lods[i]<<13)));}return data;}
 public static byte[] Dense(ushort[] raw,int levels,int mode){int h=mode==0?2:3,w=mode==1?2:4;var data=new byte[h+raw.Length*w];data[0]=0x4f;data[1]=(byte)(((h==2?1:2)<<6)|(levels<<2)|2);if(h==3)data[2]=(byte)(mode==1?1:2);
  for(int i=0;i<raw.Length;i++)if(w==2)BinaryPrimitives.WriteUInt16LittleEndian(data.AsSpan(h+i*w,2),raw[i]);else BinaryPrimitives.WriteUInt32LittleEndian(data.AsSpan(h+i*w,4),raw[i]);return data;}
 public static int Index(int j,int count)=>(j*104729+12345)&(count-1);
 public static string Hash(ReadOnlySpan<byte> bytes)=>Convert.ToHexString(SHA256.HashData(bytes));
 public static long Expected(long completed,long[] prefix)=>unchecked(completed/1024*prefix[1024]+prefix[(int)(completed%1024)]);
}
public sealed class LocalStore{
 const string Base=@"D:\Workspaces\AI\voxtree-point-lod-20261020\p39-normal-storage";
 public string Root{get;}readonly string trace,caseId,stamp;readonly string start;
 public LocalStore(string id){caseId=id;start=Process.GetCurrentProcess().StartTime.ToUniversalTime().Ticks.ToString(System.Globalization.CultureInfo.InvariantCulture);
  string name=Environment.ProcessId+"-"+start+"-"+Guid.NewGuid().ToString("N");Root=Path.GetFullPath(Path.Combine(Base,name));Check();if(Directory.Exists(Root))throw new Exception("Owned store collision");
  Directory.CreateDirectory(Root);Directory.CreateDirectory(Path.Combine(Base,"traces"));trace=Path.Combine(Base,"traces",name+".json");stamp=InputData.Hash(File.ReadAllBytes(typeof(CaseCatalog).Assembly.Location));Write("created");}
 void Check(){string b=Path.GetFullPath(Base)+Path.DirectorySeparatorChar;if(!Path.GetFullPath(Root).StartsWith(b,StringComparison.OrdinalIgnoreCase)||Path.GetFullPath(Root)==Path.GetFullPath(Base))throw new Exception("Store escaped owned root");}
 public ChunkStorageOptions Options(){Check();return new ChunkStorageOptions(Root){Compression=ChunkCompression.Direct};}
 public void Ready(){Check();Write("prepared");}
 void Write(string stage)=>File.WriteAllText(trace,JsonSerializer.Serialize(new{caseId,pid=Environment.ProcessId,startTicks=start,root=Root,stage,entrySha256=stamp}));
 public void Cleanup(){Check();if(Directory.Exists(Root))Directory.Delete(Root,true);if(Directory.Exists(Root))throw new Exception("Owned store did not clean");Write("cleaned");}
}
'''

template=r'''
public sealed class @@CLASS@@ @@CONSTRAINT@@:INormalCase{
 public NormalSpec Spec{get;}
 readonly int mode;bool initialized;ushort[] raw=null!;byte[] natural=null!,encoded=null!,validEncoded=null!,packet=null!;
 @@VALUE@@[] values=null!,destination=null!;ReadOnlyMemory<byte>[] channels=null!;@@TREE@@ tree=null!;@@CHUNK@@ chunk=null!;
 @@LOOKUP_FIELD@@
 long sum,completed,first,lifeFold;int position,zeros;long[] pointPrefix=null!,lodPrefix=null!;LocalStore? store;ChunkStorageOptions? options;
 public @@CTOR@@(NormalSpec s){Spec=s;mode=s.Mode=="Classic32"?0:s.Mode=="Generic16"?1:2;@@TYPE_CHECK@@}
 @@CONVERSIONS@@
 public ScenarioDescriptor Describe()=>new(Spec.Id,"25",Wire.Hash(new{Spec.Dataset,Spec.Mode,Spec.Op,Spec.Source,Spec.Levels,Spec.Operations,Spec.Lifecycle,primeMs=500,affinity=4,pointMap="(j*104729+12345)&(N-1)",caller="single-library-separate-operation-kernels",load="TryLoadChunkFromStorage-fresh-world",allocation="original-current-thread-absolute-difference"}),ResetLevel.LogicalState,ThreadAffinity.Any,false,Spec.Op=="lifecycle"?Spec.Lifecycle:"One complete public "+Spec.Op+" operation and specified result consumed",["baseline","candidate"]);
 void Initialize(){if(initialized)return;raw=InputData.Values(Spec);natural=InputData.Lods(raw,Spec.Levels);values=new @@VALUE@@[raw.Length];for(int i=0;i<raw.Length;i++)values[i]=Value(raw[i]);
  destination=new @@VALUE@@[raw.Length];tree=new @@TREE@@(Spec.Levels,values);
  if(Spec.Dataset=="C")validEncoded=InputData.Compact(raw,natural,Spec.Levels,mode);
  else if(Spec.Dataset=="F")validEncoded=InputData.Dense(raw,Spec.Levels,mode);
  else validEncoded=tree.Data.ToArray();
  if(Spec.Dataset is "D" or "S" or "ME" or "ML"){
   var reference=InputData.Compact(raw,natural,Spec.Levels,mode);if(!reference.AsSpan().SequenceEqual(validEncoded))throw new Exception("Independent R bytes");
  }
  if((Spec.Dataset=="E"||Spec.Dataset=="F")&&validEncoded[0]!=0x4f)throw new Exception("O input");
  tree=@@TREE@@.FromEncoded(validEncoded);encoded=(byte[])validEncoded.Clone();
  if(Spec.Dataset is "ME" or "ML"){int h=mode==0?2:3,at=Spec.Dataset=="ME"?0:raw.Length-1;BinaryPrimitives.WriteUInt16LittleEndian(encoded.AsSpan(h+at*2,2),0xe000);}
  channels=new ReadOnlyMemory<byte>[]{validEncoded};chunk=new @@CHUNK@@(Spec.Levels,channels.AsSpan());packet=new byte[chunk.SerializedLength];if(chunk.CopyEncodedTo(packet)!=packet.Length)throw new Exception("Packet length");
  @@LOOKUP_INIT@@
  first=raw[0];zeros=raw.Count(v=>v==0);pointPrefix=new long[1025];lodPrefix=new long[1025];
  for(int j=0;j<1024;j++){int p=InputData.Index(j,raw.Length);pointPrefix[j+1]=unchecked(pointPrefix[j]+raw[p]);lodPrefix[j+1]=unchecked(lodPrefix[j]+raw[p]+((long)natural[p]<<32));}
  for(int j=0;j<65536;j++){int p=j&(raw.Length-1);lifeFold=unchecked(lifeFold+raw[p]+((long)natural[p]<<32));}
  if(Spec.Op=="load"){store=new LocalStore(Spec.Id);options=store.Options();var writer=new @@WORLD@@(1<<Spec.Levels,1,options);writer.SetChunk(0,0,0,chunk);if(writer.SaveAllChunks()!=1)throw new Exception("Owned packet setup");store.Ready();}
  initialized=true;CheckState();
 }
 void CheckState(){int side=1<<Spec.Levels;
  for(int i=0;i<raw.Length;i++){var v=tree.Get(i>>(Spec.Levels*2),(i>>Spec.Levels)&(side-1),i&(side-1),out int lod);if(Raw(v)!=raw[i]||lod!=natural[i])throw new Exception("Independent value/LOD");}
  if(!tree.AsSpan().IsWellFormed()||!new @@CHUNKSPAN@@(packet).IsWellFormed())throw new Exception("Owned invariant");
  if(chunk.Levels!=Spec.Levels||chunk.ChannelCount!=1||!chunk.GetChannelData(0).Span.SequenceEqual(validEncoded))throw new Exception("Channel mutation");
  @@LOOKUP_CHECK@@
  bool valid=new @@SPAN@@(encoded).IsWellFormed();if(valid!=(Spec.Dataset is not("ME" or "ML")))throw new Exception("Malformed oracle");
 }
 public void Prepare(ScenarioContext c){if(c.Variant is not("baseline" or "candidate"))throw new Exception("Variant");Initialize();if(!NormalMode.Validation){var sw=Stopwatch.StartNew();do{ExecuteBatch(1);}while(sw.ElapsedMilliseconds<500);}}
 public void Reset(ResetContext c){sum=completed=0;position=0;}
 public long ExecuteBatch(int count){switch(Spec.Op){
  case "validate":RunValidate(count);break;case "from":RunFrom(count);break;case "get":RunGet(count);break;case "lod":RunLod(count);break;
  case "construct":RunConstruct(count);break;case "build":RunBuild(count);break;case "copy":RunCopy(count);break;case "count":RunCount(count);break;case "any":RunAny(count);break;
  case "lifecycle":RunLifecycle(count);break;case "load":RunLoad(count);break;
  case "chunk-new":RunChunkNew(count);break;case "chunk-from":RunChunkFrom(count);break;case "chunk-validate":RunChunkValidate(count);break;case "chunk-update":RunChunkUpdate(count);break;case "chunk-dense":RunChunkDense(count);break;
  @@LOOKUP_SWITCH@@
  default:throw new Exception("Unsupported exported operation");}completed+=count;return count;}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunValidate(int n){for(int i=0;i<n;i++)sum=unchecked(sum+(new @@SPAN@@(encoded).IsWellFormed()?1:0));}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunFrom(int n){for(int i=0;i<n;i++){tree=@@TREE@@.FromEncoded(encoded);sum=unchecked(sum+Raw(tree.Get(0,0,0)));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunGet(int n){int l=Spec.Levels,mask=(1<<l)-1;for(int i=0;i<n;i++){int p=InputData.Index(position++&1023,raw.Length);sum=unchecked(sum+Raw(tree.Get(p>>(l*2),(p>>l)&mask,p&mask)));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunLod(int n){int l=Spec.Levels,mask=(1<<l)-1;for(int i=0;i<n;i++){int p=InputData.Index(position++&1023,raw.Length);var v=tree.Get(p>>(l*2),(p>>l)&mask,p&mask,out int lod);sum=unchecked(sum+Raw(v)+((long)lod<<32));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunConstruct(int n){for(int i=0;i<n;i++){tree=new @@TREE@@(Spec.Levels,values);sum=unchecked(sum+Raw(tree.Get(0,0,0)));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunBuild(int n){for(int i=0;i<n;i++){tree.Build(values);sum=unchecked(sum+Raw(tree.Get(0,0,0)));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunCopy(int n){for(int i=0;i<n;i++){tree.CopyTo(destination);sum=unchecked(sum+Raw(destination[17]));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunCount(int n){int side=1<<Spec.Levels;for(int i=0;i<n;i++)sum=unchecked(sum+tree.CountMatches(new VoxelBox(0,0,0,side,side,side),@@FILTER@@.EqualTo(Value(0))));}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunAny(int n){int side=1<<Spec.Levels;for(int i=0;i<n;i++)sum=unchecked(sum+(tree.Any(new VoxelBox(0,0,0,side,side,side),@@FILTER@@.EqualTo(Value(8191)))?1:0));}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunLoad(int n){for(int i=0;i<n;i++){var reader=new @@WORLD@@(1<<Spec.Levels,1,options!);if(!reader.TryLoadChunkFromStorage(0,0,0,out var loaded))throw new Exception("Owned load missing");chunk=loaded!;sum=unchecked(sum+Raw(chunk.GetChannel(0).Get(0,0,0)));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunChunkNew(int n){for(int i=0;i<n;i++){chunk=new @@CHUNK@@(Spec.Levels,channels.AsSpan());sum=unchecked(sum+Raw(chunk.GetChannel(0).Get(0,0,0)));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunChunkFrom(int n){for(int i=0;i<n;i++){chunk=@@CHUNK@@.FromEncoded(packet);sum=unchecked(sum+Raw(chunk.GetChannel(0).Get(0,0,0)));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunChunkValidate(int n){for(int i=0;i<n;i++)sum=unchecked(sum+(new @@CHUNKSPAN@@(packet).IsWellFormed()?1:0));}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunChunkUpdate(int n){for(int i=0;i<n;i++){chunk=chunk.WithDenseChannel(0,values);sum=unchecked(sum+Raw(chunk.GetChannel(0).Get(0,0,0)));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunChunkDense(int n){for(int i=0;i<n;i++){chunk=@@CHUNK@@.FromDense(Spec.Levels,1,values);sum=unchecked(sum+Raw(chunk.GetChannel(0).Get(0,0,0)));}}
 @@LOOKUP_METHODS@@
 public ValidationResult Validate(){CheckState();long expected=Spec.Op switch{
  "get" or "lookup-get"=>InputData.Expected(completed,pointPrefix),"lod" or "lookup-lod"=>InputData.Expected(completed,lodPrefix),
  "validate"=>Spec.Dataset is "ME" or "ML"?0:completed,"chunk-validate"=>completed,"count"=>unchecked(completed*zeros),"any"=>0,
  "copy"=>unchecked(completed*raw[17]),"create"=>@@CREATE_EXPECTED@@,"lifecycle"=>unchecked(completed*lifeFold),_=>unchecked(completed*first)};
  return new ValidationResult(sum==expected);}
 public object Fingerprint()=>new{id=Spec.Id,inputHash=Describe().InputHash,rawSha256=InputData.Hash(System.Runtime.InteropServices.MemoryMarshal.AsBytes(raw.AsSpan())),validEncodedSha256=InputData.Hash(validEncoded),inputEncodedSha256=InputData.Hash(encoded),packetSha256=InputData.Hash(packet),sum,completed,primary=Spec.Primary,operations=Spec.Operations};
 public void Cleanup(){store?.Cleanup();}
}
'''

classic=dict(CLASS='ClassicCase',CONSTRAINT='',CTOR='ClassicCase',VALUE='uint',TREE='Octree',SPAN='OctreeSpan',CHUNK='OctreeChunk',CHUNKSPAN='OctreeChunkSpan',WORLD='WorldEntity',FILTER='VoxelFilter',TYPE_CHECK='',
CONVERSIONS='[MethodImpl(MethodImplOptions.AggressiveInlining)]static uint Value(ushort v)=>v; [MethodImpl(MethodImplOptions.AggressiveInlining)]static uint Raw(uint v)=>v;',
LOOKUP_FIELD='OctreeLookup lookup=null!;',LOOKUP_INIT='lookup=tree.CreateLookup();',LOOKUP_CHECK='if(lookup.StorageBytes!=(Spec.Dataset=="E"?4:validEncoded.Length))throw new Exception("Independent snapshot size");',
LOOKUP_SWITCH='case "create":RunCreate(count);break;case "lookup-get":RunLookupGet(count);break;case "lookup-lod":RunLookupLod(count);break;',
CREATE_EXPECTED='unchecked(completed*(Spec.Dataset=="E"?4:validEncoded.Length))',
LOOKUP_METHODS=r'''
 [MethodImpl(MethodImplOptions.NoInlining)]void RunCreate(int n){for(int i=0;i<n;i++){lookup=tree.CreateLookup();sum=unchecked(sum+lookup.StorageBytes);}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunLookupGet(int n){int l=Spec.Levels,mask=(1<<l)-1;for(int i=0;i<n;i++){int p=InputData.Index(position++&1023,raw.Length);sum=unchecked(sum+lookup.Get(p>>(l*2),(p>>l)&mask,p&mask));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunLookupLod(int n){int l=Spec.Levels,mask=(1<<l)-1;for(int i=0;i<n;i++){int p=InputData.Index(position++&1023,raw.Length);var v=lookup.Get(p>>(l*2),(p>>l)&mask,p&mask,out int lod);sum=unchecked(sum+v+((long)lod<<32));}}
 [MethodImpl(MethodImplOptions.NoInlining)]void RunLifecycle(int n){int l=Spec.Levels,mask=(1<<l)-1;for(int i=0;i<n;i++){lookup=tree.CreateLookup();for(int j=0;j<65536;j++){int p=j&(raw.Length-1);var v=lookup.Get(p>>(l*2),(p>>l)&mask,p&mask,out int lod);sum=unchecked(sum+v+((long)lod<<32));}}}
''')
generic=dict(CLASS='GenericCase<T>',CONSTRAINT='where T:unmanaged ',CTOR='GenericCase',VALUE='T',TREE='Octree<T>',SPAN='OctreeSpan<T>',CHUNK='OctreeChunk<T>',CHUNKSPAN='OctreeChunkSpan<T>',WORLD='WorldEntity<T>',FILTER='VoxelFilter<T>',
TYPE_CHECK='if(typeof(T)!=typeof(ushort)&&typeof(T)!=typeof(uint))throw new ArgumentException("Selected fixture types only");',
CONVERSIONS='[MethodImpl(MethodImplOptions.AggressiveInlining)]static T Value(ushort v){T r=default;if(Unsafe.SizeOf<T>()==2)Unsafe.As<T,ushort>(ref r)=v;else Unsafe.As<T,uint>(ref r)=v;return r;} [MethodImpl(MethodImplOptions.AggressiveInlining)]static uint Raw(T v)=>Unsafe.SizeOf<T>()==2?Unsafe.As<T,ushort>(ref v):Unsafe.As<T,uint>(ref v);',
LOOKUP_FIELD='',LOOKUP_INIT='',LOOKUP_CHECK='',LOOKUP_SWITCH='',CREATE_EXPECTED='throw new Exception("No generic compiled lookup")',
LOOKUP_METHODS=r'''
 [MethodImpl(MethodImplOptions.NoInlining)]void RunLifecycle(int n){int l=Spec.Levels,mask=(1<<l)-1;for(int i=0;i<n;i++){tree=Octree<T>.FromEncoded(encoded);for(int j=0;j<65536;j++){int p=j&(raw.Length-1);var v=tree.Get(p>>(l*2),(p>>l)&mask,p&mask,out int lod);sum=unchecked(sum+Raw(v)+((long)lod<<32));}}}
''')
def emit(replacements):
    s=template
    for key,value in replacements.items():s=s.replace('@@'+key+'@@',value)
    # Generic constraints follow the interface list in C# declarations.
    s=s.replace('GenericCase<T> where T:unmanaged :INormalCase','GenericCase<T>:INormalCase where T:unmanaged ')
    assert '@@' not in s
    return s
source=(research/'Scenarios-compact-leaf.cs.txt').read_text(encoding='utf-8-sig')
at=source.index('public static class ForcecraftCorpus')
output.write_text(header+emit(classic)+emit(generic)+'\n'+source[at:],encoding='utf-8',newline='\n')
print('Version25 fixture generated:107 cases,23 targets,84 guards; generic lookup creation omitted')
