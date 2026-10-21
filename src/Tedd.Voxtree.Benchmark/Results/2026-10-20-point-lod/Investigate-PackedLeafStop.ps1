param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$dependencies=@('Register-Hypothesis.ps1','Host-Lock.ps1','Prepare-PackedLeafStop.py','Run-Candidate.ps1','Build-Rig.ps1','Test-PackedLookup.ps1','Inspect-Code.ps1','Inspect-CountBody.ps1','PackedWriterOracle.cs.txt','BuilderProbe.cs.txt','PackedCorpus.cs.txt','Inspect-PackedCorpus.ps1','Scan-Forcecraft.cs.txt','Measure.ps1','Scenarios-packed-leaf.cs.txt','Scenarios-bulk.cs.txt','PackedWordFormatTests.cs.txt','PACKED-LEAF-STOP-PROTOCOL.md')
$hashes=@{};foreach($name in $dependencies){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $dependencies){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw "Queued dependency changed: $name"}}
    foreach($name in @('p26-hypothesis','p26point','p26bulk','p26bulk-screen','packed-leaf-stop-source')){
        if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P26 identity exists; inspect original work before recovery'}
    }
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p26 -ProtocolName 'PACKED-LEAF-STOP-PROTOCOL.md' -Mechanism 'A03/A09/M25/C18: P25 initializes every voxel word before bottom-up marking. A split level-one node already has its eight final LOD-zero words. Stop FillMarked at that boundary, eliminating eight recursive calls and redundant loads/fills while preserving all other source.' -Prediction 'All six dominant UInt16/UInt32 constructor and caller Build/TryBuild costs fall at least 20 percent (speedup>=1.25) against complete P25. All other 82 complete callers remain within the original 1.05 cost guard. Exact bytes, capacities, LOD, all framework/fallback tests and full-corpus comparison must pass. Static code does not establish the elapsed fraction.'
    Invoke-VoxtreeExternalPhase {
        $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p26-queued-dependencies.json')
        & python (Join-Path $PSScriptRoot 'Prepare-PackedLeafStop.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P26 source generation failed'}
    }
    $control=Join-Path $TaskRoot 'packed-bottom-up-source';$selected=Join-Path $TaskRoot 'packed-leaf-stop-source'
    & (Join-Path $PSScriptRoot 'Run-Candidate.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p26point -SourceDirectoryName packed-leaf-stop-source -BaselineSource $control -FixtureName 'Scenarios-packed-leaf.cs.txt' -TestFixture 'PackedWordFormatTests.cs.txt' -PackedLeaf -CorrectnessOnly
    Invoke-VoxtreeExternalPhase {
        $previousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p26point/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p26point') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p26point-off-results') -v minimal *> (Join-Path $TaskRoot 'p26point-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'P26 hardware-off tests failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$previousHw}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p26bulk -CandidateSource $selected -BaselineSource $control -FixtureName 'Scenarios-bulk.cs.txt' *> (Join-Path $TaskRoot 'p26bulk-build.log')
    if($LASTEXITCODE -ne 0){throw 'P26 bulk build failed'}
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p26oracle -BundleLabel p26bulk -ProbeSource PackedWriterOracle.cs.txt -Methods '__no_native_listing_requested__'
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p26bulk/p26bulk.dll') --validate *> (Join-Path $TaskRoot 'p26bulk-validation.log')
        if($LASTEXITCODE -ne 0){throw 'P26 full-caller oracle failed'}
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PACKED-LEAF-STOP-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p26-frozen-protocol.txt')
        @{fixtureSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Scenarios-bulk.cs.txt')).Hash;protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'PACKED-LEAF-STOP-PROTOCOL.md')).Hash;baseline='complete P25';candidate='packed-leaf-stop-source';cases=88;budget='bounded-consumer';seed='20261028';independentBlocks=$false}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p26bulk-binding.json')
    }
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p26bulk -ExactBytes
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p26builder-code -BundleLabel p26bulk -ProbeSource BuilderProbe.cs.txt -Methods '*WriteBottomUp* *FillMarked* *BuildOwned* *BuildRoot*'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p26bulk/p26bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p26bulk-screen') -Filter 'bulk-*' -Label p26bulk -Budget bounded-consumer -Seed '20261028'
} finally {Exit-VoxtreePerformanceHost $leases}
