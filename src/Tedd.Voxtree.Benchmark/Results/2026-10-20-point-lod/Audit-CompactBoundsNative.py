"""Verify emitted interval checks in complete, source-bound paired callers."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p32-native-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
summary=read(root/'native-summary-phase18-bounds.json');rows=[]
for item in summary['listings']:
    file=root/item['file'];assert sha(file)==item['sha256']
    parts=re.split(r'(?m)^; Assembly listing for method ',file.read_text(errors='replace'))[1:]
    selected=[m for m in item['methods'] if ':AfterBatch' in m['method'] and m['method'].endswith('(Tier1)')]
    assert len(selected)==1
    method=selected[0];assert method['listing_availability']=='complete'
    body=[s for s in parts if s.splitlines()[0]==method['method']];assert len(body)==1;body=body[0]
    # Bind an R load by its unique 13-bit value/LOD decode, not by a word load alone.
    locations=[]
    for match in re.finditer(r'\blea\s+\w+, \[2\*\w+\+0x0[23]\]',body):
        window='\n'.join(body[match.start():].splitlines()[:22])
        if not re.search(r'\b(?:sar|shr)\s+\w+, 13',window) or '0x1FFF' not in window:continue
        word=re.search(r'\bmovzx\s+\w+, word\s+ptr \[[^\]]+\]',window)
        assert word
        before=window[:word.start()]
        assert re.search(r'\badd\s+\w+, -2',before) or re.search(r'\blea\s+\w+, \[[^\]]+-0x02\]',before)
        assert not re.search(r'\bcall\s',before) and not re.search(r'\badd\s+r\w+, 2\n',before)
        locations.append(window)
    assert locations,item['file']
    identity=read(root/(item['file'].removesuffix('.asm')+'-identity.json'))
    shutdown=read(root/(item['file'].removesuffix('.asm')+'-shutdown.json'))
    assert identity['hash'].lower()==sha(root/'bundles/p32point/p32point.dll') and shutdown['exited'] and shutdown['exitCode']==0
    rows.append({'file':item['file'],'sha256':item['sha256'],'method':method['method'],'nativeBytes':method['native_bytes'],'fixedRspSubtractions':method['rsp_subtractions'],'compactSites':len(locations),'example':locations[0]})
assert len(rows)==8
value={'native_source_gate_passed':True,'pairedControl':'complete P31','selectedCallers':rows,'summarySha256':sha(root/'native-summary-phase18-bounds.json'),'mechanism':'Actual R decode contains combined remaining-byte interval compare and exact word load, without the separate slice check. Voxel-index and stored LOD guards remain.','limits':'Diagnostic optimized code and fixed reservations are not quiet-code identity, total stack, dynamic instruction frequency or measured efficacy. Complete source/semantic gates and the fixed rejection stage still required.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({'callers':8,'native_source_gate_passed':True}))
