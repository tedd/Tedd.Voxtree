"""Check every stopped-family original record is retained without resumption."""
import hashlib,json,sys,zipfile
from pathlib import Path
folder=Path(sys.argv[1]);out=folder/'evidence-phase33-family-paths-verified.json';assert not out.exists()
archive=folder/'evidence-phase33.zip'
with zipfile.ZipFile(archive) as z:
 paths={i['path']:i for i in json.loads(z.read('manifest.json'))}
 read=lambda p:json.loads(z.read(paths[p]['blob']).decode('utf-8-sig'))
 audit=read('p39-normal-family-audit.json');assert not audit['complete'] and audit['family_classification_withheld']
 counts={};required=[]
 for row in audit['cases']:
  state=row['state'];counts[state]=counts.get(state,0)+1
  prefix='p39-normal/'+row['scenario']
  if state=='unexecuted_or_unresolved_after_failure':
   assert all(prefix+s+'.json' not in paths for s in ['-operation','-grant','-request','-terminal']);continue
  suffixes=['-grant','-request','-operation','-terminal','-execution','-sessions','-controller','-controller-shutdown']
  suffixes+=['-decision','-comparison','-objective_vector'] if state=='completed' else []
  for suffix in suffixes:
   name=prefix+suffix+'.json';assert name in paths;required.append(name)
  if state=='failed':assert prefix+'-decision.json' not in paths and prefix+'-objective_vector.json' not in paths
 assert counts=={'completed':91,'failed':1,'unexecuted_or_unresolved_after_failure':15}
 catalog=read('p39-normal/catalog-export.json');records=next(t for t in catalog if t['name']=='Record')
 cols=records['columns'];kind=cols.index('Kind');js=cols.index('Json')
 launches={};sessions={}
 for row in records['rows']:
  if row[kind]=='normal_build_launch':
   r=json.loads(row[js]);launches[r['session_id']]=r
  if row[kind]=='normal_build_session':
   r=json.loads(row[js]);sessions[r['id']]=r
 assert len(launches)==2194 and len(sessions)==2193
 orphan=audit['additional_unmeasured_launch']['orphanLaunch']['session_id']
 assert set(launches)-set(sessions)=={orphan}
 assert all(s['exit_code']==0 and s['measurement']['correct'] and s['measurement']['quiescent'] for s in sessions.values())
 assert len(audit['storage_records'])==72
value=dict(passed=True,completed_cases=91,failed_cases=1,unstarted_cases=15,required_original_record_paths=len(required),
 retained_launches=2194,retained_measured_sessions=2193,unmeasured_launch=orphan,all_published_sessions_correct_quiescent_exited=True,
 cleaned_timing_storage_roots=72,complete_family=False,source_adoption=False,archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest())
out.write_bytes((json.dumps(value,indent=2)+'\n').encode());print(json.dumps(value))
