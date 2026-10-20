"""Readable normalized review supplements, never replaces, the frozen exact diff."""
import argparse
import difflib
import hashlib
import json
import subprocess
from pathlib import Path

parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
root=args.task_root.resolve()
if root!=Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():raise SystemExit('Unexpected task root')
output=root/'p18normal-source-review.json';patch=root/'p18normal-source-review.diff'
if output.exists() or patch.exists():raise SystemExit('Preserve frozen source review')
repo=Path(__file__).resolve().parents[4]
normalize=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
sha=lambda b:hashlib.sha256(b).hexdigest()
before=root/'p18control/source';after=root/'p18census/source';selected=root/'leaf-helper-inline-source'
names=lambda p:{f.name for f in p.glob('*.cs')}
assert names(after)==names(selected)
paths=subprocess.run(['git','-C',str(repo),'ls-tree','-r','--name-only','f0772c8','--','src/Tedd.Voxtree'],check=True,capture_output=True,text=True).stdout.splitlines()
original={Path(p).name:p for p in paths if p.endswith('.cs')}
assert names(before)==set(original)
changes=[];manifest=[]
for name in sorted(names(before)|names(after)):
    a=(before/name).read_bytes() if name in names(before) else b''
    b=(after/name).read_bytes() if name in names(after) else b''
    na=normalize(a) if a else '';nb=normalize(b) if b else ''
    if a:
        baseline=subprocess.run(['git','-C',str(repo),'show','f0772c8:'+original[name]],check=True,capture_output=True).stdout
        assert na==normalize(baseline),name
    if b:assert nb==normalize((selected/name).read_bytes()),name
    changed=na!=nb
    manifest.append({'file':name,'control_sha256':sha(a) if a else None,'candidate_sha256':sha(b) if b else None,'normalized_changed':changed})
    if changed:
        changes.extend(difflib.unified_diff(na.splitlines(True),nb.splitlines(True),
            fromfile='a/src/Tedd.Voxtree/'+name if a else '/dev/null',tofile='b/src/Tedd.Voxtree/'+name if b else '/dev/null'))
closure={}
for label in ['p18control','p18census']:
    closure[label]={f.name:sha(f.read_bytes()) for f in (root/'bundles'/label).glob('*.dll') if f.name!=label+'.dll'}
assert closure['p18control']==closure['p18census']
patch.write_text(''.join(changes),encoding='utf-8')
value={'baseline_revision':'f0772c8','selected_candidate':'leaf-helper-inline-source','all_baseline_files_match_revision_normalized':True,
       'all_candidate_files_match_selected_normalized':True,'same_complete_dependency_closure':True,
       'normalization':'UTF-8 BOM removed, CRLF to LF, terminal newlines canonicalized; raw byte hashes retained separately',
       'changed_files':sum(x['normalized_changed'] for x in manifest),'source_manifest':manifest,
       'review_diff_sha256':sha(patch.read_bytes()),'frozen_exact_source_diff_sha256':sha((root/'p18normal-source.diff').read_bytes()),'dependencies':closure}
output.write_text(json.dumps(value,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in value.items() if k not in ['source_manifest','dependencies']}))
