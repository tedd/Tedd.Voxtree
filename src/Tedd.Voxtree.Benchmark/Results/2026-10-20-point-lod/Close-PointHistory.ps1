param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try {
    $path=Join-Path $TaskRoot 'h2-native-audit.json';$audit=Get-Content -LiteralPath $path -Raw|ConvertFrom-Json -Depth 80
    if(-not $audit.allChecksPassedAndJoined -or $audit.rows.Count -ne 16 -or $audit.timedRuns -ne 0 -or $audit.callBoundaryDifferentialBetweenArms){throw 'H2 expected diagnostic result incomplete'}
    foreach($history in @('get-first','lod-first')){
        $identity=Get-Content -LiteralPath (Join-Path $TaskRoot "h2-$history-identity.json") -Raw|ConvertFrom-Json
        if(-not $identity.exited -or $identity.exitCode -ne 0 -or $identity.timedOut){throw 'H2 process not joined'}
    }
    $script:root=Join-Path $TaskRoot 'h2-hypothesis'
    $created=(Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
    $artifact=Import-File $path application/json
    $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$audit.state;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
    $result=Invoke-Lab lab.experiment $request
    $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
    foreach($name in @('h2-native-audit.json','h2-history-schedule.json','native-summary-phase20-history.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination (Join-Path $PSScriptRoot $name)}
    $bindings=@{files=@(foreach($n in @('POINT-HISTORY-DIAGNOSTIC.md','Prepare-PointHistory.py','PointHistoryProbe.cs.txt','Inspect-PointHistory.ps1','Audit-PointHistory.py')){@{file=$n;sha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}});sdkPin=(Get-Content -LiteralPath (Join-Path $TaskRoot 'global.json') -Raw);sdkPinSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'global.json')).Hash}
    $bindings|ConvertTo-Json -Depth 10|Set-Content -LiteralPath (Join-Path $TaskRoot 'h2-source-bindings.json')
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase20','--content-addressed')
    foreach($prefix in @('h2','point-history-h2-source','native-summary-phase20-history.json')){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'H2 diagnostic preservation failed; retain partial outputs'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase20 --prerequisites-only --require h2-native-audit.json --require h2-history-schedule.json --require h2-hypothesis/disposition-revision-response.json --require h2-get-first.asm --require h2-lod-first.asm --require point-history-h2-source/Program.cs
    if($LASTEXITCODE -ne 0){throw 'H2 diagnostic archive failed verification'}
    @{state=$audit.state;historyDependence=$true;differentialCallBoundary=$false;timedRuns=0;mappedCallers=16}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $lease}
