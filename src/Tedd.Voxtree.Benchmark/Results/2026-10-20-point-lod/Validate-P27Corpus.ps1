param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in @('p27bulk','packed-corpus-p27setup-source')){if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P27 corpus identity exists; inspect original state'}}
    Invoke-VoxtreeExternalPhase {
        $oldHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p27sem/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p27sem') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p27sem-off-results') -v minimal *> (Join-Path $TaskRoot 'p27sem-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'P27 hardware-off suite failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$oldHw}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p27bulk -CandidateSource (Join-Path $TaskRoot 'byte-palette-source') -FixtureName 'Scenarios-bulk.cs.txt' *> (Join-Path $TaskRoot 'p27bulk-build.log')
    if($LASTEXITCODE -ne 0){throw 'P27 bulk bundle build failed'}
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p27bulk/p27bulk.dll') --validate *> (Join-Path $TaskRoot 'p27bulk-validation.log')
        if($LASTEXITCODE -ne 0){throw 'P27 bulk semantic oracle failed'}
    }
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p27setup -PaletteLeaf
} finally {Exit-VoxtreePerformanceHost $lease}
