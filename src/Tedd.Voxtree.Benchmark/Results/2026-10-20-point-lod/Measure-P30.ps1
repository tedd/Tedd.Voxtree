param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Measure.ps1','BUILD-PLAN-REUSE-PROTOCOL.md','Scenarios-bulk.cs.txt')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P30 screen dependency changed'}}
    if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p30bulk-screen')){throw 'P30 screen exists; inspect original accepted state'}
    Invoke-VoxtreeExternalPhase {
        $setup=Get-Content -LiteralPath (Join-Path $TaskRoot 'p30-setup-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
        if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p30-frozen-protocol.txt')).Hash -ne $setup['BUILD-PLAN-REUSE-PROTOCOL.md']){throw 'P30 frozen protocol changed'}
        $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p30-native-audit.json') -Raw|ConvertFrom-Json
        if(-not $gate.native_source_gate_passed -or (Get-FileHash -LiteralPath (Join-Path $TaskRoot $gate.file)).Hash.ToLowerInvariant() -ne $gate.sha256){throw 'P30 native/source gate missing or changed'}
        foreach($file in (Get-Content -LiteralPath (Join-Path $TaskRoot 'p30bulk-hashes.json') -Raw|ConvertFrom-Json)){
            if((Get-FileHash -LiteralPath $file.Path).Hash -ne $file.Hash){throw 'P30 prepared bundle changed'}
        }
        $results=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p30sem-results') -Filter '*.trx')
        if($results.Count -ne 3){throw 'Missing P30 original framework tests'}
        foreach($result in $results){[xml]$trx=Get-Content -LiteralPath $result.FullName -Raw;if($trx.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$trx.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P30 framework tests did not pass'}}
        $off=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p30sem-off-results') -Filter '*.trx')
        if($off.Count -ne 1){throw 'Missing P30 hardware-off tests'}
        [xml]$trx=Get-Content -LiteralPath $off[0].FullName -Raw
        if($trx.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$trx.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P30 hardware-off tests did not pass'}
        $census=Get-Content -LiteralPath (Join-Path $TaskRoot 'p30census-audit.json') -Raw|ConvertFrom-Json
        if($census.chunks -ne 1286 -or $census.cells -ne 42139648 -or -not $census.footprint_eligibility_equal_to_j1_projection){throw 'P30 corpus incomplete'}
        $parent=Get-Content -LiteralPath (Join-Path $TaskRoot 'p30census-packed-corpus-identity.json') -Raw|ConvertFrom-Json
        if($parent.exactParentBundle -ne 'p27setup' -or -not $parent.joined -or $parent.exitCode -ne 0){throw 'P30 exact-parent census is not joined'}
        $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p30-screen-dependencies.json')
    }
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p30bulk/p30bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p30bulk-screen') -Filter 'bulk-*' -Label p30bulk -Budget bounded-consumer -Seed '20261102'
} finally {Exit-VoxtreePerformanceHost $lease}
