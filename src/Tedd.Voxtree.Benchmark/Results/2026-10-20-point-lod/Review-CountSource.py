"""Bind selected count/builder forks to snapshots and retain complete deltas."""
import argparse,difflib,hashlib,json
from pathlib import Path

parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path)
parser.add_argument('--labels',nargs='+',choices=['p19','p20','p21','p22','p23'],default=['p19','p20']);args=parser.parse_args()
root=args.task_root.resolve()
if root!=Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():raise SystemExit('Unexpected task root')
normalize=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
sha=lambda b:hashlib.sha256(b).hexdigest()
for label,control,selected,expected in [('p19','leaf-helper-inline-source','packed-count-source',{'OctreeQueries.cs','GenericOctreeQueries.cs'}),
        ('p20','packed-count-source','packed-count-vector-source',{'OctreeQueries.cs','GenericOctreeQueries.cs','VoxelFilter.cs','VoxelFilter.Generic.cs'}),
        ('p21','packed-count-vector-source','packed-count-boundary-source',{'OctreeQueries.cs','GenericOctreeQueries.cs'}),
        ('p22','p22-release-source','linear-leaf-source',{'OctreeCodec.cs','GenericOctreeCodec.cs'}),
        ('p23','p23-release-source','sizing-writer-source',{'OctreeCodec.cs','GenericOctreeCodec.cs','StorageInteger.cs'})]:
    if label not in args.labels:continue
    output=root/(label+'-source-review.json');patch=root/(label+'-source-review.diff')
    if output.exists() or patch.exists():raise SystemExit('Preserve existing source review')
    before=root/control;after=root/selected
    files=lambda p:{f.name for f in p.glob('*.cs')}
    assert files(before)==files(after)
    manifest=[];changes=[];changed=set()
    for name in sorted(files(after)):
        a=(before/name).read_bytes();b=(after/name).read_bytes();na=normalize(a);nb=normalize(b)
        snapshot=normalize((root/(label+'bulk/source')/name).read_bytes())
        assert nb==snapshot,name
        old_snapshot=normalize((root/(label+'bulk-baseline')/name).read_bytes()).replace('Snapshot.Voxtree','Tedd.Voxtree')
        assert na==old_snapshot,name
        if na!=nb:
            changed.add(name)
            changes.extend(difflib.unified_diff(na.splitlines(True),nb.splitlines(True),fromfile='a/src/Tedd.Voxtree/'+name,tofile='b/src/Tedd.Voxtree/'+name))
        manifest.append({'file':name,'control_sha256':sha(a),'candidate_sha256':sha(b),'normalized_changed':na!=nb})
    assert changed==expected,(label,changed)
    patch.write_text(''.join(changes),encoding='utf-8')
    value={'label':label,'control_source':control,'selected_source':selected,'changed_files':sorted(changed),
        'candidate_snapshot_matched':True,'control_snapshot_matched_after_namespace_mapping':True,
        'normalization':'UTF-8 BOM, CRLF and terminal newlines only; raw hashes separately retained',
        'source_manifest':manifest,'review_diff_sha256':sha(patch.read_bytes())}
    output.write_text(json.dumps(value,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in value.items() if k!='source_manifest'}))
