"""Bind P30's two-codec delta and actual paired/release corpus snapshots."""
import argparse,difflib,hashlib,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path(__file__).resolve().parents[4];out=root/'p30-source-review.json';patch=root/'p30-source-review.diff'
assert not out.exists() and not patch.exists()
before=root/'byte-palette-source';after=root/'build-plan-reuse-source'
origin=json.loads((root/'p30-source-origin.json').read_text(encoding='utf-8-sig'))
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
sha=lambda b:hashlib.sha256(b).hexdigest()
assert {f.name for f in before.glob('*.cs')}=={f.name for f in after.glob('*.cs')}
diff=[];changed=[]
for item in origin['manifest']:
    name=item['file'];x=(before/name).read_bytes();y=(after/name).read_bytes()
    assert sha(x)==item['before_sha256'] and sha(y)==item['after_sha256']
    nx=norm(x);ny=norm(y)
    for label in ['p30point','p30bulk','p30census']:
        assert ny==norm((root/f'{label}/source'/name).read_bytes()),(label,name)
        control=root/f'{label}-baseline'/name
        if label=='p30census':
            release=subprocess.run(['git','-C',str(repo),'show',f'f0772c8:src/Tedd.Voxtree/{name}'],capture_output=True)
            if release.returncode==0:assert norm(release.stdout)==norm(control.read_bytes()).replace('Snapshot.Voxtree','Tedd.Voxtree'),name
            else:assert name=='PaletteLeafEncoding.cs' and not control.exists()
        else:assert nx==norm(control.read_bytes()).replace('Snapshot.Voxtree','Tedd.Voxtree'),(label,name)
    if nx!=ny:
        changed.append(name);diff.extend(difflib.unified_diff(nx.splitlines(True),ny.splitlines(True),fromfile='a/'+name,tofile='b/'+name))
assert set(changed)=={'OctreeCodec.cs','GenericOctreeCodec.cs'},changed
for binding in origin['planned_body_bindings']:
    name=binding['file'];text=(after/name).read_text(encoding='utf-8-sig')
    start=text.index('        if (palettePlan.StorageKind == StorageKind.PackedLeaf')
    end=text.index('    internal static bool TryReadHeader(',start)
    assert sha(text[start:end].encode())==binding['unchanged_planned_body_sha256'],name
patch.write_text(''.join(diff),encoding='utf-8')
value={'control':'complete P27 for point/bulk, f0772c8 for corpus','treatment':'build-plan-reuse-source','changed_files':changed,'complete_compiled_snapshots_matched':True,'unchanged_planned_write_bodies':origin['planned_body_bindings'],'patch_sha256':sha(patch.read_bytes()),'manifest':origin['manifest']}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='manifest'}))
