"""Freeze diagnostic schedules from P32's actual completed first-eight runs."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args();root=a.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'h2-history-schedule.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert read(root/'p32-disposition.json')['state']=='not_supported'
folder=root/'p32point-screen';plans=read(folder/'p32point-plans.json');first=plans[:8]
expected=[f'point-Force{w}-L5-mixed-u16-air-{access}-{op}' for access in ['owned','span'] for op in ['get','lod'] for w in ['UInt32','UInt16']]
assert [r['scenario'] for r in first]==expected
cases=[]
for item in first:
    name=item['scenario'];plan=item['plan'];path=folder/('p32point-'+name+'-runs.json')
    runs=[json.loads(r['json']) for r in read(path)];runs.sort(key=lambda r:int(r['measurement']['start_ticks']))
    assert plan['scenario_version']=='17' and plan['blocks']==4 and plan['warmup_batches']==2 and plan['operations_per_run']==2097152
    assert len(runs)==8 and [r['block_ordinal'] for r in runs]==[0,0,1,1,2,2,3,3]
    for r in runs:assert r['measurement']['correct'] and r['measurement']['quiescent'] and r['measurement']['scenario_version']=='17'
    cases.append({'scenario':name,'version':'17','inputHash':plan['input_hash'],'operationCount':2097152,'warmupBatches':2,'resetAfterWarmup':True,'runsSourceSha256':sha(path),
                  'runs':[{'sourceRunId':r['id'],'block':r['block_ordinal'],'variant':r['measurement']['variant']} for r in runs]})
value={'bundle':'p32point','bundleSha256':sha(root/'bundles/p32point/p32point.dll'),'source':'original P32 first-eight plans and chronological run records','getFirst':cases,'lodFirst':[r for r in cases if r['scenario'].endswith('-lod')],'timingClaim':False,'limits':'Recorded within-scenario arm order and semantic call sequence; controller/GC/JIT timing and exact quiet code identity are not reproduced.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({'getFirstCases':len(cases),'lodFirstCases':len(value['lodFirst']),'getFirstRuns':64,'lodFirstRuns':32,'timedRuns':0}))
