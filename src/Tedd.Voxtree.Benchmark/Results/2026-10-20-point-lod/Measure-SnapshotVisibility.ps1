param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Measure.ps1','SNAPSHOT-VISIBILITY-PROTOCOL.md','Scenarios-snapshot-visibility.cs.txt','Scenarios-snapshot-visibility-bulk.cs.txt','Audit-SnapshotVisibilityStage.py')
$hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued P33 measurement dependency changed'}}
    foreach($label in @('p33point','p33lod','p33point-full','p33lod-full','p33bulk-full')){if(Test-Path -LiteralPath (Join-Path $TaskRoot "$label-screen")){throw 'P33 family exists; inspect accepted state without restart'}}
    Invoke-VoxtreeExternalPhase {
        $frozen=Get-Content -LiteralPath (Join-Path $TaskRoot 'p33-screen-frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
        foreach($n in $names){if($frozen[$n] -ne $hashes[$n]){throw 'P33 frozen timing source changed'}}
        $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p33-prerequisite-audit.json') -Raw|ConvertFrom-Json
        if(-not $gate.prerequisitesPassed -or -not $gate.nativeBothHistoriesPassed -or $gate.cells -ne 42139648){throw 'P33 prerequisite gate incomplete'}
        if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p33-native-audit.json')).Hash.ToLowerInvariant() -ne $gate.nativeAuditSha256){throw 'P33 native gate changed'}
        foreach($label in @('p33point','p33bulk','p33census')){foreach($f in (Get-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json") -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'P33 prepared bundle changed'}}}
        if((Get-FileHash -LiteralPath (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll')).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated isolated controller changed'}
    }
    function Audit-Stage([string]$Stage){
        Invoke-VoxtreeExternalPhase { & python (Join-Path $PSScriptRoot 'Audit-SnapshotVisibilityStage.py') $TaskRoot --stage $Stage; if($LASTEXITCODE -ne 0){throw 'P33 stage audit failed'} }
    }
    $entry=Join-Path $TaskRoot 'bundles/p33point/p33point.dll';$hostEntry=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig $entry -LabHost $hostEntry -Workspace (Join-Path $TaskRoot 'p33point-screen') -Filter 'point-*' -Label p33point -Budget bounded-lifecycle -Blocks 4 -WarmupBatches 2 -Seed '20261108'
    Audit-Stage get-first
    if(-not (Get-Content -LiteralPath (Join-Path $TaskRoot 'p33point-audit.json') -Raw|ConvertFrom-Json).stagePassed){Write-Output 'P33 Get-first rejection stage failed; later families not selected.';return}
    $selected=@(foreach($w in @('UInt32','UInt16')){foreach($access in @('owned','span')){"point-Force$w-L5-mixed-u16-air-$access-lod"}})
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig $entry -LabHost $hostEntry -Workspace (Join-Path $TaskRoot 'p33lod-screen') -SelectedScenarios $selected -Label p33lod -Budget bounded-lifecycle -Blocks 4 -WarmupBatches 2 -Seed '20261109'
    Audit-Stage lod-first
    if(-not (Get-Content -LiteralPath (Join-Path $TaskRoot 'p33lod-audit.json') -Raw|ConvertFrom-Json).stagePassed){Write-Output 'P33 LOD-first rejection stage failed; full families not selected.';return}
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig $entry -LabHost $hostEntry -Workspace (Join-Path $TaskRoot 'p33point-full-screen') -Filter 'point-*' -Label p33point-full -Budget bounded-lifecycle -Seed '20261110'
    Audit-Stage full-get-first
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig $entry -LabHost $hostEntry -Workspace (Join-Path $TaskRoot 'p33lod-full-screen') -SelectedScenarios $selected -Label p33lod-full -Budget bounded-lifecycle -Seed '20261111'
    Audit-Stage full-lod-first
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p33bulk/p33bulk.dll') -LabHost $hostEntry -Workspace (Join-Path $TaskRoot 'p33bulk-full-screen') -Filter 'bulk-*' -Label p33bulk-full -Budget bounded-consumer-v18 -Seed '20261112'
} finally {Exit-VoxtreePerformanceHost $lease}
