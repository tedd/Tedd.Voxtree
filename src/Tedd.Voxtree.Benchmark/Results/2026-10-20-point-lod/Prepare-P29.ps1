param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Register-Hypothesis.ps1','Prepare-PaletteReturn.py','Review-PaletteReturn.py','PALETTE-RETURN-PROTOCOL.md','PaletteLeafTests.cs.txt','PaletteReturnCases.cs.txt','Scenarios-byte-palette.cs.txt','Scenarios-bulk.cs.txt','Test-PackedLookup.ps1','Build-Rig.ps1','Inspect-PackedCorpus.ps1','PackedCorpus.cs.txt','Audit-PackedCorpus.py','Inspect-Code.ps1')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P29 dependency changed'}}
    if(-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase13-verified.json'))){throw 'P27 original closure must be verified'}
    foreach($name in @('p29-hypothesis','palette-return-source','p29point','p29bulk','p29census','packed-lookup-validation-p29parent','packed-lookup-validation-p29sem')){if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P29 setup identity exists; inspect original state'}}
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p29 -ProtocolName 'PALETTE-RETURN-PROTOCOL.md' -Mechanism 'C18/A11: direct throwing palette path returns checked state/value instead of boolean/out-value propagation; packed dispatch precedes existing legacy fallback. A bounded invalid-LOD sentinel preserves every raw value bit. Existing bool TryGet, encoders, wire, ownership, queries and lookup remain exact P27. Native value-only caller retains temporary value/LOD stores despite inlining.' -Prediction 'All four dominant UInt32 owned/span Get/LOD exploratory callers improve at least10 percent over complete P27, with all44 other time guards at<=1.05 cost and exact outputs/errors/bytes. Actual optimized caller must show a changed temporary-output path before spending the fixed48-case budget. No PMU/time-share claim or multiplied-ratio10x inference.'
    Invoke-VoxtreeExternalPhase {
        $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p29-setup-dependencies.json')
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PALETTE-RETURN-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p29-frozen-protocol.txt')
        & python (Join-Path $PSScriptRoot 'Prepare-PaletteReturn.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P29 source generation failed'}
    }
    foreach($case in @(@{label='p29point';fixture='Scenarios-byte-palette.cs.txt';parent='byte-palette-source'},@{label='p29bulk';fixture='Scenarios-bulk.cs.txt';parent='byte-palette-source'},@{label='p29census';fixture='Scenarios-byte-palette.cs.txt';parent=''})){
        & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label $case.label -CandidateSource (Join-Path $TaskRoot 'palette-return-source') -BaselineSource $(if($case.parent){Join-Path $TaskRoot $case.parent}else{''}) -FixtureName $case.fixture *> (Join-Path $TaskRoot ($case.label+'-build.log'))
        if($LASTEXITCODE -ne 0){throw 'P29 rig build failed; retain source and logs'}
        Invoke-VoxtreeExternalPhase {
            & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot ('bundles/'+$case.label+'/'+$case.label+'.dll')) --validate *> (Join-Path $TaskRoot ($case.label+'-validation.log'))
            if($LASTEXITCODE -ne 0){throw 'P29 complete scenario oracle failed'}
        }
    }
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Review-PaletteReturn.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P29 compiled source review failed'}
    }
    foreach($case in @(@{label='p29parent';source='byte-palette-source'},@{label='p29sem';source='palette-return-source'})){
        & (Join-Path $PSScriptRoot 'Test-PackedLookup.ps1') -TaskRoot $TaskRoot -Label $case.label -SourceDirectoryName $case.source -FixtureName PaletteLeafTests.cs.txt -ExtraFixtureName PaletteReturnCases.cs.txt -PaletteLeaf
    }
    Invoke-VoxtreeExternalPhase {
        $previousHw=$env:DOTNET_EnableHWIntrinsic
        try {
            $env:DOTNET_EnableHWIntrinsic='0';Push-Location $TaskRoot
            try {
                & dotnet test (Join-Path $TaskRoot 'packed-lookup-validation-p29sem/tests/Tests.csproj') -f net10.0 -c Release --no-build --no-restore --artifacts-path (Join-Path $TaskRoot 'tests-packed-lookup-p29sem') --logger trx --results-directory (Join-Path $TaskRoot 'packed-lookup-p29sem-off-results') -v minimal *> (Join-Path $TaskRoot 'p29sem-intrinsics-off.log')
                if($LASTEXITCODE -ne 0){throw 'P29 intrinsics-off suite failed'}
            } finally {Pop-Location}
        } finally {$env:DOTNET_EnableHWIntrinsic=$previousHw}
    }
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p29census -PaletteLeaf -ExactParentBundle p27setup
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Audit-PackedCorpus.py') $TaskRoot --bundle-label p29census
        if($LASTEXITCODE -ne 0){throw 'P29 complete corpus audit failed'}
    }
    foreach($access in @('owned','span')){foreach($op in @('get','lod')){
        & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot 'bundles/p29point') -Label "p29-UInt32-$access-$op-code" -Scenario "point-ForceUInt32-L5-mixed-u16-air-$access-$op" -Methods '*Get* *ReadStateOrInvalid* *AfterBatch* *BeforeBatch*'
    }}
} finally {Exit-VoxtreePerformanceHost $lease}
