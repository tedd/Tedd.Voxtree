"""Complete fixed P35 stage audit; retain all adverse/quality evidence."""
import json,statistics,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
label='p35world';folder=root/(label+'-screen');out=root/'p35-world-stage-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));unwrap=lambda v:json.loads(v['json']) if 'json' in v else v
expected={f'world-{w}-{op}-{pattern}' for w in ['UInt32','UInt16'] for op in ['get','lod','chunk','topology','absent'] for pattern in ['repeated','blocks32','alternating','cycle12','miss','saturated']}
plans=read(folder/(label+'-plans.json'));assert len(plans)==60 and {v['scenario'] for v in plans}==expected
ids=set();targets=set();rows=[]
for item in plans:
 name=item['scenario'];plan=item['plan'];stem=folder/(label+'-'+name)
 assert plan['blocks']==4 and plan['warmup_batches']==2 and plan['operations_per_run']==2097152
 assert plan['scenario_version']=='20' and plan['seed']=='20261114' and plan['profile']=='quiet-validation' and plan['analysis']['family_size']==60
 assert plan['maximum_duration_seconds']==120 and not plan['independent_blocks'] and not plan['confirmatory']
 assert read(Path(str(stem)+'-terminal.json'))['state']=='completed'
 runs=[unwrap(v) for v in read(Path(str(stem)+'-runs.json'))];assert len(runs)==8
 times={a:[] for a in ['baseline','candidate']};allocs={a:[] for a in times};paired={}
 for r in runs:
  assert r['id'] not in ids;ids.add(r['id']);t=r['target'];m=r['measurement'];arm=m['variant'];targets.add((t['process_id'],t['start_time_utc_ticks']))
  assert t['runtime_version']=='10.0.13' and t['architecture']=='X64' and r['plan_id']==plan['id']
  assert m['correct'] and m['quiescent'] and m['failure'] is None and int(m['completed_operations'])==2097152
  assert m['scenario_version']=='20' and m['input_hash']==plan['input_hash'] and m['start_thread_id']==m['end_thread_id']
  times[arm].append(m['nanoseconds_per_operation']);allocs[arm].append(int(m['thread_allocation_bytes']));paired.setdefault(r['block_ordinal'],[]).append(arm)
 assert set(paired)==set(range(4)) and all(sorted(v)==['baseline','candidate'] for v in paired.values())
 comp=unwrap(read(Path(str(stem)+'-comparison.json')));time=next(v for v in comp['effects_without_run_ids'] if v['metric']=='scenario.ns_per_operation');speedup=1/time['effect']
 absent='-absent-' in name and not name.endswith('-saturated');topology='-topology-' in name and (name.endswith('-repeated') or name.endswith('-blocks32'));primary=absent or topology;threshold=2 if absent else 1.20 if topology else 1/1.05
 rows.append({'scenario':name,'primary':primary,'absentPrimary':absent,'topologyPrimary':topology,'threshold':threshold,'pointEstimatePassed':speedup>=threshold,'descriptive_speedup':speedup,'time':time,'median_ns':{a:statistics.median(v) for a,v in times.items()},'allObservedAllocationsZero':{a:all(x==0 for x in v) for a,v in allocs.items()}})
shutdown=read(folder/(label+'-shutdown.json'));assert shutdown['targetExited'] and shutdown['controllerExited'] and shutdown['targetExitCode']==0
assert len(ids)==480 and len(targets)==1 and sum(v['absentPrimary'] for v in rows)==10 and sum(v['topologyPrimary'] for v in rows)==4
zero=all(all(v['allObservedAllocationsZero'].values()) for v in rows)
value={'cases':rows,'caseCount':60,'runCount':len(ids),'allCorrectQuiescentJoined':True,'allObservedAllocationsZero':zero,'primaryPassed':all(v['pointEstimatePassed'] for v in rows if v['primary']),'failedPrimaryCount':sum(not v['pointEstimatePassed'] for v in rows if v['primary']),'failedGuardCount':sum(not v['pointEstimatePassed'] for v in rows if not v['primary']),'stagePassed':all(v['pointEstimatePassed'] for v in rows) and zero,'independentBlocks':False,'normalConfirmation':False,'scope':'Complete fixed descriptive namespace-paired stage on published source; no application weighting, pooled observations, promotion or full10x claim.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='cases'}))
