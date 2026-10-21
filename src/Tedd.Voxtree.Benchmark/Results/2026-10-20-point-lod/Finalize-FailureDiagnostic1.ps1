param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $root=Join-Path $TaskRoot 'p18-failure-diagnostic-1';$path=Join-Path $root 'disposition.json'
    if(Test-Path -LiteralPath $path){throw 'D1 disposition exists; inspect revision'}
    $summary=Get-Content -LiteralPath (Join-Path $TaskRoot 'failure-diagnostic-1-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $full=Get-Content -LiteralPath (Join-Path $TaskRoot 'exception-summary-d1-source/summary.json') -Raw|ConvertFrom-Json -Depth 40
    if($summary.complete_cases -ne 8 -or $summary.declared_sessions -ne 192 -or $summary.generic_failure_reproduced){throw 'D1 outcome differs; revise diagnosis before disposition'}
    if(-not $full.fullEventEnumerationComplete -or -not $full.rawTransportEndedNormally -or $full.eventsLost -ne 0){throw 'D1 full replay unavailable'}
    @{state='inconclusive';genericFailureReproduced=$false;budgetExhausted=$true;cases=8;sessions=192;promotionEligible=$false;
        originalCappedObserverResultUnchanged=$true;fullReplay=$full;completeLifecycleAudit=$summary;
        interpretation='Generic failure was not reproduced in the fixed diagnostic budget. Full replay of the same raw trace recovers 50173 exceptions, preserving the capped export. Expected exception flow is not an application failure. Do not repeat the budget without a new diagnostic hypothesis; do not use these measurements for optimization selection or promotion.'}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $path
    $hostPath=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $hyp=Get-Content -LiteralPath (Join-Path $root 'hypothesis.json') -Raw|ConvertFrom-Json
    $recordRaw=([ordered]@{action='record';id=$hyp.id}|ConvertTo-Json -Compress)|& dotnet exec --fx-version 10.0.13 $hostPath call $root lab.inspect
    if($LASTEXITCODE -ne 0 -or ($recordRaw|ConvertFrom-Json).status -ne 'ok'){throw 'D1 hypothesis discovery failed'}
    $record=($recordRaw|ConvertFrom-Json).data;$prior=$record.json|ConvertFrom-Json
    $artifactRaw=& dotnet exec --fx-version 10.0.13 $hostPath import $root $path application/json
    if($LASTEXITCODE -ne 0){throw 'D1 disposition import failed'};$artifact=$artifactRaw|ConvertFrom-Json
    $request=[ordered]@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state='inconclusive';evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'revision-request.json')
    $response=($request|ConvertTo-Json -Depth 30 -Compress)|& dotnet exec --fx-version 10.0.13 $hostPath call $root lab.experiment
    $response|Set-Content -LiteralPath (Join-Path $root 'revision-response.json')
    if($LASTEXITCODE -ne 0 -or ($response|ConvertFrom-Json).status -ne 'ok'){throw 'D1 revision failed'}
    $dest=Join-Path $PSScriptRoot 'failure-diagnostic-1-disposition.json';if(Test-Path -LiteralPath $dest){throw 'Permanent D1 disposition exists'}
    Copy-Item -LiteralPath $path -Destination $dest
    'D1 hypothesis inconclusive; no performance comparison or promotion record created.'
} finally {Exit-VoxtreePerformanceHost $leases}
