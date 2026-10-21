"""Check actual P27 LOD branches before attempting a boundary intervention."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);p.add_argument('--output',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
rows=[]
for width,end in [('UInt16',17),('UInt32',18)]:
    f=root/f'p27-{width}-owned-code.asm';s=f.read_text(errors='replace')
    parts=[v for v in s.split('; Assembly listing for method ') if v.startswith(f'Force{width}Scenario:AfterBatchOwned') and '(Tier1)' in v.splitlines()[0]]
    assert len(parts)==1;body=parts[0]
    assert len(re.findall(r'Total bytes of code \d+',body))==1
    prefix=body[:body.index('G_M000_IG10:')]
    assert 'xor      eax, 0x6F006C' in prefix and 'xor      ecx, 100' in prefix
    path=body[body.index('G_M000_IG10:'):body.index(f'G_M000_IG{end}:')]
    assert not re.search(r'\bcall\s',path)
    assert ('shr      rdx, 32' if width=='UInt32' else 'shr      rdx, 16') in path
    assert 'movzx    rdx, byte  ptr [rax+rdx]' in path
    block='';calls=[]
    for line in body.splitlines():
        if line.startswith('G_M'):block=line.split(':')[0]
        if re.search(r'\bcall\s',line) and ('AsSpan' in line or ':Get(' in line):calls.append({'block':block,'call':line.strip()})
    assert calls
    rows.append({'file':f.name,'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'method':parts[0].splitlines()[0],
                 'palette_lod_fallthrough_block_range':f'IG10..IG{end-1}','fallthrough_calls':[],
                 'inlined_index_and_state_loads':True,'other_branch_get_span_calls':calls})
value={'candidate':'P28 proposed owned LOD boundary removal','gate':'preimplementation generated-code check',
       'disposition':'not_selected_compiler_already_removes_proposed_boundary','timed_candidate_runs':0,
       'evidence':rows,'limits':'Normal valid palette fallthrough, separate diagnostic process; fallback/error paths and quiet-run code identity are not inferred. No measured speedup or hardware bottleneck claim.'}
if a.output:
    assert not a.output.exists();a.output.write_text(json.dumps(value,indent=2)+'\n',encoding='utf-8')
print(json.dumps(value,indent=2))
