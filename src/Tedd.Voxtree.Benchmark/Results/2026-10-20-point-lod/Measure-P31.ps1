param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Measure.ps1','COMPACT-LEAF13-FORMAT-PROTOCOL.md','Scenarios-compact-leaf.cs.txt','Scenarios-compact-bulk.cs.txt')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P31 dependency changed'}}
    foreach($label in @('p31point','p31bulk')){if(Test-Path -LiteralPath (Join-Path $TaskRoot "$label-screen")){throw 'P31 family exists: inspect original accepted operation; never restart'}}
    Invoke-VoxtreeExternalPhase {
        $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p31-native-audit.json') -Raw|ConvertFrom-Json
        if(-not $gate.native_source_gate_passed -or (Get-FileHash -LiteralPath (Join-Path $TaskRoot 'native-summary-phase16-compact.json')).Hash.ToLowerInvariant() -ne $gate.summarySha256){throw 'P31 native gate changed'}
        foreach($listing in $gate.selected){if((Get-FileHash -LiteralPath (Join-Path $TaskRoot $listing.file)).Hash.ToLowerInvariant() -ne $listing.sha256){throw 'Native listing changed'}}
        $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p31-prerequisite-audit.json') -Raw|ConvertFrom-Json
        if($audit.state -ne 'supported_prerequisites_only' -or $audit.cells -ne 42139648){throw 'Missing compact prerequisite audit'}
        foreach($label in @('p31setup2','p31bulk','p31census')){
            foreach($file in (Get-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json") -Raw|ConvertFrom-Json)){
                if((Get-FileHash -LiteralPath $file.Path).Hash -ne $file.Hash){throw 'Prepared P31 bundle changed'}
            }
        }
        foreach($pair in @(@('p31setup2-validation.log',48),@('p31bulk-validation.log',96))){
            $lines=@(Get-Content -LiteralPath (Join-Path $TaskRoot $pair[0])|Where-Object{$_ -match ' valid$'})
            if($lines.Count -ne $pair[1]){throw 'Missing full paired semantic family'}
        }
        $results=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p31compact2-results') -Filter '*.trx')
        $off=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p31compact2-hwoff-results') -Filter '*.trx')
        if($results.Count -ne 3 -or $off.Count -ne 1){throw 'Missing framework or HW-off test records'}
        foreach($result in @($results)+@($off)){
            [xml]$trx=Get-Content -LiteralPath $result.FullName -Raw
            if($trx.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$trx.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P31 tests failed'}
        }
        $frozen=Get-Content -LiteralPath (Join-Path $TaskRoot 'p31-screen-frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
        foreach($name in $names){if($frozen[$name] -ne $hashes[$name]){throw 'Frozen P31 timing dependency changed'}}
        if((Get-FileHash -LiteralPath (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll')).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated isolated controller changed'}
    }
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p31setup2/p31setup2.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p31point-screen') -Filter 'point-*' -Label p31point -Budget bounded-lifecycle -Seed '20261103'
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p31bulk/p31bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p31bulk-screen') -Filter 'bulk-*' -Label p31bulk -Budget bounded-consumer-v16 -Seed '20261104'
} finally {Exit-VoxtreePerformanceHost $lease}
