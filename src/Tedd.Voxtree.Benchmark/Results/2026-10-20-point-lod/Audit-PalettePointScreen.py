"""Audit the entire new 48-case, one-read point family; no old data pooling."""
import argparse,json,statistics
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);p.add_argument('--label',choices=['p27point','p29point','p31point'],default='p27point');a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
label=a.label;folder=root/(label+'-screen');out=root/(label+'-audit.json');assert not out.exists()
seed={'p27point':'20261029','p29point':'20261101','p31point':'20261103'}[label]
version='16' if label=='p31point' else '15'
primary_count,threshold={'p27point':(8,10),'p29point':(4,1.1),'p31point':(8,1.2)}[label]
read=lambda f:json.loads(f.read_text(encoding='utf-8-sig'))
unwrap=lambda v:json.loads(v['json']) if isinstance(v,dict) and 'json' in v else v
patterns=['mixed-u16-air','mixed-u7-air','mixed-u8-air','uniform-u7-empty']
expected={f'point-Force{t}-L5-{pattern}-{access}-{op}' for t in ['UInt16','UInt32'] for pattern in patterns for access in ['owned','span'] for op in ['get','lod']}
expected.update(f'point-ForceUInt32-L5-{pattern}-compiled-{op}' for pattern in patterns for op in ['get','lod','create','lifecycle'])
plans=read(folder/(label+'-plans.json'));assert len(plans)==48 and {i['scenario'] for i in plans}==expected
ids=set();targets=set();rows=[]
for item in plans:
    name=item['scenario'];plan=item['plan'];stem=folder/(label+'-'+name)
    count=256 if name.endswith('-create') else 16 if name.endswith('-lifecycle') else 33554432 if '-compiled-' in name or '-uniform-' in name else 2097152
    assert plan['scenario_version']==version and int(plan['operations_per_run'])==count and plan['blocks']==12 and plan['warmup_batches']==4
    assert plan['seed']==seed and plan['analysis']['family_size']==48 and plan['profile']=='quiet-validation'
    assert plan['maximum_duration_seconds']==120 and not plan['independent_blocks'] and not plan['confirmatory']
    assert read(Path(str(stem)+'-terminal.json'))['state']=='completed'
    runs=[unwrap(v) for v in read(Path(str(stem)+'-runs.json'))];assert len(runs)==24
    times={'baseline':[],'candidate':[]};allocs={k:[] for k in times};blocks={}
    for run in runs:
        assert run['id'] not in ids;ids.add(run['id']);t=run['target'];m=run['measurement'];arm=m['variant']
        targets.add((t['process_id'],t['start_time_utc_ticks']))
        assert t['runtime_version']=='10.0.13' and t['architecture']=='X64' and run['plan_id']==plan['id']
        assert m['correct'] and m['quiescent'] and m['failure'] is None and int(m['completed_operations'])==count
        assert m['scenario_version']==version and m['input_hash']==plan['input_hash'] and m['start_thread_id']==m['end_thread_id']
        times[arm].append(m['nanoseconds_per_operation']);allocs[arm].append(int(m['thread_allocation_bytes'])/count)
        blocks.setdefault(run['block_ordinal'],[]).append(arm)
    assert set(blocks)==set(range(12)) and all(sorted(v)==['baseline','candidate'] for v in blocks.values())
    comparison=unwrap(read(Path(str(stem)+'-comparison.json')))
    time=next(v for v in comparison['effects_without_run_ids'] if v['metric']=='scenario.ns_per_operation')
    primary='-mixed-u16-air-' in name and '-compiled-' not in name and (label!='p29point' or name.startswith('point-ForceUInt32-'))
    rows.append({'scenario':name,'primary':primary,'descriptive_speedup':1/time['effect'],'time':time,'run_records':24,
                 'median_ns_per_registered_operation':{k:statistics.median(v) for k,v in times.items()},
                 'median_thread_allocated_bytes_per_registered_operation':{k:statistics.median(v) for k,v in allocs.items()},
                 'every_observed_thread_allocation_zero':{k:all(x==0 for x in v) for k,v in allocs.items()}})
assert len(ids)==1152 and len(targets)==1 and sum(r['primary'] for r in rows)==primary_count
shutdown=read(folder/(label+'-shutdown.json'));assert shutdown['targetExited'] and shutdown['controllerExited'] and shutdown['targetExitCode']==0
primary=[r for r in rows if r['primary']];guards=[r for r in rows if not r['primary']]
value={'complete_cases':48,'run_records':1152,'all_correct_quiescent_joined':True,'independent_blocks':False,'cases':rows,
       'primary_count':primary_count,'primary_speedup_threshold':threshold,'all_primary_point_estimates_passed':all(r['descriptive_speedup']>=threshold for r in primary),
       'adverse_other_time_guards':sum(r['descriptive_speedup']<1/1.05 for r in guards),
       'inference':'Separate exploratory same-process namespace screen; no fresh-build confirmation, no pooled older data and no source adoption'}
if label=='p27point':value['all_eight_tenfold_point_estimates']=value['all_primary_point_estimates_passed']
elif label=='p29point':value.update(control='complete P27 byte-palette-source',treatment='P29 direct throwing palette path',guard_count=44)
else:value.update(control='complete P30 build-plan-reuse-source',treatment='P31 compact R word format and consumers',guard_count=40)
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='cases'}))
