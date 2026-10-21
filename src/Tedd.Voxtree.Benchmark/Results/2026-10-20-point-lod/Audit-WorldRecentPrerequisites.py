"""Bind P34 semantic/source/native evidence before quiet timing."""
import hashlib,json,re,subprocess,sys,xml.etree.ElementTree as ET
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path(__file__).resolve().parents[4];out=root/'p34-prerequisite-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
source=root/'world-recent-source';manifest=read(root/'p34-source-hashes.json');changed=[]
for name,h in manifest.items():
 assert sha(source/name)==h
 old=subprocess.check_output(['git','-C',str(repo),'show','f0772c8:src/Tedd.Voxtree/'+name])
 if (source/name).read_bytes()!=old:changed.append(name)
assert changed==['WorldEntity.cs']
diff=subprocess.run(['git','diff','--no-index','--',str(repo/'src/Tedd.Voxtree/WorldEntity.cs'),str(source/'WorldEntity.cs')],capture_output=True,text=True)
assert diff.returncode==1
(root/'p34-world-source.diff').write_text(diff.stdout)
s=(source/'WorldEntity.cs').read_text()
assert s.count('private int _lastRecentIndex = -1;')==1
assert s.count('last.State!.LastAccessSequence = last.Access = ++_access;')==2
assert s.count('_lastRecentIndex = -1;')==3
assert s.count('_lastRecentIndex = recentIndex;')==2 and s.count('_lastRecentIndex = index;')==2
tests=[]
for p in sorted((root/'packed-lookup-p34world2-results').glob('*.trx')):
 x=ET.parse(p);ns={'t':'http://microsoft.com/schemas/VisualStudio/TeamTest/2010'}
 summary=x.find('.//t:ResultSummary',ns);c=summary.find('t:Counters',ns).attrib
 assert summary.attrib['outcome']=='Completed' and int(c['failed'])==0 and c['total']==c['passed']
 tests.append({'file':p.name,'sha256':sha(p),'count':int(c['passed'])})
assert len(tests)==3 and sorted(v['count'] for v in tests)==[398,399,400]
validation=read(root/'p34-world-validation.json');assert validation['exitCode']==0 and validation['exited'] and validation['cases']==40
assert sha(root/'bundles/p34world/p34world.dll')==validation['entrySha256'].lower()
shutdown=read(root/'p34-world-native-shutdown.json');assert shutdown['exited'] and shutdown['exitCode']==0
native=root/'p34-world-native.asm';parts=re.split(r'(?m)^; Assembly listing for method ',native.read_text())[1:]
summary=read(root/'native-summary-phase23-world.json');complete={v['method']:v for v in summary['listings'][0]['methods'] if v['listing_availability']=='complete'}
witnesses=[]
for width in ['UInt32','UInt16']:
 for arm in ['Before','After']:
  prefix=f'World{width}:{arm}Batch(int):this (Tier1)'
  chosen=[v for v in parts if v.splitlines()[0]==prefix];assert len(chosen)==1
  body=chosen[0];assert prefix in complete
  sites=list(re.finditer(r'mov\s+\w+, dword ptr \[\w+\+0x54\]\s+cmp\s+\w+, dword ptr \[\w+\+0x50\]',body))
  assert len(sites)==(4 if arm=='After' else 0)
  routes=[]
  lines=body.splitlines();labels={line.split(':')[0]:i for i,line in enumerate(lines) if re.match(r'^G_M\d+_IG\d+:',line)}
  for site in sites:
   # Exact-hit trace: valid index, matching LOD and all coordinates.
   # Out-of-line Equals returns true; its success edge may be outlined.
   index=body[:site.start()].count('\n');trace=[];equals=False;stores=0
   for _ in range(300):
    line=lines[index];trace.append(line)
    assert ':GetHashCode()' not in line and '+0x38]' not in line
    if 'ChunkCoordinate:Equals(' in line:equals=True
    if re.match(r'^\s*mov\s+qword ptr \[\w+\+0x(?:40|10)\],',line):stores+=1
    if stores==3:break
    branch=re.match(r'^\s*(j\w+)\s+(?:SHORT\s+)?(G_M\d+_IG\d+)',line)
    if branch and (branch[1]=='jmp' or (equals and branch[1]=='jne')):index=labels[branch[2]]
    else:index+=1
   else:raise AssertionError('No exact three-store success route')
   route='\n'.join(trace)
   assert ':GetHashCode()' not in route and '+0x38]' not in route
   assert len(re.findall(r'(?m)^\s*cmp\s',route))>=(3 if equals else 6)
   assert len(re.findall(r'(?m)^\s*mov\s+qword ptr \[\w+\+0x(?:40|10)\],',route))==3
   assert 'inc ' in route
   routes.append({'methodStartLine':native.read_text().splitlines().index('; Assembly listing for method '+prefix)+1,'exactHitRoute':route,'coordinateEqualsCall':equals,'note':'Valid bounds and equal LOD/coordinates; follows outlined true-Equals edge where present, stopping after three sequence stores before hash/probe.'})
  witnesses.append({'method':prefix,'nativeBytes':complete[prefix]['native_bytes'],'fixedRspSubtractions':complete[prefix]['rsp_subtractions'],'shortcutRoutes':routes})
value={'passed':True,'sourceChanged':changed,'sourceManifestSha256':sha(root/'p34-source-hashes.json'),'nativeSha256':sha(native),'tests':tests,'scenarios':40,'arms':2,'nativeWitnesses':witnesses,'limitations':['Diagnostic repeated-case Get-first history, not the complete quiet-family native identity.','Full caller bodies grow; fixed rsp subtraction is not total stack usage.','No timing, PMU, application frequency or speedup inference.'],'firstTestIssue':'p34world compilation rejected nonexistent AllChunks before execution; corrected ResidentChunks in fresh p34world2 fixture; source unchanged.','importIssue':'text/markdown importer rejected before hypothesis submission; protocol JSON imported into same catalog after verified rejection.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k not in ['nativeWitnesses','tests','limitations']}))
