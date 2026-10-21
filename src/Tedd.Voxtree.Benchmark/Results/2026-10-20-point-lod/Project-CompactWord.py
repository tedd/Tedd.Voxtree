"""Conditional complete-corpus 13+3-bit payload projection, never a timing claim."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'k2-audit.json';assert not out.exists()
read=lambda f:json.loads(f.read_text(encoding='utf-8-sig'))
source=root/'forcecraft-census-packed-p27setup/packed-corpus.json';raw=read(source)
prior=read(root/'p27setup-audit.json');assert hashlib.sha256(source.read_bytes()).hexdigest()==prior['result_sha256']
assert raw['allChecksPassed'] and raw['cells']==42139648 and len(raw['rows'])==1286
assert hashlib.sha256((root/'bundles/p27setup/p27setup.dll').read_bytes()).hexdigest()==raw['assemblySha256']
rows=raw['rows'];assert len({r['hash'] for r in rows})==686
modes=[('classic','packedUInt32','baselineUInt32Bytes','candidateUInt32Bytes',2,4),
       ('narrow','packedUInt16','baselineUInt16Bytes','candidateUInt16Bytes',3,2),
       ('wide','packedGenericUInt32','baselineGenericUInt32Bytes','candidateGenericUInt32Bytes',3,4)]
projected=[]
for r in rows:
    item={'region':r['region'],'slot':r['slot'],'hash':r['hash'],'maximum':r['maximum']}
    for mode,flag,before,current,header,width in modes:
        selected=r[flag] and r['maximum']<=8191;length=header+32768*2 if selected else r[current]
        if r[flag]:assert (r[current]-header)%4==2
        if selected:assert (length-header)%4==0
        item[mode]={'selected':selected,'release_bytes':r[before],'q_bytes':r[current],'projected_bytes':length,
                    'fits_existing_maximum':length<=header+32768*width,
                    'selected_growth_bound':not selected or length*2<=r[before]*5}
    item['p27_distinct_lookup_bytes']=0 if r['sharesOwnedEncoding'] else r['candidateLookupPayload']
    item['released_lookup_bytes']=r['baselineLookupPayload']
    projected.append(item)
def summarize(items):
    result={}
    for mode,*_ in modes:
        values=[r[mode] for r in items];chosen=[r for r in values if r['selected']]
        result[mode]={'selected':len(chosen),'released_encoded_bytes':sum(r['release_bytes'] for r in values),
                      'actual_q_encoded_bytes':sum(r['q_bytes'] for r in values),'projected_encoded_bytes':sum(r['projected_bytes'] for r in values),
                      'all_fit_existing_maximum':all(r['fits_existing_maximum'] for r in values),
                      'all_selected_within_2point5_released_bytes':all(r['selected_growth_bound'] for r in values),
                      'maximum_selected_encoded_growth':max((r['projected_bytes']/r['release_bytes'] for r in chosen),default=None)}
    released=result['classic']['released_encoded_bytes']+sum(r['released_lookup_bytes'] for r in items)
    combined=result['classic']['projected_encoded_bytes']+sum(r['p27_distinct_lookup_bytes'] for r in items)
    result['classic_combined']={'released_encoded_plus_distinct_lookup':released,
        'projected_encoded_plus_distinct_lookup_assuming_shared_new_encoding':combined,'projected_over_released':combined/released}
    return result
unique={r['hash']:r for r in projected}
summary=summarize(projected);unique_summary=summarize(list(unique.values()))
sample=[r for r in projected if r['hash']=='48A799A3EEBA729CB9DCE28F1EA54E9B19A9D46E7AA7CA8F0696E90E0F6F10FB' and r['region']=='DefaultWorld/r.-2.488.-2.region' and r['slot']==2714];assert len(sample)==1
fits=all(r[m]['selected'] and r[m]['fits_existing_maximum'] and r[m]['selected_growth_bound'] for r in sample for m,*_ in modes)
supported=fits and all(summary[m]['all_fit_existing_maximum'] and summary[m]['all_selected_within_2point5_released_bytes'] for m,*_ in modes) and summary['classic_combined']['projected_over_released']<=1
value={'state':'supported' if supported else 'not_supported','scope':'Representation and conditional payload arithmetic only; no encoding or timing implementation',
       'chunks':1286,'cells':42139648,'unique_arrays':686,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
       'parent_archive_sha256':'7422449b511b453305509c7dda8e006c069168610164e1bb1515cc1cbfff58b7',
       'maximum_raw_value':max(r['maximum'] for r in projected),'all_chunks':summary,'unique_arrays_summary':unique_summary,
       'preselected_sample':sample,'preselected_sample_fits':fits,'validated_q_length_mod4':2,'projected_r_length_mod4':0,
       'limits':'New owned lookup sharing is conditional. Excludes CLR headers, GC retention, allocation, compressed bytes, access frequency, latency and all correctness/adoption claims. Higher raw values retain full-value fallbacks.',
       'rows':projected}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='rows'},indent=2))
