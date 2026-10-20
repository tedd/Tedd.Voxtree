param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    foreach($name in @('p20-hypothesis','p20point','p20bulk','p20bulk-screen','p20census','packed-count-vector-source')){
        if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P20 identity exists; inspect original execution before recovery'}
    }
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p20 -ProtocolName 'PACKED-COUNT-VECTOR-PROTOCOL.md' -Mechanism 'A03/V03/V04: P19 count loops remain scalar. Count validated contiguous packed-word ranges with existing masked SIMD predicates, preserving raw-bit filtering, local LOD rejection, clipped-row semantics and scalar fallback.' -Prediction 'All four dominant UInt16/UInt32 count and miss callers take at most half P19 time in the frozen version-14 96-case exploratory family. Incorrect masks/tails/LOD behavior, overread, insufficient benefit or adverse mandatory guards falsify selection. No promotion from same-process estimates.'
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Prepare-PackedCountVector.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'Vector source preparation failed'}
        & python (Join-Path $PSScriptRoot 'Generate-Bulk14-Fixtures.py')
        if($LASTEXITCODE -ne 0){throw 'Version-14 fixture generation failed'}
    }
    & (Join-Path $PSScriptRoot 'Run-Candidate.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p20point -SourceDirectoryName packed-count-vector-source -BaselineSource (Join-Path $TaskRoot 'packed-count-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' -TestFixture 'PackedCountVectorTests.cs.txt' -PackedLeaf -CorrectnessOnly
    Invoke-VoxtreeExternalPhase {
        $taskPreviousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0'
            Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p20point/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p20point') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p20point-off-results') -v minimal *> (Join-Path $TaskRoot 'p20point-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'Vector fallback regression failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$taskPreviousHw}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p20census -CandidateSource (Join-Path $TaskRoot 'packed-count-vector-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' *> (Join-Path $TaskRoot 'p20census-build.log')
    if($LASTEXITCODE -ne 0){throw 'Vector released-control corpus build failed'}
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p20census
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p20bulk -CandidateSource (Join-Path $TaskRoot 'packed-count-vector-source') -BaselineSource (Join-Path $TaskRoot 'packed-count-source') -FixtureName 'Scenarios-bulk14.cs.txt' *> (Join-Path $TaskRoot 'p20bulk-build.log')
    if($LASTEXITCODE -ne 0){throw 'Vector bulk build failed'}
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p20bulk/p20bulk.dll') --validate *> (Join-Path $TaskRoot 'p20bulk-validation.log')
        if($LASTEXITCODE -ne 0){throw 'Version-14 full oracle failed'}
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PACKED-COUNT-VECTOR-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p20-frozen-protocol.txt')
        @{fixtureSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Scenarios-bulk14.cs.txt')).Hash;protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'PACKED-COUNT-VECTOR-PROTOCOL.md')).Hash;baseline='packed-count-source';candidate='packed-count-vector-source';cases=96;budget='bounded-consumer-v14';independentBlocks=$false} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'p20bulk-binding.json')
    }
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p20count-code -BundleLabel p20bulk
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p20bulk/p20bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p20bulk-screen') -Filter 'bulk-*' -Label p20bulk -Budget bounded-consumer-v14
} finally {Exit-VoxtreePerformanceHost $leases}
