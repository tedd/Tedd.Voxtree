param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source
$labHost=Join-Path $TaskRoot 'coldlog-controller-source/logged2-out/Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
 $auditPath=Join-Path $TaskRoot 'p39-first-failure-study-audit.json'
 $audit=Get-Content -LiteralPath $auditPath -Raw|ConvertFrom-Json -Depth 90
 if(-not $audit.passed -or $audit.originalTests -ne 5 -or $audit.targetLaunches -ne 28 -or $audit.retainedMeasuredSessions -ne 25 -or -not $audit.originalTargetsNotLive -or $audit.joinedWorkers -ne 5 -or $audit.comparativeTimingRecords -ne 0 -or $audit.sourceAdoption){throw 'Original study audit incomplete'}
 $roots=@((Join-Path $TaskRoot 'p39-first-failure'))
 foreach($case in $audit.cases){$roots+=Join-Path $TaskRoot ('p39-first-failure/'+$case.name)}
 foreach($root in $roots){
  $path=Join-Path $root 'study-disposition.json'
  if(Test-Path -LiteralPath $path){throw 'Original study disposition exists; inspect supported revision instead of retrying'}
  @{state='supported';scope='Deterministic first-error retention only; not library performance or promotion';audit=$audit;originalIntermittentCauseResolved=$false;productionSourceChanged=$false}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $path
  $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis.json') -Raw|ConvertFrom-Json
  $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
  $artifact=Import-File $path application/json
  $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism+' Controlled diagnostic tests support first-error retention only. Existing measurement and cleanup logic remains unchanged; original intermittent failure cause and library promotion remain unresolved.';prediction=$prior.prediction;state='supported';evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
  $request|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'study-revision-request.json')
  $response=Invoke-Lab lab.experiment $request
  $response|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'study-revision-response.json')
 }
 $snapshot=Join-Path $TaskRoot 'p39-first-failure-final-driver-source'
 if(Test-Path -LiteralPath $snapshot){throw 'Original final driver snapshot exists'}
 New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($name in @('Audit-FirstFailureStudy.py','Close-FirstFailureStudy.ps1','Preserve.py','Verify-Evidence.py','Host-Lock.ps1','Lab-LocalClient.ps1')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination $snapshot}
 Copy-Item -LiteralPath $auditPath -Destination $PSScriptRoot
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase35c','--content-addressed','--nested-catalog-root','p39-first-failure')
 foreach($prefix in @('p39-first-failure','first-failure-application-source','first-failure-native-worker-source','bundles/p39g')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Original final study preservation failed'}
 $arguments=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase35c','--prerequisites-only')
 foreach($required in @('p39-first-failure/catalog-export.json','p39-first-failure/native-driver-completed.json','p39-first-failure/study-revision-response.json','p39-first-failure-study-audit.json','p39-first-failure-initial-study-audit-driver-source/Audit-FirstFailureStudy.py','p39-first-failure-initial-study-audit-failure.json','p39-first-failure-final-driver-source/Audit-FirstFailureStudy.py','bundles/p39g1/runtimes/win-x64/native/e_sqlite3.dll','bundles/p39g1/Tedd.DotNetLab.Application.dll')){$arguments+=@('--require',$required)}
 foreach($case in $audit.cases){foreach($file in @('catalog-export.json','case-native-audit.json','quiescence-native.json','worker-terminal.json','worker-native-shutdown.json','study-revision-response.json')){$arguments+=@('--require',('p39-first-failure/'+$case.name+'/'+$file))}}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Original final study verification failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
