param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$false
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    if(Test-Path -LiteralPath (Join-Path $TaskRoot 'control-c3')){throw 'C3 workspace exists; inspect accepted operations before recovery'}
    & python (Join-Path $PSScriptRoot 'Generate-Control-C3.py')
    if($LASTEXITCODE -ne 0){throw 'C3 generation failed'}
    foreach($label in @('c30','c31')) {
        & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label $label -CandidateRevision f0772c8 -FixtureName 'Scenarios-c3.cs.txt' -PrimaryBaselineCaller:($label -eq 'c30')
        Invoke-VoxtreeExternalPhase {
            & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --callers > (Join-Path $TaskRoot "$label-callers.json")
            if($LASTEXITCODE -ne 0){throw 'C3 caller inventory failed'}
            & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --validate *> (Join-Path $TaskRoot "$label-validation.log")
            if($LASTEXITCODE -ne 0){throw 'C3 operation-unit validation failed'}
        }
    }
    if((Get-Content -LiteralPath (Join-Path $TaskRoot 'c30-callers.json') -Raw) -ne (Get-Content -LiteralPath (Join-Path $TaskRoot 'c31-callers.json') -Raw)){throw 'C3 raw AfterBatch IL differs'}
    foreach($file in Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'c30/source') -Filter '*.cs') {
        if((Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath (Join-Path $TaskRoot "c31/source/$($file.Name)")).Hash){throw 'C3 library source differs'}
    }
    $patch=& git diff --no-index -- (Join-Path $TaskRoot 'c30/Rig.csproj') (Join-Path $TaskRoot 'c31/Rig.csproj')
    if($LASTEXITCODE -gt 1){throw 'C3 project-difference capture failed'}
    $patchPath=Join-Path $TaskRoot 'control-c3-projects.diff'
    $patch | Set-Content -LiteralPath $patchPath
    $scenarios=@('point-Legacy-L5-full-owned-get','point-Legacy-L5-full-owned-lod','point-Legacy-L5-full-compiled-get','point-Legacy-L5-sparse-compiled-get','point-Wide-L5-long-owned-lod','point-Huge-L5-long-owned-lod')
    $workspace=Join-Path $TaskRoot 'control-c3'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/c31/c31.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace $workspace -SelectedScenarios $scenarios -Label c3-preflight -Budget fixed
    & (Join-Path $PSScriptRoot 'Confirm.ps1') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace $workspace -BaselineBundle (Join-Path $TaskRoot 'bundles/c30') -CandidateBundle (Join-Path $TaskRoot 'bundles/c31') -Scenarios $scenarios -ExplorationLabel c3-preflight -Label c3 -Budget grouped-window -SourcePatchFile $patchPath -SourceEquivalenceRationale 'Unchanged-library precision control: both primary namespaces and snapshot controls compile f0772c8. All primary source files and all raw AfterBatch IL hashes match. Control maps baseline to AfterBatch outside the loop; treatment selects candidate AfterBatch. The actual project diff records that define and entry identity differences. Dependencies/runtime match. Version 11 explicitly declares sixteen public reads per logical operation; checked physical counts and dense/LOD oracles verify complete useful work. Original affinity 4, five-second primes and bounded long-window counts define a new epoch. No old observations are pooled.'
} finally {Exit-VoxtreePerformanceHost $leases}
