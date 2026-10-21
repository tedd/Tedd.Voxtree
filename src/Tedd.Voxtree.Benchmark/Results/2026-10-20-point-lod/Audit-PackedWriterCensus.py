"""Bind a writer-only census to exact parent bytes and immutable original rows."""
import argparse,csv,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);p.add_argument('--label',required=True);p.add_argument('--parent-label',required=True);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
assert all(re.fullmatch(r'[a-z][a-z0-9-]*',s) for s in [a.label,a.parent_label])
output=root/(a.label+'-census-audit.json');assert not output.exists()
read=lambda f:json.loads(f.read_text(encoding='utf-8-sig'))
source=root/f'forcecraft-census-packed-{a.label}/packed-corpus.json';value=read(source)
parent=root/f'forcecraft-census-packed-{a.parent_label}/packed-corpus.json';prior=read(parent)
assert value['allChecksPassed'] and prior['allChecksPassed']
assert value['runtime']==prior['runtime']=='.NET 10.0.13' and value['architecture']==prior['architecture']=='X64'
assert value['assemblySha256']==hashlib.sha256((root/f'bundles/{a.label}/{a.label}.dll').read_bytes()).hexdigest()
rows=value['rows'];assert len(rows)==1286 and value['cells']==42139648
assert len({r['hash'] for r in rows})==686
assert rows==prior['rows'], 'Exact parent payload/eligibility/lookup/row identity changed'
original=list(csv.DictReader((root/'forcecraft-census-s2/chunks.csv').open(encoding='utf-8-sig',newline='')))
assert [(r['region'],int(r['slot']),r['voxel_sha256']) for r in original]==[(r['region'],r['slot'],r['hash']) for r in rows]
for row in rows:
    for left,right in [('baselineUInt32Bytes','candidateUInt32Bytes'),('baselineUInt16Bytes','candidateUInt16Bytes'),('baselineGenericUInt32Bytes','candidateGenericUInt32Bytes'),('baselineLookupPayload','candidateLookupPayload')]:
        assert row[left]==row[right],(row['hash'],left,right)
summary={'label':a.label,'parent_label':a.parent_label,'chunks':1286,'cells':42139648,'unique_arrays':686,
         'all_parent_rows_exact':True,'all_encoders_byte_equal_checked_by_census':True,
         'result_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'parent_result_sha256':hashlib.sha256(parent.read_bytes()).hexdigest(),
         'assembly_sha256':value['assemblySha256'],'runtime':value['runtime'],'architecture':value['architecture'],
         'limits':'Semantic and payload audit only; no latency, allocation or application-access-frequency inference. Parent release provenance remains separate.'}
output.write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary))
