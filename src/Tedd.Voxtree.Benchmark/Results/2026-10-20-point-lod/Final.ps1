param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory,[switch]$ResumePrepared)
$ErrorActionPreference='Stop'
$scenarios=@(
 'point-Legacy-L5-full-owned-get',
 'point-Legacy-L5-full-owned-lod',
 'point-Legacy-L5-full-span-lod',
 'point-Legacy-L5-full-owned-trylod',
 'point-Legacy-L5-full-sequential-get',
 'point-Legacy-L5-coarse-owned-lod',
 'point-Legacy-L5-uniform-owned-lod',
 'point-Legacy-L5-dense-owned-lod',
 'point-Wide-L5-full-owned-lod',
 'point-Wide-L5-long-owned-lod',
 'point-Huge-L5-full-owned-lod',
 'point-Huge-L5-long-owned-get',
 'point-Huge-L5-long-owned-lod',
 'point-Legacy-L5-coarse-compiled-get',
 'point-Legacy-L5-coarse-compiled-lod',
 'point-Legacy-L5-coarse-compiled-create',
 'point-Legacy-L5-coarse-compiled-lifecycle',
 'point-Legacy-L5-long-compiled-lod',
 'point-Legacy-L5-full-compiled-get',
 'point-Legacy-L5-full-compiled-lod',
 'point-Legacy-L5-full-compiled-lifecycle',
 'point-Legacy-L5-sparse-compiled-get',
 'point-Legacy-L5-sparse-compiled-lod',
 'point-Legacy-L5-sparse-compiled-lifecycle'
)
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    $scenarios|ConvertTo-Json|Set-Content (Join-Path $TaskRoot 'final-scenarios.json')
    if(-not $ResumePrepared) {
        & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label n0 -CandidateRevision f0772c8
        & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label n1
    }
    foreach($label in @('n0','n1')) {
        foreach($file in (Get-Content (Join-Path $TaskRoot "$label-hashes.json") -Raw|ConvertFrom-Json)) {
            if((Get-FileHash -LiteralPath $file.Path).Hash -ne $file.Hash){throw 'Prepared bundle hash mismatch'}
        }
        if($ResumePrepared){continue}
        Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --validate *> (Join-Path $TaskRoot "$label-validation.log")
        if($LASTEXITCODE -ne 0){throw "$label fixture validation failed"}
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --fuzz *> (Join-Path $TaskRoot "$label-fuzz.log")
        if($LASTEXITCODE -ne 0){throw "$label malformed differential failed"}
        }
    }
    $workspace=Join-Path $TaskRoot 'final-catalog'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/n1/n1.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace $workspace -SelectedScenarios $scenarios -Label selected -Budget scaled
    & (Join-Path $PSScriptRoot 'Confirm.ps1') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace $workspace -BaselineBundle (Join-Path $TaskRoot 'bundles/n0') -CandidateBundle (Join-Path $TaskRoot 'bundles/n1') -Scenarios $scenarios -ExplorationLabel selected -Label final
} finally {Exit-VoxtreePerformanceHost $leases}
