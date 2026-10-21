param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Host-Lock.ps1','Inspect-Code.ps1','Inspect-CountBody.ps1','BuilderProbe.cs.txt','Measure.ps1','P27-SCREEN-PROTOCOL.md','Scenarios-byte-palette.cs.txt','Scenarios-bulk.cs.txt','Audit-PackedCorpus.py')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P27 screen dependency changed'}}
    foreach($name in @('p27point-screen','p27bulk-screen','p27setup-audit.json')){if(Test-Path -LiteralPath (Join-Path $TaskRoot $name)){throw 'P27 screen identity exists; inspect original work'}}
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Audit-PackedCorpus.py') $TaskRoot --bundle-label p27setup
        if($LASTEXITCODE -ne 0){throw 'P27 exact projection audit failed'}
        $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p27-screen-dependencies.json')
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'P27-SCREEN-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'p27-screen-frozen-protocol.txt')
        foreach($name in @('p27setup','p27bulk')){
            $recorded=Get-Content -LiteralPath (Join-Path $TaskRoot "$name-hashes.json") -Raw|ConvertFrom-Json
            foreach($file in $recorded){if((Get-FileHash -LiteralPath $file.Path).Hash -ne $file.Hash){throw 'P27 prepared bundle changed'}}
        }
    }
    foreach($width in @('UInt16','UInt32')){foreach($access in @('owned','span')){
        & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot 'bundles/p27setup') -Label "p27-$width-$access-code" -Scenario "point-Force$width-L5-mixed-u16-air-$access-lod" -Methods '*TryGet* *TryReadState* *ReadEntry* *AfterBatch* *GetUnchecked*'
    }}
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p27builder-code -BundleLabel p27bulk -ProbeSource BuilderProbe.cs.txt -Methods '*Palette* *Collect* *Draw* *TrySelect* *CreateBuildPlan* *BuildOwned*'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p27setup/p27setup.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p27point-screen') -Filter 'point-*' -Label p27point -Budget bounded-lifecycle -Seed '20261029'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p27bulk/p27bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p27bulk-screen') -Filter 'bulk-*' -Label p27bulk -Budget bounded-consumer -Seed '20261030'
} finally {Exit-VoxtreePerformanceHost $lease}
