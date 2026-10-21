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
 $root=Join-Path $TaskRoot 'p36-normal-screen'
 if(-not (Test-Path -LiteralPath (Join-Path $root 'run-driver-completed.json'))){throw 'Original normal family is not complete; inspect original operation state'}
 $path=Join-Path $TaskRoot 'p36-normal-family-disposition.json'
 if(Test-Path -LiteralPath $path){throw 'Disposition exists; inspect original accepted state'}
 & python (Join-Path $PSScriptRoot 'Audit-WorldNormalFamily.py') $TaskRoot
 if($LASTEXITCODE -ne 0){throw 'Original normal family audit failed; retain all evidence'}
 $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p36-normal-family-audit.json') -Raw|ConvertFrom-Json -Depth 90
 if(-not $audit.complete -or $audit.distinct_process_start_identities -ne 288 -or $audit.joined_controllers -ne 12){throw 'Incomplete normal family'}
 @{state=$audit.disposition;primaryFutilityCount=$audit.primary_futility_count;guardedHarmCount=$audit.guarded_harm_count;normalSessions=288;sourceAdoption=$false;promotionEligible=$false;scope='Prospective first-family interval disposition only. Full original API/consumer/allocation and10x qualifications remain open; no posthoc allocation waiver, pooling or extra samples.'}|ConvertTo-Json|Set-Content -LiteralPath $path
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $evidence=@();foreach($file in @($path,(Join-Path $TaskRoot 'p36-normal-family-audit.json'))){$evidence+=@((Import-File $file application/json).id)}
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$audit.disposition;evidence_ids=@($prior.evidence_ids)+$evidence}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
 foreach($n in @('p36-normal-family-audit.json','p36-normal-family-disposition.json','native-summary-phase28-normal.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase28','--content-addressed')
 foreach($prefix in @('p36-normal-screen','p36-normal-family-audit.json','p36-normal-family-disposition.json','p36-normal-p36n0-native','p36-normal-p36n1-native','native-summary-phase28-normal.json')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Normal family preservation failed; retain original artifacts'}
 & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase28 --require p36-normal-screen/catalog-export.json --require p36-normal-screen/plans.json --require p36-normal-screen/run-driver-completed.json --require p36-normal-screen/disposition-revision-response.json --require p36-normal-family-audit.json --require p36-normal-family-disposition.json --require p36-normal-p36n0-native.asm --require p36-normal-p36n1-native.asm --require native-summary-phase28-normal.json
 if($LASTEXITCODE -ne 0){throw 'Normal family archive verification failed'}
 $result|ConvertTo-Json -Depth 15
}finally{Exit-VoxtreePerformanceHost $lease}
