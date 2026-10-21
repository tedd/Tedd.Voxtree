"""Retain every optimized writer version from the isolated P25 diagnostic."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
output=root/'p25-writer-native-audit.json';assert not output.exists()
f=root/'p25builder-code-code.asm';raw=f.read_bytes();methods=[]
for body in raw.decode('utf-8-sig').split('; Assembly listing for method ')[1:]:
    signature=body.splitlines()[0]
    if not any(x in signature for x in [':WriteBottomUp(',':FillMarked(']):continue
    if not re.search(r'\((Tier1|Tier1-OSR)\)$',signature):continue
    methods.append({'signature':signature,'native_bytes':int(re.search(r'; Total bytes of code (\d+)',body)[1]),
                    'rsp_subtractions':[int(x) for x in re.findall(r'\bsub\s+rsp, (\d+)',body)],
                    'called_targets':sorted(set(re.findall(r'\bcall\s+\[([^\r\n]+)\]',body)))})
identity=json.loads((root/'p25builder-code-identity.json').read_text(encoding='utf-8-sig'))
assert identity['exited'] and identity['exitCode']==0 and identity['selectedBundle']=='p25bulk'
assert len(methods)>=4 and any('FillMarked' in m['signature'] and m['called_targets'] for m in methods)
value={'asm_sha256':hashlib.sha256(raw).hexdigest(),'identity':identity,'optimized_versions':methods,
       'limits':'Separate native-only diagnostic, not quiet caller identity. Rsp subtractions exclude register pushes, outgoing arguments, callees and recursion depth. No dynamic-frequency, PMU or elapsed-cost attribution.'}
output.write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({'optimized_writer_versions':len(methods),'exited':True,'exit_code':0}))
