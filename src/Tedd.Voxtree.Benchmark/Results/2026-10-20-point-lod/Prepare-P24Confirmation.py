"""Bind the prospectively selected P24 source to a separate confirmation family."""
import argparse, copy, difflib, hashlib, json, subprocess
from pathlib import Path

p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
task=a.task_root.resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;repo=research.parents[3];root=task/'p24-confirmation'
assert not root.exists(), 'Existing family: inspect accepted records; never replace or resume automatically'
sha=lambda b:hashlib.sha256(b).hexdigest()
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
origin=json.loads((task/'p24-source-origin.json').read_text())
assert origin['hot_word_reader_tail_identical']
review=[];patch=[]
for f in sorted((task/'p24census/source').glob('*.cs')):
    b=task/'p24control/source'/f.name;s=task/'packed-word-format-source'/f.name
    assert norm(f.read_bytes())==norm(s.read_bytes()),f.name
    old=subprocess.run(['git','-C',str(repo),'show',f'f0772c8:src/Tedd.Voxtree/{f.name}'],capture_output=True)
    if old.returncode:
        assert not b.exists() and f.name=='PackedLeafEncoding.cs';before=''
    else:
        assert b.exists() and norm(b.read_bytes())==norm(old.stdout),f.name
        before=norm(b.read_bytes())
    after=norm(f.read_bytes());changed=before!=after
    review.append({'file':f.name,'normalized_changed':changed,'control_sha256':sha(b.read_bytes()) if b.exists() else None,'candidate_sha256':sha(f.read_bytes())})
    if changed:patch.extend(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='a/src/Tedd.Voxtree/'+f.name,tofile='b/src/Tedd.Voxtree/'+f.name))
assert {f.name for f in (task/'p24control/source').glob('*.cs')} <= {f.name for f in (task/'p24census/source').glob('*.cs')}
assert sha((task/'p24control/Program.cs').read_bytes())==sha((task/'p24census/Program.cs').read_bytes())
audit=json.loads((task/'caller-audit-p24normal.json').read_text(encoding='utf-8-sig'))
assert len(audit)==2 and all(len(x['methods'])==8 for x in audit)
for x,y in zip(audit[0]['methods'],audit[1]['methods']):
    assert x['method']==y['method'] and x['resolvedIlSha256']==y['resolvedIlSha256']
bundles=[]
for label in ['p24control','p24census']:
    files=[]
    for f in sorted((task/'bundles'/label).iterdir()):
        assert f.is_file() and f.suffix in {'.dll','.json'}
        files.append({'name':f.name,'path':str(f),'sha256':sha(f.read_bytes())})
    bundles.append({'label':label,'entry':label+'.dll','files':files})
deps=lambda b:{f['name']:f['sha256'] for f in b['files'] if f['name'].endswith('.dll') and f['name']!=b['entry']}
assert deps(bundles[0])==deps(bundles[1])
assert (task/'bundles/p24control/p24control.runtimeconfig.json').read_bytes()==(task/'bundles/p24census/p24census.runtimeconfig.json').read_bytes()
census=json.loads((task/'p24census-audit.json').read_text(encoding='utf-8-sig'))
assert census['cells']==42139648 and census['chunks']==1286 and census['footprint_eligibility_equal_to_p18_census']
old=json.loads((task/'p18-screen/p18normal-plans.json').read_text(encoding='utf-8-sig'))
assert len(old)==8
experiments=[]
for item in old:
    e=copy.deepcopy(item['plan']['experiment'])
    assert e['scenario_version']=='12' and e['blocks']==12 and e['analysis']['family_size']==16
    assert e['profile']=='quiet-validation' and e['target_runtime_version']=='10.0.13'
    assert e['guardrail_policies'][0]['descriptive_only'] is False
    e.update(id='prospective-P24-confirmation',seed='20261026',operations_per_run=100000000,warmup_batches=1,maximum_duration_seconds=600)
    experiments.append({'scenario':item['scenario'],'experiment':e})
root.mkdir()
(root/'source.diff').write_text(''.join(patch),encoding='utf-8')
(root/'experiments.json').write_text(json.dumps(experiments,indent=2)+'\n')
protocol=(research/'PACKED-WORD-FORMAT-PROTOCOL.md').read_bytes();(root/'protocol.md').write_bytes(protocol)
value={'selected_source':'packed-word-format-source','control_revision':'f0772c8','cases':8,'maximum_sessions':192,
       'source_review':review,'source_patch_sha256':sha((root/'source.diff').read_bytes()),'protocol_sha256':sha(protocol),
       'canonical_primary_callers_matched':8,'complete_dependency_closure_matched':True,'runtime_settings_matched':True,
       'fixture_sha256':sha((task/'p24census/Program.cs').read_bytes()),'bundles':bundles,'corpus_audit':census,
       'previous_observations_excluded':True,'primary_target':'Every time speedup adjusted lower bound >=10; all original mandatory guards remain'}
(root/'inputs.json').write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({'root':str(root),'cases':8,'maximum_sessions':192,'changed_files':sum(x['normalized_changed'] for x in review)}))
