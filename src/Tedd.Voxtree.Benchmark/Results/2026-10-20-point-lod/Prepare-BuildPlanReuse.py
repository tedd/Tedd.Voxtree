"""Prepare P30 after registration: retain the existing planned write body."""
import argparse,hashlib,json,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
before=root/'byte-palette-source';after=root/'build-plan-reuse-source'
origin=json.loads((root/'p27-source-origin.json').read_text(encoding='utf-8-sig'))
sha=lambda b:hashlib.sha256(b).hexdigest()
for item in origin['manifest']:
    f=before/item['file']
    if item['after_sha256'] is None:assert not f.exists()
    else:assert sha(f.read_bytes())==item['after_sha256'],item['file']
assert not after.exists();shutil.copytree(before,after)
body_bindings=[]
for name in ['OctreeCodec.cs','GenericOctreeCodec.cs']:
    f=after/name;s=f.read_text(encoding='utf-8-sig')
    call='!TryBuild(source, levels, encoded, out var written, layout)'
    assert s.count(call)==1;s=s.replace(call,'!TryBuildPlanned(source, levels, encoded, out var written, layout, plan)')
    start=s.index('    internal static bool TryBuild(');end=s.index('    internal static bool TryReadHeader(',start)
    method=s[start:end];brace=method.index('    {\n')
    signature=method[:brace]
    split=method.index('        if (palettePlan.StorageKind == StorageKind.PackedLeaf')
    prefix=method[:split];body=method[split:]
    assert body.endswith('    }\n\n')
    core_signature=signature.replace('internal static bool TryBuild(','private static bool TryBuildPlanned(').replace('layout = DenseVoxelLayout.Linear','layout')
    closing=core_signature.rfind(')');assert closing>=0
    core_signature=core_signature[:closing]+', BuildPlan palettePlan'+core_signature[closing:]
    core=core_signature+'    {\n        bytesWritten = 0;\n'+body
    wrapper=prefix+'        return TryBuildPlanned(source, levels, destination, out bytesWritten, layout, palettePlan);\n    }\n\n'
    note='    // The source, layout, destination minimum and plan are validated by\n    // the caller. Owned tree builds reuse the plan from this same build call.\n'
    s=s[:start]+wrapper+note+core+s[end:]
    assert s[s.index('        if (palettePlan.StorageKind == StorageKind.PackedLeaf'):s.index('    internal static bool TryReadHeader(',start)]==body
    old=(before/name).read_text(encoding='utf-8-sig')
    suffix='    internal static bool TryReadHeader('
    assert old[old.index(suffix):]==s[s.index(suffix):]
    f.write_text(s,encoding='utf-8')
    body_bindings.append({'file':name,'unchanged_planned_body_sha256':sha(body.encode()),'public_validation_and_plan_retained':True,'owned_existing_plan_reused':True})
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
manifest=[]
for f in sorted(before.glob('*.cs')):
    x=f.read_bytes();y=(after/f.name).read_bytes();manifest.append({'file':f.name,'before_sha256':sha(x),'after_sha256':sha(y),'normalized_changed':norm(x)!=norm(y)})
changed=[x['file'] for x in manifest if x['normalized_changed']]
assert set(changed)=={'OctreeCodec.cs','GenericOctreeCodec.cs'}
(root/'p30-source-origin.json').write_text(json.dumps({'parent':'complete P27','changed_files':changed,'planned_body_bindings':body_bindings,'manifest':manifest,'performance_measured':False},indent=2)+'\n')
print(json.dumps({'source':str(after),'changed_files':changed,'planned_body_bindings':body_bindings}))
