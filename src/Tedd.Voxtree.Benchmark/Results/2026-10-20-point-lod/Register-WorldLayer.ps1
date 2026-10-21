param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$root=Join-Path $TaskRoot 'p35-hypothesis';$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
try{
 if(Test-Path -LiteralPath $root){throw 'P35 metadata exists; inspect original accepted state'}
 New-Item -ItemType Directory -Path $root|Out-Null
 & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
 if($LASTEXITCODE -ne 0){throw 'P35 catalog init failed'}
 . (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
 $protocol=Join-Path $PSScriptRoot 'WORLD-LAYER-PROTOCOL.md'
 @{protocol=(Get-Content -LiteralPath $protocol -Raw);sha256=(Get-FileHash -LiteralPath $protocol).Hash}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'protocol.json')
 $artifact=Import-File (Join-Path $root 'protocol.json') application/json
 $request=@{action='create_hypothesis';mechanism='A03/A08/A09: on published f0772c8, a conservative UInt64 seen-LOD mask bypasses hashing/probing only for never-populated layers. Set records the matching bit, Clear resets it, Remove retains false positives. Preserve exact LRU, timestamps, bytes, validation, storage-load fallthrough and implicit empties; exclude P34. Hash critical-path share and application frequencies remain unmeasured.';prediction='Version20 fixed60-case stage: ten never-seen-layer primary estimates>=2; four repeated/blocks32 topology primaries>=1.20; all46 populated-layer/churn/miss/saturated-history guards cost<=1.05. Require exact semantic/source/native gates and zero read allocations before conditional fresh normal confirmation. No native-only, application or full10x claim.';evidence_ids=@($artifact.id)}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'hypothesis-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis-response.json')
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
