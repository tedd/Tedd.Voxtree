"""Bind R semantic/payload prerequisites; no speed or allocation inference."""
import argparse,difflib,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);args=p.parse_args()
root=args.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
def read(path):return json.loads(path.read_text(encoding='utf-8-sig'))
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
out=root/'p31-prerequisite-audit.json';assert not out.exists()
actual_path=root/'forcecraft-census-packed-p31census2/packed-corpus.json'
actual=read(actual_path);projection_path=root/'k2-audit.json';projection=read(projection_path)
identity=read(root/'p31census2-packed-corpus-identity.json')
assert identity['joined'] and identity['exitCode']==0 and identity['parentEligibilityBundle']=='p30census'
assert identity['projectionSha256'].lower()==sha(projection_path)
assert actual['allChecksPassed'] and actual['chunks']==1286 and actual['cells']==42139648
assert actual['runtime']=='.NET 10.0.13' and actual['architecture']=='X64'
assert actual['assemblySha256']==sha(root/'bundles/p31census/p31census.dll')
rows=actual['rows'];expected={(r['region'],r['slot']):r for r in projection['rows']}
assert len(rows)==len(expected)==1286 and len({r['hash'] for r in rows})==686
modes=[('classic','packedUInt32','baselineUInt32Bytes','candidateUInt32Bytes'),('narrow','packedUInt16','baselineUInt16Bytes','candidateUInt16Bytes'),('wide','packedGenericUInt32','baselineGenericUInt32Bytes','candidateGenericUInt32Bytes')]
for r in rows:
    e=expected[(r['region'],r['slot'])];assert r['hash']==e['hash'] and r['maximum']==e['maximum']
    for name,flag,old,new in modes:
        assert r[flag]==e[name]['selected'] and r[old]==e[name]['release_bytes'] and r[new]==e[name]['projected_bytes']
        if r[flag]:assert 2*r[new]<=5*r[old]
    assert r['baselineLookupPayload']==e['released_lookup_bytes']
    assert (0 if r['sharesOwnedEncoding'] else r['candidateLookupPayload'])==e['p27_distinct_lookup_bytes']
    if r['packedUInt32']:assert r['sharesOwnedEncoding'] and r['candidateLookupPayload']==r['candidateUInt32Bytes']
summary={name:{'selected':sum(r[flag] for r in rows),'releasedEncodedBytes':sum(r[old] for r in rows),'candidateEncodedBytes':sum(r[new] for r in rows)} for name,flag,old,new in modes}
before=sum(r['baselineUInt32Bytes']+r['baselineLookupPayload'] for r in rows)
after=sum(r['candidateUInt32Bytes']+(0 if r['sharesOwnedEncoding'] else r['candidateLookupPayload']) for r in rows)
assert before==48861892 and after==44613886 and after<=before
writer=read(root/'p31writer-oracle-identity.json');assert writer['exited'] and writer['exitCode']==0
writer_result=read(root/'p31writer-oracle-output.log')
assert writer_result['correct'] and writer_result['cases']==378 and writer_result['cells']==16178022 and writer_result['capacities']==2920
origin=read(root/'p31-source-origin.json')
parent=root/'build-plan-reuse-source';candidate=root/'compact-leaf13-source';diff=[];changed=[]
for name in sorted({p.name for p in parent.glob('*.cs')}|{p.name for p in candidate.glob('*.cs')}):
    left=parent/name;right=candidate/name
    a=left.read_text(encoding='utf-8-sig').splitlines(keepends=True) if left.exists() else []
    b=right.read_text(encoding='utf-8-sig').splitlines(keepends=True) if right.exists() else []
    if a!=b:
        changed.append({'file':name,'parentSha256':sha(left) if left.exists() else None,'candidateSha256':sha(right) if right.exists() else None})
        diff.extend(difflib.unified_diff(a,b,fromfile='P30/'+name,tofile='P31/'+name))
assert len(changed)==12 and not (candidate/'PaletteLeafEncoding.cs').exists()
for bundle in ['p31setup2','p31bulk','p31census']:
    for f in candidate.glob('*.cs'):
        assert f.read_text(encoding='utf-8-sig').rstrip()==(root/bundle/'source'/f.name).read_text(encoding='utf-8-sig').rstrip()
# The renamed/deleted Q implementation remains present in the complete P30 arm.
for bundle in ['p31setup2','p31bulk']:
    for f in parent.glob('*.cs'):
        assert f.read_text(encoding='utf-8-sig').replace('Tedd.Voxtree','Snapshot.Voxtree').rstrip()==(root/(bundle+'-baseline')/f.name).read_text(encoding='utf-8-sig').rstrip()
review_path=root/'p31-source-review.diff';assert not review_path.exists();review_path.write_text(''.join(diff),encoding='utf-8')
value={'state':'supported_prerequisites_only','timingClaim':False,'allocationClaim':False,'promotionEligible':False,'chunks':1286,'uniqueArrays':686,'cells':42139648,'corpusSha256':sha(actual_path),'projectionSha256':sha(projection_path),'allModes':summary,'classicCombined':{'release':before,'candidate':after,'ratio':after/before},'writer':writer_result,'sourceOriginSha256':sha(root/'p31-source-origin.json'),'sourceReviewSha256':sha(review_path),'changedFiles':changed,'limitations':'Payload excludes CLR headers, GC retention and compressed bytes; chunks are not access-frequency weights. Independent bytes, published fallbacks and P30 eligibility checked offline. No source adopted.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='changedFiles'},indent=2))
