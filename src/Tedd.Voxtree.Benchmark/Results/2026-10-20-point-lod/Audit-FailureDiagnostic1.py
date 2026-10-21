"""Audit closed D1 lifecycle/exception evidence; never compare its timings."""
import argparse,collections,datetime,hashlib,json,re,sqlite3
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
task=args.task_root.resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
root=task/'p18-failure-diagnostic-1';out=task/'failure-diagnostic-1-audit.json'
assert not out.exists(), 'Preserve original D1 audit'
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
controller=read(root/'controller.json');controller_end=read(root/'controller-shutdown.json')
observer_end=read(root/'observer-shutdown.json');observation=read(root/'observer/result.json')
assert controller_end['joined'] and controller_end['exitCode']==0
assert observer_end['joined']
assert observation['binding']['targetPid']==controller['pid']
assert int(observation['binding']['targetStartTicks'])==int(controller['startTicks'])
proof=read(task/'exception-recorder-v2-source/selftest-proof.json')
assert observation['binding']['entrySha256']==proof['entrySha256'].lower()
assert observation['traceSha256']==hashlib.sha256((root/'observer/exceptions.nettrace').read_bytes()).hexdigest()
events=read(root/'observer/events.json');assert len(events)==observation['eventCount']
assert all(e['ProcessID']==controller['pid'] for e in events)
inputs=read(root/'inputs.json');plans=read(root/'plans.json');outcomes=read(root/'outcomes.json')
if isinstance(outcomes,dict):outcomes=[outcomes]
assert inputs['promotion_eligible'] is False and inputs['maximum_sessions']==192 and len(plans)==8
assert [r['scenario'] for r in outcomes]==[r['scenario'] for r in plans[:len(outcomes)]]
assert all(r['state']=='completed' for r in outcomes[:-1])
with sqlite3.connect((root/'catalog.sqlite').as_uri()+'?mode=ro',uri=True) as db:
    records=[{'id':row[0],'kind':row[1],'value':json.loads(row[2])} for row in db.execute('SELECT Id,Kind,Json FROM Record ORDER BY CreatedAt,Id')]
kinds=collections.Counter(r['kind'] for r in records)
assert not any(kinds[k] for k in ['comparison','objective_vector','promotion_decision'])
sessions={r['id']:r['value'] for r in records if r['kind']=='normal_build_session'}
launches={r['value']['session_id']:r['value'] for r in records if r['kind']=='normal_build_launch'}
declared=[];rows=[];identities=set()
for item in outcomes:
    name=item['scenario'];record=read(root/(name+'-execution.json'));execution=json.loads(record['json'])
    terminal=read(root/(name+'-terminal.json'));plan=next(r['plan'] for r in plans if r['scenario']==name)
    assert execution['plan_id']==plan['id'] and execution['state']==terminal['state']==item['state']
    e=plan['experiment'];assert e['blocks']==12 and e['warmup_batches']==1 and int(e['operations_per_run'])==8388608
    assert e['seed']=='20261024' and e['maximum_duration_seconds']==600 and e['scenario_version']=='12'
    current=execution['session_ids'];assert len(current)==item['sessions'] and len(set(current))==len(current)
    if item['state']=='completed':assert len(current)==24
    pairs={}
    for sid in current:
        s=sessions[sid];m=s['measurement'];t=s['target'];runtime=s['runtime']
        assert s['plan_id']==plan['id'] and s['execution_id']==terminal['result_id']
        assert m['correct'] and m['quiescent'] and m.get('failure') is None and int(m['completed_operations'])==8388608
        assert m['input_hash']==e['input_hash'] and m['scenario_version']=='12' and m['variant']==s['variant']
        assert m['start_thread_id']==m['end_thread_id'] and s['exit_code']==0
        assert t['runtime_version']=='10.0.13' and t['architecture']=='X64'
        assert runtime['diagnostics_enabled']=='0' and runtime['profiling_enabled']=='0' and runtime['owned_process']
        bundle=inputs['bundles'][0 if s['variant']=='baseline' else 1]
        expected=next(v['sha256'] for v in bundle['files'] if v['name']==bundle['entry'])
        assert runtime['entry_assembly_hash']==expected
        launch=launches[sid];assert launch['process_id']==t['process_id'] and launch['start_time_utc_ticks']==t['start_time_utc_ticks']
        identity=(t['process_id'],t['start_time_utc_ticks']);assert identity not in identities;identities.add(identity)
        pairs.setdefault(s['block_ordinal'],[]).append(s['variant'])
    if item['state']=='completed':assert set(pairs)==set(range(12)) and all(sorted(v)==['baseline','candidate'] for v in pairs.values())
    declared.extend(current)
    rows.append({'scenario':name,'state':item['state'],'error_code':terminal.get('error_code'),
        'operation_id':terminal['id'],'execution_id':terminal.get('result_id'),'sessions':len(current),
        'started_at':execution['started_at'],'ended_at':execution.get('ended_at')})
assert len(set(declared))==len(declared)<=192
groups={}
for event in events:
    p=event['payload'];key=(p.get('ExceptionType'),p.get('ExceptionHRESULT'),p.get('ExceptionMessage'))
    group=groups.setdefault(key,{'type':key[0],'hresult':key[1],'message':key[2],'count':0,
        'first_utc':event['timestampUtc'],'last_utc':event['timestampUtc'],'threads':set(),'session_ids':set()})
    group['count']+=1;group['last_utc']=event['timestampUtc'];group['threads'].add(event['ThreadID'])
    group['session_ids'].update(re.findall(r'normal-session-[0-9a-f]{32}',key[2] or ''))
for group in groups.values():group['threads']=sorted(group['threads']);group['session_ids']=sorted(group['session_ids'])
generic=[r for r in rows if r['error_code']=='confirmation_failed']
unmatched=[v for sid,v in launches.items() if sid not in sessions]
value={'purpose':'Failure diagnostic only; no timing statistics or promotion evidence',
    'original_family_untouched':True,'complete_cases':sum(r['state']=='completed' for r in rows),
    'executed_cases':len(rows),'declared_sessions':len(declared),'catalog_session_rows':len(sessions),
    'declared_sessions_correct_quiescent_joined':True,'cases':rows,'observer_complete':observation['complete'],
    'observer_exit_code':observer_end['exitCode'],'events_lost':observation['eventsLost'],'events_truncated':observation['truncated'],
    'exception_events':len(events),'exception_groups':list(groups.values()),'generic_failure_reproduced':bool(generic),
    'uncompleted_launches':unmatched,'catalog_sessions_not_returned':sorted(set(sessions)-set(declared)),
    'controller':controller_end,'observer':observer_end,'catalog_record_counts':dict(kinds),
    'interpretation':'Reproduced generic failure needs chronology/source attribution; exception coincidence alone is not causation.' if generic else
        'No generic failure reproduced in the executed fixed budget. This does not prove the historic fault fixed or absent. All D1 measurements remain excluded from performance decisions.'}
out.write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({k:v for k,v in value.items() if k not in ['cases','exception_groups','catalog_record_counts','uncompleted_launches','catalog_sessions_not_returned']}))
