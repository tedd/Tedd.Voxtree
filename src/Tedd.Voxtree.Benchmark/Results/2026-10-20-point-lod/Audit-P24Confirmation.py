"""Audit the complete frozen family, or its terminal failure, without replacement."""
import argparse,hashlib,json,statistics
from datetime import datetime
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
task=a.task_root.resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
root=task/'p24-confirmation';output=task/'p24-confirmation-audit.json';assert not output.exists()
read=lambda f:json.loads(f.read_text(encoding='utf-8-sig'))
unwrap=lambda v:json.loads(v['json']) if isinstance(v,dict) and 'json' in v else v
dt=lambda s:datetime.fromisoformat(s)
plans=read(root/'plans.json');assert len(plans)==8
expected={f'point-Force{t}-L5-mixed-u16-air-{m}-{op}' for t in ['UInt16','UInt32'] for m in ['owned','span'] for op in ['get','lod']}
assert {i['scenario'] for i in plans}==expected
complete=all((root/(i['scenario']+'-terminal.json')).exists() for i in plans)
assert complete or (root/'driver-failure.log').exists(), 'Family still active: audit only after terminal shutdown'
hashes={arm:hashlib.sha256((task/f'bundles/{label}/{label}.dll').read_bytes()).hexdigest() for arm,label in [('baseline','p24control'),('candidate','p24census')]}
identities=set();ids=set();controllers=set();rows=[];first_start=None;last_freeze=max(dt(i['plan']['frozen_at']) for i in plans)
stopped=False
for item in plans:
    name=item['scenario'];plan=item['plan'];e=plan['experiment'];stem=root/name
    assert e['blocks']==12 and int(e['operations_per_run'])==100000000 and e['warmup_batches']==1
    assert e['seed']=='20261026' and e['scenario_version']=='12' and e['analysis']['family_size']==16
    assert e['maximum_duration_seconds']==600 and e['profile']=='quiet-validation' and e['fresh_normal_build'] and e['confirmatory'] and e['independent_blocks']
    assert e['guardrail_metrics']==['scenario.thread_allocation_bytes_per_operation'] and e['guardrail_policies'][0]['descriptive_only'] is False
    terminal=Path(str(stem)+'-terminal.json')
    if not terminal.exists():
        assert stopped;rows.append({'scenario':name,'state':'unexecuted_after_failure','sessions':0});continue
    assert not stopped, 'No postfailure replacement or further family execution permitted'
    op=read(terminal);execution=unwrap(read(Path(str(stem)+'-execution.json')))
    sessions=[unwrap(s) for s in read(Path(str(stem)+'-sessions.json'))]
    assert execution['id']==op['result_id'] and execution['plan_id']==plan['id']
    assert [s['id'] for s in sessions]==execution['session_ids']
    shutdown=read(Path(str(stem)+'-controller-shutdown.json'))
    assert shutdown['joined'] and shutdown['exitCode']==0
    identity=(shutdown['pid'],shutdown['startTicks']);assert identity not in controllers;controllers.add(identity)
    grant=read(Path(str(stem)+'-grant.json'));assert grant['maximum_operations']==24 and grant['target_id']==plan['id']
    obs={'baseline':[],'candidate':[]};blocks={};allocations=set()
    for s in sessions:
        t=s['target'];m=s['measurement'];r=s['runtime'];arm=s['variant'];key=(t['process_id'],t['start_time_utc_ticks'])
        assert key not in identities and s['id'] not in ids;identities.add(key);ids.add(s['id'])
        assert t['runtime_version']=='10.0.13' and t['architecture']=='X64' and r['entry_assembly_hash']==hashes[arm]
        assert r['owned_process'] and not r['debugger_attached'] and not r['native_profiler_present']
        assert r['diagnostics_enabled']=='0' and r['profiling_enabled']=='0' and not r['startup_hooks'] and not r['additional_dependencies']
        assert s['plan_id']==plan['id'] and s['build_id']==plan[arm+'_build_id'] and s['execution_id']==execution['id']
        assert s['exit_code']==0 and s['compilation_regime']=='normal-build/fresh-process'
        start=dt(s['started_at']);first_start=min(first_start,start) if first_start else start
        assert dt(s['exited_at'])>=start>=last_freeze
        assert m['correct'] and m['quiescent'] and m['failure'] is None
        assert int(m['completed_operations'])==100000000 and m['scenario_version']=='12' and m['input_hash']==e['input_hash']
        assert m['execution_id']==execution['id'] and m['run_id']==s['id'] and m['start_thread_id']==m['end_thread_id']
        assert int(m['thread_allocation_bytes'])==0
        assert abs(m['nanoseconds_per_operation']-m['elapsed_nanoseconds']/100000000)<1e-9
        obs[arm].append(m['nanoseconds_per_operation']);allocations.add(int(m['process_allocation_bytes']))
        blocks.setdefault(s['block_ordinal'],[]).append(arm)
    row={'scenario':name,'state':op['state'],'plan_id':plan['id'],'execution_id':execution['id'],'sessions':len(sessions),
         'exported_sessions_joined_correct_quiescent':True,'process_allocation_bytes_observed':sorted(allocations)}
    if op['state']=='completed':
        assert len(sessions)==24 and set(blocks)==set(range(12)) and all(sorted(b)==['baseline','candidate'] for b in blocks.values())
        vector=unwrap(read(Path(str(stem)+'-objective_vector.json')));decision=read(Path(str(stem)+'-decision.json'))
        time=next(x for x in vector['effects_without_run_ids'] if x['metric']=='scenario.ns_per_operation')
        allocation=next(x for x in vector['effects_without_run_ids'] if x['metric']=='scenario.thread_allocation_bytes_per_operation')
        assert time['family_size']==allocation['family_size']==16 and time['independent_blocks']==12
        interval=time.get('difference_interval');ratio=time.get('effect')
        row.update(median_ns_per_read={k:statistics.median(v) for k,v in obs.items()},speedup=1/ratio if ratio else None,
                   speedup_interval={'lower':1/interval['upper'],'upper':1/interval['lower'],'coverage':interval['coverage']} if interval else None,
                   tenfold_lower_bound_reached=bool(interval and interval['upper']<=0.1),time=time,allocation=allocation,
                   promotion_eligible=decision['promotion_eligible'],promotion_reason_codes=decision['reason_codes'])
        assert 'DOTNETLAB_CONFIRMATION_FAILURE' not in Path(str(stem)+'-controller.log').read_text(encoding='utf-8-sig')
    else:
        stopped=True;row.update(failure=execution.get('failure'),error_code=op['error_code'],inference='Partial case not compared; no replacement or continuation')
    rows.append(row)
audit={'epoch':'p24-confirmation','control':'f0772c8','candidate':'complete P24 packed-word source','planned_cases':8,'planned_sessions':192,
       'completed_cases':sum(r['state']=='completed' for r in rows),'distinct_process_start_identities':len(identities),
       'joined_controllers':len(controllers),'all_plans_frozen_before_first_session':bool(first_start and last_freeze<=first_start),
       'all_exported_sessions_joined_correct_quiescent_zero_thread_allocation':True,
       'all_eight_tenfold_lower_bounds_reached':len(rows)==8 and all(r.get('tenfold_lower_bound_reached',False) for r in rows),
       'cases':rows,'unit':'one complete public read','old_P18_D1_L1_data_excluded':True,
       'inference_limit':'Declared paired independence assumptions and uncontrolled environmental drift remain. Zero observations do not resolve degenerate allocation models. Construction/bulk/fallback/memory/API guards remain; no whole-library adoption.'}
output.write_text(json.dumps(audit,indent=2)+'\n')
print(json.dumps({k:v for k,v in audit.items() if k not in ['cases','inference_limit']}))
