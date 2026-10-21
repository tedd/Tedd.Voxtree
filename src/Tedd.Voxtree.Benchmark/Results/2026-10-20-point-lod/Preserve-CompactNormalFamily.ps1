param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
 $root=Join-Path $TaskRoot 'p39-normal'
 $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-normal-family-audit.json') -Raw|ConvertFrom-Json -Depth 90
 if($audit.complete -or $audit.completed_cases -ne 91 -or $audit.distinct_process_start_identities -ne 2193 -or $audit.joined_controllers -ne 92 -or $audit.cleaned_timing_storage_roots -ne 72 -or -not $audit.family_classification_withheld){throw 'Expected original stopped family and verified joins; do not resume or replace it'}
 $path=Join-Path $TaskRoot 'p39-normal-family-disposition.json'
 if(Test-Path -LiteralPath $path){throw 'Original disposition exists; inspect accepted state'}
 @{state='inconclusive';complete=$false;plannedCases=107;plannedSessions=2568;completedCases=91;failedCases=1;unstartedCases=15;retainedMeasuredSessions=2193;additionalUnmeasuredLaunches=1;primaryFutilityCount=0;guardedHarmCount=0;familyClassificationWithheld=$true;promotionEligible=$false;sourceAdoption=$false;scope='Original P39/P31-local family stopped under its prospective execution-failure rule. UnauthorizedAccessException in launch-directory cleanup may mask an earlier unmeasured-launch failure. All original records retained; no retry/replacement/partial-case comparison. Original margins/allocation policies unchanged. P31 remains unpromoted; original-release/consumer/full API/memory/format/allocation/original10x qualification remain open.'}|ConvertTo-Json|Set-Content -LiteralPath $path
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $evidence=@();foreach($file in @($path,(Join-Path $TaskRoot 'p39-normal-family-audit.json'))){$evidence+=@((Import-File $file application/json).id)}
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$audit.disposition;evidence_ids=@($prior.evidence_ids)+$evidence}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
 $snapshot=Join-Path $TaskRoot 'p39-normal-family-driver-source'
 if(Test-Path -LiteralPath $snapshot){throw 'Original family audit source snapshot exists'}
 New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in @('Audit-CompactNormalFamily.py','Preserve-CompactNormalFamily.ps1','Inspect-CompactNormalFailure.ps1','Verify-CompactNormalArchive.py','Run-CompactNormal.ps1','COMPACT-TERMINAL-NORMAL-PROTOCOL.md','Host-Lock.ps1','Lab-LocalClient.ps1','Preserve.py','Verify-Evidence.py')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 $initial=& git -C 'D:\SourceCode\Tedd.Voxtree' show 'c0e5e7e:src/Tedd.Voxtree.Benchmark/Results/2026-10-20-point-lod/Audit-CompactNormalFamily.py'
 if($LASTEXITCODE -ne 0){throw 'Original committed family auditor unavailable'}
 [IO.File]::WriteAllText((Join-Path $snapshot 'Audit-CompactNormalFamily-initial.py.txt'),($initial -join "`n")+"`n",[Text.UTF8Encoding]::new($false))
 foreach($pair in @(@('Tedd.DotNetLab.Application/ConfirmationService.cs','OriginalConfirmationService.cs.txt'),@('Tedd.DotNetLab.Application/NormalBuildService.cs','OriginalNormalBuildService.cs.txt'),@('Tedd.DotNetLab.Artifacts/OwnedDirectoryCleanup.cs','OriginalOwnedDirectoryCleanup.cs.txt'))){Copy-Item -LiteralPath (Join-Path $TaskRoot "coldlog-controller-source/src/$($pair[0])") -Destination (Join-Path $snapshot $pair[1])}
 foreach($n in @('p39-normal-family-audit.json','p39-normal-family-disposition.json','p39-normal-cleanup-failure.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $argsList=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase33','--content-addressed')
 foreach($prefix in @('p39-normal','p39n2','p39n3','bundles/p39n2','bundles/p39n3','caller-audit-p39normalstorage','native-summary-phase32-normal-storage.json')){$argsList+=@('--include-prefix',$prefix)}
 & python @argsList
 if($LASTEXITCODE -ne 0){throw 'Compact normal family preservation failed; preserve original evidence'}
 $argsList=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase33')
 foreach($required in @('p39-normal/catalog-export.json','p39-normal/disposition-revision-response.json','p39-normal/run-driver-start.json','p39-normal/driver-failure.log','p39-normal-family-audit.json','p39-normal-family-disposition.json','p39-normal-cleanup-failure.json','p39-normal/failed-cleanup-orphan-launch.json','p39-normal-failure-inspection-initial.json','p39-normal-failure-inspection-driver-source/Inspect-CompactNormalFailure.ps1','p39-normal-family-driver-source/Audit-CompactNormalFamily.py','p39-normal-family-driver-source/Audit-CompactNormalFamily-initial.py.txt','p39-normal-family-driver-source/OriginalConfirmationService.cs.txt','p39-normal/launches/normal-session-c9c46c4bc80b4371a55ff1c993cac45c/CompactNormal.dll','bundles/p39n2/CompactNormal.dll','bundles/p39n3/CompactNormal.dll','native-summary-phase32-normal-storage.json')){$argsList+=@('--require',$required)}
 & python @argsList
 if($LASTEXITCODE -ne 0){throw 'Compact normal family archive verification failed'}
 $verified=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase33-verified.json') -Raw|ConvertFrom-Json
 if($verified.metric_rows -ne 182){throw 'Expected182 retained objectives from91 completed cases; incomplete case has no comparison'}
 & python (Join-Path $PSScriptRoot 'Verify-CompactNormalArchive.py') $PSScriptRoot
 if($LASTEXITCODE -ne 0){throw 'Per-case original archive mapping validation failed'}
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
