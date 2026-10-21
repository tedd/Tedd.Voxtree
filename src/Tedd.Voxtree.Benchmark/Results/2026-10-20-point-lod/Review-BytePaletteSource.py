"""Bind complete release/control and P27 snapshots; preserve the entire treatment."""
import argparse,difflib,hashlib,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path(__file__).resolve().parents[4];out=root/'p27-source-review.json';patch=root/'p27-source-review.diff'
assert not out.exists() and not patch.exists()
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
sha=lambda b:hashlib.sha256(b).hexdigest()
origin=json.loads((root/'p27-source-origin.json').read_text(encoding='utf-8-sig'))
selected=root/'byte-palette-source';files={f.name for f in selected.glob('*.cs')}
for item in origin['manifest']:
    f=selected/item['file']
    if item['after_sha256'] is None:assert not f.exists()
    else:assert sha(f.read_bytes())==item['after_sha256']
paths=subprocess.run(['git','-C',str(repo),'ls-tree','-r','--name-only','f0772c8','--','src/Tedd.Voxtree'],capture_output=True,check=True).stdout.decode().splitlines()
released={Path(f).name for f in paths if f.endswith('.cs')};assert files==released|{'PaletteLeafEncoding.cs'}
manifest=[];diff=[];changed=[]
for name in sorted(files):
    after=(selected/name).read_bytes();nb=norm(after)
    if name in released:
        before=subprocess.run(['git','-C',str(repo),'show',f'f0772c8:src/Tedd.Voxtree/{name}'],capture_output=True,check=True).stdout;na=norm(before)
    else:before=None;na=''
    for label in ['p27setup','p27bulk']:
        assert nb==norm((root/f'{label}/source/{name}').read_bytes()),(label,name)
        if before is not None:assert na==norm((root/f'{label}-baseline/{name}').read_bytes()).replace('Snapshot.Voxtree','Tedd.Voxtree'),(label,name)
    if na!=nb:
        changed.append(name);diff.extend(difflib.unified_diff(na.splitlines(True),nb.splitlines(True),fromfile='a/src/Tedd.Voxtree/'+name,tofile='b/src/Tedd.Voxtree/'+name))
    manifest.append({'file':name,'release_sha256':sha(before) if before is not None else None,'selected_sha256':sha(after),'normalized_changed':na!=nb})
assert set(changed)=={'GenericOctreeCodec.cs','GenericOctreeQueries.cs','Octree.cs','Octree.Generic.cs','OctreeCodec.cs','OctreeLookup.cs','OctreeQueries.cs','PaletteLeafEncoding.cs'},changed
patch.write_text(''.join(diff),encoding='utf-8')
value={'control_revision':'f0772c8','selected_source':'byte-palette-source','changed_files':changed,'complete_source_snapshots_matched':True,
       'normalization':'BOM, line endings and terminal newlines; Snapshot namespace mapping only for control','manifest':manifest,'patch_sha256':sha(patch.read_bytes())}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='manifest'}))
