param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly
$root=Join-Path $TaskRoot 'p25-hypothesis';$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try {
    $path=Join-Path $root 'postwriter-disposition.json'
    if(Test-Path -LiteralPath $path){throw 'P25 disposition exists; inspect original revision'}
    $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p25bulk-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $primary=@($audit.cases|Where-Object{$_.scenario -match '^bulk-UInt(16|32)-L5-mixed-u16-air-(construct|callerbuild|trybuild)$'})
    $guards=@($audit.cases|Where-Object{$_.scenario -notin $primary.scenario})
    if($primary.Count -ne 6 -or $guards.Count -ne 82){throw 'P25 frozen primary/guard mismatch'}
    $passed=@($primary|Where-Object{$_.descriptive_speedup -lt 2}).Count -eq 0
    $state=if($passed){'inconclusive'}else{'not_supported'}
    $adverse=@($guards|Where-Object{$_.descriptive_speedup -lt (1/1.05)})
    $nominal=@($guards|Where-Object{$_.descriptive_speedup -lt 0.95})
    @{state=$state;primaryPassedNominally=$passed;primary=$primary;guards=$guards;adverseFrozenFivePercentCostGuards=$adverse;
      adverseProtocolNominalPoint95SpeedupGuards=$nominal;promotionEligible=$false;
      explanation='Primary requires every six dominant constructor/caller Build/TryBuild estimate >=2. Both the original 1.05 cost policy and the protocol nominal 0.95 speedup cut are retained explicitly; no post-result threshold change or waiver. Same-process observations are exploratory. No source adoption or multiplication with P24 ratios.';
      sourceReviewSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p25-source-review.json')).Hash;
      corpusAuditSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p25census-audit.json')).Hash}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $path
    $created=(Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
    $artifact=Import-File $path application/json
    $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$state;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'postwriter-revision-request.json')
    $result=Invoke-Lab lab.experiment $request
    $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'postwriter-revision-response.json')
    Copy-Item -LiteralPath $path -Destination (Join-Path $PSScriptRoot 'p25-disposition.json')
    @{state=$state;primaryPassed=$passed;adverseOriginalGuards=$adverse.Count;adverseNominalProtocolGuards=$nominal.Count}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $lease}
