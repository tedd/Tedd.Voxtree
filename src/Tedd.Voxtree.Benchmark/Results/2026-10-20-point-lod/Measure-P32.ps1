param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Measure.ps1','COMPACT-BOUNDS-PROTOCOL.md','Scenarios-compact-bounds.cs.txt','Scenarios-compact-bounds-bulk.cs.txt','Audit-CompactBoundsScreen.py')
$hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued P32 dependency changed'}}
    foreach($label in @('p32point','p32point-full','p32bulk-full')){if(Test-Path -LiteralPath (Join-Path $TaskRoot "$label-screen")){throw 'P32 family exists; inspect original accepted operation'}}
    Invoke-VoxtreeExternalPhase {
        $frozen=Get-Content -LiteralPath (Join-Path $TaskRoot 'p32-screen-frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
        foreach($n in $names){if($frozen[$n] -ne $hashes[$n]){throw 'P32 frozen dependency changed'}}
        $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p32-prerequisite-audit.json') -Raw|ConvertFrom-Json
        if(-not $gate.prerequisitesPassed -or $gate.cells -ne 42139648){throw 'P32 prerequisites incomplete'}
        if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p32-native-audit.json')).Hash.ToLowerInvariant() -ne $gate.nativeAuditSha256){throw 'P32 native gate changed'}
        foreach($label in @('p32point','p32bulk','p32census')){foreach($f in (Get-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json") -Raw|ConvertFrom-Json)){
            if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'P32 prepared bundle changed'}
        }}
        if((Get-FileHash -LiteralPath (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll')).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated isolated controller changed'}
    }
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p32point/p32point.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p32point-screen') -Filter 'point-*' -Label p32point -Budget bounded-lifecycle -Blocks 4 -WarmupBatches 2 -Seed '20261105'
    Invoke-VoxtreeExternalPhase {
        & python (Join-Path $PSScriptRoot 'Audit-CompactBoundsScreen.py') $TaskRoot
        if($LASTEXITCODE -ne 0){throw 'P32 full rejection stage audit failed'}
    }
    $stage=Get-Content -LiteralPath (Join-Path $TaskRoot 'p32point-audit.json') -Raw|ConvertFrom-Json
    if(-not $stage.stagePassed){Write-Output 'P32 fixed rejection stage failed; prospective full families are not selected.';return}
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p32point/p32point.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p32point-full-screen') -Filter 'point-*' -Label p32point-full -Budget bounded-lifecycle -Seed '20261106'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p32bulk/p32bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p32bulk-full-screen') -Filter 'bulk-*' -Label p32bulk-full -Budget bounded-consumer-v17 -Seed '20261107'
} finally {Exit-VoxtreePerformanceHost $lease}
