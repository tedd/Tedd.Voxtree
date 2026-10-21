param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Measure.ps1','Inspect-Code.ps1','OWNED-LOD-DIRECT-PROTOCOL.md','Scenarios-byte-palette.cs.txt')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P28 screen dependency changed'}}
    if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p28point-screen')){throw 'P28 screen exists; inspect original operation state'}
    Invoke-VoxtreeExternalPhase {
        $setup=Get-Content -LiteralPath (Join-Path $TaskRoot 'p28-setup-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
        if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p28-frozen-protocol.txt')).Hash -ne $setup['OWNED-LOD-DIRECT-PROTOCOL.md']){throw 'P28 frozen protocol changed'}
        foreach($file in (Get-Content -LiteralPath (Join-Path $TaskRoot 'p28point-hashes.json') -Raw|ConvertFrom-Json)){
            if((Get-FileHash -LiteralPath $file.Path).Hash -ne $file.Hash){throw 'P28 prepared bundle changed'}
        }
        foreach($label in @('p28parent','p28sem')){
            $results=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot "packed-lookup-$label-results") -Filter '*.trx')
            if($results.Count -ne 3){throw 'Missing P28 original framework tests'}
            foreach($result in $results){[xml]$trx=Get-Content -LiteralPath $result.FullName -Raw;if($trx.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$trx.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P28 framework tests did not pass'}}
        }
        $off=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p28sem-off-results') -Filter '*.trx')
        if($off.Count -ne 1){throw 'Missing P28 hardware-off tests'}
        [xml]$trx=Get-Content -LiteralPath $off[0].FullName -Raw
        if($trx.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$trx.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P28 hardware-off tests did not pass'}
        $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p28-screen-dependencies.json')
    }
    foreach($width in @('UInt16','UInt32')){
        & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot 'bundles/p28point') -Label "p28-$width-owned-code" -Scenario "point-Force$width-L5-mixed-u16-air-owned-lod" -Methods '*Get* *AsSpan* *TryReadState* *AfterBatch*'
    }
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p28point/p28point.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p28point-screen') -Filter 'point-*' -Label p28point -Budget bounded-lifecycle -Seed '20261031'
} finally {Exit-VoxtreePerformanceHost $lease}
