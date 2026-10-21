"""Bind the original version25 normal modules and pre-timing evidence."""
import hashlib,json,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;out=root/'p39-normal-preflight.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
gate=read(root/'p39-prerequisite-audit.json');assert gate['passed'] and gate['comparativeTimingRecords']==0
origin=read(root/'p39-source-origin.json');assert len(origin['manifest'])==55
callers=read(root/'caller-audit-p39normalstorage.json');library=read(root/'caller-audit-p39normalstorage-library.json')
assert len(callers)==len(library)==2
assert all(len(i['methods'])==35 for i in callers)
for a,b in zip(callers[0]['methods'],callers[1]['methods']):
 assert a['canonical']['signature']==b['canonical']['signature'] and a['resolvedIlSha256']==b['resolvedIlSha256']
 assert a['implementationFlags']==b['implementationFlags'] and 'NoInlining' in a['implementationFlags']
key=lambda m:m['canonical']['signature']
before={key(m):m for m in library[0]['methods']};after={key(m):m for m in library[1]['methods']}
assert len(before)==len(after)==1236 and before.keys()==after.keys()
changed=[k for k in before if before[k]['resolvedIlSha256']!=after[k]['resolvedIlSha256']]
assert len(changed)==1 and 'CompactLeafEncoding`1<T>::ValidateCube<>' in changed[0]
assert all(before[k]['implementationFlags']==after[k]['implementationFlags'] for k in before)
assert library[0]['publicSurface']==library[1]['publicSurface']
tool_identity=read(root/'caller-audit-p39normalstorage-identity.json')
assert tool_identity['selftestPassed'] and tool_identity['toolSha256'].lower()==sha(root/'caller-audit-p39normalstorage/out/Audit.dll')
inventories=[];fingerprints=[];bundles=[];processes={};review=[]
for index,label in enumerate(['p39n2','p39n3']):
 folder=root/(label+'-source');bundle=root/'bundles'/label
 assert {p.name for p in folder.glob('*.cs')}=={r['file'] for r in origin['manifest']}|{'Program.cs'}
 for r in origin['manifest']:
  assert sha(folder/r['file'])==r['beforeSha256' if index==0 else 'afterSha256']
  review.append(dict(label=label,file=r['file'],sha256=sha(folder/r['file'])))
 for mode in ['inventory','validate']:
  identity=read(root/(label+'-'+mode+'.json'))
  assert identity['exited'] and identity['exitCode']==0 and identity['runtime']=='10.0.13'
  assert identity['entrySha256'].lower()==sha(bundle/'CompactNormal.dll')==callers[index]['sha256'].lower()==library[index]['sha256'].lower()
  processes[(identity['pid'],identity['startTicks'])]=(label,mode)
 inventory=read(root/(label+'-inventory.log'));assert len(inventory)==107 and sum(i['primary'] for i in inventory)==23
 assert len({i['id'] for i in inventory})==107 and all(i['version']=='25' for i in inventory)
 rows=[json.loads(line) for line in (root/(label+'-validate.log')).read_text(encoding='utf-8-sig').splitlines() if line.strip()]
 assert [r['id'] for r in rows]==[i['id'] for i in inventory]
 for d,r in zip(inventory,rows):
  assert r['inputHash']==d['input_hash'] and r['completed']==d['spec']['ValidationCount']
  assert r['operations']==d['operations']==d['spec']['Operations'] and r['primary']==d['primary']==d['spec']['Primary']
 inventories.append(inventory);fingerprints.append(rows)
 files=[dict(name=p.name,path=str(p),sha256=sha(p)) for p in sorted(bundle.iterdir())]
 assert all(f['name'].endswith('.dll') or f['name'] in ['CompactNormal.deps.json','CompactNormal.runtimeconfig.json'] for f in files)
 bundles.append(dict(label=label,entry='CompactNormal.dll',files=files))
assert inventories[0]==inventories[1] and fingerprints[0]==fingerprints[1]
for name in ['Program.cs','Normal.csproj']:assert (root/'p39n2-source'/name).read_bytes()==(root/'p39n3-source'/name).read_bytes()
assert sha(root/'p39n2-source/Program.cs')==sha(research/'Scenarios-compact-normal-storage.cs.txt')
assert 'Snapshot.' not in (root/'p39n2-source/Program.cs').read_text()
deps=lambda b:{f['name']:f['sha256'] for f in b['files'] if f['name']!=b['entry']}
assert deps(bundles[0])==deps(bundles[1])
assert sha(root/'bundles/p39n2/CompactNormal.dll')!=sha(root/'bundles/p39n3/CompactNormal.dll')
traces=read(root/'p39-normal-storage-preflight.json');assert len(traces)==6
for t in traces:
 p=root/'p39-normal-storage/traces'/t['file'];r=t['record']
 assert sha(p)==t['sha256'].lower() and read(p)==r and r['stage']=='cleaned'
 label,mode=processes[(r['pid'],r['startTicks'])];assert mode=='validate'
 assert r['entrySha256'].lower()==sha(root/'bundles'/label/'CompactNormal.dll')
 assert Path(r['root']).parent==root/'p39-normal-storage' and not Path(r['root']).exists()
failed=read(root/'p39n0-validate.json');assert failed['exited'] and failed['exitCode']!=0
assert 'Owned load missing' in (root/'p39n0-validate-error.log').read_text(encoding='utf-8-sig')
summary=read(root/'native-summary-phase32-normal-storage.json');assert len(summary['listings'])==12
native=[]
for listing in summary['listings']:
 p=root/listing['file'];stem=p.stem
 assert sha(p)==listing['sha256'] and all(m['listing_availability']=='complete' for m in listing['methods'])
 identity=read(root/(stem+'-identity.json'));shutdown=read(root/(stem+'-shutdown.json'))
 label=stem.split('-')[0]
 assert identity['hash'].lower()==sha(root/'bundles'/label/'CompactNormal.dll')
 assert identity['pid']==shutdown['pid'] and shutdown['exited'] and shutdown['exitCode']==0
 assert identity['regime']=='external-owned-JIT-diagnostic-not-quiet'
 rows=[json.loads(line) for line in (root/(stem+'-output.log')).read_text(encoding='utf-8-sig').splitlines() if line.strip()]
 assert len(rows)==1 and rows[0]['id']==identity['scenario']
 # Preserve incomplete tier coverage rather than rerun until favorable code appears.
 caller=[m for m in listing['methods'] if m['method'].startswith(('ClassicCase:','GenericCase`1['))]
 if '-from-' not in stem:assert caller
 if label=='p39n3' and '-D-validate-' in stem:
  text=p.read_text();assert 'E000E000' in text and any(':ValidateCube(' in m['method'] for m in listing['methods'])
 native.append(dict(file=listing['file'],optimizedCallerAvailable=bool(caller),methods=listing['methods']))
value=dict(passed=True,fixtureVersion='25',control='Unpromoted P31 compact-leaf13-source',candidate='P39 compact-terminal-source',
 sourceFiles=55,libraryBodies=1236,unchangedLibraryBodies=1235,changedBodies=changed,publicTypes=len(library[0]['publicSurface']),
 callerMethodsMatched=35,implementationFlagsMatched=True,dependencyClosureMatched=True,semanticCasesPerModule=107,
 semanticFingerprintRowsMatched=107,storageRootsCleaned=6,fixtureSha256=sha(research/'Scenarios-compact-normal-storage.cs.txt'),
 sourcePatchSha256=sha(root/'p39-source-review.diff'),sourceReview=review,bundles=bundles,descriptors=inventories[0],native=native,
 comparativeRecords=0,sourceAdoption=False,originalFixtureFailure=failed,
 effectsReview='Only private PID/start/GUID storage under exact task root, Direct compression and explicit TryLoadChunkFromStorage. No database or user-world API/config fallback. Six successful roots cleaned; initial failed version24 root retained separately.',
 limits='Actual optimized validation and chunk callers show code/frame growth; source/IL equality does not imply identical generated code. FromEncoded callers did not reach retained Tier1 in these original bounded diagnostics. No inferred native timing or total stack. P31 remains unpromoted; this local family cannot adopt or establish original10x.')
out.write_bytes((json.dumps(value,indent=2)+'\n').encode())
print(json.dumps({k:v for k,v in value.items() if k not in ['sourceReview','bundles','descriptors','native','effectsReview','limits']}))
