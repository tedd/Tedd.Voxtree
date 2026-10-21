"""Separate published semantic control from the P31 private-reader control."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p32test-controls';assert not out.exists();out.mkdir()
rows=[]
for prefix,source,rename in [('release',root/'p32census-baseline',False),('control',root/'compact-leaf13-source',True)]:
    for f in sorted(source.glob('*.cs')):
        text=f.read_text(encoding='utf-8-sig');target=out/(prefix+'-'+f.name)
        if rename:text=text.replace('Tedd.Voxtree','Control.Voxtree')
        target.write_text(text,encoding='utf-8')
        rows.append({'source':str(f),'sourceSha256':hashlib.sha256(f.read_bytes()).hexdigest(),'file':target.name,'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'namespaceOnlyRename':rename})
assert rows and len(rows)==len(list((root/'p32census-baseline').glob('*.cs')))+len(list((root/'compact-leaf13-source').glob('*.cs')))
(root/'p32test-controls-binding.json').write_text(json.dumps(rows,indent=2)+'\n')
print(json.dumps({'files':len(rows),'publishedNamespace':'Snapshot.Voxtree','privateParentNamespace':'Control.Voxtree'}))
