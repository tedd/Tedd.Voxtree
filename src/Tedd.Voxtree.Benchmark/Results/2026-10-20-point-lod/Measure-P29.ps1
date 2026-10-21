param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Measure.ps1','PALETTE-RETURN-PROTOCOL.md','Scenarios-byte-palette.cs.txt')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P29 screen dependency changed'}}
    if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p29point-screen')){throw 'P29 screen exists; inspect original accepted state'}
    Invoke-VoxtreeExternalPhase {
        $setup=Get-Content -LiteralPath (Join-Path $TaskRoot 'p29-setup-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
        if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p29-frozen-protocol.txt')).Hash -ne $setup['PALETTE-RETURN-PROTOCOL.md']){throw 'P29 frozen protocol changed'}
        $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p29-native-gate.json') -Raw|ConvertFrom-Json
        if(-not $gate.gate_passed -or (Get-FileHash -LiteralPath (Join-Path $TaskRoot $gate.file)).Hash.ToLowerInvariant() -ne $gate.sha256){throw 'P29 native gate is missing or changed'}
        foreach($file in (Get-Content -LiteralPath (Join-Path $TaskRoot 'p29point-hashes.json') -Raw|ConvertFrom-Json)){
            if((Get-FileHash -LiteralPath $file.Path).Hash -ne $file.Hash){throw 'P29 prepared bundle changed'}
        }
        foreach($label in @('p29parent','p29sem')){
            $results=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot "packed-lookup-$label-results") -Filter '*.trx')
            if($results.Count -ne 3){throw 'Missing P29 original framework tests'}
            foreach($result in $results){[xml]$trx=Get-Content -LiteralPath $result.FullName -Raw;if($trx.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$trx.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P29 framework tests did not pass'}}
        }
        $off=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p29sem-off-results') -Filter '*.trx')
        if($off.Count -ne 1){throw 'Missing P29 hardware-off tests'}
        [xml]$trx=Get-Content -LiteralPath $off[0].FullName -Raw
        if($trx.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$trx.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P29 hardware-off tests did not pass'}
        $census=Get-Content -LiteralPath (Join-Path $TaskRoot 'p29census-audit.json') -Raw|ConvertFrom-Json
        if($census.chunks -ne 1286 -or $census.cells -ne 42139648 -or -not $census.footprint_eligibility_equal_to_j1_projection){throw 'P29 corpus incomplete'}
        $parent=Get-Content -LiteralPath (Join-Path $TaskRoot 'p29census-packed-corpus-identity.json') -Raw|ConvertFrom-Json
        if($parent.exactParentBundle -ne 'p27setup' -or -not $parent.joined -or $parent.exitCode -ne 0){throw 'P29 exact-parent census is not joined'}
        $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p29-screen-dependencies.json')
    }
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p29point/p29point.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p29point-screen') -Filter 'point-*' -Label p29point -Budget bounded-lifecycle -Seed '20261101'
} finally {Exit-VoxtreePerformanceHost $lease}
