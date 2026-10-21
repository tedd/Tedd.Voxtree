param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Register-Hypothesis.ps1','Prepare-BuildPlanReuse.py','Review-BuildPlanReuse.py','BUILD-PLAN-REUSE-PROTOCOL.md','PaletteLeafTests.cs.txt','PaletteReturnCases.cs.txt','Scenarios-byte-palette.cs.txt','Scenarios-bulk.cs.txt','Test-PackedLookup.ps1','Build-Rig.ps1','Inspect-PackedCorpus.ps1','PackedCorpus.cs.txt','Audit-PackedCorpus.py','Inspect-CountBody.ps1','BuildPlanReuseProbe.cs.txt','PackedWriterOracle.cs.txt')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P30 dependency changed'}}
    if(-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase14-verified.json'))){throw 'P29 original closure must be verified'}
    foreach($name in @('p30-hypothesis','build-plan-reuse-source','p30point','p30bulk','p30census','packed-lookup-validation-p30sem')){if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P30 setup identity exists; inspect original state'}}
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p30 -ProtocolName 'BUILD-PLAN-REUSE-PROTOCOL.md' -Mechanism 'A03/A11: eligible owned legacy-tree fallback already has a validated BuildPlan but remeasures it in TryBuild. Extract the identical planned write body; pass the existing per-call plan from BuildOwned while public TryBuild retains its original validation and planning. Exact P27 encoder policy, bytes, capacity mutations, tail, ownership and readers remain.' -Prediction 'All eight UInt16/UInt32 mixed-u7-air and mixed-u8-air constructor/owned-Build exploratory contrasts improve at least20 percent over P27, with all80 other complete-operation guards <=1.05 cost. Verify actual tree fixtures, unchanged writer body, full differential/corpus semantics and emitted plan reuse before the fixed88-case timing budget. No source cache, ratio multiplication, PMU share or10x claim from this contrast.'
    Invoke-VoxtreeExternalPhase {
        $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p30-setup-dependencies.json')
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'BUILD-PLAN-REUSE-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p30-frozen-protocol.txt')
        & python (Join-Path $PSScriptRoot 'Prepare-BuildPlanReuse.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P30 source generation failed'}
    }
    foreach($case in @(@{label='p30point';fixture='Scenarios-byte-palette.cs.txt';parent='byte-palette-source'},@{label='p30bulk';fixture='Scenarios-bulk.cs.txt';parent='byte-palette-source'},@{label='p30census';fixture='Scenarios-byte-palette.cs.txt';parent=''})){
        & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label $case.label -CandidateSource (Join-Path $TaskRoot 'build-plan-reuse-source') -BaselineSource $(if($case.parent){Join-Path $TaskRoot $case.parent}else{''}) -FixtureName $case.fixture *> (Join-Path $TaskRoot ($case.label+'-build.log'))
        if($LASTEXITCODE -ne 0){throw 'P30 rig build failed; retain source and logs'}
        Invoke-VoxtreeExternalPhase {
            & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot ('bundles/'+$case.label+'/'+$case.label+'.dll')) --validate *> (Join-Path $TaskRoot ($case.label+'-validation.log'))
            if($LASTEXITCODE -ne 0){throw 'P30 complete scenario oracle failed'}
        }
    }
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Review-BuildPlanReuse.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P30 compiled source review failed'}
    }
    & (Join-Path $PSScriptRoot 'Test-PackedLookup.ps1') -TaskRoot $TaskRoot -Label p30sem -SourceDirectoryName build-plan-reuse-source -FixtureName PaletteLeafTests.cs.txt -ExtraFixtureName PaletteReturnCases.cs.txt -PaletteLeaf
    Invoke-VoxtreeExternalPhase {
        $previousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p30sem/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p30sem') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p30sem-off-results') -v minimal *> (Join-Path $TaskRoot 'p30sem-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'P30 intrinsics-off suite failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$previousHw}
    }
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p30oracle -BundleLabel p30bulk -ProbeSource PackedWriterOracle.cs.txt -Methods '*NoMethodExpected*'
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p30census -PaletteLeaf -ExactParentBundle p27setup
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Audit-PackedCorpus.py') $TaskRoot --bundle-label p30census
        if($LASTEXITCODE -ne 0){throw 'P30 complete corpus audit failed'}
    }
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p30builder-code -BundleLabel p30bulk -ProbeSource BuildPlanReuseProbe.cs.txt -Methods '*BuildOwned* *TryBuild* *CreateBuildPlan*'
} finally {Exit-VoxtreePerformanceHost $lease}
