"""Retain exact original map oracle and add independent collision/reachability cases."""
from pathlib import Path
research=Path(__file__).resolve().parent;p=research/'CacheMaintenanceTests.cs.txt';assert not p.exists()
s=(research/'WorldRecentTests-v2.cs.txt').read_text()
s+='''

public sealed class CacheMaintenanceTests
{
 private const BindingFlags Hidden=BindingFlags.NonPublic|BindingFlags.Instance;
 private static object Map(object world)=>world.GetType().GetField("_chunks",Hidden)!.GetValue(world)!;
 private static object Field(object value,string name)=>value.GetType().GetField(name,Hidden)!.GetValue(value)!;
 private static void SameMaps(object a,object b)
 {
  foreach(var name in new[]{"_recentCount","_access","_estimatedBytes"})Assert.Equal(Field(b,name),Field(a,name));
  var aa=(int[])Field(a,"_lookup");var bb=(int[])Field(b,"_lookup");Assert.Equal(bb,aa);
  int n=(int)Field(a,"_recentCount");var ar=(Array)Field(a,"_recent");var br=(Array)Field(b,"_recent");
  var seen=new bool[n];
  foreach(int encoded in aa)if(encoded!=0){Assert.InRange(encoded,1,n);Assert.False(seen[encoded-1]);seen[encoded-1]=true;}
  Assert.All(seen,Assert.True);
  for(int j=0;j<n;j++){
   object x=ar.GetValue(j)!,y=br.GetValue(j)!;
   foreach(var name in new[]{"Hash","LodLevel","Access"})Assert.Equal(Field(y,name),Field(x,name));
   Assert.Equal(Field(y,"Coordinate").ToString(),Field(x,"Coordinate").ToString());
   int slot=(int)Field(x,"Hash")&15;int probes=0;
   while(aa[slot]!=j+1){Assert.NotEqual(0,aa[slot]);Assert.True(++probes<16);slot=(slot+1)&15;}
  }
 }
 private static ChunkAddress[] Colliders(int home,int count)
 {
  var result=new List<ChunkAddress>();var hashes=new HashSet<int>();
  for(long i=0;result.Count<count&&i<1000000;i++){
   var key=new ChunkAddress((int)(i&1)*3,i*104729-500000,long.MinValue/4+i,7);
   int hash=key.GetHashCode();
   if((hash&15)==home&&hashes.Add(hash)){
    Assert.Equal(hash,new Before.ChunkAddress(key.LodLevel,key.X,key.Y,key.Z).GetHashCode());result.Add(key);
   }
  }
  Assert.Equal(count,result.Count);return result.ToArray();
 }
 [Theory][InlineData(0)][InlineData(7)][InlineData(15)]
 public void PublicCollisionFamiliesKeepExactValuesRecencyAndProbeCounts(int home)
 {
  var keys=Colliders(home,32);var a=new WorldEntity(1,2);var b=new Before.WorldEntity(1,2);
  var c=new WorldEntity<ushort>(1,2);var d=new Before.WorldEntity<ushort>(1,2);
  var ma=Map(a);var mb=Map(b);var mc=Map(c);var md=Map(d);var random=new Random(20261115+home);
  for(int step=0;step<8000;step++){
   var key=keys[random.Next(keys.Length)];var control=new Before.ChunkAddress(key.LodLevel,key.X,key.Y,key.Z);
   if(step==2000)foreach(var map in new[]{ma,mb,mc,md})map.GetType().GetField("_access",Hidden)!.SetValue(map,ulong.MaxValue-8);
   switch(random.Next(6)){
    case 0:case 1:
     uint v=(uint)(step+1);var values=new uint[]{v,v+100};var words=new ushort[]{(ushort)v,(ushort)(v+100)};
     a.SetChunk(key,OctreeChunk.FromDense(0,2,values));b.SetChunk(control,Before.OctreeChunk.FromDense(0,2,values));
     c.SetChunk(key,OctreeChunk<ushort>.FromDense(0,2,words));d.SetChunk(control,Before.OctreeChunk<ushort>.FromDense(0,2,words));break;
    case 2:Assert.Equal(b.RemoveChunk(control),a.RemoveChunk(key));Assert.Equal(d.RemoveChunk(control),c.RemoveChunk(key));break;
    default:if(step%977==0){a.Clear();b.Clear();c.Clear();d.Clear();}break;
   }
   Assert.Equal(b.TryGetChunk(control,out var bv),a.TryGetChunk(key,out var av));
   Assert.Equal(d.TryGetChunk(control,out var dv),c.TryGetChunk(key,out var cv));
   if(av is not null)for(int channel=0;channel<2;channel++){
    Assert.Equal(bv!.GetChannel(channel).Get(0,0,0),av.GetChannel(channel).Get(0,0,0));
    Assert.Equal(dv!.GetChannel(channel).Get(0,0,0),cv!.GetChannel(channel).Get(0,0,0));
   }
   Assert.Equal(b.ChunkCount,a.ChunkCount);Assert.Equal(d.ChunkCount,c.ChunkCount);
   SameMaps(ma,mb);SameMaps(mc,md);
   foreach(var entry in b.ResidentChunks){var k=entry.Key;
    Assert.True(a.TryGetChunkResidencyInfo(new ChunkAddress(k.LodLevel,k.X,k.Y,k.Z),out var x));
    Assert.True(b.TryGetChunkResidencyInfo(k,out var y));Assert.Equal(y.LastAccessSequence,x.LastAccessSequence);
    Assert.Equal(y.EstimatedBytes,x.EstimatedBytes);Assert.Equal(y.IsDirty,x.IsDirty);
   }
  }
 }
 [Theory][InlineData(1)][InlineData(10)][InlineData(16)]
 public void InternalCapacitiesIncludingFullTableKeepCanonicalLookup(int capacity)
 {
  var typeA=Map(new WorldEntity(1,1)).GetType();var typeB=Map(new Before.WorldEntity(1,1)).GetType();
  var a=Activator.CreateInstance(typeA,Hidden,null,new object[]{capacity},null)!;
  var b=Activator.CreateInstance(typeB,Hidden,null,new object[]{capacity},null)!;
  var setA=typeA.GetMethod("Set",Hidden)!;var setB=typeB.GetMethod("Set",Hidden)!;
  var getA=typeA.GetMethods(Hidden).Single(m=>m.Name=="TryGetValue"&&m.GetParameters()[0].ParameterType==typeof(ChunkAddress));
  var getB=typeB.GetMethods(Hidden).Single(m=>m.Name=="TryGetValue"&&m.GetParameters()[0].ParameterType==typeof(Before.ChunkAddress));
  var first=OctreeChunk.FromDense(0,1,new uint[]{77});var second=Before.OctreeChunk.FromDense(0,1,new uint[]{77});
  var keys=Colliders(15,capacity+7);var random=new Random(20261115+capacity);
  for(int step=0;step<4000;step++){
   var key=keys[random.Next(keys.Length)];var control=new Before.ChunkAddress(key.LodLevel,key.X,key.Y,key.Z);
   if(step==2000)foreach(var map in new[]{a,b})map.GetType().GetField("_access",Hidden)!.SetValue(map,ulong.MaxValue-8);
   setA.Invoke(a,new object[]{key,first,(long)first.SerializedLength,true,false});
   setB.Invoke(b,new object[]{control,second,(long)second.SerializedLength,true,false});
   object?[] aa={key,null};object?[] bb={control,null};Assert.Equal(getB.Invoke(b,bb),getA.Invoke(a,aa));
   Assert.Same(first,aa[1]);Assert.Same(second,bb[1]);SameMaps(a,b);
   if(step%257==0){Assert.Equal(typeB.GetMethod("Remove",Hidden)!.Invoke(b,new object[]{control}),typeA.GetMethod("Remove",Hidden)!.Invoke(a,new object[]{key}));SameMaps(a,b);}
   if(step%1009==0){typeA.GetMethod("Clear",Hidden)!.Invoke(a,null);typeB.GetMethod("Clear",Hidden)!.Invoke(b,null);SameMaps(a,b);}
  }
 }
}
'''
p.write_text(s);print(p)
