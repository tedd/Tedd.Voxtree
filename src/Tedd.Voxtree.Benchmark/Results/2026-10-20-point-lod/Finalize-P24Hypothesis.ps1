param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try {
    $auditPath=Join-Path $TaskRoot 'p24-confirmation-audit.json'
    $audit=Get-Content -LiteralPath $auditPath -Raw|ConvertFrom-Json -Depth 80
    if($audit.completed_cases -ne 8 -or $audit.distinct_process_start_identities -ne 192 -or -not $audit.all_eight_tenfold_lower_bounds_reached){throw 'P24 full time primary is not established'}
    if(@($audit.cases|Where-Object{'degenerate_variance' -notin $_.allocation.reason_codes}).Count -ne 0){throw 'P24 allocation disposition differs from the observed model outcomes'}
    $path=Join-Path $TaskRoot 'p24-confirmation-disposition.json'
    if(Test-Path -LiteralPath $path){throw 'P24 disposition exists; inspect original revision'}
    @{state='inconclusive';timePrimary='supported: all eight adjusted speedup lower bounds >=10';promotionEligible=$false;
      unresolved='All eight mandatory allocation models have degenerate variance; broader constructor/bulk/fallback/memory/API guards remain unresolved.';
      encodedUInt32Growth=(68784288.0/13693396.0);encodedPlusDistinctLookupUInt32Growth=(71567508.0/48861892.0);
      confirmationAuditSha256=(Get-FileHash -LiteralPath $auditPath).Hash;
      archive='phase10 preserves pre-disposition catalogs and all observations; this new metadata revision is retained separately, without replacing the archive';
      cases=$audit.cases}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $path
    foreach($name in @('p24-hypothesis','p24-confirmation')){
        $root=Join-Path $TaskRoot $name
        $hyp=if($name -eq 'p24-hypothesis'){(Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json).data}else{Get-Content -LiteralPath (Join-Path $root 'hypothesis.json') -Raw|ConvertFrom-Json}
        $record=Invoke-Lab lab.inspect @{action='record';id=$hyp.id};$prior=$record.json|ConvertFrom-Json
        $artifact=Import-File $path application/json
        $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state='inconclusive';evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
        $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'postconfirmation-revision-request.json')
        $result=Invoke-Lab lab.experiment $request
        $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'postconfirmation-revision-response.json')
    }
    Copy-Item -LiteralPath $path -Destination (Join-Path $PSScriptRoot 'p24-confirmation-disposition.json')
    'P24 time primary supported; overall adoption hypothesis inconclusive. No new measurements.'
} finally {Exit-VoxtreePerformanceHost $lease}
