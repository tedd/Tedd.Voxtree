param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in @('p24-hypothesis','p24point','p24control','p24census','packed-word-format-source')){if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P24 identity exists; inspect prior state'}}
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p24 -ProtocolName 'PACKED-WORD-FORMAT-PROTOCOL.md' -Mechanism 'A12/M05: retain the packed value/exact-LOD representation, but disambiguate its header with magic P and explicit public packed-version constants. Hot word-reader bodies and capacities remain P18; published O/version1/2 layouts remain readable and unchanged.' -Prediction 'All semantic and cross-format checks pass, with packed payload/eligibility equal to P18. A separately frozen direct-release full eight-case normal confirmation must give at least a tenfold adjusted time lower bound in every dominant Get/LOD case. Point-only evidence cannot qualify broader guards or adoption.'
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Prepare-PackedWordFormat.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P24 source preparation failed'}
    }
    & (Join-Path $PSScriptRoot 'Run-Candidate.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p24point -SourceDirectoryName packed-word-format-source -BaselineSource (Join-Path $TaskRoot 'leaf-helper-inline-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' -TestFixture 'PackedWordFormatTests.cs.txt' -PackedLeaf -CorrectnessOnly
    Invoke-VoxtreeExternalPhase {
        $previousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {& dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p24point/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p24point') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p24point-off-results') -v minimal *> (Join-Path $TaskRoot 'p24point-intrinsics-off.log');if($LASTEXITCODE -ne 0){throw 'P24 intrinsics-off tests failed'}} finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$previousHw}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p24control -CandidateRevision f0772c8 -PrimaryBaselineCaller -FixtureName 'Scenarios-packed-leaf.cs.txt' *> (Join-Path $TaskRoot 'p24control-build.log')
    if($LASTEXITCODE -ne 0){throw 'P24 release control build failed'}
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p24census -CandidateSource (Join-Path $TaskRoot 'packed-word-format-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' *> (Join-Path $TaskRoot 'p24census-build.log')
    if($LASTEXITCODE -ne 0){throw 'P24 candidate normal build failed'}
    Invoke-VoxtreeExternalPhase {
        foreach($label in @('p24control','p24census')){
            & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --validate *> (Join-Path $TaskRoot "$label-normal-validation.log")
            if($LASTEXITCODE -ne 0){throw 'P24 normal oracle failed'}
        }
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PACKED-WORD-FORMAT-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p24-frozen-protocol.txt')
    }
    & (Join-Path $PSScriptRoot 'Audit-Callers.ps1') -TaskRoot $TaskRoot -Label caller-audit-p24normal -BundleLabels @('p24control','p24census')
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p24census -PackedWordMagic
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Audit-PackedCorpus.py') $TaskRoot --bundle-label p24census
        if($LASTEXITCODE -ne 0){throw 'P24 full corpus audit failed'}
    }
    foreach($type in @('UInt16','UInt32')){
        & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot 'bundles/p24census') -Label "p24-$type-owned-code" -Scenario "point-Force$type-L5-mixed-u16-air-owned-lod" -Methods '*GetPacked* *GetDirectState* *GetUnchecked* *TryGet* *ReadWord* *Value* *AfterBatch*'
    }
} finally {Exit-VoxtreePerformanceHost $leases}
