param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Audit-PalettePointScreen.py','Preserve.py','Verify-Evidence.py')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try {
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P29 closing dependency changed'}}
    $shutdown=Get-Content -LiteralPath (Join-Path $TaskRoot 'p29point-screen/p29point-shutdown.json') -Raw|ConvertFrom-Json
    if(-not $shutdown.targetExited -or -not $shutdown.controllerExited -or $shutdown.targetExitCode -ne 0){throw 'P29 original family is not joined'}
    $setup=Get-Content -LiteralPath (Join-Path $TaskRoot 'p29-setup-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
    if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p29-frozen-protocol.txt')).Hash -ne $setup['PALETTE-RETURN-PROTOCOL.md']){throw 'P29 frozen protocol changed'}
    & python (Join-Path $PSScriptRoot 'Audit-PalettePointScreen.py') $TaskRoot --label p29point
    if($LASTEXITCODE -ne 0){throw 'P29 complete family audit failed'}
    $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p29point-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $state=if($audit.all_primary_point_estimates_passed){'inconclusive'}else{'not_supported'}
    $disposition=Join-Path $TaskRoot 'p29-disposition.json';if(Test-Path -LiteralPath $disposition){throw 'P29 disposition exists'}
    @{state=$state;primaryPassed=$audit.all_primary_point_estimates_passed;primary=@($audit.cases|Where-Object primary);adverseOtherGuards=$audit.adverse_other_time_guards;guardCount=44;promotionEligible=$false;scope='Complete exploratory family versus P27; no normal confirmation, direct-release10x inference, ratio multiplication or source adoption'}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $disposition
    $script:root=Join-Path $TaskRoot 'p29-hypothesis'
    $created=(Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
    $artifact=Import-File $disposition application/json
    $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$state;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
    $result=Invoke-Lab lab.experiment $request
    $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
    foreach($name in @('p29-source-origin.json','p29-source-review.json','p29-source-review.diff','p29-native-gate.json','p29census-audit.json','p29point-audit.json','p29-disposition.json','native-summary-phase14-read.json','native-summary-p29-read-precheck.json')){
        $destination=Join-Path $PSScriptRoot $name
        if(Test-Path -LiteralPath $destination){
            if((Get-FileHash -LiteralPath $destination).Hash -ne (Get-FileHash -LiteralPath (Join-Path $TaskRoot $name)).Hash){throw 'Permanent P29 preparation record differs'}
        }else{Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination $destination}
    }
    $prefixes=@('p29','native-summary-phase14-read.json','native-summary-p29-read-precheck.json','bundles/p29','palette-return-source','packed-corpus-p29census-source','forcecraft-census-packed-p29census','packed-lookup-validation-p29','packed-lookup-p29','packed-lookup-test-options-p29','packed-lookup-tests-p29','p27contracts','packed-lookup-validation-p27contracts','packed-lookup-p27contracts','packed-lookup-test-options-p27contracts','packed-lookup-tests-p27contracts')
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase14','--content-addressed')
    foreach($prefix in $prefixes){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'P29 preservation failed; retain partial output'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase14 --require 'p29point-screen/catalog-export.json' --require 'p29-hypothesis/disposition-revision-response.json' --require 'p29point-audit.json' --require 'p29-native-gate.json' --require 'palette-return-source/PaletteLeafEncoding.cs' --require 'p29-source-review.diff' --require 'bundles/p29point/p29point.dll' --require 'forcecraft-census-packed-p29census/packed-corpus.json' --require 'p29census-packed-corpus-identity.json' --require 'p29-precheck-UInt32-owned-get.asm' --require 'p27contracts-OwnedLodSnapshotTests.cs.txt' --require 'packed-lookup-validation-p29sem/tests/ExtraReadTests.cs'
    if($LASTEXITCODE -ne 0){throw 'P29 evidence verification failed'}
    @{state=$state;primaryPassed=$audit.all_primary_point_estimates_passed;adverseOtherGuards=$audit.adverse_other_time_guards}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $lease}
