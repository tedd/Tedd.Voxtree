"""Bind original five controlled outcomes, grants, source and complete quiescence."""
import hashlib,json,sqlite3,sys
from pathlib import Path
from datetime import datetime
task=Path(sys.argv[1]).resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;main=task/'p39-first-failure';out=task/'p39-first-failure-study-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
done=read(main/'native-driver-completed.json');assert done['allPredictionsPassed'] and done['tests']==5 and done['comparativeTimingRecords']==0
assert not (main/'native-driver-failure.log').exists()
inputs=read(main/'native-inputs.json');plans=read(main/'plans.json');assert len(plans)==5
assert inputs['originalInputsSha256']==sha(main/'inputs.json')
for name,h in read(main/'frozen-dependencies-native.json').items():assert sha(research/name)==h.lower()
for b in inputs['controllerClosures']:
 for f in b['files']:assert sha(Path(f['path']))==f['sha256'].lower()
origin=read(task/'p39-first-failure-source.json');assert origin['originalSourceFiles']==47
for f in origin['manifest']:
 assert sha(task/'coldlog-controller-source/src/Tedd.DotNetLab.Application'/f['file'])==f['beforeSha256']
 assert sha(task/'first-failure-application-source'/f['file'])==f['afterSha256']
assert [f['file'] for f in origin['manifest'] if f['changed']]==['ConfirmationService.cs']
assert sha(task/'first-failure-application-source/NormalSessionPrimaryFailure.cs')==origin['addedLoggerSha256']
identities=set();workers=set();operations=set();total_sessions=0;rows=[]
for item in plans:
 name=item['test']['name'];root=Path(item['root']);plan=item['plan'];test=read(root/'case-native-audit.json')
 assert test['passed'] and test['test']==name and test['comparativeTimingRecords']==0
 bound=next(p for p in inputs['planFiles'] if p['test']==name);assert bound['sha256']==sha(root/'plan.json') and bound['id']==plan['id'] and bound['contentHash']==plan['content_hash']
 assert read(root/'plan.json')==plan
 e=plan['experiment'];assert e['blocks']==12 and int(e['operations_per_run'])==32 and e['maximum_duration_seconds']==120 and e['warmup_batches']==1
 assert e['seed']=='20261119' and e['target_runtime_version']=='10.0.13'
 grant=read(root/'grant-native.json');request=read(root/'worker-request.json')
 assert grant['maximum_operations']==24 and grant['permission']=='launch_registered_build' and grant['workspace']==str(root)
 assert grant['target_id']==plan['id'] and grant['content_hash']==plan['content_hash']
 assert request==dict(action='start_confirmation',plan_id=plan['id'],grant_id=grant['id'],idempotency_key='P39F-native-'+name,test_hook=item['test']['hold'])
 worker=read(root/'worker-native-identity.json');key=(worker['pid'],worker['startTicks']);assert key not in workers;workers.add(key)
 summary=read(root/'worker-native-output.log');index=0 if name=='original-masked' else 1
 files={f['name']:f for f in inputs['controllerClosures'][index]['files']}
 assert summary['workerSha256'].lower()==files['FirstFailureWorker.dll']['sha256'].lower()
 assert summary['applicationSha256'].lower()==files['Tedd.DotNetLab.Application.dll']['sha256'].lower()
 assert summary['nativeSha256'].lower()==inputs['nativeAssetSha256'] and summary['locksReleased']
 checks=read(root/'quiescence-native.json');assert len(checks)==test['target_launch_count']
 assert {(r['pid'],r['startTicks']) for r in checks}=={(r['process_id'],r['start_time_utc_ticks']) for r in test['launches']}
 assert all(c['originalProcessNotLive'] for c in checks)
 for launch in test['launches']:
  key=(launch['process_id'],launch['start_time_utc_ticks']);assert key not in identities;identities.add(key)
  assert datetime.fromisoformat(launch['started_at'])>=datetime.fromisoformat(plan['frozen_at'])
  assert datetime.fromisoformat(launch['started_at'])<=datetime.fromisoformat(grant['expires_at'])
 with sqlite3.connect((root/'catalog.sqlite').as_uri()+'?mode=ro',uri=True) as c:
  assert c.execute('SELECT count(*) FROM Operation').fetchone()[0]==1
  uses=c.execute('SELECT Count FROM GrantUse WHERE GrantId=?',(grant['id'],)).fetchone();assert uses and uses[0]==test['target_launch_count']
  sessions=[json.loads(v) for v, in c.execute("SELECT Json FROM Record WHERE Kind='normal_build_session'")]
  assert len(sessions)==test['retained_measured_sessions']
  if name=='original-masked':
   unused=read(root/'grant.json');assert c.execute('SELECT Count FROM GrantUse WHERE GrantId=?',(unused['id'],)).fetchone() is None
  if name=='logged-success':
   blocks={}
   for s in sessions:blocks.setdefault(s['block_ordinal'],[]).append((s['arm_ordinal'],s['variant']))
   assert set(blocks)==set(range(12)) and all(sorted(ordinal for ordinal,_ in v)==[0,1] and {a for _,a in v}=={'baseline','candidate'} for v in blocks.values())
  assert all(s['exit_code']==0 and s['measurement']['correct'] and s['measurement']['quiescent'] for s in sessions)
 total_sessions+=len(sessions);assert test['operation_id'] not in operations;operations.add(test['operation_id'])
 rows.append(dict(name=name,state=test['state'],operation_id=test['operation_id'],execution_id=test['execution_id'],
  targetLaunches=test['target_launch_count'],retainedMeasuredSessions=len(sessions),primaryLogCount=len(test['primary_logs']),
  residualLaunchDirectories=test['residual_launch_directories'],allOriginalTargetsNotLive=True,workerJoined=True))
assert len(identities)==28 and total_sessions==25 and len(workers)==len(operations)==5
value=dict(passed=True,qualification='Task-local first-error diagnostic preservation only',originalTests=5,acceptedOperations=5,
 targetLaunches=28,retainedMeasuredSessions=25,allRetainedMeasurementsCorrectQuiescentExited=True,distinctTargetIdentities=28,
 originalTargetsNotLive=True,joinedWorkers=5,allScopedGrantUsesMatch=True,originalUnusedGrantRetained=True,
 originalPlansUnchanged=True,originalSourceFiles=47,unchangedOriginalSourceFiles=46,changedOriginalSourceFiles=1,
 normalSourceAndBinariesUnchanged=True,measurementAndCleanupSourceUnchanged=True,originalStartupAndImplementationFailuresRetained=True,
 comparativeTimingRecords=0,sourceAdoption=False,cases=rows,
 limits='Controlled deletion handle is our injected cause only. Original intermittent P39N cause remains unresolved. No source-performance equivalence, old timed-process tiers, speedup or adoption inference. Original stopped normal family is not resumed, replaced or pooled.')
out.write_bytes((json.dumps(value,indent=2)+'\n').encode());print(json.dumps({k:v for k,v in value.items() if k not in ['cases','limits']}))
