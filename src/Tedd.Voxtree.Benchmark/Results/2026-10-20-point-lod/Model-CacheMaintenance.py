"""Independent canonical rebuild oracle; no latency measurement."""
import hashlib,itertools,json,random,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p36-model-audit.json';failure=root/'p36-model-counterexample.json'
assert not out.exists() and not failure.exists()
def rebuild(homes,size,excluded=-1):
 table=[0]*size
 for index,home in enumerate(homes):
  if index==excluded:continue
  slot=home
  while table[slot]:slot=(slot+1)&(size-1)
  table[slot]=index+1
 return table
def replace(table,homes,victim,newhome):
 size=len(table);mask=size-1;slot=homes[victim]
 while table[slot]!=victim+1:slot=(slot+1)&mask
 hole=slot;scan=(hole+1)&mask;writes=0
 for _ in range(size-1):
  if not table[scan]:break
  home=homes[table[scan]-1]
  if ((scan-home)&mask)>=((scan-hole)&mask):
   table[hole]=table[scan];writes+=1;hole=scan
  scan=(scan+1)&mask
 table[hole]=0;writes+=1
 newhomes=list(homes);newhomes[victim]=newhome
 index=victim;encoded=index+1;slot=newhome
 while table[slot]:
  old=table[slot]-1
  if old>index:
   table[slot],encoded=encoded,table[slot];writes+=1;index=old
  slot=(slot+1)&mask
 table[slot]=encoded;writes+=1
 return newhomes,writes
counts={'exhaustive':0,'actualSize':0};writes=[]
def check(homes,size,victim,newhome,table=None,kind='exhaustive'):
 before=rebuild(homes,size) if table is None else table.copy();candidate=before.copy()
 changed,n=replace(candidate,homes,victim,newhome);expected=rebuild(changed,size)
 if candidate!=expected:
  failure.write_text(json.dumps({'size':size,'homes':list(homes),'victim':victim,'newhome':newhome,'before':before,'candidate':candidate,'expected':expected,'kind':kind},indent=2)+'\n')
  raise AssertionError('Canonical table mismatch; preserve original counterexample')
 counts[kind]+=1
 if size==16 and len(homes)==10:writes.append(n)
 return changed,candidate
for size,maxcount in [(2,2),(4,4),(8,4)]:
 for count in range(1,maxcount+1):
  for homes in itertools.product(range(size),repeat=count):
   for victim in range(count):
    for newhome in range(size):check(homes,size,victim,newhome)
rng=random.Random(20261115)
for trial in range(1000):
 count=16 if trial%4==0 else 10
 homes=[(15 if trial%4==1 else 0) if trial%4 in (1,2) else rng.randrange(16) for _ in range(count)]
 table=rebuild(homes,16)
 for step in range(128):
  victim=rng.randrange(count);newhome=15 if trial%4==1 else 0 if trial%4==2 else rng.randrange(16)
  homes,table=check(homes,16,victim,newhome,table,'actualSize')
value={'passed':True,'counts':counts,'seed':20261115,'actualSizeReplacements':128000,'sourceSha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'lookupSlotsExact':True,'capacity10LogicalSlotAssignments':{'cases':len(writes),'candidateMean':sum(writes)/len(writes),'candidateMax':max(writes),'publishedFullRebuild':26},'limitations':'Logical table-slot assignments only; excludes other loads, victim scan, dictionary/hash work and cache-entry stores. No timing, traffic, instruction or application-frequency inference.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps(value))
