"""Check the prespecified P29 temporary-output gate in one matched hot branch."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p29-native-gate.json';assert not out.exists()
path=root/'p29-UInt32-owned-get-code.asm';text=path.read_text(errors='replace')
def body(name):
    parts=[s for s in text.split('; Assembly listing for method ') if s.startswith('ForceUInt32Scenario:'+name) and '(Tier1)' in s.splitlines()[0]]
    assert len(parts)==1;part=parts[0]
    assert len(re.findall(r'Total bytes of code \d+',part))==1 and len(re.findall(r'(?m)^G_M\d+_IG01:',part))==1
    assert 'xor      edx, 0x650067' in part or 'xor      ecx, 0x650067' in part
    return part
control=body('BeforeBatchOwned');candidate=body('AfterBatchOwned')
old=control[control.index('       mov      rcx, qword ptr [rax]'):control.index('G_M000_IG13:')]
new=candidate[candidate.index('       mov      rax, qword ptr [rax]'):candidate.index('G_M000_IG11:')]
assert 'mov      dword ptr [rsp+0xC0], ecx' in old and 'mov      ebp, dword ptr [rsp+0xC0]' in old
assert 'mov      dword ptr [rsp+0xB8], edx' in old and 'mov      r15d, 1' in old and 'test     r15d, r15d' in old
assert not re.search(r'mov\s+(?:dword|qword) ptr \[rsp',new)
assert 'mov      ecx, eax' in new and 'add      qword ptr [rbx+0x60], rcx' in new
assert 'shr      rcx, 32' in new and 'cmp      ecx, r14d' in new
rows=[]
for name,part in [('control',control),('candidate',candidate)]:
    rows.append({'arm':name,'method':part.splitlines()[0],'native_bytes':int(re.search(r'Total bytes of code (\d+)',part)[1]),
                 'fixed_rsp_subtractions':[int(v) for v in re.findall(r'sub\s+rsp,\s*(\d+)',part)]})
value={'gate_passed':True,'file':path.name,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
       'control_post_state_load_branch':old,'candidate_post_state_load_branch':new,'methods':rows,
       'finding':'Matched final Tier1 UInt32 owned Get palette branch removes temporary value store/reload, discarded LOD store and boolean-success propagation after the loaded state.',
       'limits':'Code gate only; no measured gain, PMU attribution, exact quiet code identity or total stack claim. Other branches/frames may grow.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if not k.endswith('_branch')}))
