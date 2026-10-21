"""Check the single-file delta and complete P32 prerequisite/source identities."""
import argparse,hashlib,json,xml.etree.ElementTree as ET
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args();root=a.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;out=root/'p32-prerequisite-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
norm=lambda p:p.read_text(encoding='utf-8-sig').replace('\r\n','\n').rstrip()+'\n'
origin=read(root/'p32-source-origin.json');assert [r['file'] for r in origin['manifest'] if r['changed']]==['CompactLeafEncoding.cs']
before=root/'compact-leaf13-source';after=root/'compact-bounds-source'
for row in origin['manifest']:
    assert sha(before/row['file'])==row['beforeSha256'] and sha(after/row['file'])==row['afterSha256']
    for bundle in ['p32point','p32bulk','p32census']:assert norm(after/row['file'])==norm(root/bundle/'source'/row['file'])
    for bundle in ['p32point','p32bulk']:assert norm(before/row['file']).replace('Tedd.Voxtree','Snapshot.Voxtree')==norm(root/(bundle+'-baseline')/row['file'])
for bundle in ['p32point','p32bulk']:
    assert {p.name for p in before.glob('*.cs')}=={p.name for p in (root/(bundle+'-baseline')).glob('*.cs')}
for row in origin['fixtures']:
    assert sha(research/row['file'])==row['sha256'] and norm(research/row['parent']).replace('"16"','"17"')==norm(research/row['file'])
for f in (root/'p31census-baseline').glob('*.cs'):assert norm(f)==norm(root/'p32census-baseline'/f.name)
actual_path=root/'forcecraft-census-packed-p32census/packed-corpus.json';actual=read(actual_path);parent=read(root/'forcecraft-census-packed-p31census2/packed-corpus.json')
assert actual['allChecksPassed'] and actual['runtime']=='.NET 10.0.13' and actual['architecture']=='X64'
assert actual['chunks']==1286 and actual['cells']==42139648 and actual['rows']==parent['rows']
assert len({r['hash'] for r in actual['rows']})==686 and actual['assemblySha256']==sha(root/'bundles/p32census/p32census.dll')
identity=read(root/'p32census-packed-corpus-identity.json')
assert identity['joined'] and identity['exitCode']==0 and identity['exactParentBundle']=='p31census'
assert identity['parentBundleSha256'].lower()==sha(root/'bundles/p31census/p31census.dll')
tests=[]
for folder,expected in [('packed-lookup-p32bounds-results',[413,414,415]),('packed-lookup-p32bounds-hwoff-results',[414])]:
    counts=[]
    for f in sorted((root/folder).glob('*.trx')):
        tree=ET.parse(f);ns={'t':'http://microsoft.com/schemas/VisualStudio/TeamTest/2010'}
        counters=tree.find('.//t:ResultSummary/t:Counters',ns);summary=tree.find('.//t:ResultSummary',ns)
        assert counters is not None and summary is not None and summary.attrib['outcome']=='Completed'
        assert int(counters.attrib['failed'])==0 and counters.attrib['total']==counters.attrib['passed']
        counts.append(int(counters.attrib['passed']));tests.append({'file':str(f.relative_to(root)),'sha256':sha(f),'passed':int(counters.attrib['passed'])})
    assert sorted(counts)==expected
for label,expected in [('p32point',48),('p32bulk',96)]:
    assert sum(s.endswith(' valid') for s in (root/(label+'-validation.log')).read_text(encoding='utf-8-sig').splitlines())==expected
writer=read(root/'p32writer-oracle-output.log');wi=read(root/'p32writer-oracle-identity.json')
assert writer['correct'] and writer['cases']==378 and writer['cells']==16178022 and writer['capacities']==2920
assert wi['exited'] and wi['exitCode']==0
native=read(root/'p32-native-audit.json');assert native['native_source_gate_passed'] and len(native['selectedCallers'])==8
for r in native['selectedCallers']:assert sha(root/r['file'])==r['sha256']
for r in read(root/'p32test-controls-binding.json'):
    assert sha(Path(r['source']))==r['sourceSha256'] and sha(root/'p32test-controls'/r['file'])==r['sha256']
protocol=read(root/'p32-hypothesis/protocol.json');assert protocol['protocolSha256'].lower()==sha(research/'COMPACT-BOUNDS-PROTOCOL.md')
value={'prerequisitesPassed':True,'sourceDeltaFiles':1,'sourceOriginSha256':sha(root/'p32-source-origin.json'),'sourceReviewSha256':sha(root/'p32-source-review.diff'),'nativeAuditSha256':sha(root/'p32-native-audit.json'),'protocolSha256':sha(research/'COMPACT-BOUNDS-PROTOCOL.md'),'corpusSha256':sha(actual_path),'chunks':1286,'uniqueArrays':686,'cells':42139648,'exactParentBytesAndPayload':True,'frameworkTests':tests,'writer':writer,'promotionEligible':False,'limits':'Semantic/source/native prerequisites only; guarded unaligned load still requires measured usefulness. P31 remains unpromoted and all release/API guards remain.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='frameworkTests'},indent=2))
