param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    $labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $summary=Get-Content -LiteralPath (Join-Path $TaskRoot 'screen-summary-phase3.json') -Raw | ConvertFrom-Json -Depth 100
    foreach($label in @('p15','p16','p17','p18')) {
        $catalog=Join-Path $TaskRoot "$label-hypothesis"
        $destination=Join-Path $catalog 'postscreen-disposition.json'
        if(Test-Path -LiteralPath $destination){throw 'Disposition exists; inspect its revision before recovery'}
        $created=(Get-Content -LiteralPath (Join-Path $catalog 'hypothesis-response.json') -Raw | ConvertFrom-Json).data
        $text=(@{action='record';id=$created.id} | ConvertTo-Json -Compress) | & dotnet exec --fx-version 10.0.13 $labHost call $catalog lab.inspect
        if($LASTEXITCODE -ne 0 -or ($text | ConvertFrom-Json).status -ne 'ok'){throw 'Hypothesis revision discovery failed'}
        $record=($text | ConvertFrom-Json).data
        $prior=$record.json | ConvertFrom-Json
        $state=if($label -eq 'p16'){'not_supported'}else{'inconclusive'}
        @{label=$label;controlEvidence=($summary.families | Where-Object label -EQ $label);state=$state;
            explanation=$(if($label -eq 'p16'){'Public getter hints did not establish material primary LOD benefit; caller code/stack grew and codec calls remained. Individual intervention is not selected.'}else{'Generated-code and exploratory timing evidence is retained, including adverse cases. Fresh normal-build benefit/guards, build/read lifecycle and bulk consumers remain unresolved.'});
            promotionEligible=$false;crossEpochMultiplicationAllowed=$false;
            nativeEvidenceIndexSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'native-summary-phase3.json')).Hash;
            precisionControlSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'control-c3-audit.json')).Hash} |
            ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $destination
        $import=& dotnet exec --fx-version 10.0.13 $labHost import $catalog $destination application/json
        if($LASTEXITCODE -ne 0){throw 'Disposition artifact import failed'}
        $artifact=$import | ConvertFrom-Json
        $import | Set-Content -LiteralPath (Join-Path $catalog 'postscreen-artifact.json')
        $request=[ordered]@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;
            mechanism=$prior.mechanism;prediction=$prior.prediction;state=$state;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
        $request | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $catalog 'postscreen-revision-request.json')
        $result=($request | ConvertTo-Json -Depth 10 -Compress) | & dotnet exec --fx-version 10.0.13 $labHost call $catalog lab.experiment
        $result | Set-Content -LiteralPath (Join-Path $catalog 'postscreen-revision-response.json')
        if($LASTEXITCODE -ne 0 -or ($result | ConvertFrom-Json).status -ne 'ok'){throw 'Hypothesis disposition revision failed'}
        "$label disposition: $state"
    }
} finally {Exit-VoxtreePerformanceHost $leases}
