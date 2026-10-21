param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Audit-PalettePointScreen.py','Audit-BulkConsumers.py','Preserve.py','Verify-Evidence.py')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P31 closing dependency changed'}}
    foreach($label in @('p31point','p31bulk')){
        $shutdown=Get-Content -LiteralPath (Join-Path $TaskRoot "$label-screen/$label-shutdown.json") -Raw|ConvertFrom-Json
        if(-not $shutdown.targetExited -or -not $shutdown.controllerExited -or $shutdown.targetExitCode -ne 0){throw 'P31 original family is not joined'}
    }
    $frozen=Get-Content -LiteralPath (Join-Path $TaskRoot 'p31-screen-frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
    foreach($name in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $frozen[$name]){throw 'P31 frozen timing source changed'}}
    & python (Join-Path $PSScriptRoot 'Audit-PalettePointScreen.py') $TaskRoot --label p31point
    if($LASTEXITCODE -ne 0){throw 'P31 complete point audit failed'}
    & python (Join-Path $PSScriptRoot 'Audit-BulkConsumers.py') $TaskRoot --label p31bulk
    if($LASTEXITCODE -ne 0){throw 'P31 complete bulk audit failed'}
    $point=Get-Content -LiteralPath (Join-Path $TaskRoot 'p31point-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $bulk=Get-Content -LiteralPath (Join-Path $TaskRoot 'p31bulk-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $adverse=@($bulk.cases|Where-Object{$_.descriptive_speedup -lt (1/1.05)})
    $reads=@($point.cases|Where-Object{$_.scenario -notmatch '-(create|lifecycle)$'})
    $zero=@($reads|Where-Object{-not $_.every_observed_thread_allocation_zero.candidate}).Count -eq 0
    $state=if($point.all_primary_point_estimates_passed){'inconclusive'}else{'not_supported'}
    $path=Join-Path $TaskRoot 'p31-disposition.json';if(Test-Path -LiteralPath $path){throw 'P31 disposition exists'}
    @{state=$state;primaryPassed=$point.all_primary_point_estimates_passed;primary=@($point.cases|Where-Object primary);adversePointGuardCount=$point.adverse_other_time_guards;pointGuardCount=40;adverseBulkGuards=$adverse;bulkGuardCount=96;observedSteadyReadAllocationsAllZero=$zero;steadyReadCases=$reads.Count;releaseAllocationGuard='Not independently qualified by these P30-controlled timings; no adoption follows';promotionEligible=$false;scope='Complete original exploratory point48/bulk96 families against P30; no direct-release10x, old-ratio multiplication, normal confirmation or public-API completion claim'}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $path
    $script:root=Join-Path $TaskRoot 'p31-hypothesis'
    $created=(Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
    $artifact=Import-File $path application/json
    $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$state;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
    $result=Invoke-Lab lab.experiment $request
    $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
    foreach($name in @('p31point-audit.json','p31bulk-audit.json','p31-disposition.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination (Join-Path $PSScriptRoot $name)}
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase17','--content-addressed')
    foreach($prefix in @('p31point','p31bulk-screen','p31bulk-audit.json','p31-disposition.json','p31-hypothesis')){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'P31 timing preservation failed; retain partial outputs'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase17 --require 'p31point-screen/catalog-export.json' --require 'p31bulk-screen/catalog-export.json' --require 'p31-hypothesis/disposition-revision-response.json' --require 'p31point-audit.json' --require 'p31bulk-audit.json' --require 'p31-disposition.json'
    if($LASTEXITCODE -ne 0){throw 'P31 timing archive failed verification'}
    @{state=$state;primaryPassed=$point.all_primary_point_estimates_passed;adversePointGuards=$point.adverse_other_time_guards;adverseBulkGuards=$adverse.Count;observedSteadyReadAllocationsAllZero=$zero}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $lease}
