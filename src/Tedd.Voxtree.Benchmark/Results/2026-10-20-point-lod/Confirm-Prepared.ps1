param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
$scenarios=@(Get-Content (Join-Path $TaskRoot 'final-scenarios.json') -Raw|ConvertFrom-Json)
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label n0c -CandidateRevision f0772c8 -PrimaryBaselineCaller
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label n1c
    foreach($label in @('n0c','n1c')) {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --callers > (Join-Path $TaskRoot "$label-callers.json")
        if($LASTEXITCODE -ne 0){throw 'Caller IL inventory failed'}
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --validate > (Join-Path $TaskRoot "$label-validation.log")
        if($LASTEXITCODE -ne 0){throw 'Confirmation fixture validation failed'}
    }
    if((Get-Content (Join-Path $TaskRoot 'n0c-callers.json') -Raw) -ne (Get-Content (Join-Path $TaskRoot 'n1c-callers.json') -Raw)){throw 'Caller IL mismatch'}
    & (Join-Path $PSScriptRoot 'Confirm.ps1') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'final-catalog') -BaselineBundle (Join-Path $TaskRoot 'bundles/n0c') -CandidateBundle (Join-Path $TaskRoot 'bundles/n1c') -Scenarios $scenarios -ExplorationLabel selected -Label final
} finally {Exit-VoxtreePerformanceHost $leases}
