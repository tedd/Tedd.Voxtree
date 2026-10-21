"""Bind exact original normal binaries to the six additional-warmup diagnostics."""
import hashlib,json,sys
from pathlib import Path
task=Path(sys.argv[1]).resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;root=task/'p39-warmup';out=task/'p39-warmup-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
inputs=read(root/'inputs.json');gate=read(task/'p39-normal-preflight.json')
assert inputs['originalPreflightSha256'].lower()==sha(task/'p39-normal-preflight.json')
assert inputs['protocolSha256'].lower()==sha(research/'COMPACT-WARMUP-PROTOCOL.md')
assert inputs['helperSourceSha256'].lower()==sha(research/'CompactWarmup.cs.txt')
assert (task/'p39-warmup-probe-source/Program.cs').read_bytes()==(research/'CompactWarmup.cs.txt').read_bytes()
assert inputs['processBudget']==6 and inputs['minimumAdditionalCalls']==4096 and inputs['minimumAdditionalMilliseconds']==3000
assert inputs['comparativeTimingRecords']==0 and inputs['originalBundles']==gate['bundles']
done=read(root/'driver-completed.json');assert done['processes']==6 and done['joined'] and done['comparativeTimingRecords']==0
assert not (root/'driver-failure.log').exists()
bundles=read(root/'frozen-bundles.json');assert len(bundles)==2
files=[]
for i,b in enumerate(bundles):
 assert b['label']==f'p39w{i}'
 f={Path(r['Path']).name:r for r in b['files']};files.append(f)
 for r in f.values():assert sha(Path(r['Path']))==r['Hash'].lower()
 for r in gate['bundles'][i]['files']:
  if r['name'].endswith('.dll'):assert f[r['name']]['Hash'].lower()==r['sha256']
assert files[0].keys()==files[1].keys()
assert [n for n in files[0] if files[0][n]['Hash']!=files[1][n]['Hash']]==['CompactNormal.dll']
summary=read(task/'native-summary-phase34-warmup.json');assert len(summary['listings'])==6
native={l['file']:l for l in summary['listings']};identities=set();rows=[]
for c in inputs['cases']:
 mode=c['spec']['Mode'];fingerprints=[];bodies=[]
 for i in [0,1]:
  label=f'p39w{i}-{mode}-from';identity=read(root/(label+'-identity.json'));exit=read(root/(label+'-shutdown.json'))
  assert identity['scenario']==c['id'] and identity['inputHash']==c['input_hash']
  assert identity['helperSha256'].lower()==files[i]['CompactWarmup.dll']['Hash'].lower()
  assert identity['librarySha256'].lower()==files[i]['CompactNormal.dll']['Hash'].lower()
  key=(identity['pid'],identity['startTicks']);assert key not in identities;identities.add(key)
  assert exit['pid']==key[0] and exit['startTicks']==key[1] and exit['joined'] and exit['exitCode']==0 and not exit['timedOut']
  lines=[l for l in (root/(label+'-output.log')).read_text(encoding='utf-8-sig').splitlines() if l.strip()];assert len(lines)==1
  output=json.loads(lines[0]);assert output['scenario']==c['id'] and output['version']=='25' and output['inputHash']==c['input_hash']
  assert output['runtime']=='.NET 10.0.13' and output['architecture']=='X64'
  assert output['helperSha256']==identity['helperSha256'] and output['librarySha256']==identity['librarySha256']
  assert output['additionalWarmupCalls']>=4096 and output['minimumWarmupCalls']==4096 and output['minimumWarmupMilliseconds']==3000
  assert output['finalOperations']==512 and output['comparativeTimingRecords']==0 and output['fingerprint']['completed']==512
  fingerprints.append(output['fingerprint'])
  listing=native[label+'.asm'];assert listing['sha256']==sha(task/listing['file'])
  assert all(m['listing_availability']=='complete' for m in listing['methods'])
  run=[m for m in listing['methods'] if ':RunFrom(' in m['method'] and m['method'].endswith('(Tier1)')]
  cube=[m for m in listing['methods'] if ':ValidateCube(' in m['method'] and m['method'].endswith('(Tier1)')]
  assert len(run)==len(cube)==1
  if i==1:assert 'E000E000' in (task/listing['file']).read_text()
  bodies.append(dict(arm='P31' if i==0 else 'P39',librarySha256=identity['librarySha256'],additionalWarmupCalls=output['additionalWarmupCalls'],
   caller=run[0],validator=cube[0],listingSha256=listing['sha256']))
 assert fingerprints[0]==fingerprints[1]
 rows.append(dict(mode=mode,scenario=c['id'],fingerprint=fingerprints[0],native=bodies))
value=dict(passed=True,qualification='Optimized caller/validator coverage after fixed additional priming on exact original modules only',
 processCount=6,distinctIdentities=len(identities),allJoinedCorrect=True,callerPairs=3,originalNormalBinariesByteIdentical=True,
 helperAndDependenciesMatched=True,onlyStagedModuleDelta='Original CompactNormal.dll',coveragePredictionSupported=True,
 comparativeTimingRecords=0,sourceAdoption=False,cases=rows,
 limits='New diagnostic regime cannot establish old timed-process tiers, latency cause, stack high-water mark, steady-state benefit or adoption. P39N remains stopped/inconclusive and no observations are pooled/replaced.')
out.write_bytes((json.dumps(value,indent=2)+'\n').encode());print(json.dumps({k:v for k,v in value.items() if k not in ['cases','limits']}))
