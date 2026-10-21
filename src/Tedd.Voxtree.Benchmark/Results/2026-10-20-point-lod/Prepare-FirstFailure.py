"""Prepare a failure-only Application copy; preserve every original controller file."""
import difflib,hashlib,json,sys
from pathlib import Path
from xml.sax.saxutils import escape
task=Path(sys.argv[1]).resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;old=task/'coldlog-controller-source';source=task/'first-failure-application-source';worker=task/'first-failure-worker-source'
assert not source.exists() and not worker.exists()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(old/'logged2-out/Tedd.DotNetLab.Host.dll')=='a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'
source.mkdir();worker.mkdir();manifest=[]
needle='''        }
        finally
        {
            try { if(started&&!process.HasExited)'''
insertion='''        }
        catch(Exception error) when(error is not OutOfMemoryException)
        {
            LogNormalSessionPrimaryFailure(error,sessionId,executionId,plan.Id,build.Id,block,arm,variant);
            throw;
        }
        finally
        {
            try { if(started&&!process.HasExited)'''
for p in sorted((old/'src/Tedd.DotNetLab.Application').glob('*.cs')):
 b=p.read_bytes();dest=source/p.name
 if p.name=='ConfirmationService.cs':
  text=b.decode('utf-8-sig').replace('\r\n','\n');assert text.count(needle)==1
  changed=text.replace(needle,insertion)
  assert changed.replace(insertion,needle)==text
  dest.write_bytes(changed.encode())
  (task/'p39-first-failure-source.diff').write_bytes(''.join(difflib.unified_diff(text.splitlines(True),changed.splitlines(True),fromfile='a/ConfirmationService.cs',tofile='b/ConfirmationService.cs')).encode())
 else:dest.write_bytes(b)
 manifest.append(dict(file=p.name,beforeSha256=sha(p),afterSha256=sha(dest),changed=p.name=='ConfirmationService.cs'))
assert sum(r['changed'] for r in manifest)==1
(source/'NormalSessionPrimaryFailure.cs').write_bytes((research/'NormalSessionPrimaryFailure.cs.txt').read_bytes())
(worker/'Program.cs').write_bytes((research/'FirstFailureWorker.cs.txt').read_bytes())
files=list(sorted((old/'logged2-out').glob('*.dll')))
def refs(exclude):return ''.join(f'<Reference Include="{escape(p.stem)}"><HintPath>{escape(p.as_posix())}</HintPath></Reference>' for p in files if p.name not in exclude)
props='<TargetFramework>net10.0</TargetFramework><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><LangVersion>14.0</LangVersion><Optimize>true</Optimize><UseSharedCompilation>false</UseSharedCompilation><Deterministic>true</Deterministic><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward>'
(source/'Application.csproj').write_bytes(('<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup>'+props+'<AssemblyName>Tedd.DotNetLab.Application</AssemblyName></PropertyGroup><ItemGroup>'+refs({'Tedd.DotNetLab.Application.dll'})+'</ItemGroup></Project>').encode())
(worker/'Worker.csproj').write_bytes(('<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup>'+props+'<OutputType>Exe</OutputType><AssemblyName>FirstFailureWorker</AssemblyName></PropertyGroup><ItemGroup>'+refs(set())+'</ItemGroup></Project>').encode())
value=dict(originalHostSha256=sha(old/'logged2-out/Tedd.DotNetLab.Host.dll'),originalApplicationSha256=sha(old/'logged2-out/Tedd.DotNetLab.Application.dll'),manifest=manifest,
 addedLoggerSha256=sha(source/'NormalSessionPrimaryFailure.cs'),workerSourceSha256=sha(worker/'Program.cs'),protocolSha256=sha(research/'FIRST-FAILURE-PROTOCOL.md'),
 originalSourceFiles=len(manifest),changedOriginalFiles=1,sourceReversalExact=True,measurementAndCleanupSourceUnchanged=True,
 dependencies=[dict(path=str(p),sha256=sha(p)) for p in files])
(task/'p39-first-failure-source.json').write_bytes((json.dumps(value,indent=2)+'\n').encode());print(json.dumps({k:v for k,v in value.items() if k not in ['manifest','dependencies']}))
