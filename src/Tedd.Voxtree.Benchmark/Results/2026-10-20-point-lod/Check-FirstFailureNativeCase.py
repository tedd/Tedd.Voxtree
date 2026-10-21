"""Check one original deterministic controller test, without performance inference."""
import hashlib,json,sqlite3,sys,traceback
from pathlib import Path
root=Path(sys.argv[1]).resolve();task=Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
assert root.parent==task/'p39-first-failure'
out=root/'case-native-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
try:
 expected=read(root/'test-inputs.json');parent=read(root.parent/'native-inputs.json');plan=read(root/'plan.json')
 terminal=read(root/'worker-terminal.json');accepted=read(root/'worker-accepted.json');execution=read(root/'worker-execution.json')
 identity=read(root/'worker-native-identity.json');shutdown=read(root/'worker-native-shutdown.json')
 assert shutdown['pid']==identity['pid'] and shutdown['startTicks']==identity['startTicks'] and shutdown['joined'] and shutdown['exitCode']==0 and not shutdown['timedOut']
 summary=read(root/'worker-native-output.log')
 assert summary['root']==str(root) and summary['runtime']=='10.0.13' and summary['diagnosticOnly'] and summary['comparativeTimingRecords']==0
 assert summary['workerSha256'].lower()==identity['workerSha256'].lower() and summary['applicationSha256'].lower()==identity['applicationSha256'].lower()
 assert summary['nativeSha256'].lower()==parent['nativeAssetSha256'].lower()
 assert summary['locksReleased'] and summary['locksHeld']==(1 if expected['hold']=='hold' else 0)
 assert terminal['id']==accepted['id']==summary['operationId']==execution['operation_id']
 assert terminal['target_id']==plan['id']==execution['plan_id'] and execution['plan_hash']==plan['content_hash']
 assert terminal['state']==execution['state']==expected['expectedState'] and summary['state'].lower()==expected['expectedState']
 assert terminal.get('error_code')==expected['expectedCode']
 log=(root/'worker-native-error.log').read_text(encoding='utf-8-sig').splitlines()
 primary=[json.loads(s.removeprefix('DOTNETLAB_NORMAL_SESSION_PRIMARY_FAILURE ')) for s in log if s.startswith('DOTNETLAB_NORMAL_SESSION_PRIMARY_FAILURE ')]
 outer=[json.loads(s.removeprefix('DOTNETLAB_CONFIRMATION_FAILURE ')) for s in log if s.startswith('DOTNETLAB_CONFIRMATION_FAILURE ')]
 assert len(primary)==expected['expectedPrimary'] and len(outer)==(0 if expected['expectedState']=='completed' else 1)
 if primary:
  assert primary[0]['failure_code']=='scenario_not_found' and primary[0]['execution_id']==execution['id'] and primary[0]['plan_id']==plan['id']
  assert primary[0]['block_ordinal']==primary[0]['arm_ordinal']==0 and not primary[0]['detail_truncated']
  assert next(i for i,s in enumerate(log) if s.startswith('DOTNETLAB_NORMAL_SESSION_PRIMARY_FAILURE '))<next(i for i,s in enumerate(log) if s.startswith('DOTNETLAB_CONFIRMATION_FAILURE '))
 if expected['hold']=='hold':
  assert outer[0]['exception_type'] in ['System.IO.IOException','System.UnauthorizedAccessException'] and 'OwnedDirectoryCleanup' in outer[0]['detail']
 elif expected['missing']:
  assert outer[0]['failure_code']=='scenario_not_found' and outer[0]['exception_type']=='Tedd.DotNetLab.Contracts.LabException'
 records={}
 with sqlite3.connect((root/'catalog.sqlite').as_uri()+'?mode=ro',uri=True) as c:
  for i,kind,revision,value in c.execute('SELECT Id,Kind,Revision,Json FROM Record ORDER BY Revision'):
   records[i]=(kind,json.loads(value))
 launches=[v for k,v in records.values() if k=='normal_build_launch'];sessions=[v for k,v in records.values() if k=='normal_build_session']
 assert len(launches)==expected['expectedLaunches'] and len(sessions)==expected['expectedSessions']
 assert len({(l['process_id'],l['start_time_utc_ticks']) for l in launches})==len(launches)
 for l in launches:assert l['execution_id']==execution['id']
 if primary:assert primary[0]['session_id']==launches[0]['session_id']
 builds=read(root/'builds.json');normal=parent['normalBundles'];known={b['id']:n for b,n in zip(builds,normal)}
 for s in sessions:
  m=s['measurement'];runtime=s['runtime'];b=known[s['build_id']]
  hashes={f['name']:f['sha256'] for f in b['files'] if f['name'].endswith('.dll')}
  assert runtime['assembly_hashes']==hashes and runtime['entry_assembly_hash']==hashes['CompactNormal.dll']
  assert s['exit_code']==0 and m['correct'] and m['quiescent'] and m['failure'] is None and int(m['completed_operations'])==32
  assert m['scenario_version']=='25' and m['input_hash']==parent['descriptor']['input_hash']
  assert s['execution_id']==execution['id'] and s['compilation_regime']=='normal-build/fresh-process'
  assert runtime['owned_process'] and runtime['diagnostics_enabled']=='0' and runtime['profiling_enabled']=='0' and not runtime['native_profiler_present'] and not runtime['debugger_attached']
 if expected['expectedState']=='completed':assert set(execution['session_ids'])=={s['id'] for s in sessions}
 else:assert not execution['session_ids']
 residual=list((root/'launches').iterdir())
 assert len(residual)==(1 if expected['hold']=='hold' else 0)
 if residual:
  assert residual[0].name==launches[0]['session_id'] and (residual[0]/'CompactNormal.dll').exists()
  assert sha(residual[0]/'CompactNormal.dll')==known[launches[0]['build_id']]['files'][next(i for i,f in enumerate(known[launches[0]['build_id']]['files']) if f['name']=='CompactNormal.dll')]['sha256']
 value=dict(passed=True,test=expected['name'],operation_id=terminal['id'],execution_id=execution['id'],state=terminal['state'],primary_logs=primary,outer_logs=outer,
  target_launch_count=len(launches),retained_measured_sessions=len(sessions),launches=launches,residual_launch_directories=[str(p) for p in residual],
  measured_sessions_correct_quiescent_exited=True,worker_joined=True,quiescence_check_required=True,comparativeTimingRecords=0)
except Exception:
 value=dict(passed=False,root=str(root),failure=traceback.format_exc(),comparativeTimingRecords=0)
 out.write_bytes((json.dumps(value,indent=2)+'\n').encode());print(value['failure']);raise
out.write_bytes((json.dumps(value,indent=2)+'\n').encode());print(json.dumps({k:v for k,v in value.items() if k not in ['primary_logs','outer_logs','launches']}))
