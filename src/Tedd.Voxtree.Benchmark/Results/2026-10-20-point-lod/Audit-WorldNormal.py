"""Bind single-library normal builds, source patch and semantic/caller identity."""
import hashlib,json,subprocess,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path(__file__).resolve().parents[4];out=root/'p36-normal-preflight.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip()+'\n'
gate=read(root/'p36-prerequisite-audit.json');assert gate['passed'] and gate['fieldsAndReadBodiesUnchanged']
inventories=read(root/'caller-audit-p36normal.json');assert len(inventories)==2 and all(len(v['methods'])==8 for v in inventories)
for a,b in zip(inventories[0]['methods'],inventories[1]['methods']):
 assert a['method']==b['method'] and a['resolvedIlSha256']==b['resolvedIlSha256'] and a['implementationFlags']==b['implementationFlags'] and 'NoInlining' in a['implementationFlags']
source_names=set(read(root/'p36-source-hashes.json'));review=[];bundles=[]
for label in ['p36n0','p36n1']:
 folder=root/(label+'-source');bundle=root/'bundles'/label
 assert {p.name for p in folder.glob('*.cs')}==source_names|{'Program.cs'}
 for name in sorted(source_names):
  expected=subprocess.check_output(['git','-C',str(repo),'show','f0772c8:src/Tedd.Voxtree/'+name]) if label=='p36n0' else (root/'cache-maintenance-source'/name).read_bytes()
  assert norm((folder/name).read_bytes())==norm(expected)
  review.append({'label':label,'file':name,'sha256':sha(folder/name),'normalizedSourceMatched':True})
 validation=read(root/(label+'-validation.json'));assert validation['exited'] and validation['exitCode']==0 and validation['cases']==48
 assert validation['entrySha256'].lower()==sha(bundle/'WorldNormal.dll')==inventories[len(bundles)]['sha256'].lower()
 files=[{'name':p.name,'path':str(p),'sha256':sha(p)} for p in sorted(bundle.iterdir())]
 assert all(p['name'].endswith('.dll') or p['name'] in ['WorldNormal.deps.json','WorldNormal.runtimeconfig.json'] for p in files)
 bundles.append({'label':label,'entry':'WorldNormal.dll','files':files})
assert (root/'p36n0-source/Program.cs').read_bytes()==(root/'p36n1-source/Program.cs').read_bytes()
program=(root/'p36n0-source/Program.cs').read_text();assert 'Snapshot.' not in program and 'Before.' not in program
assert all(token not in program for token in ['StorageOptions','File.','Directory.','SqlConnection'])
assert (root/'p36n0-source/Normal.csproj').read_bytes()==(root/'p36n1-source/Normal.csproj').read_bytes()
assert sha(root/'bundles/p36n0/WorldNormal.dll')!=sha(root/'bundles/p36n1/WorldNormal.dll')
deps=lambda b:{f['name']:f['sha256'] for f in b['files'] if f['name'].endswith('.dll') and f['name']!=b['entry']}
assert deps(bundles[0])==deps(bundles[1])
for name in ['WorldNormal.runtimeconfig.json','WorldNormal.deps.json']:assert (root/'bundles/p36n0'/name).read_bytes()==(root/'bundles/p36n1'/name).read_bytes()
value={'passed':True,'control':'f0772c8','candidate':'cache-maintenance-source, P36 only','fixtureVersion':'22','entryAssembly':'WorldNormal.dll','sourceMatched':True,'callerMethodsMatched':8,'implementationFlagsMatched':True,'dependencyClosureMatched':True,'runtimeConfigMatched':True,'depsJsonMatched':True,'singleImplementationPerModule':True,'semanticCasesPerModule':48,'comparativeRecords':0,'fixtureSha256':sha(root/'p36n0-source/Program.cs'),'callerAuditSha256':sha(root/'caller-audit-p36normal.json'),'sourcePatchSha256':sha(root/'p36-source.diff'),'sourceReview':review,'bundles':bundles,'effectsReview':'Generated project links only task-owned source and exact dependency DLLs, disables parent Directory.Build imports; startup/callbacks create synthetic arrays/dictionaries/octrees and task-owned Harness IPC, with no configured storage or database calls.','initialValidationDriverIssue':'Original script parse rejected the status string $label: before execution; preserved initial source and corrected ${label}; neither semantic producer was submitted before correction.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k not in ['sourceReview','bundles','effectsReview','initialValidationDriverIssue']}))
