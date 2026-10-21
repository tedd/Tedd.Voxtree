"""Freeze the real selected builds and first normal family before new data."""
import hashlib,json,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;folder=root/'p36-normal-screen';assert not folder.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
gate=read(root/'p36-normal-preflight.json');assert gate['passed'] and gate['callerMethodsMatched']==8 and gate['comparativeRecords']==0
inventory=read(root/'p36-normal-scenarios.json');assert len(inventory)==2 and all(len(v['descriptors'])==48 for v in inventory)
descriptors={v['id']:v for v in inventory[0]['descriptors']};assert descriptors=={v['id']:v for v in inventory[1]['descriptors']}
names=[f'normal-world-{w}-{op}-{pattern}' for op in ['get','lod','chunk'] for pattern in ['cycle12','repeated'] for w in ['UInt32','UInt16']]
assert len(names)==12 and all(n in descriptors for n in names)
experiments=[]
for name in names:
 d=descriptors[name];assert d['version']=='22';primary=name.endswith('-cycle12')
 experiment={'id':'prospective-P36-first-normal','scenario_id':name,'scenario_version':'22','input_hash':d['input_hash'],'variants':['baseline','candidate'],'blocks':12,'operations_per_run':16777216,'warmup_batches':1,'seed':'20261116','profile':'quiet-validation','independent_blocks':True,'independence_justification':'Each block consists of two newly launched/joined normal processes with no shared heap/JIT/PGO/fixture state. Fixed randomized arm order and shared host admission control drift; independence assumes residual errors after pairing are uncorrelated. Process-specific default hash seeds, heap placement, hardware/thermal state and unrelated load remain limitations.','confirmatory':True,'maximum_duration_seconds':600,'analysis':{'alpha_family':0.05,'family_size':24,'equivalence_lower_ratio':0.95,'equivalence_upper_ratio':1.05,'useful_improvement_ratio':1/1.10 if primary else 0.95,'meaningful_regression_ratio':1.05,'minimum_blocks':10},'primary_metric':'scenario.ns_per_operation','fresh_normal_build':True,'guardrail_metrics':['scenario.thread_allocation_bytes_per_operation'],'guardrail_policies':[{'metric':'scenario.thread_allocation_bytes_per_operation','unit':'bytes/operation','observation_kind':'batch_normalized_allocation_delta','direction':'lower_is_better','scale':'absolute_difference','equivalence_lower':-0.01,'equivalence_upper':0.01,'useful_improvement':-0.01,'meaningful_regression':0.01,'minimum_blocks':10,'descriptive_only':False}],'target_runtime_version':'10.0.13'}
 experiments.append({'scenario':name,'primary':primary,'experiment':experiment})
for bundle in gate['bundles']:
 for f in bundle['files']:assert sha(Path(f['path']))==f['sha256']
folder.mkdir();(folder/'experiments.json').write_text(json.dumps(experiments,indent=2)+'\n')
for origin,name in [(root/'p36-source.diff','source.diff'),(research/'WORLD-NORMAL-PROTOCOL.md','protocol.md')]: (folder/name).write_bytes(origin.read_bytes())
value={'scope':'P36 first fresh-normal family; no adoption or complete10x qualification','selected_source':'cache-maintenance-source','control_revision':'f0772c8','cases':12,'maximum_sessions':288,'source_patch_sha256':sha(folder/'source.diff'),'protocol_sha256':sha(folder/'protocol.md'),'preflight_sha256':sha(root/'p36-normal-preflight.json'),'fixture_sha256':gate['fixtureSha256'],'caller_methods_matched':8,'bundles':gate['bundles'],'previous_observations_excluded':True}
(folder/'inputs.json').write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='bundles'}))
