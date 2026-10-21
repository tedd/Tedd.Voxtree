"""Independent fixed P39 proof before source: leaf semantics, packing and bounds."""
import hashlib,itertools,json,platform,random,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent
output=root/'p39-terminal-model.json';counterexample=root/'p39-terminal-counterexample.json'
assert not output.exists() and not counterexample.exists(), 'Original model producer exists'
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protocol=read(root/'p39-hypothesis/protocol.json')
assert protocol['sha256'].lower()==sha(research/'COMPACT-TERMINAL-PROTOCOL.md')
origin=read(root/'p31-source-origin.json');parent=root/'compact-leaf13-source'
for row in origin['manifest']:
 if row['after_sha256'] is not None:assert sha(parent/row['file'])==row['after_sha256']
assert len(list(parent.glob('*.cs')))==55
assert read(root/'p31-disposition.json')['state']=='not_supported'

def reference(words):
    # Translate the original recursive terminal behavior, including each child.
    first=words[0];lod=first>>13
    if lod>1:return False
    if lod==1:return all(word==first for word in words)
    same=True
    for word in words:
        child_lod=word>>13
        if child_lod>0:return False
        # At level0 the uniform branch compares exactly this one word to itself.
        if child_lod!=0 or (word&8191)!=(first&8191):same=False
    return not same

def packed(words):
    # Only originLOD0 is the selected branch; every other origin keeps old code.
    if words[0]>>13!=0:return reference(words)
    a=words[0]|(words[1]<<16);b=words[2]|(words[3]<<16)
    c=words[4]|(words[5]<<16);d=words[6]|(words[7]<<16)
    stamp=words[0]|(words[0]<<16)
    metadata=(a|b|c|d)&0xE000E000
    different=(a^stamp)|(b^stamp)|(c^stamp)|(d^stamp)
    return metadata==0 and different!=0

counts={'metadata':0,'rawEquality':0,'singleWord':0,'random':0}
def check(words,category):
    before=reference(words);after=packed(words)
    if before!=after:
        counterexample.write_text(json.dumps(dict(category=category,words=list(words),reference=before,packed=after),indent=2)+'\n')
        raise AssertionError('P39 counterexample retained; stop original producer')
    counts[category]+=1

# Metadata has a disjoint bit mask: any nonzero field rejects regardless of raw
# values. Unequal representatives prevent the canonical-equality check masking it.
for lods in itertools.product(range(8),repeat=7):
    check((1,)+tuple((lod<<13)|(2 if i==6 else 1) for i,lod in enumerate(lods)),'metadata')
# With metadata zero, only equality of each remaining word to the origin matters.
for partition in range(128):
    check((3,)+tuple(5 if partition&(1<<i) else 3 for i in range(7)),'rawEquality')
for position in range(8):
    for value in range(8192 if position==0 else 65536):
        words=[0]*8;words[position]=value;check(words,'singleWord')
random_source=random.Random(20261117)
for i in range(65536):
    first=random_source.getrandbits(13)
    if i%257==0:words=(first,)*8
    else:words=(first,)+tuple(random_source.getrandbits(13 if i%2==0 else 16) for _ in range(7))
    check(words,'random')
assert counts=={'metadata':2097152,'rawEquality':128,'singleWord':466944,'random':65536}

bounds=0;maximum_end=0
for side in [8,16,32,64]:
    size=side**3*2
    for x in range(0,side,2):
        for y in range(0,side,2):
            for z in range(0,side,2):
                offsets=[((xx*side+yy)*side+z)*2 for xx in [x,x+1] for yy in [y,y+1]]
                assert all(0<=offset<=size-4 and offset%2==0 for offset in offsets)
                actual={index for offset in offsets for index in [offset//2,offset//2+1]}
                expected={((x+dx)*side+(y+dy))*side+(z+dz) for dx in [0,1] for dy in [0,1] for dz in [0,1]}
                assert len(actual)==8 and actual==expected
                maximum_end=max(maximum_end,max(offsets)+4);bounds+=1
assert bounds==37440 and maximum_end==524288 and maximum_end<2**31
audit=dict(passed=True,counts=counts,totalCases=sum(counts.values()),alignedCubes=bounds,maximumPayloadByteEnd=maximum_end,
           parent='complete unpromoted P31, excluding P32-P38',parentValidatorSha256=sha(parent/'CompactLeafEncoding.cs'),
           sourceSha256=sha(Path(__file__)),protocolSha256=protocol['sha256'].lower(),python=platform.python_version(),seed=20261117,
           proof='LOD fields cannot cancel under OR; with metadata zero, raw acceptance depends only on equality to the origin. Row pairs cover exactly the original eight leaves within exact-length payload bounds.',
           limits='Independent integer model and source-domain proof only; not compiled correctness, generated code, time, allocation or source adoption.')
output.write_text(json.dumps(audit,indent=2)+'\n')
print(json.dumps(audit))
