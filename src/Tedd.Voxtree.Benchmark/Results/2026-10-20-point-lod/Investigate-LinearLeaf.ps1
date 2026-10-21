param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    foreach($name in @('p22-hypothesis','p22point','p22bulk','p22bulk-screen','linear-leaf-source','p22-release-source')){
        if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P22 identity exists; inspect prior work'}
    }
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p22 -ProtocolName 'LINEAR-LEAF-PROTOCOL.md' -Mechanism 'A09/M25/C18: the released linear builder makes eight level-zero recursive summary calls and uses eight-summary scratch at level one. Specialize only this fixed shape, collapsing equal values or emitting the same eight value tokens directly, retaining all higher recursion and storage decisions.' -Prediction 'All ten dominant mixed-u16-air constructor/build/callerbuild/trybuild/required callers take at least 20 percent less time than f0772c8, with no greater than 5 percent adverse estimate in other construction/size/buildread guards. Exact bytes, capacity-failure mutations and complete callers must pass; native shrinkage alone is insufficient.'
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Prepare-LinearLeaf.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P22 source preparation failed'}
    }
    & (Join-Path $PSScriptRoot 'Run-Candidate.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p22point -SourceDirectoryName linear-leaf-source -BaselineSource (Join-Path $TaskRoot 'p22-release-source') -FixtureName 'Scenarios-packed-leaf.cs.txt' -TestFixture 'LinearLeafTests.cs.txt' -CorrectnessOnly
    Invoke-VoxtreeExternalPhase {
        $previousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p22point/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p22point') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p22point-off-results') -v minimal *> (Join-Path $TaskRoot 'p22point-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'P22 fallback tests failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$previousHw}
    }
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p22bulk -CandidateSource (Join-Path $TaskRoot 'linear-leaf-source') -BaselineSource (Join-Path $TaskRoot 'p22-release-source') -FixtureName 'Scenarios-bulk.cs.txt' *> (Join-Path $TaskRoot 'p22bulk-build.log')
    if($LASTEXITCODE -ne 0){throw 'P22 bulk build failed'}
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p22oracle -BundleLabel p22bulk -ProbeSource BuilderOracle.cs.txt -Methods '__no_native_listing_requested__'
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p22bulk/p22bulk.dll') --validate *> (Join-Path $TaskRoot 'p22bulk-validation.log')
        if($LASTEXITCODE -ne 0){throw 'P22 bulk oracle failed'}
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'LINEAR-LEAF-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p22-frozen-protocol.txt')
        @{fixtureSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Scenarios-bulk.cs.txt')).Hash;protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'LINEAR-LEAF-PROTOCOL.md')).Hash;baseline='p22-release-source';candidate='linear-leaf-source';cases=88;budget='bounded-consumer';independentBlocks=$false} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'p22bulk-binding.json')
    }
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p22builder-code -BundleLabel p22bulk -ProbeSource BuilderProbe.cs.txt -Methods '*BuildLinear* *WriteVarUInt* *WriteValue* *BuildRoot*'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p22bulk/p22bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p22bulk-screen') -Filter 'bulk-*' -Label p22bulk -Budget bounded-consumer
} finally {Exit-VoxtreePerformanceHost $leases}
