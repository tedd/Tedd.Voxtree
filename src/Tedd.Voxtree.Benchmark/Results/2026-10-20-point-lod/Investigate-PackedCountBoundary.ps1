param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    foreach($name in @('p21-hypothesis','p21point','p21bulk','p21bulk-screen','packed-count-boundary-source')){
        if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P21 identity exists; inspect prior work'}
    }
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p21 -ProtocolName 'PACKED-COUNT-BOUNDARY-PROTOCOL.md' -Mechanism 'C18: P20 vector helper expands the shared CountPacked dispatcher and fixed stack frame. Prevent inlining only of the two vector helpers, retaining all executable bodies and semantics, to protect the scalar short-row path.' -Prediction 'All four dominant seven-element-row count/miss callers are at least 20 percent faster than P20, with no greater than 5 percent adverse estimate in the eight full/17-row count/miss guards. Code shrink without complete-caller benefit is insufficient; same-process results do not authorize adoption.'
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Prepare-PackedCountBoundary.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P21 source preparation failed'}
    }
    & (Join-Path $PSScriptRoot 'Run-Candidate.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p21point -SourceDirectoryName packed-count-boundary-source -BaselineSource (Join-Path $TaskRoot 'packed-count-vector-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' -TestFixture 'PackedCountVectorTests.cs.txt' -PackedLeaf -CorrectnessOnly
    Invoke-VoxtreeExternalPhase {
        $taskPreviousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p21point/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p21point') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p21point-off-results') -v minimal *> (Join-Path $TaskRoot 'p21point-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'P21 fallback tests failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$taskPreviousHw}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p21bulk -CandidateSource (Join-Path $TaskRoot 'packed-count-boundary-source') -BaselineSource (Join-Path $TaskRoot 'packed-count-vector-source') -FixtureName 'Scenarios-bulk14.cs.txt' *> (Join-Path $TaskRoot 'p21bulk-build.log')
    if($LASTEXITCODE -ne 0){throw 'P21 bulk build failed'}
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p21bulk/p21bulk.dll') --validate *> (Join-Path $TaskRoot 'p21bulk-validation.log')
        if($LASTEXITCODE -ne 0){throw 'P21 bulk oracle failed'}
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PACKED-COUNT-BOUNDARY-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p21-frozen-protocol.txt')
        @{fixtureSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Scenarios-bulk14.cs.txt')).Hash;protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'PACKED-COUNT-BOUNDARY-PROTOCOL.md')).Hash;baseline='packed-count-vector-source';candidate='packed-count-boundary-source';cases=96;budget='bounded-consumer-v14';independentBlocks=$false} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'p21bulk-binding.json')
    }
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p21shape-code -BundleLabel p21bulk -ProbeSource CountShapeProbe.cs.txt
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p21bulk/p21bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p21bulk-screen') -Filter 'bulk-*' -Label p21bulk -Budget bounded-consumer-v14
} finally {Exit-VoxtreePerformanceHost $leases}
