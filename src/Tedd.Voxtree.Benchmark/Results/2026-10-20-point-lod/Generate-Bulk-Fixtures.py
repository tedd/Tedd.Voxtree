"""Generate matched complete-operation callers; do not overwrite frozen fixtures."""
from pathlib import Path

here=Path(__file__).resolve().parent
output=here/'Scenarios-bulk.cs.txt'
if output.exists(): raise SystemExit('Bulk fixture exists; preserve its identity')
corpus=(here/'Scenarios-packed-leaf.cs.txt').read_text().split('public static class ForcecraftCorpus {',1)[1]
template=(here/'BulkScenarioTemplate.cs.txt').read_text()
prefix='''using System.Diagnostics;
using System.Runtime.CompilerServices;
using Tedd.DotNetLab.Contracts;
using Tedd.DotNetLab.Harness;
using Before = Snapshot.Voxtree;
using After = Tedd.Voxtree;
FixtureMode.Validation=args[0]=="--validate";
if(OperatingSystem.IsWindows())Process.GetCurrentProcess().ProcessorAffinity=(nint)4;
var registry=new ScenarioRegistry();
foreach(var pattern in new[]{"mixed-u16-air","mixed-u7-air","mixed-u8-air","uniform-u7-empty"})
foreach(var op in new[]{"construct","build","callerbuild","trybuild","required","fromencoded","copy","validate","count","miss","buildread"})
{registry.Register(new BulkUInt32Scenario(pattern,op));registry.Register(new BulkUInt16Scenario(pattern,op));}
if(args[0]=="--validate"){
 foreach(var d in registry.Describe()){
  var scenario=(ISynchronousScenario)registry.Get(d.Id);
  foreach(var variant in new[]{"baseline","candidate"}){
   scenario.Prepare(new ScenarioContext(variant,CancellationToken.None));scenario.Reset(new ResetContext(ResetLevel.LogicalState));
   scenario.ExecuteBatch(2);if(!scenario.Validate().Correct)throw new Exception(d.Id+variant);scenario.Cleanup();
  }
  Console.WriteLine(d.Id+" valid");
 }
 return;
}
var host=new HarnessHost(registry,args[1]);
if(args[0]=="--harness-owned"||Environment.GetEnvironmentVariable("DOTNET_EnableDiagnostics")=="0")await host.RunOwnedAsync();
else{
 Console.WriteLine(Wire.Serialize(host.Target));using var cancel=new CancellationTokenSource();
 _=Task.Run(async()=>{await Console.In.ReadLineAsync();cancel.Cancel();});await host.ListenAsync(cancel.Token);
}
public static class FixtureMode{public static bool Validation;}
'''

def batch(name,tree,obj,ns,typ):
    filter_type=f'{ns}.VoxelFilter'+('<ushort>' if typ=='ushort' else '')
    operations={
      'construct':f'{obj}=new {tree}(5,values);sum=unchecked(sum+(long){obj}.Get(0,0,0));',
      'build':f'{obj}.Build(values);sum=unchecked(sum+(long){obj}.Get(0,0,0));',
      'callerbuild':f'sum=unchecked(sum+{tree}.Build(values,5,buffer));',
      'trybuild':f'if(!{tree}.TryBuild(values,5,buffer,out int written))throw new Exception("Build failed");sum=unchecked(sum+written);',
      'required':f'sum=unchecked(sum+{tree}.GetRequiredSize(values,5));',
      'fromencoded':f'{obj}={tree}.FromEncoded(original{name});sum=unchecked(sum+(long){obj}.Get(0,0,0));',
      'copy':f'{obj}.CopyTo(destination);sum=unchecked(sum+(long)destination[2047]);',
      'validate':f'if(!{obj}.AsSpan().IsWellFormed())throw new Exception("Validation failed");sum=unchecked(sum+1);',
      'count':f'sum=unchecked(sum+{obj}.CountMatches(new {ns}.VoxelBox(0,0,0,32,32,32),{filter_type}.EqualTo(0)));',
      'miss':f'sum=unchecked(sum+{obj}.CountMatches(new {ns}.VoxelBox(0,0,0,32,32,32),{filter_type}.EqualTo(65535)));',
      'buildread':f'{obj}=new {tree}(5,values);for(int j=0;j<65536;j++){{int p=j&32767;var value={obj}.Get(p/1024,p/32%32,p%32,out int lod);sum=unchecked(sum+(long)value+((long)lod<<32));}}'
    }
    return f'[MethodImpl(MethodImplOptions.NoInlining)] void {name}Batch(int count){{switch(op){{'+''.join(f'case "{op}":for(int i=0;i<count;i++){{{body}}}return;' for op,body in operations.items())+'default:throw new Exception("Unknown bulk op");}}'

parts=[prefix]
for typ,width,suffix in [('uint','UInt32',''),('ushort','UInt16','<ushort>')]:
    before='Before.Octree'+suffix;after='After.Octree'+suffix
    text=template
    replacements={'@CLASS@':'Bulk'+width+'Scenario','@TYPE@':typ,'@WIDTH@':width,
                  '@BEFORETREE@':before,'@AFTERTREE@':after,
                  '@BATCHES@':batch('Before',before,'before','Before',typ)+'\n'+batch('After',after,'after','After',typ)}
    for key,value in replacements.items(): text=text.replace(key,value)
    if '@' in text: raise RuntimeError('Unresolved fixture placeholder')
    parts.append(text)
parts.append('public static class ForcecraftCorpus {'+corpus)
output.write_text('\n'.join(parts),encoding='utf-8')
