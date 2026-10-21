"""Audit the complete fixed P34 rejection stage, including every adverse case."""
import json,statistics,hashlib,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
label='p34world';folder=root/(label+'-screen');out=root/'p34-world-stage-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
unwrap=lambda v:json.loads(v['json']) if 'json' in v else v
expected={f'world-{w}-{op}-{pattern}' for w in ['UInt32','UInt16'] for op in ['get','lod','chunk','topology'] for pattern in ['repeated','blocks32','alternating','cycle12','miss']}
plans=read(folder/(label+'-plans.json'));assert len(plans)==40 and {v['scenario'] for v in plans}==expected
ids=set();targets=set();rows=[]
for item in plans:
 name=item['scenario'];plan=item['plan'];stem=folder/(label+'-'+name)
 assert plan['blocks']==4 and plan['warmup_batches']==2 and plan['operations_per_run']==2097152
 assert plan['scenario_version']=='19' and plan['seed']=='20261113' and plan['profile']=='quiet-validation'
 assert plan['analysis']['family_size']==40 and plan['maximum_duration_seconds']==120 and not plan['independent_blocks'] and not plan['confirmatory']
 assert read(Path(str(stem)+'-terminal.json'))['state']=='completed'
 runs=[unwrap(v) for v in read(Path(str(stem)+'-runs.json'))];assert len(runs)==8
 times={a:[] for a in ['baseline','candidate']};allocs={a:[] for a in times};paired={}
 for r in runs:
  assert r['id'] not in ids;ids.add(r['id']);t=r['target'];m=r['measurement'];arm=m['variant']
  targets.add((t['process_id'],t['start_time_utc_ticks']))
  assert t['runtime_version']=='10.0.13' and t['architecture']=='X64' and r['plan_id']==plan['id']
  assert m['correct'] and m['quiescent'] and m['failure'] is None and int(m['completed_operations'])==2097152
  assert m['scenario_version']=='19' and m['input_hash']==plan['input_hash'] and m['start_thread_id']==m['end_thread_id']
  times[arm].append(m['nanoseconds_per_operation']);allocs[arm].append(int(m['thread_allocation_bytes']))
  paired.setdefault(r['block_ordinal'],[]).append(arm)
 assert set(paired)==set(range(4)) and all(sorted(v)==['baseline','candidate'] for v in paired.values())
 comp=unwrap(read(Path(str(stem)+'-comparison.json')))
 time=next(v for v in comp['effects_without_run_ids'] if v['metric']=='scenario.ns_per_operation');speedup=1/time['effect']
 primary=name.endswith('-repeated') and '-topology-' not in name;threshold=1.10 if primary else 1/1.05
 rows.append({'scenario':name,'primary':primary,'threshold':threshold,'pointEstimatePassed':speedup>=threshold,'descriptive_speedup':speedup,'time':time,'median_ns':{a:statistics.median(v) for a,v in times.items()},'allObservedAllocationsZero':{a:all(x==0 for x in v) for a,v in allocs.items()}})
shutdown=read(folder/(label+'-shutdown.json'));assert shutdown['targetExited'] and shutdown['controllerExited'] and shutdown['targetExitCode']==0
assert len(ids)==320 and len(targets)==1 and sum(v['primary'] for v in rows)==6
zero=all(all(v['allObservedAllocationsZero'].values()) for v in rows)
value={'cases':rows,'caseCount':40,'runCount':len(ids),'allCorrectQuiescentJoined':True,'allObservedAllocationsZero':zero,'primaryPassed':all(v['pointEstimatePassed'] for v in rows if v['primary']),'failedGuardCount':sum(not v['pointEstimatePassed'] for v in rows if not v['primary']),'stagePassed':all(v['pointEstimatePassed'] for v in rows) and zero,'independentBlocks':False,'normalConfirmation':False,'scope':'Fixed descriptive rejection stage against complete published source; no application weighting, pooled samples, source promotion or full10x claim.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='cases'}))
