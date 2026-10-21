"""Bind the isolated owned getter delta to both actual compiled snapshots."""
import argparse,difflib,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
before=root/'byte-palette-source';after=root/'owned-lod-direct-source'
out=root/'p28-source-review.json';patch=root/'p28-source-review.diff';assert not out.exists() and not patch.exists()
origin=json.loads((root/'p28-source-origin.json').read_text(encoding='utf-8-sig'))
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
sha=lambda b:hashlib.sha256(b).hexdigest()
assert {f.name for f in before.glob('*.cs')}=={f.name for f in after.glob('*.cs')}
diff=[];changed=[]
for item in origin['manifest']:
    name=item['file'];x=(before/name).read_bytes();y=(after/name).read_bytes()
    assert sha(x)==item['before_sha256'] and sha(y)==item['after_sha256']
    nx=norm(x);ny=norm(y)
    assert nx==norm((root/'p28point-baseline'/name).read_bytes()).replace('Snapshot.Voxtree','Tedd.Voxtree'),name
    assert ny==norm((root/'p28point/source'/name).read_bytes()),name
    if nx!=ny:
        changed.append(name);diff.extend(difflib.unified_diff(nx.splitlines(True),ny.splitlines(True),fromfile='a/'+name,tofile='b/'+name))
assert changed==['Octree.Generic.cs','Octree.cs'],changed
patch.write_text(''.join(diff),encoding='utf-8')
value={'control':'complete P27 byte-palette-source','treatment':'owned-lod-direct-source','changed_files':changed,'complete_compiled_snapshots_matched':True,'patch_sha256':sha(patch.read_bytes()),'manifest':origin['manifest']}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='manifest'}))
