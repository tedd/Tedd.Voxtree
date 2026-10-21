"""Fresh P35 source and version20 fixture; no execution or old prototype reuse."""
import hashlib,json,subprocess,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;repo=research.parents[3]
source=root/'world-layer-source';assert not source.exists();source.mkdir()
files=subprocess.check_output(['git','-C',str(repo),'ls-tree','-r','--name-only','f0772c8','--','src/Tedd.Voxtree'],text=True).splitlines()
for f in files:
 if f.endswith('.cs'):(source/Path(f).name).write_bytes(subprocess.check_output(['git','-C',str(repo),'show','f0772c8:'+f]))
p=source/'WorldEntity.cs';s=p.read_text()
def change(a,b,n=1):
 global s
 assert s.count(a)==n,(a,s.count(a),n);s=s.replace(a,b)
change('    private ulong _access;','    private ulong _access;\n    private ulong _seenLodLevels;')
for signature,bit in [('ChunkCoordinate coordinate','1UL'),('ChunkAddress address','(1UL << address.LodLevel)')]:
 anchor=f'    internal bool TryGetValue({signature}, out TChunk? value)\n    {{\n'
 change(anchor,anchor+f'''        if ((_seenLodLevels & {bit}) == 0)
        {{
            value = null;
            return false;
        }}

''')
change('        _items[address] = value;','        _items[address] = value;\n        _seenLodLevels |= 1UL << address.LodLevel;')
change('        _access = 0;','        _access = 0;\n        _seenLodLevels = 0;')
p.write_text(s)
(root/'p35-source-hashes.json').write_text(json.dumps({p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(source.glob('*.cs'))},indent=2)+'\n')
fixture=research/'Scenarios-world-layer.cs.txt';assert not fixture.exists()
t=(research/'Scenarios-world-recent.cs.txt').read_text()
def fixture_change(a,b,n=1):
 global t
 assert t.count(a)==n,(a,t.count(a),n);t=t.replace(a,b)
fixture_change('new[]{"get","lod","chunk","topology"}','new[]{"get","lod","chunk","topology","absent"}')
fixture_change('new[]{"repeated","blocks32","alternating","cycle12","miss"}','new[]{"repeated","blocks32","alternating","cycle12","miss","saturated"}')
fixture_change('"19",','"20",',2)
fixture_change('"repeated"=>0,','"repeated"=>0,"saturated"=>0,',2)
fixture_change('long expected=index>=12?0:','long expected=op=="absent"||index>=12?0:',2)
for world,chunk,value in [('WorldEntity','OctreeChunk','uint'),('WorldEntity<ushort>','OctreeChunk<ushort>','ushort')]:
 anchor='''  for(int j=0;j<points.Length;j++){'''
 # Replace the matching class section only; both classes share the same anchor.
 start=t.index('public sealed class WorldUInt32') if value=='uint' else t.index('public sealed class WorldUInt16')
 pos=t.index(anchor,start)
 extra=f'''  if(pattern=="saturated"){{
   var values=new {value}[]{{1,101}};
   var a={chunk}.FromDense(0,2,values);var b=Before.{chunk}.FromDense(0,2,values);
   foreach(int level in new[]{{1,2,4,5,6,7}}){{
    world.SetLodChunk(level,50,0,0,a);before.SetLodChunk(level,50,0,0,b);
    world.RemoveChunk(new ChunkAddress(level,50,0,0));before.RemoveChunk(new Before.ChunkAddress(level,50,0,0));
   }}
  }}
'''
 t=t[:pos]+extra+t[pos:]
 for arm,w in [('Before','before'),('After','world')]:
  end=t.index('throw new Exception();}',t.index(f'private void {arm}Batch(int count)',start))
  extra=f'''if(op=="absent"){{for(int i=0;i<count;i++){{int j=position++&1023,x=points[j],channel=(j>>1)&1;bool found={w}.TryGetLod(2,channel,(long)x<<2,0,0,out {value} result);sum=unchecked(sum+(long)result+(found?65536:0));}}return;}}
'''
  t=t[:end]+extra+t[end:]
fixture.write_text(t)
print(json.dumps({'source':str(source),'files':len(list(source.glob('*.cs'))),'fixture':str(fixture),'cases':60,'changed':['WorldEntity.cs']}))
