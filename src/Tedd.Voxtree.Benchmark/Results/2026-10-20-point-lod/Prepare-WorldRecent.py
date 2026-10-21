"""Create fresh P34 sources and deterministic version19 fixture; no execution."""
import json,subprocess,hashlib
from pathlib import Path
import sys
root=Path(sys.argv[1]).resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path(__file__).resolve().parents[4]
source=root/'world-recent-source'
assert not source.exists()
source.mkdir()
files=subprocess.check_output(['git','-C',str(repo),'ls-tree','-r','--name-only','f0772c8','--','src/Tedd.Voxtree'],text=True).splitlines()
for f in files:
    if f.endswith('.cs'):
        (source/Path(f).name).write_bytes(subprocess.check_output(['git','-C',str(repo),'show','f0772c8:'+f]))
p=source/'WorldEntity.cs';s=p.read_text()
def change(a,b,n=1):
    global s
    assert s.count(a)==n,(a,s.count(a),n)
    s=s.replace(a,b)
change('    private int _recentCount;','    private int _recentCount;\n    private int _lastRecentIndex = -1;')
for signature,key,lod in [('ChunkCoordinate coordinate','coordinate','0'),('ChunkAddress address','address.Coordinate','address.LodLevel')]:
    anchor=f'    internal bool TryGetValue({signature}, out TChunk? value)\n    {{\n'
    change(anchor,anchor+f'''        if ((uint)_lastRecentIndex < (uint)_recentCount)
        {{
            ref var last = ref _recent[_lastRecentIndex];
            if (last.LodLevel == {lod} && last.Coordinate == {key})
            {{
                last.State!.LastAccessSequence = last.Access = ++_access;
                value = last.Value;
                return true;
            }}
        }}

''')
change('                entry.State!.LastAccessSequence = entry.Access = ++_access;', '                _lastRecentIndex = recentIndex;\n                entry.State!.LastAccessSequence = entry.Access = ++_access;',2)
change('            _recent[index].Value = value;', '            _lastRecentIndex = index;\n            _recent[index].Value = value;')
change('        _recentCount--;','        _lastRecentIndex = -1;\n        _recentCount--;')
change('        _recentCount = 0;','        _lastRecentIndex = -1;\n        _recentCount = 0;')
change('        _recent[index] = new CacheEntry(address, hash, value, state);','        _lastRecentIndex = index;\n        _recent[index] = new CacheEntry(address, hash, value, state);')
p.write_text(s)
manifest={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(source.glob('*.cs'))}
(root/'p34-source-hashes.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({'source':str(source),'files':len(manifest),'changed':['WorldEntity.cs']}))
