param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$dependencies=@('Register-Hypothesis.ps1','Host-Lock.ps1','Prepare-BottomUpPacked.py','Run-Candidate.ps1','Build-Rig.ps1','Test-PackedLookup.ps1','Inspect-Code.ps1','Inspect-CountBody.ps1','PackedWriterOracle.cs.txt','BuilderProbe.cs.txt','PackedCorpus.cs.txt','Inspect-PackedCorpus.ps1','Scan-Forcecraft.cs.txt','Measure.ps1','Audit-PackedCorpus.py','Scenarios-packed-leaf.cs.txt','Scenarios-bulk.cs.txt','PackedWordFormatTests.cs.txt','PACKED-BOTTOM-UP-PROTOCOL.md')
$dependencyHashes=@{};foreach($name in $dependencies){$dependencyHashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $dependencies){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $dependencyHashes[$name]){throw "Queued dependency changed: $name"}}
    foreach($name in @('p25-hypothesis','p25point','p25bulk','p25bulk-screen','packed-bottom-up-source','p25census')){
        if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P25 identity exists; inspect original records before recovery'}
    }
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p25 -ProtocolName 'PACKED-BOTTOM-UP-PROTOCOL.md' -Mechanism 'A02/A03/A06/M05: packed output already reserves every voxel word. Initialize raw values once, identify uniform parents from eight canonical child anchors bottom-up, then fill canonical leaves. Remove repeated source-cube uniformity scans without extra arrays, changed bytes, selection or readers.' -Prediction 'Dominant UInt16/UInt32 complete constructors and caller Build/TryBuild become at least twice as fast as complete P24; every other complete caller stays within 5 percent. Exact packed bytes, capacities, LOD, full corpus, fallbacks and tests must pass first; static scan counts do not establish cost shares.'
    Invoke-VoxtreeExternalPhase {
        $dependencyHashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p25-queued-dependencies.json')
        & python (Join-Path $PSScriptRoot 'Prepare-BottomUpPacked.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P25 source preparation failed'}
    }
    & (Join-Path $PSScriptRoot 'Run-Candidate.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p25point -SourceDirectoryName packed-bottom-up-source -BaselineSource (Join-Path $TaskRoot 'packed-word-format-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' -TestFixture 'PackedWordFormatTests.cs.txt' -PackedLeaf -CorrectnessOnly
    Invoke-VoxtreeExternalPhase {
        $previousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p25point/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p25point') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p25point-off-results') -v minimal *> (Join-Path $TaskRoot 'p25point-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'P25 fallback tests failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$previousHw}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p25bulk -CandidateSource (Join-Path $TaskRoot 'packed-bottom-up-source') -BaselineSource (Join-Path $TaskRoot 'packed-word-format-source') -FixtureName 'Scenarios-bulk.cs.txt' *> (Join-Path $TaskRoot 'p25bulk-build.log')
    if($LASTEXITCODE -ne 0){throw 'P25 bulk build failed'}
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p25oracle -BundleLabel p25bulk -ProbeSource PackedWriterOracle.cs.txt -Methods '__no_native_listing_requested__'
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p25bulk/p25bulk.dll') --validate *> (Join-Path $TaskRoot 'p25bulk-validation.log')
        if($LASTEXITCODE -ne 0){throw 'P25 bulk oracle failed'}
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PACKED-BOTTOM-UP-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p25-frozen-protocol.txt')
        @{fixtureSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Scenarios-bulk.cs.txt')).Hash;protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'PACKED-BOTTOM-UP-PROTOCOL.md')).Hash;baseline='complete P24';candidate='packed-bottom-up-source';cases=88;budget='bounded-consumer';seed='20261027';independentBlocks=$false} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'p25bulk-binding.json')
    }
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p25bulk -ExactBytes
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p25census -CandidateSource (Join-Path $TaskRoot 'packed-bottom-up-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' *> (Join-Path $TaskRoot 'p25census-build.log')
    if($LASTEXITCODE -ne 0){throw 'P25 release corpus bundle failed'}
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p25census -PackedWordMagic
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Audit-PackedCorpus.py') $TaskRoot --bundle-label p25census
        if($LASTEXITCODE -ne 0){throw 'P25 release corpus audit failed'}
    }
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p25builder-code -BundleLabel p25bulk -ProbeSource BuilderProbe.cs.txt -Methods '*WriteBottomUp* *FillMarked* *BuildOwned* *BuildRoot*'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p25bulk/p25bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p25bulk-screen') -Filter 'bulk-*' -Label p25bulk -Budget bounded-consumer -Seed '20261027'
} finally {Exit-VoxtreePerformanceHost $leases}
