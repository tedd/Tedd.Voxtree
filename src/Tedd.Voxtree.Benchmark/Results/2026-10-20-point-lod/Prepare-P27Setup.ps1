param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Register-Hypothesis.ps1','Prepare-BytePalette.py','PaletteLeafEncoding.cs.txt','Scenarios-byte-palette.cs.txt','Build-Rig.ps1','BYTE-PALETTE-FORMAT-PROTOCOL.md')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P27 dependency changed'}}
    foreach($name in @('p27-hypothesis','byte-palette-source','p27setup')){if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P27 setup identity exists; inspect original state'}}
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p27 -ProtocolName 'BYTE-PALETTE-FORMAT-PROTOCOL.md' -Mechanism 'A12/A14/M01/M05/M25: replace expanded packed words with one byte per voxel and a sorted full raw value/LOD table. J1 measured <=83 states per chunk and27 on the preselected sample. Bound selected encoded growth at25 percent and preserve exact released fallback bytes, values, LOD, capacities and consumers.' -Prediction 'New format exactly reproduces J1 selection and payload on all1286 chunks, preserves semantics on all public consumers, and every prioritized UInt16/UInt32 owned/span point/LOD case reaches10x versus f0772c8 under a separate frozen experiment. Two loads and projected bytes establish no latency or allocation claim; original guards remain.'
    Invoke-VoxtreeExternalPhase {
        $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p27-setup-dependencies.json')
        & python (Join-Path $PSScriptRoot 'Prepare-BytePalette.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P27 source preparation failed'}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p27setup -CandidateSource (Join-Path $TaskRoot 'byte-palette-source') -FixtureName 'Scenarios-byte-palette.cs.txt' *> (Join-Path $TaskRoot 'p27setup-build.log')
    if($LASTEXITCODE -ne 0){throw 'P27 initial build failed; preserve log'}
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p27setup/p27setup.dll') --validate *> (Join-Path $TaskRoot 'p27setup-validation.log')
        if($LASTEXITCODE -ne 0){throw 'P27 initial semantic oracle failed; retain evidence'}
    }
} finally {Exit-VoxtreePerformanceHost $lease}
