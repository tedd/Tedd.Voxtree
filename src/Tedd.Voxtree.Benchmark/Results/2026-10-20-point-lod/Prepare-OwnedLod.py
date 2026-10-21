"""Fork complete P27, changing only two owned LOD getter boundaries."""
import argparse,hashlib,json,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
before=root/'byte-palette-source';after=root/'owned-lod-direct-source'
origin=json.loads((root/'p27-source-origin.json').read_text(encoding='utf-8-sig'))
for item in origin['manifest']:
    f=before/item['file']
    if item['after_sha256'] is None:assert not f.exists()
    else:assert hashlib.sha256(f.read_bytes()).hexdigest()==item['after_sha256'],item['file']
assert not after.exists();shutil.copytree(before,after)
for name,typ,codec,helper in [('Octree.cs','uint','OctreeCodec','OctreeThrowHelper'),
                               ('Octree.Generic.cs','T','VoxelCodec<T>','GenericOctreeThrowHelper<T>')]:
    f=after/name;s=f.read_text(encoding='utf-8-sig')
    old=f'    public {typ} Get(int x, int y, int z, out int lodLevel) => AsSpan().Get(x, y, z, out lodLevel);'
    assert s.count(old)==1
    new=f'''    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public {typ} Get(int x, int y, int z, out int lodLevel)
    {{
        var encoded = Volatile.Read(ref _data);
        if (encoded.Length == 0)
            throw new InvalidOperationException("The octree has not been built.");
        lodLevel = 0;
        if ((uint)x >= (uint)SideLength) return {helper}.ThrowCoordinate(nameof(x), x);
        if ((uint)y >= (uint)SideLength) return {helper}.ThrowCoordinate(nameof(y), y);
        if ((uint)z >= (uint)SideLength) return {helper}.ThrowCoordinate(nameof(z), z);
        if (!{codec}.TryGetUnchecked(encoded, _levels, {codec}.GetStorageKindUnchecked(encoded),
                x, y, z, out var value, out lodLevel))
            return {helper}.ThrowMalformed();
        return value;
    }}'''
    f.write_text(s.replace(old,new),encoding='utf-8')
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
manifest=[]
for f in sorted(before.glob('*.cs')):
    x=f.read_bytes();y=(after/f.name).read_bytes()
    manifest.append({'file':f.name,'before_sha256':hashlib.sha256(x).hexdigest(),'after_sha256':hashlib.sha256(y).hexdigest(),'normalized_changed':norm(x)!=norm(y)})
assert [x['file'] for x in manifest if x['normalized_changed']]==['Octree.Generic.cs','Octree.cs']
(root/'p28-source-origin.json').write_text(json.dumps({'parent':'complete P27','manifest':manifest,'changed_files':['Octree.Generic.cs','Octree.cs'],'performance_measured':False},indent=2)+'\n')
print(json.dumps({'source':str(after),'changed_files':['Octree.Generic.cs','Octree.cs']}))
