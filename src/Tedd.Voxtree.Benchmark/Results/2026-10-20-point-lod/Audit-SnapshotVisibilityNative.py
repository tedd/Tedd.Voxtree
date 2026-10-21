"""P33 source-only flag proof and actual valid-LOD routes in both histories."""
import argparse,collections,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args();root=a.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'p33-native-audit.json';assert not out.exists();research=Path(__file__).resolve().parent
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
norm=lambda p:p.read_text(encoding='utf-8-sig').replace('\r\n','\n').rstrip()+'\n'
origin=read(root/'p33-source-origin.json');before=root/'compact-leaf13-source';after=root/'owned-snapshot-inline-v2-source'
assert {r['file'] for r in origin['manifest'] if r['changed']}=={'Octree.cs','Octree.Generic.cs'}
attribute='    [MethodImpl(MethodImplOptions.AggressiveInlining)]\n'
for row in origin['manifest']:
    name=row['file'];assert sha(before/name)==row['beforeSha256'] and sha(after/name)==row['afterSha256']
    text=norm(after/name)
    if row['changed']:
        signature='    public OctreeSpan AsSpan()' if name=='Octree.cs' else '    public OctreeSpan<T> AsSpan()'
        assert text.count(attribute+signature)==1 and text.replace(attribute+signature,signature)==norm(before/name)
    else:assert norm(before/name)==text
    assert text==norm(root/'p33point/source'/name)
    assert norm(before/name).replace('Tedd.Voxtree','Snapshot.Voxtree')==norm(root/'p33point-baseline'/name)
for fixture in origin['fixtures']:
    assert norm(research/fixture['parent']).replace('"16"','"18"')==norm(research/fixture['file']) and sha(research/fixture['file'])==fixture['sha256']
assert norm(root/'snapshot-visibility-p33-source/Program.cs')==norm(research/'PointHistoryProbe.cs.txt')
summary=read(root/'native-summary-phase21-snapshot.json');schedule=read(root/'p33-history-schedule.json');rows=[];processes=set()
assert schedule['bundleSha256']==sha(root/'bundles/p33point/p33point.dll')
for listing in summary['listings']:
    path=root/listing['file'];assert sha(path)==listing['sha256'];history=listing['file'].removeprefix('p33-').removesuffix('.asm')
    identity=read(root/('p33-'+history+'-identity.json'))
    assert identity['exited'] and identity['exitCode']==0 and not identity['timedOut']
    assert identity['bundleSha256'].lower()==schedule['bundleSha256'] and identity['scheduleSha256'].lower()==sha(root/'p33-history-schedule.json')
    assert identity['entrySha256'].lower()==sha(root/'bundles/p33-probe/P33Probe.dll')
    processes.add((identity['pid'],identity['start']))
    results=[json.loads(s) for s in (root/('p33-'+history+'-output.log')).read_text(encoding='utf-8-sig').splitlines() if s.startswith('{')]
    assert len(results)==1;result=results[0]
    assert result['correct'] and result['runtime']=='.NET 10.0.13' and result['architecture']=='X64' and result['bundleHash']==schedule['bundleSha256']
    assert result['caseCount']==(8 if history=='get-first' else 4) and result['runs']==result['caseCount']*8
    parts=path.read_text(errors='replace').split('; Assembly listing for method ')[1:]
    methods=[m for m in listing['methods'] if m['method'].startswith('Force') and m['method'].endswith('(Tier1)')];assert len(methods)==8
    for method in methods:
        assert method['listing_availability']=='complete'
        bodies=[s for s in parts if s.splitlines()[0]==method['method']];assert len(bodies)==1;body=bodies[0]
        groups=list(re.finditer(r'(?m)^(G_M\d+_IG\d+):',body));ids=[m[1] for m in groups]
        texts={m[1]:body[m.start():groups[i+1].start() if i+1<len(groups) else len(body)] for i,m in enumerate(groups)}
        ds=[i for i,g in enumerate(ids) if '0x6F006C' in texts[g] and ', 100' in texts[g]];assert len(ds)==1;d=ds[0]
        branch=re.findall(r'\b(jne|je)\s+(?:SHORT )?(G_M\d+_IG\d+)',texts[ids[d]])[-1]
        start=ids[d+1] if branch[0]=='jne' else branch[1];barrier=branch[1] if branch[0]=='jne' else ids[d+1]
        def edges(g):
            text=texts[g];targets=re.findall(r'\bj\w+\s+(?:SHORT )?(G_M\d+_IG\d+)',text)
            ins=[l.strip() for l in text.splitlines()[1:] if l.strip() and not l.startswith(';')]
            if ids.index(g)+1<len(ids) and not (ins[-1].startswith('jmp ') or ins[-1]=='ret'):targets.append(ids[ids.index(g)+1])
            return targets
        def route(predicate):
            q=collections.deque([(start,[start])]);seen=set()
            while q:
                g,path=q.popleft()
                if g in seen or g==barrier:continue
                seen.add(g);text=texts[g]
                if 'ThrowHelper' in text or 'CORINFO_HELP_THROW' in text or 'CORINFO_HELP_RNGCHKFAIL' in text:continue
                if predicate(text):return path
                for e in edges(g):q.append((e,path+[e]))
            return None
        word_route=route(lambda t:bool(re.search(r'\b(?:sar|shr)\s+\w+, 13',t)) and '0x1FFF' in t and 'word  ptr' in t)
        selected=word_route or route(lambda t:bool(re.search(r'\bcall\s+\[(?:Tedd|Snapshot)\.Voxtree\..*:(?:Get|TryGetUnchecked|TryGetCore)\(',t)))
        assert selected,method['method']
        calls=[l.strip() for g in selected for l in texts[g].splitlines() if re.search(r'\bcall\s',l)]
        rows.append({'history':history,'width':'UInt32' if method['method'].startswith('ForceUInt32') else 'UInt16','access':'owned' if 'BatchOwned' in method['method'] else 'span','arm':'baseline' if ':Before' in method['method'] else 'candidate','file':listing['file'],'sha256':listing['sha256'],'method':method['method'],'nativeBytes':method['native_bytes'],'fixedRspSubtractions':method['rsp_subtractions'],'lodDispatcher':ids[d],'nextOperationBarrier':barrier,'mappedRoute':selected,'inlineCompactWord':word_route is not None,'staticCallSitesInMappedRoute':calls,'routeText':'\n'.join(texts[g] for g in selected)})
assert len(rows)==16 and len(processes)==2
checks=[]
for history in ['get-first','lod-first']:
    for width in ['UInt32','UInt16']:
        for access in ['owned','span']:
            get=lambda arm:next(r for r in rows if (r['history'],r['width'],r['access'],r['arm'])==(history,width,access,arm))
            old=get('baseline')['staticCallSitesInMappedRoute'];new=get('candidate')['staticCallSitesInMappedRoute']
            if history=='get-first' and access=='owned':
                passed=len(old)==(1 if width=='UInt32' else 2) and any(':AsSpan()' in c for c in old) and not any(':AsSpan()' in c for c in new) and len(new)<=(0 if width=='UInt32' else 1)
            else:passed=not new
            checks.append({'history':history,'width':width,'access':access,'controlCalls':old,'candidateCalls':new,'passed':passed})
value={'native_source_gate_passed':all(r['passed'] for r in checks),'sourceDelta':'Only the two AsSpan implementation flags; executable bodies and every other source unchanged','sourceOriginSha256':sha(root/'p33-source-origin.json'),'summarySha256':sha(root/'native-summary-phase21-snapshot.json'),'checks':checks,'rows':rows,'timedRuns':0,'allChecksPassedAndJoined':True,'limits':'Static mapped valid R routes in two diagnostic histories; no dynamic call frequency, quiet-code identity, hardware/stack cost attribution or measured benefit. P31 remains unpromoted.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='rows'},indent=2))
