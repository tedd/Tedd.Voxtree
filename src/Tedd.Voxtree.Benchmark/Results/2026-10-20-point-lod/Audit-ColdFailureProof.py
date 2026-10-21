"""Audit L1 functional outcomes and cold stderr details; never compare timings."""
import argparse,collections,hashlib,json,sqlite3
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
task=args.task_root.resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
output=task/'coldlog-functional-audit.json';assert not output.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
rows=[];all_identities=set();total_sessions=0;total_launches=0
for variant in ['base','logged']:
    root=task/f'coldlog-{variant}-proof2';outcomes=read(root/'outcomes.json')
    assert [v['label'] for v in outcomes]==['invalid','valid']
    shutdown=read(root/'controller-shutdown.json');assert shutdown['joined'] and shutdown['exitCode']==0
    with sqlite3.connect((root/'catalog.sqlite').as_uri()+'?mode=ro',uri=True) as db:
        records=[{'id':r[0],'kind':r[1],'value':json.loads(r[2])} for r in db.execute('SELECT Id,Kind,Json FROM Record')]
    counts=collections.Counter(v['kind'] for v in records)
    assert all(not counts[k] for k in ['comparison','objective_vector','promotion_decision'])
    sessions={r['id']:r['value'] for r in records if r['kind']=='normal_build_session'}
    launches={r['value']['session_id']:r['value'] for r in records if r['kind']=='normal_build_launch'}
    assert len(sessions)==24 and len(launches)==25
    inputs=read(root/'target-inputs.json');declared=[];case_rows=[]
    for label in ['invalid','valid']:
        terminal=read(root/(label+'-terminal.json'));record=read(root/(label+'-execution.json'));execution=json.loads(record['json'])
        assert execution['state']==terminal['state']
        case_launches=[v for v in launches.values() if v['execution_id']==terminal['result_id']]
        if label=='invalid':
            assert terminal['state']=='failed' and terminal['error_code']=='invalid_plan' and not execution['session_ids'] and len(case_launches)==1
        else:
            assert terminal['state']=='completed' and len(execution['session_ids'])==24 and len(case_launches)==24
        pairs={}
        for sid in execution['session_ids']:
            s=sessions[sid];m=s['measurement'];t=s['target'];runtime=s['runtime']
            assert s['exit_code']==0 and m['correct'] and m['quiescent'] and m.get('failure') is None
            assert int(m['completed_operations'])==8388608 and m['scenario_version']=='12' and m['start_thread_id']==m['end_thread_id']
            assert t['runtime_version']=='10.0.13' and t['architecture']=='X64'
            assert runtime['owned_process'] and runtime['diagnostics_enabled']=='0' and runtime['profiling_enabled']=='0'
            bundle=inputs['bundles'][0 if s['variant']=='baseline' else 1]
            assert runtime['entry_assembly_hash']==next(f['sha256'] for f in bundle['files'] if f['name']==bundle['entry'])
            identity=(t['process_id'],t['start_time_utc_ticks']);assert identity not in all_identities;all_identities.add(identity)
            pairs.setdefault(s['block_ordinal'],[]).append(s['variant'])
        if label=='valid':assert set(pairs)==set(range(12)) and all(sorted(v)==['baseline','candidate'] for v in pairs.values())
        declared.extend(execution['session_ids'])
        case_rows.append({'label':label,'operation_id':terminal['id'],'state':terminal['state'],
            'failure_code':terminal.get('error_code'),'returned_sessions':len(execution['session_ids']),'launches':len(case_launches)})
    assert set(declared)==set(sessions)
    prefix='DOTNETLAB_CONFIRMATION_FAILURE '
    lines=(root/'controller.log').read_text(encoding='utf-8-sig').splitlines()
    details=[json.loads(line[len(prefix):]) for line in lines if line.startswith(prefix)]
    assert len(details)==(1 if variant=='logged' else 0)
    if details:
        v=details[0];assert v['operation_id']==case_rows[0]['operation_id'] and v['failure_code']=='invalid_plan'
        assert v['exception_type']=='Tedd.DotNetLab.Contracts.LabException' and not v['detail_truncated']
        assert 'Normal-build scenario differs from the frozen input/variant.' in v['detail'] and 'RunNormalSessionAsync' in v['detail']
        assert v['operation_id']!=case_rows[1]['operation_id']
    total_sessions+=len(sessions);total_launches+=len(launches)
    rows.append({'variant':variant,'cases':case_rows,'controller_joined':True,'controller_exit_code':0,
        'structured_failure_lines':len(details),'details':details,'successful_sessions_correct_quiescent_joined':24})
assert total_sessions==48 and total_launches==50
source=task/'coldlog-controller-source'
base={p.relative_to(source/'base2-out').as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in (source/'base2-out').rglob('*.dll')}
logged={p.relative_to(source/'logged2-out').as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in (source/'logged2-out').rglob('*.dll')}
assert base.keys()==logged.keys();changed=sorted(p for p in base if base[p]!=logged[p])
assert changed==['Tedd.DotNetLab.Application.dll','Tedd.DotNetLab.Host.dll','Tedd.DotNetLab.Mcp.dll']
value={'purpose':'Controller functional proof only; no performance statistics or promotion',
    'variants':rows,'valid_sessions':total_sessions,'launches':total_launches,'expected_rejected_launches':2,
    'dll_count_per_output':len(base),'changed_dlls':changed,'source_review':read(source/'patch-review.json'),
    'supported_functionally':True,'historic_fault_fixed':False,'shared_installation_changed':False,
    'interpretation':'Failure codes and valid lifecycle outcomes match. Logging variant provides original exception details only for the controlled failure. This does not localize/repair the historic failure or qualify any library optimization.'}
output.write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({k:v for k,v in value.items() if k not in ['variants','source_review']}))
