"""Summarize all chunks and unique arrays separately; payloads count sharing once."""
import argparse
import csv
import hashlib
import json
from pathlib import Path

parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path)
parser.add_argument('--bundle-label',choices=['p18census','p20census'],default='p18census');args=parser.parse_args()
root=args.task_root.resolve()
if root!=Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():raise SystemExit('Unexpected task root')
source=root/('forcecraft-census-packed-'+args.bundle_label+'/packed-corpus.json')
output=root/('packed-corpus-audit.json' if args.bundle_label=='p18census' else args.bundle_label+'-audit.json')
if output.exists():raise SystemExit('Preserve existing audit')
value=json.loads(source.read_text(encoding='utf-8-sig'));rows=value['rows']
assert value['allChecksPassed'] and len(rows)==1286 and value['cells']==1286*32768
assert value['runtime']=='.NET 10.0.13' and value['architecture']=='X64'
assert value['assemblySha256']==hashlib.sha256((root/'bundles'/args.bundle_label/(args.bundle_label+'.dll')).read_bytes()).hexdigest()
unique={row['hash']:row for row in rows};assert len(unique)==686
prior=list(csv.DictReader((root/'forcecraft-census-s2/chunks.csv').open(encoding='utf-8-sig',newline='')))
assert [(r['region'],int(r['slot']),r['voxel_sha256']) for r in prior]==[(r['region'],r['slot'],r['hash']) for r in rows]
summary={'chunks':len(rows),'unique_array_count':len(unique),'cells':value['cells'],
    'runtime':value['runtime'],'architecture':value['architecture'],'result_sha256':hashlib.sha256(source.read_bytes()).hexdigest()}
for name,records in [('all_chunks',rows),('unique_arrays',list(unique.values()))]:
    s={'packed_u32':sum(x['packedUInt32'] for x in records),'packed_u16':sum(x['packedUInt16'] for x in records),
       'packed_generic_u32':sum(x['packedGenericUInt32'] for x in records),'maximum_value':max(x['maximum'] for x in records)}
    for key in ['baselineUInt32Bytes','candidateUInt32Bytes','baselineUInt16Bytes','candidateUInt16Bytes',
                'baselineGenericUInt32Bytes','candidateGenericUInt32Bytes','baselineLookupPayload']:
        s[key]=sum(x[key] for x in records)
    s['candidate_distinct_lookup_payload']=sum(0 if x['sharesOwnedEncoding'] else x['candidateLookupPayload'] for x in records)
    s['baseline_encoded_plus_lookup_payload']=s['baselineUInt32Bytes']+s['baselineLookupPayload']
    s['candidate_encoded_plus_lookup_payload']=s['candidateUInt32Bytes']+s['candidate_distinct_lookup_payload']
    summary[name]=s
summary['u16_width_excluded_chunks']=sum(x['packedUInt32'] and not x['packedUInt16'] and x['maximum']>4095 for x in rows)
summary['checks']='every chunk/cell; independent LOD partitions; owned/span/value/LOD/lookup/FromEncoded; copy, validation, count/any; eligibility; identical fallback bytes; original census row identity'
summary['limits']='Payload excludes object/array headers and GC overhead; no measured access frequency, allocation or latency inference'
if args.bundle_label=='p20census':
    previous=json.loads((root/'packed-corpus-audit.json').read_text())
    assert summary['all_chunks']==previous['all_chunks'] and summary['unique_arrays']==previous['unique_arrays']
    summary['footprint_eligibility_equal_to_p18_census']=True
output.write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
print(json.dumps(summary,indent=2))
