param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory,[switch]$RecoverRejectedImport)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$root=Join-Path $TaskRoot 'p34-hypothesis'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
try{
 if(Test-Path -LiteralPath $root){
  if(-not $RecoverRejectedImport -or (Test-Path -LiteralPath (Join-Path $root 'hypothesis-request.json')) -or (Test-Path -LiteralPath (Join-Path $root 'protocol-artifact.json'))){throw 'P34 metadata exists; inspect original state'}
  @{code='invalid_request';message='Unsupported importer media type.';mediaType='text/markdown';scope='Import rejected before hypothesis request or measurement; protocol preserved; recover with application/json'}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'rejected-import.json')
 }else{
  New-Item -ItemType Directory -Path $root|Out-Null
  & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
  if($LASTEXITCODE -ne 0){throw 'P34 catalog init failed'}
 }
 . (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
 $protocol=Join-Path $PSScriptRoot 'WORLD-RECENT-PROTOCOL.md'
 Copy-Item -LiteralPath $protocol -Destination (Join-Path $root 'protocol.md')
 @{protocol=(Get-Content -LiteralPath $protocol -Raw);sha256=(Get-FileHash -LiteralPath $protocol).Hash}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'protocol.json')
 $artifact=Import-File (Join-Path $root 'protocol.json') application/json
 $artifact|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'protocol-artifact.json')
 $request=@{action='create_hypothesis';mechanism='A repeated-work/locality intervention on published f0772c8 RecentChunkMap: a full-address last-entry comparison bypasses HashCode.Combine and lookup probing only on an exact hit. Retain precise access-sequence, LRU, replacement/removal/clear/storage semantics; no P24-P33 source is combined. Hash critical-path share is unmeasured.';prediction='Version19 public world repeated get/lod/chunk descriptive speedup >=1.10 across both widths, all34 changing-address/topology/miss guards cost<=1.05, zero read allocations and exact mutation/residency parity. Verify emitted shortcut and timestamp stores, run the entire fixed40-case four-pair stage before any conditional fresh normal confirmation. Failure rejects universal suitability; no application or 10x claim.';evidence_ids=@($artifact.id)}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'hypothesis-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis-response.json')
 $result|ConvertTo-Json -Depth 10
}finally{Exit-VoxtreePerformanceHost $lease}
