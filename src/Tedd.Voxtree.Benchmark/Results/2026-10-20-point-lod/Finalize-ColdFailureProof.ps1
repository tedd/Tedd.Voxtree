param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $proof=Get-Content -LiteralPath (Join-Path $TaskRoot 'coldlog-functional-audit.json') -Raw|ConvertFrom-Json -Depth 80
    if(-not $proof.supported_functionally -or $proof.valid_sessions -ne 48 -or $proof.launches -ne 50){throw 'L1 functional proof incomplete'}
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    foreach($variant in @('base','logged')){
        $root=Join-Path $TaskRoot "coldlog-$variant-proof2";$path=Join-Path $root 'disposition.json'
        if(Test-Path -LiteralPath $path){throw 'L1 disposition exists; inspect revision'}
        @{state='supported';scope='Functional logging claim only; no performance/promotion evidence';proof=$proof;historicFaultFixed=$false}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $path
        $hostPath=Join-Path $TaskRoot "coldlog-controller-source/${variant}2-out/Tedd.DotNetLab.Host.dll"
        $hyp=Get-Content -LiteralPath (Join-Path $root 'hypothesis.json') -Raw|ConvertFrom-Json
        $raw=([ordered]@{action='record';id=$hyp.id}|ConvertTo-Json -Compress)|& dotnet exec --fx-version 10.0.13 $hostPath call $root lab.inspect
        if($LASTEXITCODE -ne 0 -or ($raw|ConvertFrom-Json).status -ne 'ok'){throw 'L1 hypothesis discovery failed'}
        $record=($raw|ConvertFrom-Json).data;$prior=$record.json|ConvertFrom-Json
        $artifactRaw=& dotnet exec --fx-version 10.0.13 $hostPath import $root $path application/json
        if($LASTEXITCODE -ne 0){throw 'L1 disposition import failed'};$artifact=$artifactRaw|ConvertFrom-Json
        $request=[ordered]@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state='supported';evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
        $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'revision-request.json')
        $response=($request|ConvertTo-Json -Depth 30 -Compress)|& dotnet exec --fx-version 10.0.13 $hostPath call $root lab.experiment
        $response|Set-Content -LiteralPath (Join-Path $root 'revision-response.json')
        if($LASTEXITCODE -ne 0 -or ($response|ConvertFrom-Json).status -ne 'ok'){throw 'L1 hypothesis revision failed'}
    }
    'L1 logging hypothesis supported functionally; no performance comparison created.'
} finally {Exit-VoxtreePerformanceHost $leases}
