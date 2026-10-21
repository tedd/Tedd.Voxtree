"""Bind the visited P31 LOD branch before a checked-read intervention."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p32-bounds-precheck.json';assert not out.exists()
rows=[]
for width,end in [('UInt32',18),('UInt16',17)]:
    f=root/f'p31-native-{width.lower()}-owned-lod.asm'
    parts=[s for s in f.read_text(errors='replace').split('; Assembly listing for method ') if s.startswith(f'Force{width}Scenario:AfterBatchOwned') and '(Tier1)' in s.splitlines()[0]]
    assert len(parts)==1;body=parts[0]
    assert len(re.findall(r'Total bytes of code \d+',body))==1
    dispatch=body[:body.index('G_M000_IG10:')]
    assert 'xor      eax, 0x6F006C' in dispatch and 'xor      ecx, 100' in dispatch
    path=body[body.index('G_M000_IG10:'):body.index(f'G_M000_IG{end}:')]
    assert not re.search(r'\bcall\s',path)
    decode=path[path.index('G_M000_IG14:'):path.index('G_M000_IG15:')]
    assert 'cmp      edx, ecx' in decode and 'cmp      edx, 2' in decode
    assert 'add      rdx, 2' in decode and re.search(r'cmp\s+rdx, r8',decode)
    assert 'word  ptr [rax]' in decode and 'sar      edx, 13' in decode and 'and      ecx, 0x1FFF' in decode
    rows.append({'file':f.name,'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'method':body.splitlines()[0],
                 'lodFallthrough':f'IG10..IG{end-1}','calls':[],'compactDecodeBlock':'IG14','decode':decode})
value={'gate':'preimplementation retained-code check','parent':'complete P31, unpromoted',
       'predictionLead':'The selected LOD path retains explicit index and byte bounds plus a subsequent span-slice check. Test one equivalent byte interval guard and a guarded unaligned word load; retain index and LOD checks.',
       'evidence':rows,'limits':'Static diagnostic fallthrough evidence, not branch-frequency/causal-share/quiet-code identity or a measured speedup. Other operation/error branches are not substituted for this path.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({'boundCallers':len(rows),'timedRuns':0,'gate':'source experiment justified'}))
