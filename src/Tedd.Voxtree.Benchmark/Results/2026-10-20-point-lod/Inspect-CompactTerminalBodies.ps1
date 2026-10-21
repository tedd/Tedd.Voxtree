param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$addendum=Join-Path $PSScriptRoot 'COMPACT-TERMINAL-IL-COVERAGE.md';$frozen=(Get-FileHash -LiteralPath $addendum).Hash
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$root=Join-Path $TaskRoot 'p39-hypothesis';$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 if((Get-FileHash -LiteralPath $addendum).Hash -ne $frozen){throw 'Queued coverage addendum changed'}
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
 $output=Join-Path $TaskRoot 'caller-audit-p39bodies.json'
 if((Test-Path -LiteralPath $output) -or (Test-Path -LiteralPath (Join-Path $root 'coverage-revision-request.json'))){throw 'Original full inventory/coverage revision exists; inspect accepted state'}
 @{text=(Get-Content -LiteralPath $addendum -Raw);sha256=$frozen;frozenBeforeInventory=$true}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'coverage-addendum.json')
 $artifact=Import-File (Join-Path $root 'coverage-addendum.json') application/json
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$prior.state;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'coverage-revision-request.json')
 Invoke-Lab lab.experiment $request|ConvertTo-Json -Depth 60|Set-Content -LiteralPath (Join-Path $root 'coverage-revision-response.json')
 $original=Get-Content -LiteralPath (Join-Path $TaskRoot 'caller-audit-p38library-identity.json') -Raw|ConvertFrom-Json
 $tool=Join-Path $TaskRoot 'caller-audit-p38library/out/Audit.dll'
 if(-not $original.selftestPassed -or (Get-FileHash -LiteralPath $tool).Hash -ne $original.toolSha256){throw 'Original self-tested metadata tool changed'}
 foreach($label in @('p31census','p39census')){foreach($f in @(Get-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json") -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'Compiled library audit input changed'}}}
 & $dotnet exec --fx-version 10.0.13 $tool --library $output (Join-Path $TaskRoot 'bundles/p31census/p31census.dll') (Join-Path $TaskRoot 'bundles/p39census/p39census.dll')
 if($LASTEXITCODE -ne 0){throw 'Original complete P31/P39 IL inventory failed'}
 @{runtime='10.0.13';sourceSha256=$original.sourceSha256;toolSha256=$original.toolSha256;selftestPassed=$true;tool=$tool;bundleLabels=@('p31census','p39census');mode='library';coverageAddendumSha256=$frozen;coverageFrozenBeforeInventory=$true;observer='complete metadata-only library inventory; no fixture or static constructor executed'}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'caller-audit-p39bodies-identity.json')
}finally{Exit-VoxtreePerformanceHost $lease}
