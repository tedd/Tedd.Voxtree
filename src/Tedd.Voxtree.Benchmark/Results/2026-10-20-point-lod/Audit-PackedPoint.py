"""Audit the frozen eight-case budget, preserving incomplete cases without inference."""
import argparse
import hashlib
import json
import statistics
from datetime import datetime
from pathlib import Path

parser=argparse.ArgumentParser()
parser.add_argument('task_root',type=Path)
args=parser.parse_args()
task=args.task_root.resolve()
if task!=Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve(): raise SystemExit('Unexpected task root')
root=task/'p18-screen';output=task/'p18normal-audit.json'
if output.exists(): raise SystemExit('Preserve existing audit')
expected={f'point-Force{typ}-L5-mixed-u16-air-{access}-{op}' for typ in ['UInt16','UInt32'] for access in ['owned','span'] for op in ['get','lod']}
plans=json.loads((root/'p18normal-plans.json').read_text(encoding='utf-8-sig'))
assert {p['scenario'] for p in plans}==expected and len(plans)==8
unwrap=lambda v:json.loads(v['json']) if isinstance(v,dict) and 'json' in v else v
read=lambda f:json.loads(f.read_text(encoding='utf-8-sig'))
hashes={variant:hashlib.sha256((task/f'bundles/{label}/{label}.dll').read_bytes()).hexdigest() for variant,label in [('baseline','p18control'),('candidate','p18census')]}
rows=[];identities=set();session_ids=set();errors=[]
for item in plans:
    name=item['scenario'];plan=item['plan'];experiment=plan['experiment'];stem=root/('p18normal-'+name)
    assert experiment['blocks']==12 and experiment['operations_per_run']==8388608 and experiment['warmup_batches']==1
    assert experiment['scenario_version']=='12' and experiment['analysis']['family_size']==16
    assert experiment['profile']=='quiet-validation' and experiment['fresh_normal_build'] and experiment['confirmatory']
    assert experiment['seed']=='20261023' and experiment['maximum_duration_seconds']==600
    terminal_path=Path(str(stem)+'-terminal.json')
    if not terminal_path.exists():
        errors.append(name+': not executed after preceding failure')
        rows.append({'scenario':name,'state':'unexecuted','plan_id':plan['id'],'sessions':0})
        continue
    terminal=read(terminal_path);complete=terminal['state']=='completed'
    session_path=Path(str(stem)+('-sessions.json' if complete else '-failed-sessions.json'))
    sessions=[unwrap(v) for v in read(session_path)]
    if complete:assert len(sessions)==24
    else:
        failed=unwrap(read(Path(str(stem)+'-failed-execution.json')))
        assert failed['state']=='failed' and len(sessions)==len(failed['session_ids'])
        assert [s['id'] for s in sessions]==failed['session_ids']
        errors.append(name+': failed original execution; partial sessions not compared')
    blocks={};observations={'baseline':[],'candidate':[]};process_allocations=[]
    for session in sessions:
        target=session['target'];m=session['measurement'];runtime=session['runtime'];variant=session['variant']
        key=(target['process_id'],target['start_time_utc_ticks'])
        assert key not in identities and session['id'] not in session_ids
        identities.add(key);session_ids.add(session['id'])
        blocks.setdefault(session['block_ordinal'],[]).append(variant)
        assert session['plan_id']==plan['id'] and session['build_id']==plan[variant+'_build_id']
        assert target['runtime_version']=='10.0.13' and target['architecture']=='X64'
        assert runtime['entry_assembly_hash']==hashes[variant]
        assert runtime['owned_process'] and not runtime['debugger_attached'] and not runtime['native_profiler_present']
        assert runtime['diagnostics_enabled']=='0' and runtime['profiling_enabled']=='0'
        assert session['exit_code']==0 and session['exited_at'] and session['compilation_regime']=='normal-build/fresh-process'
        assert datetime.fromisoformat(session['exited_at'])>=datetime.fromisoformat(session['started_at'])>=datetime.fromisoformat(plan['frozen_at'])
        assert m['correct'] and m['quiescent'] and m['failure'] is None
        assert int(m['completed_operations'])==8388608 and m['scenario_version']=='12' and m['input_hash']==experiment['input_hash']
        assert m['start_thread_id']==m['end_thread_id'] and int(m['thread_allocation_bytes'])==0
        assert abs(m['nanoseconds_per_operation']-m['elapsed_nanoseconds']/8388608)<1e-9
        observations[variant].append(m['nanoseconds_per_operation'])
        process_allocations.append(int(m['process_allocation_bytes']))
    if not complete:
        rows.append({'scenario':name,'state':'failed','plan_id':plan['id'],'execution_id':failed['id'],
            'failure':failed['failure'],'sessions':len(sessions),'retained_partial_sessions_joined_correct_quiescent':True,
            'inference':'No comparison of incomplete original budget; no replacement or resumed target'})
        continue
    assert set(blocks)==set(range(12)) and all(sorted(v)==['baseline','candidate'] for v in blocks.values())
    objective=unwrap(read(Path(str(stem)+'-objective_vector.json')))
    time=next(x for x in objective['effects_without_run_ids'] if x['metric']=='scenario.ns_per_operation')
    allocation=next(x for x in objective['effects_without_run_ids'] if x['metric']=='scenario.thread_allocation_bytes_per_operation')
    assert time['family_size']==allocation['family_size']==16 and time['independent_blocks']==12
    interval=time.get('difference_interval');ratio=time.get('effect')
    rows.append({'scenario':name,'state':'completed','sessions':24,'plan_id':plan['id'],'execution_id':objective['execution_id'],
        'median_ns_per_read':{k:statistics.median(v) for k,v in observations.items()},
        'speedup':1/ratio if ratio else None,
        'speedup_interval':{'lower':1/interval['upper'],'upper':1/interval['lower'],'coverage':interval['coverage']} if interval else None,
        'tenfold_lower_bound_reached':bool(interval and interval['upper']<=0.1),
        'time':time,'allocation':allocation,'process_allocation_bytes_observed':sorted(set(process_allocations)),
        'promotion_eligible':objective['promotion_eligible']})
shutdown=read(root/'p18normal-controller-shutdown.json')
assert shutdown['controllerExited'] and shutdown['exitCode']==0
audit={'epoch':'p18normal','control':'f0772c8','candidate':'complete P18 source',
    'planned_cases':8,'planned_sessions':192,'completed_cases':sum(r['state']=='completed' for r in rows),
    'distinct_process_start_identities':len(identities),'complete_joined_correct_quiescent_zero_thread_allocation':not errors and len(identities)==192,
    'all_exported_sessions_joined_correct_quiescent_zero_thread_allocation':True,
    'unit':'one complete public read','cases':rows,'errors':errors,
    'inference_limit':'Declared paired independence assumptions, unresolved C3 precision and allocation models; no fallback/build/bulk/query guard or whole-library adoption claim'}
output.write_text(json.dumps(audit,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in audit.items() if k!='cases'}))
