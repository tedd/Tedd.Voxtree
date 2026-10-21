"""Create distinct P37 source identities from the complete published tree."""
import hashlib, json, subprocess, sys
from pathlib import Path
root=Path(sys.argv[1]).resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;repo=research.parents[3]
assert (root/'p37-hypothesis/hypothesis-response.json').exists()
names=['outline-published-source','outline-source','outline-control-source']
assert not any((root/n).exists() for n in names), 'Preserve original source producer'
for n in names:(root/n).mkdir()
files=subprocess.check_output(['git','-C',str(repo),'ls-tree','-r','--name-only','f0772c8','--','src/Tedd.Voxtree'],text=True).splitlines()
for f in files:
 if not f.endswith('.cs'):continue
 data=subprocess.check_output(['git','-C',str(repo),'show','f0772c8:'+f])
 name=Path(f).name
 for folder in ['outline-published-source','outline-source']:(root/folder/name).write_bytes(data)
 (root/'outline-control-source'/name).write_bytes(data.replace(b'Tedd.Voxtree',b'Snapshot.Voxtree'))
path=root/'outline-source/WorldEntity.cs';data=path.read_bytes()
anchor=b'    private void AddRecent(ChunkAddress address, int hash, TChunk value, ResidencyState state)'
assert data.count(anchor)==1
newline=b'\r\n' if b'\r\n' in data else b'\n'
data=data.replace(anchor,b'    [MethodImpl(MethodImplOptions.NoInlining)]'+newline+anchor)
path.write_bytes(data)
manifest={n:{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((root/n).glob('*.cs'))} for n in names}
assert all(len(v)==53 for v in manifest.values())
(root/'p37-source-hashes.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({'source':str(path.parent),'files':53,'changed':['WorldEntity.cs'],'treatment':'AddRecent NoInlining only; published source'}))
