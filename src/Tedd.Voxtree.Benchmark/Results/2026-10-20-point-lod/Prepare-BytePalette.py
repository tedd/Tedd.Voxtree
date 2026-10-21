"""Create complete P27 from the selected P24 source; no old prototype reads."""
import argparse,hashlib,json,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;before=root/'packed-word-format-source';after=root/'byte-palette-source'
origin=json.loads((root/'p24-source-origin.json').read_text(encoding='utf-8-sig'))
for item in origin['manifest']:
    assert hashlib.sha256((before/item['file']).read_bytes()).hexdigest()==item['after_sha256'],item['file']
assert not after.exists();shutil.copytree(before,after)
for f in after.glob('*.cs'):
    if f.name=='PackedLeafEncoding.cs':continue
    s=f.read_text(encoding='utf-8-sig')
    updated=s.replace('PackedLeafEncoding<','PaletteLeafEncoding<').replace('PackedLeafFormatVersion','PaletteLeafFormatVersion')
    if updated!=s:f.write_text(updated,encoding='utf-8')
(after/'PackedLeafEncoding.cs').unlink()
shutil.copyfile(research/'PaletteLeafEncoding.cs.txt',after/'PaletteLeafEncoding.cs')
for name,typ,condition in [('OctreeCodec.cs','uint','levels is >= 3 and <= 6'),
                          ('GenericOctreeCodec.cs','TStorage','levels is >= 3 and <= 6 && ValueSize is 2 or 4')]:
    f=after/name;s=f.read_text();helper=f'PaletteLeafEncoding<{typ}>'
    old=f'''return {helper}.Select(source, levels, writer.Position, denseLength)
            ? BuildPlan.PackedLeaf(denseLength) : BuildPlan.Tree(writer.Position);'''
    new=f'''return {helper}.TrySelect(source, levels, layout, writer.Position, denseLength, HeaderSize, out var paletteLength)
            ? BuildPlan.PackedLeaf(paletteLength) : BuildPlan.Tree(writer.Position);'''
    assert s.count(old)==1;s=s.replace(old,new)
    start=s.index('    internal static bool TryBuild(');end=s.index('    internal static bool TryReadHeader(',start)
    part=s[start:end]
    marker='        var denseLength = GetDenseSize(source.Length);'
    assert part.count(marker)==1
    preparation=f'''        var palettePlan = {condition}
            ? CreateBuildPlan(source, levels, layout) : default;
        if (palettePlan.StorageKind == StorageKind.PackedLeaf && destination.Length >= palettePlan.EncodedLength)
        {{
            {helper}.Write(source, levels, layout, destination, HeaderSize);
            bytesWritten = palettePlan.EncodedLength;
            return true;
        }}

'''
    part=part.replace(marker,preparation+marker)
    oldblock=f'''        if (treeCompleted && !root.IsUniform && writer.Position < denseLength &&
            {helper}.Select(source, levels, writer.Position, denseLength))
        {{
            if (destination.Length < denseLength) return false;
            {helper}.Write(source, levels, layout, destination, HeaderSize);
            bytesWritten = denseLength;
            return true;
        }}'''
    assert part.count(oldblock)==1
    part=part.replace(oldblock,'''        // Preserve the speculative legacy prefix on a short selected-format
        // destination, but never choose a different format based on capacity.
        if (palettePlan.StorageKind == StorageKind.PackedLeaf) return false;''')
    s=s[:start]+part+s[end:];f.write_text(s,encoding='utf-8')
for name in ['Octree.cs','Octree.Generic.cs']:
    f=after/name;s=f.read_text();s=s.replace('packed value/leaf-LOD representation','byte-indexed value/leaf-LOD palette representation')
    f.write_text(s,encoding='utf-8')
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
files=sorted({f.name for f in before.glob('*.cs')}|{f.name for f in after.glob('*.cs')})
manifest=[]
for name in files:
    x=before/name;y=after/name;av=x.read_bytes() if x.exists() else None;bv=y.read_bytes() if y.exists() else None
    manifest.append({'file':name,'before_sha256':hashlib.sha256(av).hexdigest() if av is not None else None,
                     'after_sha256':hashlib.sha256(bv).hexdigest() if bv is not None else None,
                     'normalized_changed':av is None or bv is None or norm(av)!=norm(bv)})
changed=[x['file'] for x in manifest if x['normalized_changed']]
assert set(changed)=={'GenericOctreeCodec.cs','GenericOctreeQueries.cs','Octree.cs','Octree.Generic.cs','OctreeCodec.cs','OctreeLookup.cs','OctreeQueries.cs','PackedLeafEncoding.cs','PaletteLeafEncoding.cs'},changed
assert not any('.Select(' in f.read_text() for f in after.glob('*Codec.cs') if 'PaletteLeafEncoding' in f.read_text())
(root/'p27-source-origin.json').write_text(json.dumps({'parent':'complete P24','changed_files':changed,'manifest':manifest,
    'format':'Q/version3/kind3; byte grid plus sorted full-value/LOD palette','performance_measured':False},indent=2)+'\n')
print(json.dumps({'source':str(after),'changed_files':changed}))
