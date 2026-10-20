param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory,
      [Parameter(Mandatory)][ValidateSet('p19','p20','p21')][string]$Label)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -MeasurementOnly
try {
    $catalog=Join-Path $TaskRoot "$Label-hypothesis"
    $destination=Join-Path $catalog 'postcount-disposition.json'
    if(Test-Path -LiteralPath $destination){throw 'Disposition exists; inspect prior revision'}
    $hostPath=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $created=(Get-Content -LiteralPath (Join-Path $catalog 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $text=([ordered]@{action='record';id=$created.id}|ConvertTo-Json -Compress)|& dotnet exec --fx-version 10.0.13 $hostPath call $catalog lab.inspect
    if($LASTEXITCODE -ne 0 -or ($text|ConvertFrom-Json).status -ne 'ok'){throw 'Hypothesis revision discovery failed'}
    $record=($text|ConvertFrom-Json).data;$prior=$record.json|ConvertFrom-Json
    $summary=Get-Content -LiteralPath (Join-Path $TaskRoot "$($Label)bulk-audit.json") -Raw|ConvertFrom-Json -Depth 80
    $state=if($Label -eq 'p19'){'not_supported'}else{'inconclusive'}
    @{label=$Label;state=$state;completeScreen=$summary;promotionEligible=$false;
        explanation=$(if($Label -eq 'p19'){'Scalar specialization removes general Accept in code but fails the frozen four-case primary: UInt16 count/miss estimates are adverse. Do not select this intervention universally.'}else{'Validated vector-count mechanism and complete exploratory effects remain distinct from fresh confirmation. Required fresh caller and regression guards, original confirmation failure localization and format adoption remain unresolved.'});
        sourceReviewSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot "$Label-source-review.json")).Hash} | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $destination
    $import=& dotnet exec --fx-version 10.0.13 $hostPath import $catalog $destination application/json
    if($LASTEXITCODE -ne 0){throw 'Disposition import failed'}
    $import|Set-Content -LiteralPath (Join-Path $catalog 'postcount-artifact.json');$artifact=$import|ConvertFrom-Json
    $request=[ordered]@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$state;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 15|Set-Content -LiteralPath (Join-Path $catalog 'postcount-revision-request.json')
    $result=($request|ConvertTo-Json -Depth 15 -Compress)|& dotnet exec --fx-version 10.0.13 $hostPath call $catalog lab.experiment
    $result|Set-Content -LiteralPath (Join-Path $catalog 'postcount-revision-response.json')
    if($LASTEXITCODE -ne 0 -or ($result|ConvertFrom-Json).status -ne 'ok'){throw 'Hypothesis revision failed'}
    "$Label disposition: $state"
} finally {Exit-VoxtreePerformanceHost $leases}
