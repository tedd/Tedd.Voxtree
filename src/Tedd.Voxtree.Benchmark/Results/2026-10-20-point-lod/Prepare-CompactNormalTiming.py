"""Freeze all P39N first-family experiments before any timing session."""
import hashlib,json,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;folder=root/'p39-normal';assert not folder.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
gate=read(root/'p39-normal-preflight.json');assert gate['passed'] and gate['comparativeRecords']==0
assert gate['callerMethodsMatched']==35 and gate['semanticCasesPerModule']==107 and gate['storageRootsCleaned']==6
experiments=[]
for d in gate['descriptors']:
 assert d['version']=='25'
 experiment={'id':'prospective-P39N-first-normal','scenario_id':d['id'],'scenario_version':'25','input_hash':d['input_hash'],'variants':['baseline','candidate'],'blocks':12,'operations_per_run':d['operations'],'warmup_batches':1,'seed':'20261118','profile':'quiet-validation','independent_blocks':True,'independence_justification':'Each block uses two fresh joined normal sessions, isolating heap/JIT/PGO/fixture state. Fixed randomized order and shared mutex mitigate drift. Residual paired independence is assumed; process separation alone does not prove it. Thermal state, unrelated load, SMT, heap/code placement, GC and OS file-cache state remain limitations.','confirmatory':True,'maximum_duration_seconds':600,'analysis':{'alpha_family':0.05,'family_size':214,'equivalence_lower_ratio':0.95,'equivalence_upper_ratio':1.05,'useful_improvement_ratio':0.8 if d['primary'] else 0.95,'meaningful_regression_ratio':1.05,'minimum_blocks':10},'primary_metric':'scenario.ns_per_operation','fresh_normal_build':True,'guardrail_metrics':['scenario.thread_allocation_bytes_per_operation'],'guardrail_policies':[{'metric':'scenario.thread_allocation_bytes_per_operation','unit':'bytes/operation','observation_kind':'batch_normalized_allocation_delta','direction':'lower_is_better','scale':'absolute_difference','equivalence_lower':-0.01,'equivalence_upper':0.01,'useful_improvement':-0.01,'meaningful_regression':0.01,'minimum_blocks':10,'descriptive_only':False}],'target_runtime_version':'10.0.13'}
 experiments.append(dict(scenario=d['id'],primary=d['primary'],experiment=experiment))
assert len(experiments)==107 and sum(i['primary'] for i in experiments)==23
for bundle in gate['bundles']:
 for f in bundle['files']:assert sha(Path(f['path']))==f['sha256']
folder.mkdir();(folder/'experiments.json').write_bytes((json.dumps(experiments,indent=2)+'\n').encode())
for original,name in [(root/'p39-source-review.diff','source.diff'),(research/'COMPACT-TERMINAL-NORMAL-PROTOCOL.md','protocol.md')]: (folder/name).write_bytes(original.read_bytes())
value=dict(scope='P39N first P31-local normal family; no adoption/full10x qualification',selected_source='compact-terminal-source',control_source='compact-leaf13-source',cases=107,targets=23,guards=84,maximum_sessions=2568,source_patch_sha256=sha(folder/'source.diff'),protocol_sha256=sha(folder/'protocol.md'),preflight_sha256=sha(root/'p39-normal-preflight.json'),fixture_sha256=gate['fixtureSha256'],caller_methods_matched=35,bundles=gate['bundles'],previous_observations_excluded=True)
(folder/'inputs.json').write_bytes((json.dumps(value,indent=2)+'\n').encode());print(json.dumps({k:v for k,v in value.items() if k!='bundles'}))
