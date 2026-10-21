param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 $main=Join-Path $TaskRoot 'p39-first-failure'
 $plans=@(Get-Content -LiteralPath (Join-Path $main 'plans.json') -Raw|ConvertFrom-Json -Depth 90)
 if($plans.Count -ne 5 -or @(Get-ChildItem -LiteralPath $main -Recurse -Filter 'worker-accepted.json').Count -ne 0 -or @(Get-ChildItem -LiteralPath $main -Recurse -Filter 'grant.json').Count -ne 0){throw 'Expected exactly five frozen pre-launch plans and no grants/operations'}
 $hashes=Get-Content -LiteralPath (Join-Path $main 'frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
 foreach($n in $hashes.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Frozen diagnostic dependency changed'}}
 $origin=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-source.json') -Raw|ConvertFrom-Json -Depth 70
 $changed=@()
 foreach($r in $origin.manifest){
  $old=Join-Path $TaskRoot "coldlog-controller-source/src/Tedd.DotNetLab.Application/$($r.file)";$new=Join-Path $TaskRoot "first-failure-application-source/$($r.file)"
  if((Get-FileHash -LiteralPath $old).Hash.ToLowerInvariant() -ne $r.beforeSha256 -or (Get-FileHash -LiteralPath $new).Hash.ToLowerInvariant() -ne $r.afterSha256){throw 'Original Application source binding changed'}
  if($r.changed){$changed+=@($r.file)}
 }
 if($changed.Count -ne 1 -or $changed[0] -ne 'ConfirmationService.cs' -or $origin.originalSourceFiles -ne 47){throw 'Expected only one original source delta'}
 $input=Get-Content -LiteralPath (Join-Path $main 'inputs.json') -Raw|ConvertFrom-Json -Depth 90
 $closure=@();foreach($b in $input.controllerClosures){$dict=@{};foreach($f in $b.files){if((Get-FileHash -LiteralPath $f.path).Hash -ne $f.sha256){throw 'Original diagnostic closure changed'};$dict[$f.name]=$f.sha256};$closure+=@($dict)}
 if($closure[0].Count -ne $closure[1].Count -or @($closure[0].Keys|Where-Object{$closure[0][$_] -ne $closure[1][$_]}).Count -ne 1 -or $closure[0]['Tedd.DotNetLab.Application.dll'] -eq $closure[1]['Tedd.DotNetLab.Application.dll']){throw 'Expected only Application.dll delta in complete closure'}
 $self=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-logger-selftest.log') -Raw|ConvertFrom-Json
 $selfId=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-logger-selftest.json') -Raw|ConvertFrom-Json
 if(-not $self.passed -or $self.tests -ne 2 -or -not $selfId.joined -or $selfId.exitCode -ne 0){throw 'Original logger selftests incomplete'}
 $snapshot=Join-Path $TaskRoot 'p39-first-failure-prerequisite-driver-source';if(Test-Path -LiteralPath $snapshot){throw 'Original prerequisite snapshot exists'};New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in @('FIRST-FAILURE-PROTOCOL.md','Prepare-FirstFailure.py','Build-FirstFailure.ps1','Build-FirstFailureWorker2.ps1','NormalSessionPrimaryFailure.cs.txt','FirstFailureWorker.cs.txt','Register-FirstFailure.ps1','Run-FirstFailure.ps1','Check-FirstFailureCase.py','Preserve-FirstFailurePrerequisites.ps1','Host-Lock.ps1','Lab-LocalClient.ps1','Preserve.py','Verify-Evidence.py')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 Copy-Item -LiteralPath (Join-Path $TaskRoot 'coldlog-controller-source/src/Tedd.DotNetLab.Application/ConfirmationService.cs') -Destination (Join-Path $snapshot 'OriginalConfirmationService.cs.txt')
 @{passed=$true;originalSourceFiles=47;changedOriginalSourceFiles=1;addedPrivateLogger=$true;unchangedOriginalSourceFiles=46;originalMeasurementCleanupLogicUnchanged=$true;controllerClosureFiles=$closure[0].Count;onlyControllerFileDelta='Tedd.DotNetLab.Application.dll';loggerSelftests=2;plans=5;grantsIssued=0;targetLaunches=0;maximumTargetLaunches=28;maximumDiagnosticMeasuredSessions=25;comparativeTimingRecords=0;initialWorkerCompilerFailureRetained=$true}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-prerequisite-audit.json')
 Copy-Item -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-prerequisite-audit.json') -Destination $PSScriptRoot
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase35a','--content-addressed','--nested-catalog-root','p39-first-failure')
 foreach($prefix in @('p39-first-failure','first-failure-application-source','first-failure-worker-source','first-failure-worker2-source','bundles/p39f')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Original controller diagnostic prerequisite preservation failed'}
 $arguments=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase35a','--prerequisites-only')
 foreach($required in @('p39-first-failure/catalog-export.json','p39-first-failure/plans.json','p39-first-failure/frozen-dependencies.json','p39-first-failure-prerequisite-audit.json','p39-first-failure-source.json','p39-first-failure-worker-repair.json','p39-first-failure-worker-build.log','p39-first-failure-initial-build-driver-source/FirstFailureWorker.cs.txt','first-failure-application-source/NormalSessionPrimaryFailure.cs','first-failure-worker2-source/Program.cs','p39-first-failure-prerequisite-driver-source/OriginalConfirmationService.cs.txt','bundles/p39f0/Tedd.DotNetLab.Application.dll','bundles/p39f1/Tedd.DotNetLab.Application.dll','bundles/p39f0/FirstFailureWorker.dll','bundles/p39f1/FirstFailureWorker.dll')){$arguments+=@('--require',$required)}
 foreach($p in $plans){$arguments+=@('--require',"p39-first-failure/$($p.test.name)/catalog-export.json",'--require',"p39-first-failure/$($p.test.name)/plan.json")}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Original controller diagnostic prerequisite archive verification failed'}
 $verified=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase35a-verified.json') -Raw|ConvertFrom-Json
 if($verified.catalogs -ne 6 -or $verified.metric_rows -ne 0){throw 'Expected six catalogs and zero comparative metrics'}
}finally{Exit-VoxtreePerformanceHost $lease}
