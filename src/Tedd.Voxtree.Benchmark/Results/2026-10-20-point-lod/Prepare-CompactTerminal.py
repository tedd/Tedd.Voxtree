"""One terminal validator branch on exact P31 after the original model passes."""
import difflib,hashlib,json,shutil,subprocess,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;repo=research.parents[3]
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
model=read(root/'p39-terminal-model.json')
assert model['passed'] and model['totalCases']==2629760 and model['alignedCubes']==37440
assert model['sourceSha256']==sha(research/'Model-CompactTerminal.py')
before=root/'compact-leaf13-source';after=root/'compact-terminal-source'
parent_tests=root/'compact-terminal-parent-source';release_tests=root/'compact-terminal-release-source'
assert not any(p.exists() for p in [after,parent_tests,release_tests])
origin=read(root/'p31-source-origin.json')
for row in origin['manifest']:
 if row['after_sha256'] is not None:assert sha(before/row['file'])==row['after_sha256']
assert sha(before/'CompactLeafEncoding.cs')==model['parentValidatorSha256']
for folder in [after,parent_tests,release_tests]:folder.mkdir()
for path in sorted(before.glob('*.cs')):
 shutil.copy2(path,after/path.name)
 (parent_tests/path.name).write_bytes(path.read_bytes().replace(b'Tedd.Voxtree',b'Parent.Voxtree'))
files=subprocess.check_output(['git','-C',str(repo),'ls-tree','-r','--name-only','f0772c8','--','src/Tedd.Voxtree'],text=True).splitlines()
for f in files:
 if f.endswith('.cs'):(release_tests/Path(f).name).write_bytes(subprocess.check_output(['git','-C',str(repo),'show','f0772c8:'+f]).replace(b'Tedd.Voxtree',b'Snapshot.Voxtree'))
path=after/'CompactLeafEncoding.cs';text=path.read_text(encoding='utf-8-sig')
anchor='''        var half = 1 << (level - 1);
        var raw = word & ValueMask;'''
terminal='''        if (level == 1)
        {
            // The uniform and invalid-origin cases returned above. These eight
            // leaves must have LOD0 and cannot all be the same canonical value.
            var offset = ((x * side + y) * side + z) * 2;
            var rowStride = side * 2;
            var planeStride = side * side * 2;
            var a = BinaryPrimitives.ReadUInt32LittleEndian(payload.Slice(offset, 4));
            var b = BinaryPrimitives.ReadUInt32LittleEndian(payload.Slice(offset + rowStride, 4));
            var c = BinaryPrimitives.ReadUInt32LittleEndian(payload.Slice(offset + planeStride, 4));
            var d = BinaryPrimitives.ReadUInt32LittleEndian(payload.Slice(offset + planeStride + rowStride, 4));
            var repeated = (uint)word | ((uint)word << 16);
            return ((a | b | c | d) & 0xE000E000u) == 0 &&
                ((a ^ repeated) | (b ^ repeated) | (c ^ repeated) | (d ^ repeated)) != 0;
        }
'''
assert text.count(anchor)==1
updated=text.replace(anchor,terminal+anchor);path.write_text(updated,encoding='utf-8')
manifest=[dict(file=p.name,beforeSha256=sha(p),afterSha256=sha(after/p.name),changed=p.read_bytes()!=(after/p.name).read_bytes()) for p in sorted(before.glob('*.cs'))]
assert len(manifest)==55 and [r['file'] for r in manifest if r['changed']]==['CompactLeafEncoding.cs']
assert updated.replace(terminal,'')==text
(root/'p39-source-review.diff').write_text(''.join(difflib.unified_diff(text.splitlines(True),updated.splitlines(True),fromfile='P31/CompactLeafEncoding.cs',tofile='P39/CompactLeafEncoding.cs')))
value=dict(parent='complete P31, unpromoted/not_supported; excludes P32-P38',hypothesis=read(root/'p39-hypothesis/hypothesis-response.json')['id'],
           manifest=manifest,modelSha256=sha(root/'p39-terminal-model.json'),terminalInsertion=terminal,writerAndPointBodiesUnchanged=True,measured=False)
(root/'p39-source-origin.json').write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({'source':str(after),'files':len(manifest),'changedFiles':['CompactLeafEncoding.cs'],'modelPassedBeforeSource':True}))
