param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    foreach($name in @('p19-hypothesis','p19point','p19bulk','p19bulk-screen','packed-count-source')){
        if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P19 identity exists; inspect prior execution before recovery'}
    }
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p19 -ProtocolName 'PACKED-COUNT-PROTOCOL.md' -Mechanism 'A09/C18: packed CountMatches uses per-voxel general State.Accept and box construction in actual x64 code. Select Count once and use a dedicated scalar counter, preserving the existing point word validation and all other consumers.' -Prediction 'All four dominant UInt16/UInt32 count and miss callers take at most half the P18 elapsed time in the frozen 88-case exploratory screen. Semantic mismatch, persistent general count dispatch, inadequate reduction or adverse required guards falsify selection; no automatic adoption from same-process blocks.'
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Prepare-PackedCount.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P19 preparation failed'}
    }
    & (Join-Path $PSScriptRoot 'Run-Candidate.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p19point -SourceDirectoryName packed-count-source -BaselineSource (Join-Path $TaskRoot 'leaf-helper-inline-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' -TestFixture 'PackedCountTests.cs.txt' -PackedLeaf -CorrectnessOnly
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p19bulk -CandidateSource (Join-Path $TaskRoot 'packed-count-source') -BaselineSource (Join-Path $TaskRoot 'leaf-helper-inline-source') -FixtureName 'Scenarios-bulk.cs.txt' *> (Join-Path $TaskRoot 'p19bulk-build.log')
    if($LASTEXITCODE -ne 0){throw 'P19 bulk build failed'}
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p19bulk/p19bulk.dll') --validate *> (Join-Path $TaskRoot 'p19bulk-validation.log')
        if($LASTEXITCODE -ne 0){throw 'P19 complete-operation oracle failed'}
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PACKED-COUNT-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p19-frozen-protocol.txt')
        @{fixtureSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Scenarios-bulk.cs.txt')).Hash;protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'PACKED-COUNT-PROTOCOL.md')).Hash;baseline='leaf-helper-inline-source';candidate='packed-count-source';cases=88;budget='bounded-consumer';independentBlocks=$false} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'p19bulk-binding.json')
    }
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p19count-code -BundleLabel p19bulk
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p19bulk/p19bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p19bulk-screen') -Filter 'bulk-*' -Label p19bulk -Budget bounded-consumer
} finally {Exit-VoxtreePerformanceHost $leases}
