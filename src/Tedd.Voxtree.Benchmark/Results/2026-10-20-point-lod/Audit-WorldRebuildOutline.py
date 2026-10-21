"""Audit the original P38 source/IL/correctness/native feasibility evidence."""
import difflib,hashlib,json,subprocess,sys,xml.etree.ElementTree as ET
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;repo=research.parents[3]
out=root/'p38-prerequisite-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
completion=read(root/'p38-feasibility-driver-completed.json')
assert completion['driverExitedNormally'] and completion['comparativeTimingRecords']==0
assert not (root/'p38-feasibility-driver-failure.log').exists()
driver=read(root/'p38-feasibility-driver-start.json')
assert sha(root/'p38-driver-source/Run-WorldRebuildFeasibility.ps1')==driver['driverSha256'].lower()
for name,h in driver['dependencies'].items():
 assert sha(root/'p38-driver-source'/name)==h.lower()==sha(research/name)
manifest=read(root/'p38-source-hashes.json');assert len(manifest)==3
attribute=b'    [MethodImpl(MethodImplOptions.NoInlining)]'
changed=[]
for name,h in manifest['rebuild-outline-published-source'].items():
 old=subprocess.check_output(['git','-C',str(repo),'show','f0772c8:src/Tedd.Voxtree/'+name])
 assert (root/'rebuild-outline-published-source'/name).read_bytes()==old
 assert sha(root/'rebuild-outline-published-source'/name)==h
 candidate=(root/'rebuild-outline-source'/name).read_bytes()
 assert sha(root/'rebuild-outline-source'/name)==manifest['rebuild-outline-source'][name]
 assert (root/'rebuild-outline-control-source'/name).read_bytes()==old.replace(b'Tedd.Voxtree',b'Snapshot.Voxtree')
 assert sha(root/'rebuild-outline-control-source'/name)==manifest['rebuild-outline-control-source'][name]
 if candidate!=old:
  changed.append(name);newline=b'\r\n' if b'\r\n' in old else b'\n'
  anchor=b'    private void RebuildLookup()'
  assert candidate.count(attribute+newline+anchor)==1
  assert candidate.replace(attribute+newline+anchor,anchor)==old
 assert (root/'p38n0-source'/name).read_bytes()==old
 assert (root/'p38n1-source'/name).read_bytes()==candidate
assert len(manifest['rebuild-outline-source'])==53 and changed==['WorldEntity.cs']
old=(root/'rebuild-outline-published-source/WorldEntity.cs').read_text()
new=(root/'rebuild-outline-source/WorldEntity.cs').read_text()
(root/'p38-source.diff').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='f0772c8/WorldEntity.cs',tofile='P38/WorldEntity.cs')))
library=read(root/'caller-audit-p38library.json');assert len(library)==2
key=lambda m:m['canonical']['signature']
before={key(m):m for m in library[0]['methods']};after={key(m):m for m in library[1]['methods']}
assert len(before)==len(library[0]['methods'])==len(after)==1203 and before.keys()==after.keys()
assert library[0]['publicSurface']==library[1]['publicSurface'] and len(library[0]['publicSurface'])==47
assert all(before[k]['rawIlSha256']==after[k]['rawIlSha256'] and before[k]['resolvedIlSha256']==after[k]['resolvedIlSha256'] for k in before)
flags=[k for k in before if before[k]['implementationFlags']!=after[k]['implementationFlags']]
assert len(flags)==1 and 'RecentChunkMap`1<TChunk>::RebuildLookup<>' in flags[0]
assert before[flags[0]]['implementationFlags']=='IL' and after[flags[0]]['implementationFlags']=='NoInlining'
callers=read(root/'caller-audit-p38world.json');assert len(callers)==2
assert all(len(v['methods'])==8 for v in callers)
for a,b in zip(callers[0]['methods'],callers[1]['methods']):
 assert key(a)==key(b) and a['resolvedIlSha256']==b['resolvedIlSha256'] and a['implementationFlags']==b['implementationFlags']
assert (root/'p38n0-source/Program.cs').read_bytes()==(root/'p38n1-source/Program.cs').read_bytes()==(research/'Scenarios-world-normal.cs.txt').read_bytes()
assert (root/'p38n0-source/Normal.csproj').read_bytes()==(root/'p38n1-source/Normal.csproj').read_bytes()
program=(root/'p38n0-source/Program.cs').read_text()
assert not any(s in program for s in ['Snapshot.','Before.','StorageOptions','SqlConnection','File.','Directory.'])
bundles=[]
for i,label in enumerate(['p38n0','p38n1']):
 bundle=root/'bundles'/label
 files={p.name:sha(p) for p in bundle.iterdir() if p.is_file()}
 assert set(files)=={'WorldNormal.dll','WorldNormal.deps.json','WorldNormal.runtimeconfig.json','Tedd.DotNetLab.Harness.dll','Tedd.DotNetLab.Contracts.dll','Tedd.DotNetLab.Transport.Local.dll','Tedd.MortonEncoding.dll'}
 assert files['WorldNormal.dll']==library[i]['sha256'].lower()==callers[i]['sha256'].lower()
 validation=read(root/(label+'-validation.json'))
 assert validation['exited'] and validation['exitCode']==0 and validation['cases']==48 and validation['arms']==2
 assert validation['entrySha256'].lower()==files['WorldNormal.dll']
 for f in read(root/(label+'-hashes.json')):assert sha(Path(f['Path']))==f['Hash'].lower()
 bundles.append(files)
assert bundles[0]['WorldNormal.dll']!=bundles[1]['WorldNormal.dll']
assert {k:v for k,v in bundles[0].items() if k!='WorldNormal.dll'}=={k:v for k,v in bundles[1].items() if k!='WorldNormal.dll'}
tests=[];ns={'t':'http://microsoft.com/schemas/VisualStudio/TeamTest/2010'}
for path in sorted((root/'packed-lookup-p38world-results').glob('*.trx')):
 tree=ET.parse(path);summary=tree.find('.//t:ResultSummary',ns);c=summary.find('t:Counters',ns).attrib
 assert summary.attrib['outcome']=='Completed' and c['total']==c['passed'] and int(c['failed'])==0
 tests.append(dict(file=path.name,sha256=sha(path),count=int(c['passed'])))
assert len(tests)==3 and sorted(t['count'] for t in tests)==[408,409,410]
options=read(root/'packed-lookup-test-options-p38world.json')
assert options['source']=='rebuild-outline-source' and options['baselineSource']=='rebuild-outline-control-source'
for name in manifest['rebuild-outline-source']:
 assert sha(root/'rebuild-outline-source'/name)==manifest['rebuild-outline-source'][name]
test_source=root/'packed-lookup-validation-p38world/tests'
assert (test_source/'PackedLookupTests.cs').read_bytes()==(research/'CacheMaintenanceTests.cs.txt').read_bytes()
assert (test_source/'ExtraReadTests.cs').read_bytes()==(research/'WorldLayerTests.cs.txt').read_bytes()
native=read(root/'native-summary-phase30-outline.json');assert len(native['listings'])==2
def one(methods,prefix):
 matches=[m for m in methods if m['method'].startswith(prefix) and m['method'].endswith('(Tier1)')]
 assert len(matches)==1 and matches[0]['listing_availability']=='complete',prefix
 return matches[0]
def clears(m):return [c for c in m['call_sites'] if any(t in c for t in ['ClearWithoutReferences','ClearWithReferences','System.Array:Clear'])]
for i,label in enumerate(['p38n0','p38n1']):
 listing=native['listings'][i];assert listing['file']==label+'-native.asm' and listing['sha256']==sha(root/listing['file'])
 identity=read(root/(label+'-native-identity.json'));shutdown=read(root/(label+'-native-shutdown.json'))
 assert identity['hash'].lower()==bundles[i]['WorldNormal.dll'] and identity['pid']==shutdown['pid']
 assert shutdown['exited'] and shutdown['exitCode']==0 and identity['scenario']=='cycle12'
 assert len([s for s in (root/(label+'-native-output.log')).read_text(encoding='utf-8-sig').splitlines() if s.endswith(' valid')])==8
candidate_helper=one(native['listings'][1]['methods'],'Tedd.Voxtree.RecentChunkMap`1[System.__Canon]:RebuildLookup(')
native_rows=[]
for width in ['UInt32','UInt16']:
 for op in ['Get','Lod','Chunk','Topology']:
  prefix=f'World{width}:After{op}('
  b=one(native['listings'][0]['methods'],prefix);a=one(native['listings'][1]['methods'],prefix)
  calls=[c for c in a['call_sites'] if ':RebuildLookup(' in c]
  native_rows.append(dict(width=width,operation=op,controlBytes=b['native_bytes'],candidateBytes=a['native_bytes'],
                          controlFixedRsp=b['rsp_subtractions'],candidateFixedRsp=a['rsp_subtractions'],
                          controlClearSites=clears(b),candidateClearSites=clears(a),candidateRebuildLookupCalls=calls,
                          gatePassed=bool(clears(b) and not clears(a) and calls and a['native_bytes']<b['native_bytes'] and max(a['rsp_subtractions'],default=0)<=max(b['rsp_subtractions'],default=0))))
passed=all(r['gatePassed'] for r in native_rows)
audit=dict(passed=passed,scope='P38 feasibility only, NoInlining on published RebuildLookup; no comparative timing or adoption.',
           sourceReversalExact=True,otherFilesByteIdentical=52,compiledSourcesExact=True,sourceManifestSha256=sha(root/'p38-source-hashes.json'),
           libraryIlBodiesUnchanged=1203,rawIlAndResolvedIlMatched=True,exportedTypesMatched=47,changedImplementationFlag=flags[0],
           callersMatched=8,semanticCasesPerModule=48,tests=tests,bundles=bundles,candidateRebuildLookup=candidate_helper,nativeCallers=native_rows,
           state='supported' if passed else 'not_supported',comparativeRecords=0,
           limits=['Supported refers only to this feasibility gate, not performance.','Native bytes/fixed rsp are not elapsed-time causes, total stack, all timed code versions or application frequency.','Every affected API/constructor/mutation/churn/storage/allocation/realistic-byte-consumer time guard and full10x qualification remains open.'])
out.write_text(json.dumps(audit,indent=2)+'\n')
print(json.dumps({k:v for k,v in audit.items() if k not in ['tests','bundles','nativeCallers','candidateRebuildLookup','limits']}))
