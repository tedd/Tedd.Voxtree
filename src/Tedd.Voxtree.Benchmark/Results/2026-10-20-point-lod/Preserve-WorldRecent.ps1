param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 $frozen=Get-Content -LiteralPath (Join-Path $TaskRoot 'p34-timing-frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
 foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'P34 frozen dependency changed'}}
 & python (Join-Path $PSScriptRoot 'Review-WorldRecentSource.py') $TaskRoot
 if($LASTEXITCODE -ne 0){throw 'P34 complete source/context review failed'}
 $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p34-world-stage-audit.json') -Raw|ConvertFrom-Json -Depth 80
 if($audit.caseCount -ne 40 -or $audit.runCount -ne 320 -or -not $audit.allCorrectQuiescentJoined){throw 'P34 stage incomplete'}
 $root=Join-Path $TaskRoot 'p34-hypothesis'
 $path=Join-Path $TaskRoot 'p34-disposition.json';if(Test-Path -LiteralPath $path){throw 'P34 disposition exists; inspect accepted state'}
 $state=if($audit.stagePassed){'inconclusive'}else{'not_supported'}
 @{state=$state;primaryPassed=$audit.primaryPassed;failedGuardCount=$audit.failedGuardCount;stagePassed=$audit.stagePassed;allObservedAllocationsZero=$audit.allObservedAllocationsZero;normalConfirmation=$false;promotionEligible=$false;scope='Exploratory last-entry shortcut on published f0772c8; conditional fresh confirmation only if every stage gate passes; no adoption or complete10x claim.'}|ConvertTo-Json|Set-Content -LiteralPath $path
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $evidence=@();foreach($file in @($path,(Join-Path $TaskRoot 'p34-world-stage-audit.json'),(Join-Path $TaskRoot 'p34-prerequisite-audit.json'),(Join-Path $TaskRoot 'p34-source-review.json'))){$evidence+=@((Import-File $file application/json).id)}
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$state;evidence_ids=@($prior.evidence_ids)+$evidence}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
 foreach($n in @('p34-world-stage-audit.json','p34-prerequisite-audit.json','p34-disposition.json','p34-source-review.json','p34-world-normalized-source.diff','native-summary-phase23-world.json','p34-world-source.diff')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase23','--content-addressed')
 foreach($prefix in @('p34','world-recent-source','bundles/p34world','packed-lookup-validation-p34world','packed-lookup-p34world','packed-lookup-tests-p34world','packed-lookup-test-options-p34world','native-summary-phase23-world')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P34 evidence preservation failed; retain original artifacts'}
 & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase23 --require p34world-screen/catalog-export.json --require p34-hypothesis/catalog-export.json --require p34-world-stage-audit.json --require p34-prerequisite-audit.json --require p34-world-native.asm --require bundles/p34world/p34world.dll --require world-recent-source/WorldEntity.cs --require p34-hypothesis/disposition-revision-response.json
 if($LASTEXITCODE -ne 0){throw 'P34 evidence archive verification failed'}
 $result|ConvertTo-Json -Depth 15
}finally{Exit-VoxtreePerformanceHost $lease}
