"""Bind P30's source/format prerequisite to complete matched optimized callers."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p30-native-audit.json';assert not out.exists()
read=lambda f:json.loads(f.read_text(encoding='utf-8-sig'))
identity=read(root/'p30builder-code-identity.json')
assert identity['exited'] and identity['exitCode']==0 and identity['selectedBundle']=='p30bulk'
assert identity['selectedBundleSha256'].lower()==hashlib.sha256((root/'bundles/p30bulk/p30bulk.dll').read_bytes()).hexdigest()
formats=json.loads((root/'p30builder-code-output.log').read_text(encoding='utf-8-sig').splitlines()[0])
assert formats['allPrimaryFixturesLegacyTree'] and {r['pattern'] for r in formats['formats']}=={'mixed-u7-air','mixed-u8-air'}
assert all(r['classicKind']==r['narrowKind']==0 for r in formats['formats'])
path=root/'p30builder-code-code.asm';text=path.read_text(errors='replace')
parts=[s for s in text.split('; Assembly listing for method ') if s and '(Tier1)' in s.splitlines()[0]]
def record(part):
    assert len(re.findall(r'Total bytes of code \d+',part))==1 and len(re.findall(r'(?m)^G_M\d+_IG01:',part))==1,part.splitlines()[0]
    calls=[s.strip() for s in part.splitlines() if re.search(r'\bcall\s',s)]
    return {'method':part.splitlines()[0],'native_bytes':int(re.search(r'Total bytes of code (\d+)',part)[1]),
            'fixed_rsp_subtractions':[int(v) for v in re.findall(r'sub\s+rsp,\s*(\d+)',part)],'calls':calls}
def unique(prefix):
    matches=[s for s in parts if s.startswith(prefix)];assert len(matches)==1,(prefix,len(matches))
    return record(matches[0])
rows=[]
for codec in ['OctreeCodec','GenericOctreeCodec`1[ushort]']:
    old=unique(f'Snapshot.Voxtree.{codec}:BuildOwned(')
    new=unique(f'Tedd.Voxtree.{codec}:BuildOwned(')
    core=unique(f'Tedd.Voxtree.{codec}:TryBuildPlanned(')
    assert sum(':CreateBuildPlan(' in s for s in old['calls'])==1
    # The first planner and both writers are expanded in these owned callers.
    # The baseline's remaining external planner is the redundant second pass.
    assert not any(':CreateBuildPlan(' in s for s in new['calls'])
    assert sum(':BuildLinearSubtree(' in s for s in old['calls'])==2
    assert sum(':BuildLinearSubtree(' in s for s in new['calls'])==2
    planner=unique(f'Snapshot.Voxtree.{codec}:CreateBuildPlan(')
    assert any(':BuildLinearSubtree(' in s for s in planner['calls'])
    assert not any(':CreateBuildPlan(' in s for s in core['calls'])
    public=[record(s) for s in parts if s.startswith('Tedd.Voxtree.') and ':TryBuild(' in s.splitlines()[0] and
            (('ushort' in s.splitlines()[0]) if 'ushort' in codec else ('ushort' not in s.splitlines()[0]))]
    public=[r for r in public if any(':CreateBuildPlan(' in c or ':BuildLinearSubtree(' in c for c in r['calls'])]
    assert public,codec
    rows.append({'codec':codec,'control_owned':old,'candidate_owned':new,'control_redundant_planner':planner,'candidate_planned_core':core,'candidate_public_planning_callers':public,'inlining':'First plan and write core are expanded in owned callers; control retains one additional external planner.'})
oracle=json.loads((root/'p30oracle-output.log').read_text(encoding='utf-8-sig'))
assert oracle['correct'] and oracle['cases']==378 and oracle['cells']==16178022 and oracle['capacities']>=2788
value={'native_source_gate_passed':True,'file':path.name,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
       'primary_formats':formats,'writer_differential':oracle,'methods':rows,
       'finding':'Source reuses the owned plan. Expanded native owned paths remove the remaining external CreateBuildPlan call; the separate planned core has no planner, while public caller-buffer paths retain planning.',
       'limits':'Qualified code/source prerequisite only, not dynamic call counts, causal time shares, quiet code identity, total recursive stack or a speedup claim.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='methods'}))
