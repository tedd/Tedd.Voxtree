"""Audit J1 cardinalities and frozen projections; never infer speed from bytes."""
import argparse,csv,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'j1-audit.json';assert not out.exists()
read=lambda f:json.loads(f.read_text(encoding='utf-8-sig'))
source=root/'forcecraft-census-palette-j1/palette-states.json';v=read(source);rows=v['rows']
assert v['allChecksPassed'] and len(rows)==1286 and v['cells']==42139648
assert v['runtime']=='.NET 10.0.13' and v['architecture']=='X64'
assert v['assemblySha256']==hashlib.sha256((root/'bundles/p24census/p24census.dll').read_bytes()).hexdigest()
original=list(csv.DictReader((root/'forcecraft-census-s2/chunks.csv').open(encoding='utf-8-sig',newline='')))
assert [(r['region'],r['slot'],r['hash']) for r in rows]==[(r['region'],int(r['slot']),r['voxel_sha256']) for r in original]
parent=read(root/'forcecraft-census-packed-p24census/packed-corpus.json')['rows']
for r,b in zip(rows,parent):
    assert r['hash']==b['hash'] and r['maximum']==b['maximum']
    for name,h,entry,old_key,new_key in [('classic',2,8,'baselineUInt32Bytes','candidateUInt32Bytes'),('narrow',3,4,'baselineUInt16Bytes','candidateUInt16Bytes'),('wide',3,8,'baselineGenericUInt32Bytes','candidateGenericUInt32Bytes')]:
        s=r[name];c=s['jointStates'];projected=h+2+32768+c*entry
        assert s['releasedBytes']==b[old_key] and s['currentBytes']==b[new_key] and s['uncappedProjection']==projected
        assert s['countFits']==(1<=c<=256) and s['capacityFits']==(projected<=h+32768*(entry//2))
        assert s['growthFits']==(projected*4<=s['releasedBytes']*5)
        eligible=s['releasedKind']==0 and s['countFits'] and s['capacityFits'] and s['growthFits']
        assert s['eligible']==eligible and s['selectedProjection']==(projected if eligible else s['releasedBytes'])
    assert r['releasedLookupPayload']==b['baselineLookupPayload'] and r['currentLookupPayload']==b['candidateLookupPayload']
def summarize(records):
    result={}
    for name in ['classic','narrow','wide']:
        states=[r[name] for r in records];hist={}
        for s in states:hist[str(s['jointStates'])]=hist.get(str(s['jointStates']),0)+1
        result[name]={'eligible':sum(s['eligible'] for s in states),'over256':sum(not s['countFits'] for s in states),
                      'maximum_joint_states':max(s['jointStates'] for s in states),'joint_state_histogram':hist,
                      'released_encoded_bytes':sum(s['releasedBytes'] for s in states),'current_encoded_bytes':sum(s['currentBytes'] for s in states),
                      'projected_selected_bytes':sum(s['selectedProjection'] for s in states)}
    result['classic_combined']={
        'released_encoded_plus_distinct_lookup':sum(r['classic']['releasedBytes']+(0 if r['releasedLookupSharesEncoding'] else r['releasedLookupPayload']) for r in records),
        'current_encoded_plus_distinct_lookup':sum(r['classic']['currentBytes']+(0 if r['currentLookupSharesEncoding'] else r['currentLookupPayload']) for r in records),
        'projected_encoded_plus_distinct_lookup_assuming_shared_new_encoding':sum(r['classic']['selectedProjection']+(0 if r['classic']['eligible'] or r['releasedLookupSharesEncoding'] else r['releasedLookupPayload']) for r in records),
        'released_lookup_shares_encoding_chunks':sum(r['releasedLookupSharesEncoding'] for r in records)}
    return result
unique={r['hash']:r for r in rows};assert len(unique)==686
sample=read(root/'forcecraft-census-s2/census.json')['samples']['mixed-u16-air']
dominant=next(r for r in rows if r['region']==sample['region'] and r['slot']==sample['slot']);assert dominant['hash']==sample['hash']
selected=all(dominant[k]['eligible'] for k in ['classic','narrow','wide'])
value={'chunks':1286,'cells':42139648,'unique_arrays':686,'all_chunks':summarize(rows),'unique_arrays_summary':summarize(list(unique.values())),
       'preselected_dominant_sample':dominant,'preselected_sample_fits_all_three_apis':selected,
       'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'scope':'Cardinality and fixed byte projection only; no encoding implemented or performance measured',
       'limits':'Projected lookup sharing is an explicit assumption; headers, heap overhead, allocation, cache behavior, setup/query costs and application access frequency are not qualified.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k not in ['all_chunks','unique_arrays_summary','preselected_dominant_sample']}))
