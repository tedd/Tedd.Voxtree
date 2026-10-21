param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 $frozen=Get-Content -LiteralPath (Join-Path $TaskRoot 'p35-timing-frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
 foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'P35 timing dependency changed'}}
 $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p35-world-stage-audit.json') -Raw|ConvertFrom-Json -Depth 80
 if($audit.caseCount -ne 60 -or $audit.runCount -ne 480 -or -not $audit.allCorrectQuiescentJoined){throw 'P35 stage incomplete'}
 $root=Join-Path $TaskRoot 'p35-hypothesis';$path=Join-Path $TaskRoot 'p35-disposition.json'
 if(Test-Path -LiteralPath $path){throw 'P35 disposition exists; inspect original accepted state'}
 $state=if($audit.stagePassed){'inconclusive'}else{'not_supported'}
 @{state=$state;primaryPassed=$audit.primaryPassed;failedPrimaryCount=$audit.failedPrimaryCount;failedGuardCount=$audit.failedGuardCount;stagePassed=$audit.stagePassed;allObservedAllocationsZero=$audit.allObservedAllocationsZero;normalConfirmation=$false;promotionEligible=$false;scope='P35 conservative seen-layer filter on complete published source. Only an all-gates pass selects separately frozen normal confirmation and constructor/mutation/storage/memory/caller guards. No adoption or full10x claim.'}|ConvertTo-Json|Set-Content -LiteralPath $path
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $evidence=@();foreach($file in @($path,(Join-Path $TaskRoot 'p35-world-stage-audit.json'),(Join-Path $TaskRoot 'p35-prerequisite-audit.json'))){$evidence+=@((Import-File $file application/json).id)}
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$state;evidence_ids=@($prior.evidence_ids)+$evidence}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
 foreach($n in @('p35-world-stage-audit.json','p35-disposition.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase25','--content-addressed')
 foreach($prefix in @('p35world-screen','p35-world-stage-audit.json','p35-disposition.json','p35-timing-frozen-dependencies.json','p35-hypothesis')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P35 stage preservation failed; retain original artifacts'}
 & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase25 --require p35world-screen/catalog-export.json --require p35-hypothesis/catalog-export.json --require p35-world-stage-audit.json --require p35-disposition.json --require p35-hypothesis/disposition-revision-response.json
 if($LASTEXITCODE -ne 0){throw 'P35 stage archive verification failed'}
 $result|ConvertTo-Json -Depth 15
}finally{Exit-VoxtreePerformanceHost $lease}
