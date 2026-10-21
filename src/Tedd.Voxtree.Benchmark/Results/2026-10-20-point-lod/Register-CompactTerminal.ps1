param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$root=Join-Path $TaskRoot 'p39-hypothesis';$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
try{
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
 if(Test-Path -LiteralPath $root){throw 'P39 metadata exists; inspect original accepted state'}
 New-Item -ItemType Directory -Path $root|Out-Null
 & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
 if($LASTEXITCODE -ne 0){throw 'P39 catalog initialization failed'}
 . (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
 $protocol=Join-Path $PSScriptRoot 'COMPACT-TERMINAL-PROTOCOL.md'
 @{protocol=(Get-Content -LiteralPath $protocol -Raw);sha256=(Get-FileHash -LiteralPath $protocol).Hash}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'protocol.json')
 $artifact=Import-File (Join-Path $root 'protocol.json') application/json
 $request=@{action='create_hypothesis';mechanism='P39 A09/A03/C18: on exact unpromoted P31, replace level1/originLOD0 eight recursive leaf validations with four checked little-endian row pairs, zero metadata mask plus unequal-to-origin requirement. Preserve canonical uniform rejection, all other recursion, writer/selection/format/point paths; no P32-P38 changes.';prediction='Before source, independent fixed2629760-case equivalence model and37440 aligned-cube bounds proof pass. Then exact source/compiled-body/API identity except terminal validator, full malformed/boundary regressions, original-byte/writer/1286-chunk corpus and actual x64 terminal branch show removed recursive leaf calls. No comparative timing, parent-gate waiver, allocation waiver, source adoption or full10x claim.';evidence_ids=@($artifact.id)}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'hypothesis-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis-response.json')
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
