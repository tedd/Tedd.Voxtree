"""Bind conditional P33 semantic gates after the passed two-history code gate."""
import argparse,hashlib,json,xml.etree.ElementTree as ET
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args();root=a.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p33-prerequisite-audit.json';assert not out.exists();research=Path(__file__).resolve().parent
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();norm=lambda p:p.read_text(encoding='utf-8-sig').replace('\r\n','\n').rstrip()+'\n'
gate=read(root/'p33-native-audit.json');assert gate['native_source_gate_passed'] and len(gate['rows'])==16
for row in gate['rows']:assert sha(root/row['file'])==row['sha256']
origin=read(root/'p33-source-origin.json');before=root/'compact-leaf13-source';after=root/'owned-snapshot-inline-v2-source'
for row in origin['manifest']:
    name=row['file'];assert sha(before/name)==row['beforeSha256'] and sha(after/name)==row['afterSha256']
    for label in ['p33point','p33bulk','p33census']:assert norm(after/name)==norm(root/label/'source'/name)
    for label in ['p33point','p33bulk']:assert norm(before/name).replace('Tedd.Voxtree','Snapshot.Voxtree')==norm(root/(label+'-baseline')/name)
for f in (root/'p31census-baseline').glob('*.cs'):assert norm(f)==norm(root/'p33census-baseline'/f.name)
path=root/'forcecraft-census-packed-p33census/packed-corpus.json';census=read(path);parent=read(root/'forcecraft-census-packed-p31census2/packed-corpus.json')
assert census['allChecksPassed'] and census['runtime']=='.NET 10.0.13' and census['architecture']=='X64' and census['chunks']==1286 and census['cells']==42139648
assert census['rows']==parent['rows'] and len({r['hash'] for r in census['rows']})==686 and census['assemblySha256']==sha(root/'bundles/p33census/p33census.dll')
identity=read(root/'p33census-packed-corpus-identity.json');assert identity['joined'] and identity['exitCode']==0 and identity['exactParentBundle']=='p31census'
assert identity['parentBundleSha256'].lower()==sha(root/'bundles/p31census/p31census.dll')
tests=[]
for folder,expected in [('packed-lookup-p33sem-results',[410,411,412]),('packed-lookup-p33sem-hwoff-results',[411])]:
    counts=[]
    for f in (root/folder).glob('*.trx'):
        tree=ET.parse(f);ns={'t':'http://microsoft.com/schemas/VisualStudio/TeamTest/2010'};summary=tree.find('.//t:ResultSummary',ns);c=tree.find('.//t:ResultSummary/t:Counters',ns)
        assert c is not None and summary is not None and summary.attrib['outcome']=='Completed' and int(c.attrib['failed'])==0 and c.attrib['total']==c.attrib['passed']
        counts.append(int(c.attrib['passed']));tests.append({'file':str(f.relative_to(root)),'sha256':sha(f),'passed':int(c.attrib['passed'])})
    assert sorted(counts)==expected
for label,count in [('p33point',48),('p33bulk',96)]:assert sum(s.endswith(' valid') for s in (root/(label+'-validation.log')).read_text(encoding='utf-8-sig').splitlines())==count
writer=read(root/'p33writer-oracle-output.log');wi=read(root/'p33writer-oracle-identity.json');assert writer['correct'] and writer['cases']==378 and writer['cells']==16178022 and writer['capacities']==2920 and wi['exited'] and wi['exitCode']==0
protocol=read(root/'p33-hypothesis/protocol.json');assert protocol['protocolSha256'].lower()==sha(research/'SNAPSHOT-VISIBILITY-PROTOCOL.md')
value={'prerequisitesPassed':True,'nativeBothHistoriesPassed':True,'sourceDelta':'Only two AsSpan implementation flags','nativeAuditSha256':sha(root/'p33-native-audit.json'),'sourceOriginSha256':sha(root/'p33-source-origin.json'),'sourceReviewSha256':sha(root/'p33-source-review.diff'),'protocolSha256':sha(research/'SNAPSHOT-VISIBILITY-PROTOCOL.md'),'chunks':1286,'cells':42139648,'uniqueArrays':686,'corpusSha256':sha(path),'exactParentBytesAndPayload':True,'frameworkTests':tests,'writer':writer,'promotionEligible':False,'limits':'Source/native/semantic prerequisites only; no quiet or application benefit, release guard qualification or public-API completion follows.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='frameworkTests'},indent=2))
