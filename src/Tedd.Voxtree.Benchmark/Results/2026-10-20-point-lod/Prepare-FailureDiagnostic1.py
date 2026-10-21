"""Bind D1 to archived inputs without changing the original failed catalog."""
import argparse,hashlib,json,zipfile
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
task=args.task_root.resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;root=task/'p18-failure-diagnostic-1'
assert not root.exists(), 'D1 exists; inspect accepted records before recovery'
sha=lambda b:hashlib.sha256(b).hexdigest()
archive=research/'evidence-phase7.zip'
assert sha(archive.read_bytes())==(research/'evidence-phase7.sha256').read_text().split()[0]
with zipfile.ZipFile(archive) as z:
    paths={v['path']:v for v in json.loads(z.read('manifest.json'))}
    raw=lambda name:z.read(paths[name]['blob'])
    plans=json.loads(raw('p18-screen/p18normal-plans.json'))
    assert len(plans)==8
    bundles=[]
    for label in ['p18control','p18census']:
        folder=task/'bundles'/label;files=[]
        for file in sorted(folder.iterdir()):
            assert file.is_file() and file.suffix in {'.dll','.json'}
            name=file.relative_to(task).as_posix();digest=sha(file.read_bytes())
            assert digest==paths[name]['sha256'],name
            files.append({'name':file.name,'path':str(file),'sha256':digest})
        bundles.append({'label':label,'entry':label+'.dll','files':files})
    old_failed=json.loads(raw('p18-screen/p18normal-point-ForceUInt32-L5-mixed-u16-air-span-get-terminal.json'))
    assert old_failed['state']=='failed' and old_failed['error_code']=='confirmation_failed'
    patch=raw('p18normal-source.diff')
    experiments=[]
    for item in plans:
        e=item['plan']['experiment']
        assert e['scenario_id']==item['scenario'] and e['scenario_version']=='12'
        assert e['blocks']==12 and int(e['operations_per_run'])==8388608 and e['warmup_batches']==1
        assert e['maximum_duration_seconds']==600 and e['profile']=='quiet-validation' and e.get('baseline') is None
        e['id']='prospective-D1-diagnostic';e['seed']='20261024'
        e['independence_justification']='Fresh-session lifecycle diagnostic only. API-required design flags do not qualify these observed sessions as statistical or promotion evidence; no comparisons are permitted.'
        experiments.append({'scenario':item['scenario'],'experiment':e})
    root.mkdir()
    (root/'source.diff').write_bytes(patch)
    (root/'experiments.json').write_text(json.dumps(experiments,indent=2)+'\n')
    protocol=(research/'FAILURE-DIAGNOSTIC-1.md').read_bytes();(root/'protocol.md').write_bytes(protocol)
    value={'purpose':'failure diagnostic only; no performance comparison/promotion',
        'promotion_eligible':False,'maximum_sessions':192,'original_failed_operation':old_failed,
        'archive_sha256':sha(archive.read_bytes()),'original_plans_sha256':paths['p18-screen/p18normal-plans.json']['sha256'],
        'source_patch_sha256':sha(patch),'protocol_sha256':sha(protocol),'bundles':bundles}
    (root/'inputs.json').write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({'root':str(root),'cases':len(experiments),'maximum_sessions':192,'bundles_verified_against_frozen_archive':True}))
