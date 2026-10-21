param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    foreach($name in @('p23-hypothesis','p23point','p23bulk','p23bulk-screen','sizing-writer-source','p23-release-source')){
        if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P23 identity exists; inspect prior work'}
    }
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p23 -ProtocolName 'SIZING-WRITER-PROTOCOL.md' -Mechanism 'A03/A09/C04: measurement-only writer loops still advance and check bounds/mode for every byte. Compute canonical token length from exact unsigned bit length and advance once, preserving partial failure positions and ordinary writes, on .NET 10+ only.' -Prediction 'All six nonuniform real-fixture GetRequiredSize callers take at least 10 percent less time than f0772c8, with no greater than 5 percent adverse estimate in the other construction/size/buildread guards. Exact bytes, capacity-failure mutations and complete callers must pass; fewer loop iterations alone are insufficient.'
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Prepare-SizingWriter.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P23 source preparation failed'}
    }
    & (Join-Path $PSScriptRoot 'Run-Candidate.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p23point -SourceDirectoryName sizing-writer-source -BaselineSource (Join-Path $TaskRoot 'p23-release-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' -TestFixture 'SizingWriterTests.cs.txt' -CorrectnessOnly
    Invoke-VoxtreeExternalPhase {
        $previousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p23point/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p23point') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p23point-off-results') -v minimal *> (Join-Path $TaskRoot 'p23point-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'P23 fallback tests failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$previousHw}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p23bulk -CandidateSource (Join-Path $TaskRoot 'sizing-writer-source') -BaselineSource (Join-Path $TaskRoot 'p23-release-source') -FixtureName 'Scenarios-bulk.cs.txt' *> (Join-Path $TaskRoot 'p23bulk-build.log')
    if($LASTEXITCODE -ne 0){throw 'P23 bulk build failed'}
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p23oracle -BundleLabel p23bulk -ProbeSource BuilderOracle.cs.txt -Methods '__no_native_listing_requested__'
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p23bulk/p23bulk.dll') --validate *> (Join-Path $TaskRoot 'p23bulk-validation.log')
        if($LASTEXITCODE -ne 0){throw 'P23 bulk oracle failed'}
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'SIZING-WRITER-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p23-frozen-protocol.txt')
        @{fixtureSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Scenarios-bulk.cs.txt')).Hash;protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'SIZING-WRITER-PROTOCOL.md')).Hash;baseline='p23-release-source';candidate='sizing-writer-source';cases=88;budget='bounded-consumer';independentBlocks=$false} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'p23bulk-binding.json')
    }
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p23builder-code -BundleLabel p23bulk -ProbeSource BuilderProbe.cs.txt -Methods '*BuildLinear* *WriteVarUInt* *WriteValue* *BuildRoot*'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p23bulk/p23bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p23bulk-screen') -Filter 'bulk-*' -Label p23bulk -Budget bounded-consumer
} finally {Exit-VoxtreePerformanceHost $leases}
