param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $TaskRoot 'coldlog-controller-source/logged2-out/Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 $root=Join-Path $TaskRoot 'p39-first-failure'
 if(Test-Path -LiteralPath (Join-Path $root 'native-inputs.json')){throw 'Original native binding exists; inspect without overwriting'}
 $env:P39_NATIVE_RESEARCH=$PSScriptRoot
 @'
import hashlib,json,os,sqlite3
from pathlib import Path
t=Path('D:/Workspaces/AI/voxtree-point-lod-20261020');r=t/'p39-first-failure';research=Path(os.environ['P39_NATIVE_RESEARCH'])
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
old=read(r/'inputs.json');value=dict(old);bundles=read(t/'p39-first-failure-native-controller-bundles.json')
maps=[]
for b in bundles:
 f={x['name']:x for x in b['files']}
 for x in f.values():assert sha(Path(x['path']))==x['sha256'].lower()
 maps.append(f)
assert maps[0].keys()==maps[1].keys()
assert [n for n in maps[0] if maps[0][n]['sha256']!=maps[1][n]['sha256']]==['Tedd.DotNetLab.Application.dll']
native_hash=maps[0]['runtimes\\win-x64\\native\\e_sqlite3.dll']['sha256'].lower()
checks=[]
for arm in [0,1]:
 for kind in ['native','logger']:
  stem=f'p39-first-failure-{kind}-p39g{arm}-selftest';identity=read(t/(stem+'.json'))
  assert identity['joined'] and identity['workerSha256'].lower()==maps[arm]['FirstFailureWorker.dll']['sha256'].lower()
  if arm==0 and kind=='logger':
   assert identity['exitCode']!=0 and 'New logger absent' in (t/(stem+'-error.log')).read_text(encoding='utf-8-sig')
   checks.append(dict(test=stem,classification='retained implementation preflight failure; original logger absent by design',identity=identity));continue
  assert identity['exitCode']==0
  output=read(t/(stem+'.log'));assert output['passed']
  if kind=='native':assert not output['databaseOpened'] and output['nativeSha256'].lower()==native_hash and output['sqliteVersionNumber']>0
  else:assert output['tests']==2 and output['detailLimit']==32768 and output['throwingWriterContained']
  checks.append(dict(test=stem,classification='passed',identity=identity,output=output))
catalogs=[]
for path in sorted(r.glob('*/catalog.sqlite')):
 with sqlite3.connect(path.as_uri()+'?mode=ro',uri=True) as c:
  counts=dict(acceptedOperations=c.execute('SELECT count(*) FROM Operation').fetchone()[0],grantUses=c.execute('SELECT count(*) FROM GrantUse').fetchone()[0],targetLaunches=c.execute("SELECT count(*) FROM Record WHERE Kind='normal_build_launch'").fetchone()[0])
 assert all(v==0 for v in counts.values());catalogs.append(dict(test=path.parent.name,**counts))
assert len(catalogs)==5
value.update(controllerClosures=bundles,originalInputsSha256=sha(r/'inputs.json'),addendum=(research/'FIRST-FAILURE-NATIVE-ADDENDUM.md').read_text(),addendumSha256=sha(research/'FIRST-FAILURE-NATIVE-ADDENDUM.md'),nativeAssetSha256=native_hash,
 nativeWorkerSourceSha256=sha(research/'FirstFailureNativeWorker.cs.txt'),preflight=checks,plansNeverAccepted=True,preTargetCatalogCounts=catalogs,
 planFiles=[dict(test=p.parent.name,sha256=sha(p),id=read(p)['id'],contentHash=read(p)['content_hash']) for p in sorted(r.glob('*/plan.json'))])
assert len(value['planFiles'])==5 and sha(t/'first-failure-native-worker-source/Program.cs')==value['nativeWorkerSourceSha256']
(r/'native-inputs.json').write_bytes((json.dumps(value,indent=2)+'\n').encode())
audit=dict(passed=True,requiredNativeResolutions=2,newLoggerChecks=2,successfulPreflightProcesses=3,retainedFailedPreflightProcesses=1,targetOperationsAccepted=0,targetLaunches=0,
 originalFivePlansUnchanged=True,onlyControllerArmDelta='Application.dll',nativeAssetSha256=native_hash,originalStartupFailureRetained=True,comparativeTimingRecords=0)
(t/'p39-first-failure-native-prerequisite-audit.json').write_bytes((json.dumps(audit,indent=2)+'\n').encode());print(json.dumps(audit))
'@|python -
 if($LASTEXITCODE -ne 0){throw 'Original native prerequisite binding failed'}
 $names=@('FIRST-FAILURE-PROTOCOL.md','FIRST-FAILURE-NATIVE-ADDENDUM.md','FirstFailureNativeWorker.cs.txt','NormalSessionPrimaryFailure.cs.txt','Run-FirstFailureNative.ps1','Check-FirstFailureNativeCase.py','Host-Lock.ps1','Lab-LocalClient.ps1')
 $frozen=@{};foreach($n in $names){$frozen[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
 $frozen|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'frozen-dependencies-native.json')
 $a=Import-File (Join-Path $root 'native-inputs.json') application/json
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis.json') -Raw|ConvertFrom-Json;$record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism+' Before any target acceptance, retain failed native-helper startup and bind a separate helper to the exact original SQLite asset. Original five plans/predictions remain unchanged; old-logger invocation error retained as failed implementation preflight. No target operation or data is replaced.';prediction=$prior.prediction;state='planned';evidence_ids=@($prior.evidence_ids)+@($a.id)}
 $request|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'native-binding-revision-request.json');$response=Invoke-Lab lab.experiment $request
 $response|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'native-binding-revision-response.json')
 $snapshot=Join-Path $TaskRoot 'p39-first-failure-native-binding-driver-source';if(Test-Path -LiteralPath $snapshot){throw 'Original native binding source snapshot exists'};New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in @('Bind-FirstFailureNative.ps1','Build-FirstFailureNative.ps1','Complete-FirstFailureNativePreflight.ps1','FIRST-FAILURE-NATIVE-ADDENDUM.md','FirstFailureNativeWorker.cs.txt','Run-FirstFailureNative.ps1','Check-FirstFailureNativeCase.py','FIRST-FAILURE-PROTOCOL.md','Preserve.py','Verify-Evidence.py','Host-Lock.ps1','Lab-LocalClient.ps1')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 foreach($n in @('p39-first-failure-startup-stop.json','p39-first-failure-native-prerequisite-audit.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination $PSScriptRoot}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase35b','--content-addressed','--nested-catalog-root','p39-first-failure')
 foreach($prefix in @('p39-first-failure','first-failure-native-worker-source','first-failure-application-source','bundles/p39g')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Original native prerequisite archive failed'}
 $arguments=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase35b','--prerequisites-only')
 foreach($required in @('p39-first-failure/native-inputs.json','p39-first-failure/frozen-dependencies-native.json','p39-first-failure/native-binding-revision-response.json','p39-first-failure/native-binding-revision-request.json','p39-first-failure-startup-stop.json','p39-first-failure-native-prerequisite-audit.json','p39-first-failure/original-masked/worker-error.log','p39-first-failure/original-masked/worker-shutdown.json','p39-first-failure-native-initial-driver-source/FIRST-FAILURE-NATIVE-ADDENDUM.md','p39-first-failure-native-binding-driver-source/Run-FirstFailureNative.ps1','first-failure-native-worker-source/Program.cs','bundles/p39g0/FirstFailureWorker.dll','bundles/p39g1/FirstFailureWorker.dll','bundles/p39g0/runtimes/win-x64/native/e_sqlite3.dll','bundles/p39g1/runtimes/win-x64/native/e_sqlite3.dll')){$arguments+=@('--require',$required)}
 foreach($name in @('original-masked','logged-masked','logged-cleanup','logged-primary','logged-success')){$arguments+=@('--require',"p39-first-failure/$name/catalog-export.json")}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Original native prerequisite archive verification failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
