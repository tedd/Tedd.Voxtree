"""P26: one causal cutoff in the P25 writer; preserve the full reader tail."""
import argparse,hashlib,json,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
before=root/'packed-bottom-up-source';after=root/'packed-leaf-stop-source'
review=json.loads((root/'p25-source-review.json').read_text(encoding='utf-8-sig'))
for item in review['source_manifest']:
    assert hashlib.sha256((before/item['file']).read_bytes()).hexdigest()==item['candidate_sha256'],item['file']
assert not after.exists();shutil.copytree(before,after)
f=after/'PackedLeafEncoding.cs';old=f.read_text(encoding='utf-8-sig')
anchor='''        var half = size >> 1;
        for (var child = 0; child < 8; child++)
            FillMarked('''
assert old.count(anchor)==1
replacement='''        // Split level-one nodes already contain eight final LOD-zero words.
        if (level == 1) return;
        var half = size >> 1;
        for (var child = 0; child < 8; child++)
            FillMarked('''
new=old.replace(anchor,replacement);f.write_text(new,encoding='utf-8')
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n')
changed=[x.name for x in after.glob('*.cs') if norm(x.read_bytes())!=norm((before/x.name).read_bytes())]
assert changed==['PackedLeafEncoding.cs']
assert old[old.index('    private static bool Uniform('):]==new[new.index('    private static bool Uniform('):]
assert old[:old.index('    private static void FillMarked(')]==new[:new.index('    private static void FillMarked(')]
(root/'p26-source-origin.json').write_text(json.dumps({'parent':'complete P25','changed_files':changed,
    'initialization_and_reader_tail_identical':True,'before_sha256':hashlib.sha256((before/f.name).read_bytes()).hexdigest(),
    'after_sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'extra_arrays':0},indent=2)+'\n')
print('P26 fill cutoff generated; source outside FillMarked is unchanged')
