param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$false
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    if(Test-Path -LiteralPath (Join-Path $TaskRoot 'control-c2')){throw 'C2 workspace exists; inspect prior accepted operations before recovery'}
    $fixture=Join-Path $PSScriptRoot 'Scenarios-c2.cs.txt'
    & python (Join-Path $PSScriptRoot 'Generate-Fixtures.py') --prime-ms 5000 --version 9 --output $fixture
    if($LASTEXITCODE -ne 0){throw 'C2 fixture generation failed'}
    foreach($label in @('c20','c21')) {
        & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label $label -CandidateRevision f0772c8 -FixtureName 'Scenarios-c2.cs.txt' -PrimaryBaselineCaller:($label -eq 'c20')
        Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --callers > (Join-Path $TaskRoot "$label-callers.json")
        if($LASTEXITCODE -ne 0){throw 'C2 caller inventory failed'}
        }
    }
    if((Get-Content -LiteralPath (Join-Path $TaskRoot 'c20-callers.json') -Raw) -ne (Get-Content -LiteralPath (Join-Path $TaskRoot 'c21-callers.json') -Raw)){throw 'C2 raw AfterBatch IL differs'}
    foreach($file in Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'c20/source') -Filter '*.cs') {
        if((Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath (Join-Path $TaskRoot "c21/source/$($file.Name)")).Hash){throw 'C2 library sources differ'}
    }
    $patch=& git diff --no-index -- (Join-Path $TaskRoot 'c20/Rig.csproj') (Join-Path $TaskRoot 'c21/Rig.csproj')
    if($LASTEXITCODE -gt 1){throw 'C2 project-difference capture failed'}
    $patchPath=Join-Path $TaskRoot 'control-c2-projects.diff'
    $patch | Set-Content -LiteralPath $patchPath
    $scenarios=@('point-Legacy-L5-full-owned-get','point-Legacy-L5-full-owned-lod','point-Legacy-L5-full-compiled-get','point-Legacy-L5-sparse-compiled-get','point-Wide-L5-long-owned-lod','point-Huge-L5-long-owned-lod')
    $workspace=Join-Path $TaskRoot 'control-c2'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/c21/c21.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace $workspace -SelectedScenarios $scenarios -Label c2-preflight -Budget fixed
    & (Join-Path $PSScriptRoot 'Confirm.ps1') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace $workspace -BaselineBundle (Join-Path $TaskRoot 'bundles/c20') -CandidateBundle (Join-Path $TaskRoot 'bundles/c21') -Scenarios $scenarios -ExplorationLabel c2-preflight -Label c2 -Budget long-window -SourcePatchFile $patchPath -SourceEquivalenceRationale 'Unchanged-library precision control: both primary namespaces and snapshot controls compile f0772c8. All primary source files and all raw AfterBatch IL hashes match. The control maps the baseline label to AfterBatch at compile time; treatment selects candidate AfterBatch. This one dispatch difference occurs once per batch outside identical loops. The attached real project diff records that define and entry-label/path differences, not unrelated production worktree edits. Dependencies and runtime settings match. Independent dense-value/LOD oracles validate inputs and complete work. Version 9, original fixed affinity 4, five-second primes and long-window counts define a new epoch; no old observations are pooled.'
} finally {Exit-VoxtreePerformanceHost $leases}
