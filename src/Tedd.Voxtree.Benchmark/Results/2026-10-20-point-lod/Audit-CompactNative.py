"""Index complete optimized compact paths without attributing whole-method calls."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args();root=a.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p31-native-audit.json';assert not out.exists()
read=lambda f:json.loads(f.read_text(encoding='utf-8-sig'))
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
summary=read(root/'native-summary-phase16-compact.json');selected=[]
for listing in summary['listings']:
    path=root/listing['file'];assert sha(path)==listing['sha256']
    parts=re.split(r'(?m)^; Assembly listing for method ',path.read_text(errors='replace'))[1:]
    for method in listing['methods']:
        name=method['method']
        if not name.endswith('(Tier1)') or method['listing_availability']!='complete':continue
        point=bool(re.match(r'ForceUInt(16|32)Scenario:AfterBatch(Owned|Span)',name))
        key=point or ('Tedd.Voxtree.' in name and any(x in name for x in [':BuildOwned(',':TryBuildPlanned(',':ValidateCube(',':CountCompact(', 'CompactWordSearch:Count(']))
        if not key:continue
        bodies=[b for b in parts if b.splitlines()[0]==name];assert len(bodies)==1
        body=bodies[0];observations={}
        if point:
            matches=list(re.finditer(r'movzx\s+\w+, word\s+ptr[^\n]*\n(?:[^\n]*\n){0,6}?\s*(?:sar|shr)\s+\w+, 13\n(?:[^\n]*\n){0,4}?\s*and\s+\w+, 0x1FFF',body))
            assert matches, name
            observations={'compactWordLoadShiftMaskSites':len(matches),'example':matches[0].group(0)}
        if 'CompactWordSearch:Count(' in name:
            assert 'ymm' in body and 'vpcmpgtw' in body and 'vpcmpeqw' in body and 'popcnt' in body
            observations={'vectorPath':'256-bit word load, unsigned LOD comparison, masked equality, extracted mask/popcount; bounded scalar tail retained'}
        selected.append({'file':listing['file'],'sha256':listing['sha256'],'method':name,'nativeBytes':method['native_bytes'],'rspSubtractions':method['rsp_subtractions'],'observations':observations})
assert len([x for x in selected if x['method'].startswith('Force')])==8
assert any('CompactWordSearch:Count(' in x['method'] for x in selected)
assert sum(':ValidateCube(' in x['method'] for x in selected)==2
assert sum(':BuildOwned(' in x['method'] for x in selected)>=2
value={'native_source_gate_passed':True,'summarySha256':sha(root/'native-summary-phase16-compact.json'),'selected':selected,'limits':'Diagnostic Tier1 listings include multiple caller operation branches and OSR versions. Examples establish emitted compact decoding, not dynamic branch frequency or quiet-code identity. Rsp subtraction is fixed frame reservation, excluding pushes, recursion and callees; no total stack or hardware causal claim.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({'selected':len(selected),'pointCallers':8,'native_source_gate_passed':True}))
