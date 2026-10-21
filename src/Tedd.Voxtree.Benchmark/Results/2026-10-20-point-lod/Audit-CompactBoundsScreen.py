"""Audit P32's complete prespecified rejection stage; never add samples."""
import argparse,json,statistics
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args();root=a.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
folder=root/'p32point-screen';out=root/'p32point-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));unwrap=lambda v:json.loads(v['json']) if 'json' in v else v
patterns=['mixed-u16-air','mixed-u7-air','mixed-u8-air','uniform-u7-empty']
expected={f'point-Force{w}-L5-{p}-{a}-{o}' for w in ['UInt32','UInt16'] for p in patterns for a in ['owned','span'] for o in ['get','lod']}
expected.update(f'point-ForceUInt32-L5-{p}-compiled-{o}' for p in patterns for o in ['get','lod','create','lifecycle'])
plans=read(folder/'p32point-plans.json');assert len(plans)==48 and {r['scenario'] for r in plans}==expected
rows=[];ids=set();targets=set()
for item in plans:
    name=item['scenario'];plan=item['plan'];stem=folder/('p32point-'+name)
    count=256 if name.endswith('-create') else 16 if name.endswith('-lifecycle') else 33554432 if '-compiled-' in name or '-uniform-' in name else 2097152
    assert plan['blocks']==4 and plan['warmup_batches']==2 and plan['operations_per_run']==count
    assert plan['scenario_version']=='17' and plan['seed']=='20261105' and plan['profile']=='quiet-validation' and plan['analysis']['family_size']==48
    assert not plan['independent_blocks'] and not plan['confirmatory'] and plan['maximum_duration_seconds']==120
    assert read(Path(str(stem)+'-terminal.json'))['state']=='completed'
    runs=[unwrap(v) for v in read(Path(str(stem)+'-runs.json'))];assert len(runs)==8
    times={k:[] for k in ['baseline','candidate']};allocs={k:[] for k in times};blocks={}
    for run in runs:
        assert run['id'] not in ids;ids.add(run['id']);t=run['target'];m=run['measurement'];arm=m['variant']
        targets.add((t['process_id'],t['start_time_utc_ticks']))
        assert t['runtime_version']=='10.0.13' and t['architecture']=='X64' and run['plan_id']==plan['id']
        assert m['correct'] and m['quiescent'] and m['failure'] is None and int(m['completed_operations'])==count
        assert m['scenario_version']=='17' and m['input_hash']==plan['input_hash'] and m['start_thread_id']==m['end_thread_id']
        times[arm].append(m['nanoseconds_per_operation']);allocs[arm].append(int(m['thread_allocation_bytes'])/count)
        blocks.setdefault(run['block_ordinal'],[]).append(arm)
    assert set(blocks)==set(range(4)) and all(sorted(v)==['baseline','candidate'] for v in blocks.values())
    comparison=unwrap(read(Path(str(stem)+'-comparison.json')))
    time=next(v for v in comparison['effects_without_run_ids'] if v['metric']=='scenario.ns_per_operation')
    speedup=1/time['effect'];dominant='-mixed-u16-air-' in name and '-compiled-' not in name
    primary=dominant and name.startswith('point-ForceUInt32-') and name.endswith('-lod')
    threshold=1.1 if primary else 1/1.05 if dominant else 1/1.1
    rows.append({'scenario':name,'primary':primary,'dominantOther':dominant and not primary,'speedupThreshold':threshold,'pointEstimatePassed':speedup>=threshold,'descriptive_speedup':speedup,'time':time,'run_records':8,'median_ns_per_registered_operation':{a:statistics.median(v) for a,v in times.items()},'median_thread_allocated_bytes_per_registered_operation':{a:statistics.median(v) for a,v in allocs.items()},'every_observed_thread_allocation_zero':{a:all(x==0 for x in v) for a,v in allocs.items()}})
assert len(ids)==384 and len(targets)==1 and sum(r['primary'] for r in rows)==2 and sum(r['dominantOther'] for r in rows)==6
shutdown=read(folder/'p32point-shutdown.json');assert shutdown['targetExited'] and shutdown['controllerExited'] and shutdown['targetExitCode']==0
value={'complete_cases':48,'run_records':384,'all_correct_quiescent_joined':True,'independent_blocks':False,'control':'complete P31, unpromoted','treatment':'P32 one checked-word-reader delta','stage':'fixed rejection stage only','stagePassed':all(r['pointEstimatePassed'] for r in rows),'primaryPassed':all(r['pointEstimatePassed'] for r in rows if r['primary']),'adverseOtherDominant':sum(not r['pointEstimatePassed'] for r in rows if r['dominantOther']),'adverseOtherGuards':sum(not r['pointEstimatePassed'] for r in rows if not r['primary'] and not r['dominantOther']),'cases':rows,'inference':'Four non-independent paired blocks; retain insufficient-independent-evidence and allocation model flags. No confidence, normal confirmation, release ratio or adoption claim.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='cases'}))
