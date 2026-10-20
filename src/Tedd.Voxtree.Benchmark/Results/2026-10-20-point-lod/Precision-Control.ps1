param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
$scenarios=@('point-Legacy-L5-full-owned-get','point-Legacy-L5-full-owned-lod','point-Legacy-L5-full-compiled-get','point-Legacy-L5-sparse-compiled-get','point-Wide-L5-long-owned-lod','point-Huge-L5-long-owned-lod')
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    foreach($label in @('pc0','pc1')) {
        & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label $label -CandidateRevision f0772c8 -FixtureName 'Scenarios-precision.cs.txt' -PrimaryBaselineCaller:($label -eq 'pc0')
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --callers > (Join-Path $TaskRoot "$label-callers.json")
        if($LASTEXITCODE -ne 0){throw 'Precision caller inventory failed'}
    }
    if((Get-Content (Join-Path $TaskRoot 'pc0-callers.json') -Raw) -ne (Get-Content (Join-Path $TaskRoot 'pc1-callers.json') -Raw)){throw 'Precision caller IL mismatch'}
    $workspace=Join-Path $TaskRoot 'precision-control'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/pc1/pc1.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace $workspace -SelectedScenarios $scenarios -Label control-screen -Budget precision
    & (Join-Path $PSScriptRoot 'Confirm.ps1') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace $workspace -BaselineBundle (Join-Path $TaskRoot 'bundles/pc0') -CandidateBundle (Join-Path $TaskRoot 'bundles/pc1') -Scenarios $scenarios -ExplorationLabel control-screen -Label precision -Budget precision
} finally {Exit-VoxtreePerformanceHost $leases}
