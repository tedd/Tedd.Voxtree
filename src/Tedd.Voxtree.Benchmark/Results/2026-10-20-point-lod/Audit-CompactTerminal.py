"""Bind original P39 source/model/compiled/corpus/native prerequisites; no time."""
import hashlib,json,re,sys,xml.etree.ElementTree as ET
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;out=root/'p39-prerequisite-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
model=read(root/'p39-terminal-model.json')
assert model['passed'] and model['totalCases']==2629760 and model['alignedCubes']==37440
assert model['sourceSha256']==sha(research/'Model-CompactTerminal.py')
assert model['protocolSha256']==sha(research/'COMPACT-TERMINAL-PROTOCOL.md')
assert not (root/'p39-terminal-counterexample.json').exists()
origin=read(root/'p39-source-origin.json');assert origin['modelSha256']==sha(root/'p39-terminal-model.json')
parent=root/'compact-leaf13-source';candidate=root/'compact-terminal-source'
assert len(origin['manifest'])==55 and [r['file'] for r in origin['manifest'] if r['changed']]==['CompactLeafEncoding.cs']
for r in origin['manifest']:
 name=r['file'];assert sha(parent/name)==r['beforeSha256'] and sha(candidate/name)==r['afterSha256']
 assert (root/'compact-terminal-parent-source'/name).read_bytes()==(parent/name).read_bytes().replace(b'Tedd.Voxtree',b'Parent.Voxtree')
 for label in ['p39census','p39terminal']:
  assert (root/label/'source'/name).read_text(encoding='utf-8-sig').rstrip()==(candidate/name).read_text().rstrip()
 assert (root/'p39terminal-baseline'/name).read_text(encoding='utf-8-sig').rstrip()==(parent/name).read_text().replace('Tedd.Voxtree','Snapshot.Voxtree').rstrip()
assert (candidate/'CompactLeafEncoding.cs').read_text().replace(origin['terminalInsertion'],'')==(parent/'CompactLeafEncoding.cs').read_text()
inventories=read(root/'caller-audit-p39bodies.json');assert len(inventories)==2
key=lambda m:m['canonical']['signature']
before={key(m):m for m in inventories[0]['methods']};after={key(m):m for m in inventories[1]['methods']}
assert len(before)==len(inventories[0]['methods']) and len(after)==len(inventories[1]['methods']) and before.keys()==after.keys()
changed=[k for k in before if before[k]['resolvedIlSha256']!=after[k]['resolvedIlSha256']]
assert len(changed)==1 and 'CompactLeafEncoding`1<T>::ValidateCube<>' in changed[0]
assert all(before[k]['implementationFlags']==after[k]['implementationFlags'] for k in before)
assert inventories[0]['publicSurface']==inventories[1]['publicSurface']
for i,label in enumerate(['p31census','p39census']):assert inventories[i]['sha256'].lower()==sha(root/'bundles'/label/(label+'.dll'))
identity=read(root/'caller-audit-p39bodies-identity.json')
assert identity['coverageFrozenBeforeInventory'] and identity['coverageAddendumSha256'].lower()==sha(research/'COMPACT-TERMINAL-IL-COVERAGE.md')
assert identity['selftestPassed'] and identity['toolSha256'].lower()==sha(Path(identity['tool']))
coverage=read(root/'p39-hypothesis/coverage-addendum.json')
assert coverage['frozenBeforeInventory'] and coverage['sha256'].lower()==identity['coverageAddendumSha256'].lower()

tests=[];ns={'t':'http://microsoft.com/schemas/VisualStudio/TeamTest/2010'}
for p in sorted((root/'packed-lookup-p39terminal-results').glob('*.trx')):
 tree=ET.parse(p);s=tree.find('.//t:ResultSummary',ns);c=s.find('t:Counters',ns).attrib
 assert s.attrib['outcome']=='Completed' and c['total']==c['passed'] and int(c['failed'])==0
 tests.append(dict(file=p.name,sha256=sha(p),count=int(c['passed'])))
assert len(tests)==3 and sorted(t['count'] for t in tests)==[417,418,419]
testdir=root/'packed-lookup-validation-p39terminal'
assert (testdir/'tests/PackedLookupTests.cs').read_bytes()==(research/'CompactLeafTests.cs.txt').read_bytes()
assert (testdir/'tests/ExtraReadTests.cs').read_bytes()==(research/'CompactTerminalTests.cs.txt').read_bytes()
for r in read(testdir/'additional-source-binding.json'):assert sha(Path(r['Path']))==r['Hash'].lower()
assert 'compact-terminal-parent-source/*.cs' in (testdir/'tests/Tests.csproj').read_text()
validation=read(root/'p39-terminal-validation.json')
assert validation['exited'] and validation['exitCode']==0 and validation['cases']==96 and validation['arms']==2
assert validation['entrySha256'].lower()==sha(root/'bundles/p39terminal/p39terminal.dll')

corpus_path=root/'forcecraft-census-packed-p39census/packed-corpus.json';corpus=read(corpus_path)
assert corpus['allChecksPassed'] and corpus['chunks']==1286 and corpus['cells']==42139648
assert corpus['runtime']=='.NET 10.0.13' and corpus['architecture']=='X64'
assert corpus['assemblySha256']==sha(root/'bundles/p39census/p39census.dll')
old=read(root/'forcecraft-census-packed-p31census2/packed-corpus.json')
assert corpus['rows']==old['rows'] and len({r['hash'] for r in corpus['rows']})==686
corpus_identity=read(root/'p39census-packed-corpus-identity.json')
assert corpus_identity['joined'] and corpus_identity['exitCode']==0 and corpus_identity['exactParentBundle']=='p31census'
assert corpus_identity['parentBundleSha256'].lower()==sha(root/'bundles/p31census/p31census.dll')
for name in ['p39-corpus-driver','p39-native-driver']:
 done=read(root/(name+'-completed.json'));assert done['driverExitedNormally'] and done['comparativeTimingRecords']==0
 assert not (root/(name+'-failure.log')).exists()
 start=read(root/(name+'-start.json'));folder=root/(name+'-source')
 for n,h in start['dependencies'].items():assert sha(folder/n)==h.lower()==sha(research/n)

native_path=root/'p39-terminal-native.asm';text=native_path.read_text()
summary=read(root/'native-summary-phase31-terminal.json');listing=summary['listings'][0]
assert len(summary['listings'])==1 and listing['sha256']==sha(native_path)
diag=read(root/'p39-terminal-native-identity.json');shutdown=read(root/'p39-terminal-native-shutdown.json')
assert diag['hash'].lower()==validation['entrySha256'].lower() and diag['pid']==shutdown['pid']
assert shutdown['exited'] and shutdown['exitCode']==0 and diag['scenario']=='validate'
assert len([s for s in (root/'p39-terminal-native-output.log').read_text(encoding='utf-8-sig').splitlines() if s.endswith(' valid')])==8
parts=re.split(r'(?m)^; Assembly listing for method ',text)[1:]
native=[]
for width in ['uint','ushort']:
 methods=[];regions=[]
 for namespace in ['Snapshot.Voxtree','Tedd.Voxtree']:
  prefix=f'{namespace}.CompactLeafEncoding`1[{width}]:ValidateCube('
  matches=[m for m in listing['methods'] if m['method'].startswith(prefix) and m['method'].endswith('(Tier1)')]
  assert len(matches)==1 and matches[0]['listing_availability']=='complete'
  m=matches[0];raw=[p for p in parts if p.splitlines()[0]==m['method']];assert len(raw)==1
  assert sum(':ValidateCube(' in c for c in m['call_sites'])==1
  methods.append(m);regions.append(raw[0])
 candidate_text=regions[1]
 starts=list(re.finditer(r'(?m)^(G_M\d+_IG\d+):',candidate_text))
 blocks={m.group(1):candidate_text[m.start():(starts[i+1].start() if i+1<len(starts) else len(candidate_text))] for i,m in enumerate(starts)}
 choices=[]
 for i,m in enumerate(starts):
  b=blocks[m.group(1)];target=re.search(r'\bjne\s+(G_M\d+_IG\d+)',b)
  if not target or not re.search(r'\bcmp\s+\w+, 1\b',b):continue
  end=next((s.start() for s in starts if s.group(1)==target.group(1)),None)
  if end is None or end<=m.start():continue
  fast=blocks[starts[i+1].group(1)]
  if 'E000E000' in fast:choices.append((m.start(),end,b+fast,fast))
 assert choices and len(choices)==candidate_text.count('E000E000')
 terminals=[]
 for start,end,region,fast in choices:
  # Do not count reloads of the inlined path's local variables as payload reads.
  loads=re.findall(r'(?m)^\s*mov\s+\w+,\s*dword ptr \[(?!rsp|rbp)[^\]]+\]',fast)
  bounds=re.findall(r'\bja\s+(G_M\d+_IG\d+)',fast)
  assert len(loads)==4 and len(bounds)==4 and len(set(bounds))==1
  assert 'ThrowArgumentOutOfRangeException' in blocks[bounds[0]]
  assert not re.search(r'\bcall\s',region) and fast.count('xor ')==4
  mask=re.search(r'test\s+[^\n]*E000E000[^\n]*\n\s*jne\s+(G_M\d+_IG\d+)',fast);assert mask
  reject=mask.group(1);seen=set();reject_path=[]
  while True:
   assert reject not in seen;seen.add(reject);block=blocks[reject];reject_path.append(block)
   assert not re.search(r'\bcall\s',block)
   if re.search(r'\bret\b',block):break
   jump=re.search(r'\bjmp\s+(?:SHORT\s+)?(G_M\d+_IG\d+)',block)
   if jump:reject=jump.group(1)
   else:
    # Cold false-result blocks can fall through into a separate epilogue.
    assert not re.search(r'\b(?:j[a-z]+|int3)\b',block)
    labels=list(blocks);index=labels.index(reject);assert index+1<len(labels)
    reject=labels[index+1]
  direct=bool(re.search(r'\bsetne\b',fast))
  if direct:
   complete=candidate_text[start:end]
   assert re.search(r'\bret\b',complete) and not re.search(r'\bcall\s',complete)
  else:
   # An inlined child's successful validation continues its enclosing loop.
   assert re.search(r'\bje\s+'+re.escape(mask.group(1)),fast)
  terminals.append(dict(terminalBlock=region,boundedRowLoads=loads,rangeCheckCount=4,metadataRejectPath=''.join(reject_path),
                        terminalCalls=0,continuation='method return' if direct else 'enclosing validation loop after inlined child'))
 assert any(t['continuation']=='method return' for t in terminals)
 assert re.search(r'\bcmp\s+[^\n]+, 8\b',regions[0]) and 'IndexOf' in regions[0]
 native.append(dict(width=width,control=methods[0],candidate=methods[1],terminalRegions=terminals,
                    parentPartialRecursiveInliningObserved=True,
                    interpretation='Both direct and inlined-child terminal paths replace repeated scalar leaf validation with four checked row pairs. Parent already inlines one recursive level: source eight-child invocations are not a universal count of native recursive calls. Higher recursion/uniform search remains. No time/PMU/total-stack inference.'))
value=dict(passed=True,state='supported_prerequisites_only',sourceFiles=55,otherFilesByteIdentical=54,sourceReversalExact=True,
           model=model,actualLibraryIlBodyCount=len(before),unchangedLibraryBodies=len(before)-1,changedBodies=changed,
           publicTypes=len(inventories[0]['publicSurface']),implementationFlagsMatched=True,coverageCorrectionRetained=True,
           tests=tests,bulkCases=96,bulkArms=2,chunks=1286,uniqueArrays=686,cells=42139648,exactCorpusRowsMatchP31=True,
           corpusSha256=sha(corpus_path),libraryBodyAuditSha256=sha(root/'caller-audit-p39bodies.json'),nativeSha256=sha(native_path),
           native=native,comparativeTimingRecords=0,sourceAdoption=False,
           initialAuditFailureRetained=read(root/'p39-initial-audit-failure.json'),
           secondAuditFailureRetained=read(root/'p39-second-audit-failure.json'),
           limitations='P31 parent remains unpromoted/not_supported under old timing. These gates establish mechanism/correctness only. No fresh original-release time, allocation, application or full10x qualification is claimed.')
out.write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({k:v for k,v in value.items() if k not in ['model','tests','native','limitations']}))
