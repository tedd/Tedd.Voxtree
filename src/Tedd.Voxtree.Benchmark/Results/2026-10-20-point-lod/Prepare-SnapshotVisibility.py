"""P33 changes only two snapshot-factory implementation flags on complete P31."""
import argparse,copy,difflib,hashlib,json,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args();root=a.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;before=root/'compact-leaf13-source';after=root/'owned-snapshot-inline-v2-source'
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
hyp=read(root/'p33-hypothesis/hypothesis-response.json');assert hyp['status']=='ok' and hyp['data']['state']=='proposed'
assert read(root/'p32-disposition.json')['state']=='not_supported' and read(root/'h2-native-audit.json')['allChecksPassedAndJoined']
for row in read(root/'p31-source-origin.json')['manifest']:
    if row['after_sha256'] is not None:assert sha(before/row['file'])==row['after_sha256']
assert not after.exists();shutil.copytree(before,after);diff=[]
attribute='    [MethodImpl(MethodImplOptions.AggressiveInlining)]\n'
for name,signature in [('Octree.cs','    public OctreeSpan AsSpan()'),('Octree.Generic.cs','    public OctreeSpan<T> AsSpan()')]:
    f=after/name;s=f.read_text(encoding='utf-8-sig');assert s.count(signature)==1
    n=s.replace(signature,attribute+signature);assert n.replace(attribute+signature,signature)==s
    f.write_text(n,encoding='utf-8');diff.extend(difflib.unified_diff(s.splitlines(keepends=True),n.splitlines(keepends=True),fromfile='P31/'+name,tofile='P33/'+name))
manifest=[{'file':f.name,'beforeSha256':sha(f),'afterSha256':sha(after/f.name),'changed':f.read_bytes()!=(after/f.name).read_bytes()} for f in sorted(before.glob('*.cs'))]
assert {r['file'] for r in manifest if r['changed']}=={'Octree.Generic.cs','Octree.cs'}
fixtures=[]
for old,new in [('Scenarios-compact-leaf.cs.txt','Scenarios-snapshot-visibility.cs.txt'),('Scenarios-compact-bulk.cs.txt','Scenarios-snapshot-visibility-bulk.cs.txt')]:
    source=(research/old).read_text(encoding='utf-8-sig');dest=research/new;assert not dest.exists() and '"16"' in source
    dest.write_text(source.replace('"16"','"18"'),encoding='utf-8');fixtures.append({'parent':old,'file':new,'sha256':sha(dest),'onlyVersionChanged':True})
(root/'p33-source-origin.json').write_text(json.dumps({'parent':'complete P31, unpromoted; no P32','hypothesis':hyp['data']['id'],'manifest':manifest,'fixtures':fixtures,'delta':'Only AggressiveInlining flags on the two AsSpan factories; executable source bodies unchanged','measured':False},indent=2)+'\n')
(root/'p33-source-review.diff').write_text(''.join(diff),encoding='utf-8')
contexts=[]
for path,purpose in [
    (Path('D:/SourceCode/Tedd.Forcecraft10/src/Tedd.Forcecraft.Common/Fluids/PlanetAtmosphere.cs'),'TryInitializeUniform reads byte channel stored-leaf LOD at the origin'),
    (Path('D:/SourceCode/Tedd.Forcecraft10/src/Tedd.Forcecraft.Common/Models/Lod/LodTopologyIndex.cs'),'TryGetOwner uses WorldEntity.TryGetLod resolution lookup under its external gate'),
    (Path('D:/SourceCode/Tedd.Forcecraft10/src/Tedd.Forcecraft.Common/Fluids/FluidChunkSnapshot.cs'),'Fluid channel snapshots use OctreeChunk<byte>')]:
    assert path.is_file();contexts.append({'file':str(path),'sha256':sha(path),'staticContext':purpose})
(root/'p33-forcecraft-context.json').write_text(json.dumps({'readOnly':True,'applicationExecuted':False,'sites':contexts,'limits':'Static call-site/type context only; no access frequency, application speedup or actual-world LOD equivalence claim.'},indent=2)+'\n')
print(json.dumps({'source':str(after),'changedFiles':[r['file'] for r in manifest if r['changed']],'fixtures':fixtures}))
