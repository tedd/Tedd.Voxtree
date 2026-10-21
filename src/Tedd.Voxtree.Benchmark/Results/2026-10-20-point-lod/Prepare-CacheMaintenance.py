"""Fresh P36 source; separate-operation version21 semantic/native fixture."""
import hashlib,json,subprocess,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;repo=research.parents[3]
model=json.loads((root/'p36-model-audit.json').read_text());assert model['passed'] and model['counts']=={'exhaustive':149476,'actualSize':128000}
source=root/'cache-maintenance-source';assert not source.exists();source.mkdir()
files=subprocess.check_output(['git','-C',str(repo),'ls-tree','-r','--name-only','f0772c8','--','src/Tedd.Voxtree'],text=True).splitlines()
for f in files:
 if f.endswith('.cs'):(source/Path(f).name).write_bytes(subprocess.check_output(['git','-C',str(repo),'show','f0772c8:'+f]))
p=source/'WorldEntity.cs';s=p.read_text()
anchor='''            for (var candidate = 1; candidate < _recentCount; candidate++)
                if (_recent[candidate].Access < _recent[index].Access) index = candidate;
'''
assert s.count(anchor)==1;s=s.replace(anchor,anchor+'            RemoveRecentLookup(index);\n')
anchor='''        _recent[index] = new CacheEntry(address, hash, value, state);
        RebuildLookup();
'''
assert s.count(anchor)==1;s=s.replace(anchor,'''        _recent[index] = new CacheEntry(address, hash, value, state);
        InsertRecentLookup(index, hash);
''')
anchor='    private void RebuildLookup()\n'
assert s.count(anchor)==1
helpers='''    private void RemoveRecentLookup(int index)
    {
        var slot = _recent[index].Hash & LookupMask;
        while (_lookup[slot] != index + 1) slot = (slot + 1) & LookupMask;
        var hole = slot;
        var scan = (hole + 1) & LookupMask;
        // Move only entries whose probe interval crosses the hole. The bound
        // also handles a full table without relying on an existing empty slot.
        for (var probe = 0; probe < LookupSize - 1; probe++)
        {
            var encoded = _lookup[scan];
            if (encoded == 0) break;
            var home = _recent[encoded - 1].Hash & LookupMask;
            if (((scan - home) & LookupMask) >= ((scan - hole) & LookupMask))
            {
                _lookup[hole] = encoded;
                hole = scan;
            }
            scan = (scan + 1) & LookupMask;
        }
        _lookup[hole] = 0;
    }

    private void InsertRecentLookup(int index, int hash)
    {
        var encoded = index + 1;
        var slot = hash & LookupMask;
        while (_lookup[slot] != 0)
        {
            var existing = _lookup[slot];
            // Earlier indexes have priority, matching RebuildLookup's order.
            // Preserve each key's probe count instead of appending replacements.
            if (existing > encoded)
            {
                _lookup[slot] = encoded;
                encoded = existing;
            }
            slot = (slot + 1) & LookupMask;
        }
        _lookup[slot] = encoded;
    }

'''
s=s.replace(anchor,helpers+anchor);p.write_text(s)
(root/'p36-source-hashes.json').write_text(json.dumps({p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(source.glob('*.cs'))},indent=2)+'\n')

fixture=research/'Scenarios-cache-maintenance.cs.txt';assert not fixture.exists()
t=(research/'Scenarios-world-recent.cs.txt').read_text()
def change(a,b,n=1):
 global t
 assert t.count(a)==n,(a,t.count(a),n);t=t.replace(a,b)
change('new[]{"repeated","blocks32","alternating","cycle12","miss"}','new[]{"repeated","blocks32","alternating","cycle10","cycle12","miss"}')
change('"19",','"21",',2);change('"cycle12"=>j%12,','"cycle10"=>j%10,"cycle12"=>j%12,',2)
change('primeMs=3000,consumer=', 'primeMs=1000,callerShape="separate-operation-methods",consumer=',2)
change('sw.ElapsedMilliseconds<3000','sw.ElapsedMilliseconds<1000',2)
change('Initialize();baseline=c.Variant=="baseline";','''Initialize();
#if PRIMARY_BASELINE_CALLER
 baseline=false;
#else
 baseline=c.Variant=="baseline";
#endif
''',2)
change('public long ExecuteBatch(int count){if(baseline)BeforeBatch(count);else AfterBatch(count);completed+=count;return count;}','''public long ExecuteBatch(int count){
#if PRIMARY_BASELINE_CALLER
 AfterBatch(count);
#else
 if(baseline)BeforeBatch(count);else AfterBatch(count);
#endif
 completed+=count;return count;}''',2)
def closing(text,start):
 depth=0
 for pos in range(start,len(text)):
  if text[pos]=='{':depth+=1
  elif text[pos]=='}':
   depth-=1
   if depth==0:return pos
 raise AssertionError('Unclosed fixture method')
for width in ['UInt32','UInt16']:
 for arm in ['Before','After']:
  class_start=t.index('public sealed class World'+width)
  marker=f'[MethodImpl(MethodImplOptions.NoInlining)] private void {arm}Batch(int count)'
  start=t.index(marker,class_start);brace=t.index('{',start);end=closing(t,brace)
  body=t[brace+1:end];methods=[];cases=[]
  for op in ['get','lod','chunk','topology']:
   token=f'if(op=="{op}")';a=body.index(token);b=body.index('{',a);c=closing(body,b)
   name=arm+op.title();methods.append(f'[MethodImpl(MethodImplOptions.NoInlining)] private void {name}(int count)'+body[b:c+1])
   cases.append(f'case "{op}": {name}(count); return;')
  replacement=marker+'{switch(op){'+''.join(cases)+'default:throw new Exception();}}\n'+'\n'.join(methods)
  t=t[:start]+replacement+t[end+1:]
fixture.write_text(t)
print(json.dumps({'source':str(source),'files':len(list(source.glob('*.cs'))),'fixture':str(fixture),'cases':48,'changed':['WorldEntity.cs']}))
