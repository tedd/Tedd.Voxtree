"""Summarize hash-bound diagnostics; no timing or hardware-cost inference."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p24-native-audit-v2.json';assert not out.exists()
results=[]
for width in ['UInt16','UInt32']:
    f=root/f'p24-{width}-owned-code.asm';raw=f.read_bytes();text=raw.decode('utf-8-sig')
    shutdown=json.loads((root/f'p24-{width}-owned-code-shutdown.json').read_text(encoding='utf-8-sig'))
    assert shutdown['exited'] and shutdown['exitCode']==0
    methods=[]
    for body in text.split('; Assembly listing for method ')[1:]:
        signature=body.splitlines()[0]
        if not re.search(r'\((Tier1|Tier1-OSR)\)$',signature):continue
        if not (signature.startswith(f'Force{width}Scenario:AfterBatch') or signature.startswith('Tedd.Voxtree.') and any(x in signature for x in [':TryGetUnchecked(',':TryGet(',':ReadWord(',':Value('])):continue
        size=re.search(r'; Total bytes of code (\d+)',body);assert size
        methods.append({'signature':signature,'native_bytes':int(size[1]),
                        'rsp_subtractions':[int(x) for x in re.findall(r'\bsub\s+rsp, (\d+)',body)],
                        'called_targets':sorted(set(re.findall(r'\bcall\s+\[([^\r\n]+)\]',body)))})
    assert any('PackedLeafEncoding' in m['signature'] and ':TryGet(' in m['signature'] for m in methods)
    assert any('AfterBatchOwned' in m['signature'] for m in methods)
    results.append({'width':width,'asm_sha256':hashlib.sha256(raw).hexdigest(),'methods':methods,'shutdown':shutdown})
assert re.findall(r'\bcall\s+\[([^\r\n]+)\]', 'call [Helper`1[ushort]:Read()]')==['Helper`1[ushort]:Read()']
value={'regime':'Separate ordinary-tiered x64 diagnostic, owned LOD selector, not quiet-run code identity',
       'supersedes':'p24-native-audit.json: call-target parser stopped at generic-argument bracket; sizes/frames unchanged',
       'results':results,'limits':'rsp subtractions exclude register pushes, outgoing arguments, callees and recursive depth. Code size and static branches do not establish dynamic counts, PMU stalls or elapsed fractions. Different tier/OSR versions remain separate.'}
out.write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({'widths':len(results),'optimized_method_versions':sum(len(x['methods']) for x in results)}))
