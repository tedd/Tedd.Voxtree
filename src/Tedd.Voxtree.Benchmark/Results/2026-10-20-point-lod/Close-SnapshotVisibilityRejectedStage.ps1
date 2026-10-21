param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try {
    $frozen=Get-Content -LiteralPath (Join-Path $TaskRoot 'p33-screen-frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
    foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'P33 frozen measurement source changed'}}
    $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p33point-audit.json') -Raw|ConvertFrom-Json -Depth 80
    if($audit.stagePassed -or -not $audit.all_correct_quiescent_joined -or $audit.complete_cases -ne 48 -or $audit.run_records -ne 384){throw 'P33 Get-first stage is not a complete rejected family'}
    foreach($label in @('p33lod','p33point-full','p33lod-full','p33bulk-full')){if(Test-Path -LiteralPath (Join-Path $TaskRoot "$label-screen")){throw 'Unexpected later family; inspect before closing'}}
    $path=Join-Path $TaskRoot 'p33-disposition.json';if(Test-Path -LiteralPath $path){throw 'P33 disposition exists'}
    $steady=@($audit.cases|Where-Object{$_.scenario -notmatch '-(create|lifecycle)$'})
    $zero=@($steady|Where-Object{-not $_.every_observed_thread_allocation_zero.candidate}).Count -eq 0
    @{state='not_supported';nativeBothHistoriesPassed=$true;primaryPassed=$audit.primaryPassed;primary=@($audit.cases|Where-Object primary);adverseOtherDominant=@($audit.cases|Where-Object{$_.dominantOther -and -not $_.pointEstimatePassed});adverseOtherGuards=@($audit.cases|Where-Object{-not $_.primary -and -not $_.dominantOther -and -not $_.pointEstimatePassed});otherGuardCount=40;observedSteadyReadAllocationsAllZero=$zero;steadyReadCases=$steady.Count;conditionalLaterFamilies='Not selected by the prospectively specified complete Get-first rejection stage';promotionEligible=$false;scope='P33 snapshot-factory flags remove the mapped boundary and improve both owned LOD primary estimates, but fail mandatory Get-first guards. No LOD-first timing, full time family, release comparison, normal confirmation, ratio multiplication or source adoption.'}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $path
    $script:root=Join-Path $TaskRoot 'p33-hypothesis'
    $created=(Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
    $artifact=Import-File $path application/json
    $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state='not_supported';evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
    $result=Invoke-Lab lab.experiment $request
    $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
    foreach($n in @('p33point-audit.json','p33-disposition.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase22','--content-addressed')
    foreach($prefix in @('p33point-screen','p33point-audit.json','p33-disposition.json','p33-hypothesis')){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'P33 rejected-stage preservation failed; retain partial outputs'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase22 --require p33point-screen/catalog-export.json --require p33point-audit.json --require p33-disposition.json --require p33-hypothesis/disposition-revision-response.json
    if($LASTEXITCODE -ne 0){throw 'P33 rejected-stage archive failed verification'}
    @{state='not_supported';primaryPassed=$audit.primaryPassed;adverseOtherDominant=$audit.adverseOtherDominant;adverseOtherGuards=$audit.adverseOtherGuards;observedSteadyReadAllocationsAllZero=$zero}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $lease}
