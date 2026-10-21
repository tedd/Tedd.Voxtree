"""Validate and summarize the complete frozen exploratory consumer family."""
import argparse
import hashlib
import json
import statistics
from pathlib import Path

parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path)
parser.add_argument('--label',choices=['p18bulk','p19bulk','p20bulk','p21bulk','p22bulk','p23bulk','p25bulk','p26bulk'],default='p18bulk');args=parser.parse_args()
task=args.task_root.resolve()
if task!=Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():raise SystemExit('Unexpected task root')
label=args.label
version,family,control,treatment={'p18bulk':('13',88,'f0772c8','complete P18 source'),
    'p19bulk':('13',88,'complete P18 source','P19 count specialization'),
    'p20bulk':('14',96,'P19 count specialization','P20 validated vector counts'),
    'p21bulk':('14',96,'P20 validated vector counts','P21 vector helper boundary'),
    'p22bulk':('13',88,'f0772c8','P22 linear leaf specialization'),
    'p23bulk':('13',88,'f0772c8','P23 measurement-only token lengths'),
    'p25bulk':('13',88,'complete P24 source','P25 bottom-up packed writer'),
    'p26bulk':('13',88,'complete P25 source','P26 stop initialized single-voxel fills')}[label]
root=task/(label+'-screen');output=task/(label+'-audit.json')
if output.exists():raise SystemExit('Preserve original bulk audit')
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
unwrap=lambda v:json.loads(v['json']) if 'json' in v else v
ops=['construct','build','callerbuild','trybuild','required','fromencoded','copy','validate','count','miss','buildread']
patterns=['mixed-u16-air','mixed-u7-air','mixed-u8-air','uniform-u7-empty']
expected={f'bulk-{width}-L5-{pattern}-{op}' for width in ['UInt16','UInt32'] for pattern in patterns for op in ops}
if version=='14':expected.update(f'bulk-{width}-L5-mixed-u16-air-{op}' for width in ['UInt16','UInt32'] for op in ['count7','miss7','count17','miss17'])
plans=read(root/(label+'-plans.json'));assert len(plans)==family and {p['scenario'] for p in plans}==expected
rows=[];ids=set();targets=set()
for item in plans:
    name=item['scenario'];plan=item['plan'];op=name.rsplit('-',1)[1]
    count=2 if op=='buildread' else 64 if op in ['copy','validate','count','miss','count7','miss7','count17','miss17'] else 16
    assert plan['scenario_version']==version and plan['operations_per_run']==count and plan['blocks']==12
    assert plan['analysis']['family_size']==family and plan['warmup_batches']==4 and not plan['independent_blocks']
    assert plan['maximum_duration_seconds']==120 and plan['profile']=='quiet-validation'
    if label=='p25bulk':assert plan['seed']=='20261027'
    if label=='p26bulk':assert plan['seed']=='20261028'
    stem=root/(label+'-'+name);terminal=read(Path(str(stem)+'-terminal.json'));assert terminal['state']=='completed'
    runs=[unwrap(v) for v in read(Path(str(stem)+'-runs.json'))];assert len(runs)==24
    observations={a:[] for a in ['baseline','candidate']};allocations={a:[] for a in observations};blocks={}
    for run in runs:
        assert run['id'] not in ids;ids.add(run['id']);target=run['target'];m=run['measurement'];arm=m['variant']
        targets.add((target['process_id'],target['start_time_utc_ticks']))
        assert target['runtime_version']=='10.0.13' and target['architecture']=='X64'
        assert m['correct'] and m['quiescent'] and m['failure'] is None and int(m['completed_operations'])==count
        assert m['scenario_version']==version and m['input_hash']==plan['input_hash'] and run['plan_id']==plan['id']
        assert m['start_thread_id']==m['end_thread_id']
        observations[arm].append(m['nanoseconds_per_operation'])
        allocations[arm].append(int(m['thread_allocation_bytes'])/count)
        blocks.setdefault(run['block_ordinal'],[]).append(arm)
    assert set(blocks)==set(range(12)) and all(sorted(v)==['baseline','candidate'] for v in blocks.values())
    comparison=unwrap(read(Path(str(stem)+'-comparison.json')))
    time=next(v for v in comparison['effects_without_run_ids'] if v['metric']=='scenario.ns_per_operation')
    rows.append({'scenario':name,'operation':op,'logical_operations_per_run':count,'run_records':24,
        'descriptive_speedup':1/time['effect'],'time':time,
        'median_ns_per_complete_operation':{a:statistics.median(v) for a,v in observations.items()},
        'median_thread_allocated_bytes_per_complete_operation':{a:statistics.median(v) for a,v in allocations.items()}})
assert len(ids)==family*24 and len(targets)==1
shutdown=read(root/(label+'-shutdown.json'));assert shutdown['targetExited'] and shutdown['controllerExited'] and shutdown['targetExitCode']==0
value={'cases':rows,'complete_cases':len(rows),'run_records':len(ids),'process_start_identities':[list(t) for t in targets],
       'all_correct_quiescent_joined':True,'independent_blocks':False,'control':control,'treatment':treatment,
       'inference':'Exploratory same-process cost and allocation observations, no fresh guard qualification; includes all adverse results'}
output.write_text(json.dumps(value,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in value.items() if k!='cases'}))
