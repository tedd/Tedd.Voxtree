param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Preserve.py','Verify-Evidence.py')
$hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try {
    foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued closure dependency changed'}}
    $frozen=Get-Content -LiteralPath (Join-Path $TaskRoot 'p32-screen-frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
    foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'P32 frozen source changed'}}
    $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p32point-audit.json') -Raw|ConvertFrom-Json -Depth 80
    if($audit.stagePassed -or -not $audit.all_correct_quiescent_joined -or $audit.complete_cases -ne 48 -or $audit.run_records -ne 384){throw 'P32 original rejection stage is not a complete rejected family'}
    foreach($label in @('p32point-full','p32bulk-full')){if(Test-Path -LiteralPath (Join-Path $TaskRoot "$label-screen")){throw 'Unexpected conditional family: inspect before closing'}}
    $path=Join-Path $TaskRoot 'p32-disposition.json';if(Test-Path -LiteralPath $path){throw 'P32 disposition exists'}
    $steady=@($audit.cases|Where-Object{$_.scenario -notmatch '-(create|lifecycle)$'})
    $zero=@($steady|Where-Object{-not $_.every_observed_thread_allocation_zero.candidate}).Count -eq 0
    @{state='not_supported';primaryPassed=$audit.primaryPassed;primary=@($audit.cases|Where-Object primary);adverseOtherDominant=$audit.adverseOtherDominant;adverseOtherGuards=$audit.adverseOtherGuards;otherGuardCount=40;observedSteadyReadAllocationsAllZero=$zero;steadyReadCases=$steady.Count;conditionalFullFamilies='Not selected by the prospectively specified complete rejection stage';promotionEligible=$false;scope='P32 complete four-pair rejection stage versus unpromoted P31. No extra samples, full time family, release comparison, normal confirmation or source adoption. No unsafe load burden adopted without measured benefit.'}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $path
    $script:root=Join-Path $TaskRoot 'p32-hypothesis'
    $created=(Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
    $artifact=Import-File $path application/json
    $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state='not_supported';evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
    $result=Invoke-Lab lab.experiment $request
    $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
    foreach($n in @('p32point-audit.json','p32-disposition.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase19','--content-addressed')
    foreach($prefix in @('p32point-screen','p32point-audit.json','p32-disposition.json','p32-hypothesis')){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'P32 stage preservation failed; retain partial outputs'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase19 --require p32point-screen/catalog-export.json --require p32point-audit.json --require p32-disposition.json --require p32-hypothesis/disposition-revision-response.json
    if($LASTEXITCODE -ne 0){throw 'P32 stage archive failed verification'}
    @{state='not_supported';primaryPassed=$audit.primaryPassed;adverseOtherDominant=$audit.adverseOtherDominant;adverseOtherGuards=$audit.adverseOtherGuards;observedSteadyReadAllocationsAllZero=$zero}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $lease}
