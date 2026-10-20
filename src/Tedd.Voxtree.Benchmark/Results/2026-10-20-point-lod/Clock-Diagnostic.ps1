param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label clock1 -CandidateRevision f0772c8 -FixtureName 'Scenarios-clock.cs.txt'
    $index=0
    foreach($priority in @('normal','high','high','normal')) {
        $index++
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/clock1/clock1.dll') --clocks $priority *> (Join-Path $TaskRoot "clock1-$index-$priority.jsonl")
        if($LASTEXITCODE -ne 0){throw 'Clock diagnostic failed; preserve original observations'}
        Write-Output "Clock diagnostic $index ($priority) completed"
    }
} finally {Exit-VoxtreePerformanceHost $leases}
