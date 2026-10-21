"""Complete P36 feasibility/source/native identity audit; no timing."""
import difflib,hashlib,json,re,subprocess,sys,xml.etree.ElementTree as ET
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path(__file__).resolve().parents[4];research=Path(__file__).resolve().parent;out=root/'p36-prerequisite-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
model=read(root/'p36-model-audit.json');assert model['passed'] and model['counts']=={'exhaustive':149476,'actualSize':128000}
assert model['sourceSha256']==sha(research/'Model-CacheMaintenance.py') and not (root/'p36-model-counterexample.json').exists()
source=root/'cache-maintenance-source';manifest=read(root/'p36-source-hashes.json');changed=[]
for name,h in manifest.items():
 assert sha(source/name)==h
 old_bytes=subprocess.check_output(['git','-C',str(repo),'show','f0772c8:src/Tedd.Voxtree/'+name]);old=old_bytes.decode().replace('\r\n','\n')
 text=(source/name).read_text()
 if text!=old:changed.append(name)
 else:assert (source/name).read_bytes()==old_bytes
 assert (root/'p36world/source'/name).read_text().rstrip()==text.rstrip()
 assert (root/'p36world-baseline'/name).read_text().rstrip()==old.replace('Tedd.Voxtree','Snapshot.Voxtree').rstrip()
assert len(manifest)==53 and changed==['WorldEntity.cs']
old=subprocess.check_output(['git','-C',str(repo),'show','f0772c8:src/Tedd.Voxtree/WorldEntity.cs']).decode().replace('\r\n','\n')
s=(source/'WorldEntity.cs').read_text();start=s.index('    private void RemoveRecentLookup(');end=s.index('    private void RebuildLookup()',start)
back=s[:start]+s[end:];assert back.count('            RemoveRecentLookup(index);\n')==1
back=back.replace('            RemoveRecentLookup(index);\n','').replace('        InsertRecentLookup(index, hash);','        RebuildLookup();');assert back==old
assert '_seenLodLevels' not in s and '_lastRecentIndex' not in s
diff=''.join(difflib.unified_diff(old.splitlines(True),s.splitlines(True),fromfile='f0772c8/WorldEntity.cs',tofile='P36/WorldEntity.cs'))
(root/'p36-source.diff').write_text(diff)
tests=[]
for p in sorted((root/'packed-lookup-p36world-results').glob('*.trx')):
 x=ET.parse(p);ns={'t':'http://microsoft.com/schemas/VisualStudio/TeamTest/2010'};summary=x.find('.//t:ResultSummary',ns);c=summary.find('t:Counters',ns).attrib
 assert summary.attrib['outcome']=='Completed' and int(c['failed'])==0 and c['total']==c['passed']
 tests.append({'file':p.name,'sha256':sha(p),'count':int(c['passed'])})
assert len(tests)==3 and sorted(v['count'] for v in tests)==[408,409,410]
validation=read(root/'p36-world-validation.json');assert validation['exited'] and validation['exitCode']==0 and validation['cases']==48
assert sha(root/'bundles/p36world/p36world.dll')==validation['entrySha256'].lower()
identity=read(root/'p36-cache-native-identity.json');assert identity['hash'].lower()==validation['entrySha256'].lower() and identity['scenario']=='cycle12'
shutdown=read(root/'p36-cache-native-shutdown.json');assert shutdown['exited'] and shutdown['exitCode']==0
native=root/'p36-cache-native.asm';summary=read(root/'native-summary-phase26-cache.json');assert summary['listings'][0]['sha256']==sha(native)
methods=summary['listings'][0]['methods'];complete={m['method']:m for m in methods if m['listing_availability']=='complete'}
def one(prefix):
 choices=[v for k,v in complete.items() if k.startswith(prefix) and k.endswith('(Tier1)')];assert len(choices)==1,prefix
 return choices[0]
def clears(m):return [c for c in m['call_sites'] if 'ClearWithoutReferences' in c or 'ClearWithReferences' in c or 'System.Array:Clear' in c]
before=one('Snapshot.Voxtree.RecentChunkMap`1[System.__Canon]:AddRecent(')
after=one('Tedd.Voxtree.RecentChunkMap`1[System.__Canon]:AddRecent(')
assert clears(before) and not clears(after) and not any('RebuildLookup' in c for c in after['call_sites'])
helpers=[one('Tedd.Voxtree.RecentChunkMap`1[System.__Canon]:'+name+'(') for name in ['RemoveRecentLookup','InsertRecentLookup']]
assert all(not clears(v) and not any('RebuildLookup' in c for c in v['call_sites']) for v in helpers)
callers=[]
for w in ['UInt32','UInt16']:
 for op in ['Get','Lod','Chunk','Topology']:
  b=one(f'World{w}:Before{op}(');a=one(f'World{w}:After{op}(');assert clears(b) and not clears(a)
  callers.append({'width':w,'operation':op,'controlMethod':b['method'],'candidateMethod':a['method'],'controlBytes':b['native_bytes'],'candidateBytes':a['native_bytes'],'controlFixedRsp':b['rsp_subtractions'],'candidateFixedRsp':a['rsp_subtractions'],'controlStaticClearSites':clears(b),'candidateStaticClearSites':clears(a)})
value={'passed':True,'scope':'P36 feasibility only; no comparative timing or source adoption.','model':model,'sourceFiles':53,'changedFiles':changed,'otherFilesByteIdentical':52,'sourceReversalExact':True,'fieldsAndReadBodiesUnchanged':True,'compiledSourcesMatch':True,'sourceManifestSha256':sha(root/'p36-source-hashes.json'),'tests':tests,'callerCases':48,'arms':2,'nativeSha256':sha(native),'baselineAddRecent':before,'candidateAddRecent':after,'candidateHelpers':helpers,'callers':callers,'limitations':['Static alternative ClearWithReferences/ClearWithoutReferences sites are not two executed clears.','Source hot reads unchanged; miss-path inlining changes caller layout/register allocation and can still affect hit timing.','Fixed rsp subtraction is not total stack usage; code size/logical writes do not establish speedup.','Separate operation methods/version21 form a new epoch; no P34/P35 timing is reused.']}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k not in ['model','tests','baselineAddRecent','candidateAddRecent','candidateHelpers','callers','limitations']}))
