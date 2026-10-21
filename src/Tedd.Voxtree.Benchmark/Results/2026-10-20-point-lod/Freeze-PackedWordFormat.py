"""Validate already-written P24 source after the terminal ordering-only setup failure."""
import argparse,hashlib,json
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
root=args.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
before=root/'leaf-helper-inline-source';after=root/'packed-word-format-source';output=root/'p24-source-origin.json'
assert not output.exists() and not (root/'p24point').exists()
changed=[];manifest=[]
for p in sorted(after.glob('*.cs')):
 a=(before/p.name).read_bytes();b=p.read_bytes();norm=lambda v:v.decode('utf-8-sig').replace('\r\n','\n')
 if norm(a)!=norm(b):changed.append(p.name)
 manifest.append({'file':p.name,'before_sha256':hashlib.sha256(a).hexdigest(),'after_sha256':hashlib.sha256(b).hexdigest()})
assert set(changed)=={'GenericOctreeCodec.cs','Octree.Generic.cs','Octree.cs','OctreeCodec.cs','PackedLeafEncoding.cs'}
a=(before/'PackedLeafEncoding.cs').read_text();b=(after/'PackedLeafEncoding.cs').read_text()
assert a[a.index('    private static void WriteCube('):]==b[b.index('    private static void WriteCube('):]
output.write_text(json.dumps({'control':'complete P18','changed_files':changed,'hot_word_reader_tail_identical':True,'manifest':manifest,
 'setup_note':'Initial exact-list check stopped after source writing, before any build or measurement. Exact five-file set independently verified; no source generation or sampling repeated.'},indent=2)+'\n')
print('Existing P24 source frozen after exact-set and unchanged-hot-tail checks')
