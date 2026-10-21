param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
throw 'P28 not selected: actual P27 owned LOD palette branches already inline the proposed span boundary. See P28-BOUNDARY-PRECHECK.md.'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Register-Hypothesis.ps1','Prepare-OwnedLod.py','Review-OwnedLod.py','Scenarios-byte-palette.cs.txt','PaletteLeafTests.cs.txt','Test-PackedLookup.ps1','Build-Rig.ps1','OWNED-LOD-DIRECT-PROTOCOL.md')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$test=Join-Path $PSScriptRoot '../../../Tedd.Voxtree.Tests/OwnedLodSnapshotTests.cs'
$testHash=(Get-FileHash -LiteralPath $test).Hash
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P28 setup dependency changed'}}
    if((Get-FileHash -LiteralPath $test).Hash -ne $testHash){throw 'Queued P28 semantic test changed'}
    if(-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase13-verified.json'))){throw 'P27 original closure must be verified before P28'}
    foreach($name in @('p28-hypothesis','owned-lod-direct-source','p28point','packed-lookup-validation-p28parent','packed-lookup-validation-p28sem')){if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P28 setup identity exists; inspect original state'}}
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p28 -ProtocolName 'OWNED-LOD-DIRECT-PROTOCOL.md' -Mechanism 'C18/A11: replace owned Get-with-LOD trusted-span materialization and call boundary with one volatile snapshot, identical ordered guards and direct checked codec call; expose only these two small methods to selective inlining. Exact complete P27 encoder/readers/format remain.' -Prediction 'Both dominant owned UInt16/UInt32 LOD callers improve at least10 percent versus complete P27 in the fixed48-case screen, preserving every other1.05 cost guard, outputs, exception order, concurrent snapshot and zero-allocation reads. Emitted boundaries are supporting diagnostics, not a causal time fraction; direct-release10x requires later independent confirmation.'
    Invoke-VoxtreeExternalPhase {
        $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p28-setup-dependencies.json')
        @{path=(Resolve-Path -LiteralPath $test).Path;sha256=$testHash}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p28-semantic-test-binding.json')
        Copy-Item -LiteralPath $test -Destination (Join-Path $TaskRoot 'p28-OwnedLodSnapshotTests.cs.txt')
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'OWNED-LOD-DIRECT-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p28-frozen-protocol.txt')
        & python (Join-Path $PSScriptRoot 'Prepare-OwnedLod.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P28 source generation failed'}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p28point -CandidateSource (Join-Path $TaskRoot 'owned-lod-direct-source') -BaselineSource (Join-Path $TaskRoot 'byte-palette-source') -FixtureName Scenarios-byte-palette.cs.txt *> (Join-Path $TaskRoot 'p28point-build.log')
    if($LASTEXITCODE -ne 0){throw 'P28 paired build failed; retain log'}
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Review-OwnedLod.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P28 complete source binding failed'}
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p28point/p28point.dll') --validate *> (Join-Path $TaskRoot 'p28point-validation.log')
        if($LASTEXITCODE -ne 0){throw 'P28 full point semantic oracles failed'}
    }
    foreach($case in @(@{label='p28parent';source='byte-palette-source'},@{label='p28sem';source='owned-lod-direct-source'})){
        & (Join-Path $PSScriptRoot 'Test-PackedLookup.ps1') -TaskRoot $TaskRoot -Label $case.label -SourceDirectoryName $case.source -FixtureName PaletteLeafTests.cs.txt -PaletteLeaf
    }
    Invoke-VoxtreeExternalPhase {
        $previousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p28sem/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p28sem') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p28sem-off-results') -v minimal *> (Join-Path $TaskRoot 'p28sem-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'P28 intrinsics-off suite failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$previousHw}
    }
} finally {Exit-VoxtreePerformanceHost $lease}
