param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -MeasurementOnly
try {
    $catalog=Join-Path $TaskRoot 'p22-hypothesis'
    $destination=Join-Path $catalog 'postbuilder-disposition.json'
    if(Test-Path -LiteralPath $destination){throw 'Disposition exists; inspect prior revision'}
    $hostPath=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $created=(Get-Content -LiteralPath (Join-Path $catalog 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $text=([ordered]@{action='record';id=$created.id}|ConvertTo-Json -Compress)|& dotnet exec --fx-version 10.0.13 $hostPath call $catalog lab.inspect
    if($LASTEXITCODE -ne 0 -or ($text|ConvertFrom-Json).status -ne 'ok'){throw 'Hypothesis revision discovery failed'}
    $record=($text|ConvertFrom-Json).data;$prior=$record.json|ConvertFrom-Json
    $summary=Get-Content -LiteralPath (Join-Path $TaskRoot 'p22bulk-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $ops=@('construct','build','callerbuild','trybuild','required')
    $primary=@($summary.cases|Where-Object {$_.scenario -like '*-mixed-u16-air-*' -and $_.operation -in $ops})
    $guards=@($summary.cases|Where-Object {($_.operation -in $ops -and $_.scenario -notlike '*-mixed-u16-air-*') -or $_.operation -eq 'buildread'})
    if($primary.Count -ne 10 -or $guards.Count -ne 38){throw 'Frozen primary/guard mismatch'}
    $primaryPassed=@($primary|Where-Object {$_.descriptive_speedup -lt 1.25}).Count -eq 0
    $adverse=@($guards|Where-Object {$_.descriptive_speedup -lt (1/1.05)})
    $state=if($primaryPassed){'inconclusive'}else{'not_supported'}
    @{label='p22';state=$state;completeScreen=$summary;primaryPassedNominally=$primaryPassed;adverseMandatoryGuards=$adverse;promotionEligible=$false;
        explanation='Complete exploratory estimates are retained, including every adverse case. Same-process blocks do not qualify fresh regression guards. Original P18 confirmation failure localization and independent ordinary caller confirmation remain unresolved; no prototype is adopted.';
        sourceReviewSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p22-source-review.json')).Hash;
        fullCorpusAuditSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p22bulk-audit-corpus.json')).Hash} | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $destination
    $import=& dotnet exec --fx-version 10.0.13 $hostPath import $catalog $destination application/json
    if($LASTEXITCODE -ne 0){throw 'Disposition import failed'}
    $import|Set-Content -LiteralPath (Join-Path $catalog 'postbuilder-artifact.json');$artifact=$import|ConvertFrom-Json
    $request=[ordered]@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$state;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 15|Set-Content -LiteralPath (Join-Path $catalog 'postbuilder-revision-request.json')
    $result=($request|ConvertTo-Json -Depth 15 -Compress)|& dotnet exec --fx-version 10.0.13 $hostPath call $catalog lab.experiment
    $result|Set-Content -LiteralPath (Join-Path $catalog 'postbuilder-revision-response.json')
    if($LASTEXITCODE -ne 0 -or ($result|ConvertFrom-Json).status -ne 'ok'){throw 'Hypothesis revision failed'}
    @{state=$state;primaryPassedNominally=$primaryPassed;adverseMandatoryGuards=$adverse.Count}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $leases}
