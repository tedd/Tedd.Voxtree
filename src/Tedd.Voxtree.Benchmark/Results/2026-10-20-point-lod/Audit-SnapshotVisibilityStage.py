"""Audit each prospectively bounded P33 point stage; never pool stages."""
import argparse,json,statistics
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);p.add_argument('--stage',choices=['get-first','lod-first','full-get-first','full-lod-first'],required=True);a=p.parse_args();root=a.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
label,blocks,warmups,seed={
 'get-first':('p33point',4,2,'20261108'),'lod-first':('p33lod',4,2,'20261109'),
 'full-get-first':('p33point-full',12,4,'20261110'),'full-lod-first':('p33lod-full',12,4,'20261111')}[a.stage]
lod=a.stage.endswith('lod-first');full=a.stage.startswith('full-');folder=root/(label+'-screen');out=root/(label+'-audit.json');assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));unwrap=lambda v:json.loads(v['json']) if 'json' in v else v
patterns=['mixed-u16-air','mixed-u7-air','mixed-u8-air','uniform-u7-empty']
expected={f'point-Force{w}-L5-mixed-u16-air-{access}-lod' for w in ['UInt32','UInt16'] for access in ['owned','span']}
if not lod:
    expected={f'point-Force{w}-L5-{p}-{access}-{op}' for w in ['UInt32','UInt16'] for p in patterns for access in ['owned','span'] for op in ['get','lod']}
    expected.update(f'point-ForceUInt32-L5-{p}-compiled-{op}' for p in patterns for op in ['get','lod','create','lifecycle'])
plans=read(folder/(label+'-plans.json'));assert len(plans)==len(expected) and {r['scenario'] for r in plans}==expected
rows=[];ids=set();targets=set()
for item in plans:
    name=item['scenario'];plan=item['plan'];stem=folder/(label+'-'+name)
    count=256 if name.endswith('-create') else 16 if name.endswith('-lifecycle') else 33554432 if '-compiled-' in name or '-uniform-' in name else 2097152
    assert plan['blocks']==blocks and plan['warmup_batches']==warmups and plan['operations_per_run']==count
    assert plan['scenario_version']=='18' and plan['seed']==seed and plan['profile']=='quiet-validation' and plan['analysis']['family_size']==len(expected)
    assert plan['maximum_duration_seconds']==120 and not plan['independent_blocks'] and not plan['confirmatory']
    assert read(Path(str(stem)+'-terminal.json'))['state']=='completed'
    runs=[unwrap(v) for v in read(Path(str(stem)+'-runs.json'))];assert len(runs)==2*blocks
    times={k:[] for k in ['baseline','candidate']};allocs={k:[] for k in times};paired={}
    for run in runs:
        assert run['id'] not in ids;ids.add(run['id']);t=run['target'];m=run['measurement'];arm=m['variant']
        targets.add((t['process_id'],t['start_time_utc_ticks']))
        assert t['runtime_version']=='10.0.13' and t['architecture']=='X64' and run['plan_id']==plan['id']
        assert m['correct'] and m['quiescent'] and m['failure'] is None and int(m['completed_operations'])==count
        assert m['scenario_version']=='18' and m['input_hash']==plan['input_hash'] and m['start_thread_id']==m['end_thread_id']
        times[arm].append(m['nanoseconds_per_operation']);allocs[arm].append(int(m['thread_allocation_bytes'])/count);paired.setdefault(run['block_ordinal'],[]).append(arm)
    assert set(paired)==set(range(blocks)) and all(sorted(v)==['baseline','candidate'] for v in paired.values())
    comparison=unwrap(read(Path(str(stem)+'-comparison.json')));time=next(v for v in comparison['effects_without_run_ids'] if v['metric']=='scenario.ns_per_operation');speedup=1/time['effect']
    dominant='-mixed-u16-air-' in name and '-compiled-' not in name
    primary=not lod and dominant and '-owned-' in name and name.endswith('-lod')
    threshold=1.1 if primary else 1/1.05 if lod or full or dominant else 1/1.1
    rows.append({'scenario':name,'primary':primary,'dominantOther':not lod and dominant and not primary,'speedupThreshold':threshold,'pointEstimatePassed':speedup>=threshold,'descriptive_speedup':speedup,'time':time,'run_records':2*blocks,'median_ns_per_registered_operation':{k:statistics.median(v) for k,v in times.items()},'median_thread_allocated_bytes_per_registered_operation':{k:statistics.median(v) for k,v in allocs.items()},'every_observed_thread_allocation_zero':{k:all(x==0 for x in v) for k,v in allocs.items()}})
assert len(ids)==len(expected)*2*blocks and len(targets)==1 and sum(r['primary'] for r in rows)==(0 if lod else 2)
shutdown=read(folder/(label+'-shutdown.json'));assert shutdown['targetExited'] and shutdown['controllerExited'] and shutdown['targetExitCode']==0
value={'stage':a.stage,'complete_cases':len(rows),'run_records':len(ids),'all_correct_quiescent_joined':True,'independent_blocks':False,'stagePassed':all(r['pointEstimatePassed'] for r in rows),'primaryPassed':all(r['pointEstimatePassed'] for r in rows if r['primary']),'adverseOtherDominant':sum(not r['pointEstimatePassed'] for r in rows if r['dominantOther']),'adverseOtherGuards':sum(not r['pointEstimatePassed'] for r in rows if not r['primary'] and not r['dominantOther']),'cases':rows,'control':'complete P31, unpromoted','treatment':'P33 two AsSpan implementation flags','inference':'Separate non-independent exploratory stage, no pooled records, confidence-based promotion, direct-release ratio or API completion claim.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='cases'}))
