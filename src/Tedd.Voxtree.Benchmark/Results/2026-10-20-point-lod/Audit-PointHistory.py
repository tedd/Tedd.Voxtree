"""Map LOD routes rather than attributing every call in a multi-op caller."""
import argparse,collections,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args();root=a.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
out=root/'h2-native-audit.json';assert not out.exists()
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
summary=read(root/'native-summary-phase20-history.json');schedule=read(root/'h2-history-schedule.json')
assert schedule['bundleSha256']==sha(root/'bundles/p32point/p32point.dll')
rows=[];processes=set()
for listing in summary['listings']:
    path=root/listing['file'];assert sha(path)==listing['sha256']
    history=listing['file'].removeprefix('h2-').removesuffix('.asm')
    identity=read(root/('h2-'+history+'-identity.json'))
    assert identity['exited'] and identity['exitCode']==0 and not identity['timedOut']
    assert identity['bundleSha256'].lower()==schedule['bundleSha256'] and identity['scheduleSha256'].lower()==sha(root/'h2-history-schedule.json')
    processes.add((identity['pid'],identity['start']))
    output=[json.loads(s) for s in (root/('h2-'+history+'-output.log')).read_text(encoding='utf-8-sig').splitlines() if s.startswith('{')]
    assert len(output)==1;result=output[0]
    assert result['correct'] and result['runtime']=='.NET 10.0.13' and result['architecture']=='X64'
    assert result['caseCount']==(8 if history=='get-first' else 4) and result['runs']==result['caseCount']*8 and result['bundleHash']==schedule['bundleSha256']
    parts=path.read_text(errors='replace').split('; Assembly listing for method ')[1:]
    methods=[m for m in listing['methods'] if m['method'].startswith('Force') and m['method'].endswith('(Tier1)')]
    assert len(methods)==8
    for method in methods:
        assert method['listing_availability']=='complete'
        bodies=[s for s in parts if s.splitlines()[0]==method['method']];assert len(bodies)==1;body=bodies[0]
        groups=list(re.finditer(r'(?m)^(G_M\d+_IG\d+):',body));ids=[m[1] for m in groups]
        texts={m[1]:body[m.start():groups[i+1].start() if i+1<len(groups) else len(body)] for i,m in enumerate(groups)}
        dispatch=[i for i,g in enumerate(ids) if '0x6F006C' in texts[g] and ', 100' in texts[g]];assert len(dispatch)==1;d=dispatch[0]
        branch=re.findall(r'\b(jne|je)\s+(?:SHORT )?(G_M\d+_IG\d+)',texts[ids[d]])[-1]
        start=ids[d+1] if branch[0]=='jne' else branch[1]
        barrier=branch[1] if branch[0]=='jne' else ids[d+1]
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
        selected=word_route or route(lambda t:'VoxelCodec' in t and ':TryGetUnchecked(' in t and bool(re.search(r'\bcall\s',t)))
        assert selected,method['method']
        calls=[l.strip() for g in selected for l in texts[g].splitlines() if re.search(r'\bcall\s',l)]
        assert all(':AsSpan()' in c or ('VoxelCodec' in c and ':TryGetUnchecked(' in c) for c in calls)
        width='UInt32' if method['method'].startswith('ForceUInt32') else 'UInt16'
        access='owned' if 'BatchOwned' in method['method'] else 'span';arm='baseline' if ':Before' in method['method'] else 'candidate'
        expected=0 if history=='lod-first' or access=='span' else 1 if width=='UInt32' else 2
        assert len(calls)==expected
        rows.append({'history':history,'width':width,'access':access,'arm':arm,'file':listing['file'],'sha256':listing['sha256'],'method':method['method'],'nativeBytes':method['native_bytes'],'fixedRspSubtractions':method['rsp_subtractions'],'lodDispatcher':ids[d],'nextOperationBarrier':barrier,'mappedRoute':selected,'inlineCompactWord':word_route is not None,'staticCallSitesInMappedRoute':calls,'routeText':'\n'.join(texts[g] for g in selected)})
assert len(rows)==16 and len(processes)==2
for history in ['get-first','lod-first']:
    for width in ['UInt32','UInt16']:
        for access in ['owned','span']:
            pair=[r for r in rows if (r['history'],r['width'],r['access'])==(history,width,access)]
            assert len(pair)==2
            normalized=lambda r:[c.replace('Snapshot.Voxtree','Tedd.Voxtree') for c in r['staticCallSitesInMappedRoute']]
            assert normalized(pair[0])==normalized(pair[1])
value={'state':'not_supported','scope':'H2 differential call-boundary explanation for P32 ratio; history dependence itself is supported','nativeOnly':True,'timedRuns':0,'allChecksPassedAndJoined':True,'processStartIdentities':[list(p) for p in processes],'bundleSha256':schedule['bundleSha256'],'scheduleSha256':sha(root/'h2-history-schedule.json'),'summarySha256':sha(root/'native-summary-phase20-history.json'),'callBoundaryDifferentialBetweenArms':False,'rows':rows,'limits':'Mapped static instruction-group routes for known valid coordinates/R payloads; no sampled call frequency or quiet-code identity. Span AsSpan preamble is outside the per-read loop. Both arms change alike, so common call boundaries do not establish the cause of the time ratio. Native layout/dataflow differ; no hardware attribution or source adoption.'}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({k:v for k,v in value.items() if k!='rows'},indent=2))
