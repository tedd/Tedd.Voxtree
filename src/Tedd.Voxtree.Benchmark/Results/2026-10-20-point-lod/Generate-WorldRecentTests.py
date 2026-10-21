"""Generate public-state/cache-order differential tests against published source."""
from pathlib import Path
p=Path(__file__).with_name('WorldRecentTests-v2.cs.txt');assert not p.exists()
s='''using System.Reflection;
using Tedd.Voxtree;
using Before=Snapshot.Voxtree;
namespace Tedd.Voxtree.Tests;
public sealed class WorldRecentTests {
 private const BindingFlags Fields=BindingFlags.NonPublic|BindingFlags.Instance;
 private static object Map(object world)=>world.GetType().GetField("_chunks",Fields)!.GetValue(world)!;
 private static object Field(object obj,string name)=>obj.GetType().GetField(name,Fields)!.GetValue(obj)!;
 private static void CompareMap(object a,object b){
  a=Map(a);b=Map(b);
  foreach(var name in new[]{"_recentCount","_access","_estimatedBytes"})Assert.Equal(Field(b,name),Field(a,name));
  Assert.Equal((int[])Field(b,"_lookup"),(int[])Field(a,"_lookup"));
  int n=(int)Field(a,"_recentCount");var aa=(Array)Field(a,"_recent");var bb=(Array)Field(b,"_recent");
  for(int j=0;j<n;j++){
   object av=aa.GetValue(j)!,bv=bb.GetValue(j)!;
   Assert.Equal(Field(bv,"Coordinate").ToString(),Field(av,"Coordinate").ToString());
   foreach(var name in new[]{"LodLevel","Hash","Access"})Assert.Equal(Field(bv,name),Field(av,name));
  }
 }
'''
t='''
 [Fact] public void WIDTHExactResidencyAndRecentOrder(){
  var a=new WorldTYPE(1,2);var b=new Before.WorldTYPE(1,2);
  var random=new Random(20261113);
  for(int step=0;step<6000;step++){
   int index=random.Next(32),lod=random.Next(2)*3;long x=index-16;
   if(step%131==0)x=long.MinValue/8;
   var address=new ChunkAddress(lod,x,0,0);var control=new Before.ChunkAddress(lod,x,0,0);
   if(step==1000){foreach(var world in new object[]{a,b}){var m=Map(world);m.GetType().GetField("_access",Fields)!.SetValue(m,ulong.MaxValue-8);}}
   switch(random.Next(9)){
    case 0:case 1:case 2:
     var values=new VALUE[]{(VALUE)(step+1),(VALUE)(step+101)};
     a.SetChunk(address,ChunkTYPE.FromDense(0,2,values));b.SetChunk(control,Before.ChunkTYPE.FromDense(0,2,values));break;
    case 3:Assert.Equal(b.RemoveChunk(control),a.RemoveChunk(address));break;
    case 4:
     if(step%17==0){a.Clear();b.Clear();}else{
      Assert.Equal(b.TryGetChunk(control,out var bc),a.TryGetChunk(address,out var ac));
      if(ac is not null)Assert.Equal(bc!.GetChannel(0).Get(0,0,0),ac.GetChannel(0).Get(0,0,0));
     }break;
    case 5:case 6:
     Assert.Equal(b.TryGetChunk(new Before.ChunkCoordinate(x,0,0),out var bb),a.TryGetChunk(new ChunkCoordinate(x,0,0),out var ab));
     if(ab is not null)Assert.Equal(bb!.GetChannel(1).Get(0,0,0),ab.GetChannel(1).Get(0,0,0));break;
    case 7:
     Assert.Equal(b.TryGet(1,x,0,0,out var bv),a.TryGet(1,x,0,0,out var av));Assert.Equal(bv,av);break;
    default:
     Assert.Equal(b.TryGetLod(3,0,x<<3,0,0,out var bl),a.TryGetLod(3,0,x<<3,0,0,out var al));Assert.Equal(bl,al);break;
   }
   // Immediate repeats exercise replacement/removal, LOD aliases and default misses.
   for(int repeat=0;repeat<2;repeat++)Assert.Equal(b.TryGetChunk(control,out _),a.TryGetChunk(address,out _));
   Assert.Equal(b.ChunkCount,a.ChunkCount);Assert.Equal(b.EstimatedResidentBytes,a.EstimatedResidentBytes);
   foreach(var kv in b.ResidentChunks){
    var key=kv.Key;Assert.True(a.TryGetChunkResidencyInfo(new ChunkAddress(key.LodLevel,key.X,key.Y,key.Z),out var ai));
    Assert.True(b.TryGetChunkResidencyInfo(key,out var bi));
    Assert.Equal(bi.LastAccessSequence,ai.LastAccessSequence);Assert.Equal(bi.EstimatedBytes,ai.EstimatedBytes);
    Assert.Equal(bi.IsDirty,ai.IsDirty);Assert.Equal(bi.IsImplicitEmpty,ai.IsImplicitEmpty);
   }
   CompareMap(a,b);
  }
 }
'''
for width,world,chunk,value in [('UInt32','WorldEntity','OctreeChunk','uint'),('UInt16','WorldEntity<ushort>','OctreeChunk<ushort>','ushort')]:
 s+=t.replace('WIDTH',width).replace('WorldTYPE',world).replace('ChunkTYPE',chunk).replace('VALUE',value)
s+='}\n';p.write_text(s);print(p)
