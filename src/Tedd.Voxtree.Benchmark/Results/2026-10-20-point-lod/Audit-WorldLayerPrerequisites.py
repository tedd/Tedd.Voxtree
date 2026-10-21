"""Bind exact source, semantic tests, compiled callers and zero-layer branches."""
import difflib,hashlib,json,re,subprocess,sys,xml.etree.ElementTree as ET
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path(__file__).resolve().parents[4];out=root/'p35-prerequisite-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
source=root/'world-layer-source';manifest=read(root/'p35-source-hashes.json');changed=[]
for name,h in manifest.items():
 assert sha(source/name)==h
 old=subprocess.check_output(['git','-C',str(repo),'show','f0772c8:src/Tedd.Voxtree/'+name]).decode().replace('\r\n','\n')
 text=(source/name).read_text()
 if text!=old:changed.append(name)
 assert (root/'p35world/source'/name).read_text().rstrip()==text.rstrip()
 assert (root/'p35world-baseline'/name).read_text().rstrip()==old.replace('Tedd.Voxtree','Snapshot.Voxtree').rstrip()
assert changed==['WorldEntity.cs']
old=subprocess.check_output(['git','-C',str(repo),'show','f0772c8:src/Tedd.Voxtree/WorldEntity.cs']).decode().replace('\r\n','\n')
s=(source/'WorldEntity.cs').read_text();back=s.replace('    private ulong _seenLodLevels;\n','')
back,n=re.subn(r'        if \(\(_seenLodLevels & (?:1UL|\(1UL << address.LodLevel\))\) == 0\)\n        \{\n            value = null;\n            return false;\n        \}\n\n','',back);assert n==2
back=back.replace('        _seenLodLevels |= 1UL << address.LodLevel;\n','').replace('        _seenLodLevels = 0;\n','');assert back==old
diff=''.join(difflib.unified_diff(old.splitlines(True),s.splitlines(True),fromfile='f0772c8/WorldEntity.cs',tofile='P35/WorldEntity.cs'))
(root/'p35-world-source.diff').write_text(diff)
map_source=s[s.index('internal sealed class RecentChunkMap'):]
assert map_source.count('_items[address] = value;')==1 and map_source.count('_items.Remove(address)')==1 and map_source.count('_items.Clear();')==1
assert '_items[address] = value;\n        _seenLodLevels |= 1UL << address.LodLevel;' in map_source
assert map_source.count('_seenLodLevels')==5 and '_lastRecentIndex' not in s
tests=[]
for p in sorted((root/'packed-lookup-p35world-results').glob('*.trx')):
 x=ET.parse(p);ns={'t':'http://microsoft.com/schemas/VisualStudio/TeamTest/2010'};summary=x.find('.//t:ResultSummary',ns);c=summary.find('t:Counters',ns).attrib
 assert summary.attrib['outcome']=='Completed' and int(c['failed'])==0 and c['total']==c['passed']
 tests.append({'file':p.name,'sha256':sha(p),'count':int(c['passed'])})
assert len(tests)==3 and sorted(v['count'] for v in tests)==[402,403,404]
validation=read(root/'p35-world-validation.json');assert validation['exited'] and validation['exitCode']==0 and validation['cases']==60
assert sha(root/'bundles/p35world/p35world.dll')==validation['entrySha256'].lower()
shutdown=read(root/'p35-world-native-shutdown.json');assert shutdown['exited'] and shutdown['exitCode']==0
native=root/'p35-world-native.asm';parts=re.split(r'(?m)^; Assembly listing for method ',native.read_text())[1:]
summary=read(root/'native-summary-phase24-world.json');complete={v['method']:v for v in summary['listings'][0]['methods'] if v['listing_availability']=='complete'}
witnesses=[]
for width in ['UInt32','UInt16']:
 for arm in ['Before','After']:
  header=f'World{width}:{arm}Batch(int):this (Tier1)';chosen=[p for p in parts if p.splitlines()[0]==header];assert len(chosen)==1 and header in complete
  body=chosen[0];split=re.split(r'(?m)^(G_M\d+_IG\d+):',body);groups={split[i]:split[i+1] for i in range(1,len(split),2)};names=list(groups)
  routes=[]
  for name,group in groups.items():
   guards=[]
   for m in re.finditer(r'mov\s+(r\w+), qword ptr \[r\w+\+0x48\]',group):
    bit=re.search(r'bt\s+'+m[1]+r', r\w+\s+jae\s+(?:SHORT\s+)?(G_M\d+_IG\d+)',group[m.end():])
    if bit:guards.append(('address',bit[1],group[m.start():]))
   base=re.search(r'test\s+byte\s+ptr \[r\w+\+0x48\], 1\s+je\s+(?:SHORT\s+)?(G_M\d+_IG\d+)',group)
   if base:guards.append(('coordinate',base[1],group[base.start():]))
   for kind,target,guard in guards:
    destination=groups[target]
    assert re.search(r'(?m)^\s*xor\s+(r?\w+), \1',destination)
    assert ':GetHashCode()' not in destination and not re.search(r'\b(?:imul|rol)\s',destination)
    assert not re.search(r'(?m)^\s*mov\s+qword ptr \[(?!rbp|rsp)\w+\+0x(?:40|10)\],',destination)
    fallthrough=group[group.index(guard)+len(re.split(r'\b(?:jae|je)\s+(?:SHORT\s+)?G_M\d+_IG\d+',guard,maxsplit=1)[0]):]
    following=groups[names[names.index(name)+1]]
    assert ':GetHashCode()' in following or re.search(r'\b(?:imul|rol)\s',fallthrough)
    routes.append({'kind':kind,'guardGroup':name,'zeroBitTarget':target,'guardBlock':group,'zeroBitTargetBlock':destination,'loadedBitFollowingBlock':following,'note':'Zero layer bit branches to map-miss/null state without hash or access stores; loaded bit retains original hash path. Public storage fallthrough is separately validated.'})
  assert len(routes)==(5 if arm=='After' else 0)
  witnesses.append({'method':header,'nativeBytes':complete[header]['native_bytes'],'fixedRspSubtractions':complete[header]['rsp_subtractions'],'routes':routes})
value={'passed':True,'control':'complete published f0772c8, excluding P24-P34','sourceFiles':len(manifest),'changedFiles':changed,'sourceReversalExact':True,'compiledSourcesMatch':True,'allMapWritesCovered':True,'sourceManifestSha256':sha(root/'p35-source-hashes.json'),'nativeSha256':sha(native),'tests':tests,'callerCases':60,'arms':2,'nativeWitnesses':witnesses,'limitations':['Native Get-first repeated-case diagnostic is not quiet-family code identity.','Code size and fixed rsp subtraction establish neither latency nor total stack usage.','Four same-process timing pairs remain descriptive; no application frequency or PMU evidence.'],'testWarnings':'xUnit2009 suggests Assert.StartsWith for the two task-root path assertions; assertions remain effective and all tests pass.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k not in ['nativeWitnesses','tests','limitations']}))
