param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Audit-PalettePointScreen.py','Audit-BulkConsumers.py','Review-BytePaletteSource.py','Summarize-Native.py','Preserve.py','Verify-Evidence.py')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P27 closing dependency changed'}}
    foreach($label in @('p27point','p27bulk')){
        $shutdown=Get-Content -LiteralPath (Join-Path $TaskRoot "$label-screen/$label-shutdown.json") -Raw|ConvertFrom-Json
        if(-not $shutdown.targetExited -or -not $shutdown.controllerExited -or $shutdown.targetExitCode -ne 0){throw 'P27 original family not joined'}
    }
    $dependencies=Get-Content -LiteralPath (Join-Path $TaskRoot 'p27-screen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
    if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p27-screen-frozen-protocol.txt')).Hash -ne $dependencies['P27-SCREEN-PROTOCOL.md']){throw 'P27 frozen protocol changed'}
    & python (Join-Path $PSScriptRoot 'Audit-PalettePointScreen.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'P27 complete point audit failed'}
    & python (Join-Path $PSScriptRoot 'Audit-BulkConsumers.py') $TaskRoot --label p27bulk
    if($LASTEXITCODE -ne 0){throw 'P27 complete consumer audit failed'}
    & python (Join-Path $PSScriptRoot 'Review-BytePaletteSource.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'P27 complete source review failed'}
    & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase13 --files p27-UInt16-owned-code.asm p27-UInt16-span-code.asm p27-UInt32-owned-code.asm p27-UInt32-span-code.asm p27builder-code-code.asm --include-fullopts
    if($LASTEXITCODE -ne 0){throw 'P27 native indexing failed'}
    $point=Get-Content -LiteralPath (Join-Path $TaskRoot 'p27point-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $bulk=Get-Content -LiteralPath (Join-Path $TaskRoot 'p27bulk-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $state=if($point.all_eight_tenfold_point_estimates){'inconclusive'}else{'not_supported'}
    $adverse=@($bulk.cases|Where-Object{$_.descriptive_speedup -lt (1/1.05)})
    $disposition=Join-Path $TaskRoot 'p27-disposition.json';if(Test-Path -LiteralPath $disposition){throw 'P27 disposition exists'}
    @{state=$state;allEightPointPrimariesPassed=$point.all_eight_tenfold_point_estimates;primary=@($point.cases|Where-Object primary);adverseOtherPointGuards=$point.adverse_other_time_guards;adverseBulkGuards=$adverse;bulkGuardCount=88;promotionEligible=$false;scope='Two complete exploratory families, separate analyses; no fresh confirmation, prior-ratio multiplication or source adoption'}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $disposition
    $script:root=Join-Path $TaskRoot 'p27-hypothesis'
    $created=(Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
    $artifact=Import-File $disposition application/json
    $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$state;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
    $result=Invoke-Lab lab.experiment $request
    $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
    foreach($name in @('p27-source-origin.json','p27-source-review.json','p27-source-review.diff','p27setup-audit.json','p27point-audit.json','p27bulk-audit.json','native-summary-phase13.json','p27-disposition.json')){
        $destination=Join-Path $PSScriptRoot $name;if(Test-Path -LiteralPath $destination){throw 'Permanent P27 record exists'}
        Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination $destination
    }
    $prefixes=@('p27','native-summary-phase13.json','bundles/p27','byte-palette-source','packed-corpus-p27setup-source','forcecraft-census-packed-p27setup','packed-lookup-validation-p27sem','packed-lookup-p27sem','packed-lookup-test-options-p27sem','packed-lookup-tests-p27sem','count-body-p27')
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase13','--content-addressed')
    foreach($prefix in $prefixes){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'P27 preservation failed; retain partial output'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase13 --require 'p27point-screen/catalog-export.json' --require 'p27bulk-screen/catalog-export.json' --require 'p27-hypothesis/disposition-revision-response.json' --require 'p27point-audit.json' --require 'p27bulk-audit.json' --require 'p27setup-audit.json' --require 'byte-palette-source/PaletteLeafEncoding.cs' --require 'bundles/p27setup/p27setup.dll' --require 'bundles/p27bulk/p27bulk.dll' --require 'forcecraft-census-packed-p27setup/packed-corpus.json' --require 'p27-source-review.diff'
    if($LASTEXITCODE -ne 0){throw 'P27 evidence verification failed'}
    @{state=$state;adverseOtherPointGuards=$point.adverse_other_time_guards;adverseBulkGuards=$adverse.Count}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $lease}
