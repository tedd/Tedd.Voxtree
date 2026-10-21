"""One private checked-read change on complete P31; no validation/format delta."""
import argparse,hashlib,json,shutil,difflib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;before=root/'compact-leaf13-source';after=root/'compact-bounds-source'
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert read(root/'p31-disposition.json')['state']=='not_supported'
assert len(read(root/'p32-bounds-precheck.json')['evidence'])==2
hyp=read(root/'p32-hypothesis/hypothesis-response.json');assert hyp['status']=='ok' and hyp['data']['state']=='proposed'
origin=read(root/'p31-source-origin.json')
for row in origin['manifest']:
    if row['after_sha256'] is not None:assert sha(before/row['file'])==row['after_sha256']
assert not after.exists();shutil.copytree(before,after)
path=after/'CompactLeafEncoding.cs';text=path.read_text(encoding='utf-8-sig')
old='''        if ((uint)offset > (uint)data.Length || data.Length - offset < 2) return false;
        word = BinaryPrimitives.ReadUInt16LittleEndian(data.Slice(offset, 2));'''
new='''        // Both predicates accept exactly [0, data.Length-2], including short spans.
        // The complete interval is checked before this exactly two-byte load.
        if (data.Length < 2 || (uint)offset > (uint)(data.Length - 2)) return false;
        word = Unsafe.ReadUnaligned<ushort>(ref Unsafe.Add(ref MemoryMarshal.GetReference(data), offset));
        if (!BitConverter.IsLittleEndian) word = BinaryPrimitives.ReverseEndianness(word);'''
assert text.count(old)==1;updated=text.replace(old,new);path.write_text(updated,encoding='utf-8')
manifest=[{'file':f.name,'beforeSha256':sha(f),'afterSha256':sha(after/f.name),'changed':f.read_bytes()!=(after/f.name).read_bytes()} for f in sorted(before.glob('*.cs'))]
assert [r['file'] for r in manifest if r['changed']]==['CompactLeafEncoding.cs']
fixtures=[]
for source,dest in [('Scenarios-compact-leaf.cs.txt','Scenarios-compact-bounds.cs.txt'),('Scenarios-compact-bulk.cs.txt','Scenarios-compact-bounds-bulk.cs.txt')]:
    s=(research/source).read_text(encoding='utf-8-sig');d=research/dest;assert not d.exists()
    assert '"16"' in s;s=s.replace('"16"','"17"');d.write_text(s,encoding='utf-8')
    fixtures.append({'parent':source,'file':dest,'sha256':sha(d),'onlyVersionChanged':True})
diff=''.join(difflib.unified_diff(text.splitlines(keepends=True),updated.splitlines(keepends=True),fromfile='P31/CompactLeafEncoding.cs',tofile='P32/CompactLeafEncoding.cs'))
(root/'p32-source-review.diff').write_text(diff,encoding='utf-8')
value={'parent':'complete P31, unpromoted','hypothesis':hyp['data']['id'],'manifest':manifest,'fixtures':fixtures,'delta':'Equivalent checked byte interval plus guarded exactly-two-byte unaligned LE load. Index, LOD, writer, validator and every other file unchanged.','measured':False}
(root/'p32-source-origin.json').write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({'source':str(after),'changedFiles':['CompactLeafEncoding.cs'],'hypothesis':hyp['data']['id']}))
