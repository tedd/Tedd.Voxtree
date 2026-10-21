param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$root=Join-Path $TaskRoot 'p38-hypothesis';$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
try{
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
 if(Test-Path -LiteralPath $root){throw 'P38 metadata exists; inspect original accepted state'}
 New-Item -ItemType Directory -Path $root|Out-Null
 & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
 if($LASTEXITCODE -ne 0){throw 'P38 catalog initialization failed'}
 . (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
 $protocol=Join-Path $PSScriptRoot 'WORLD-REBUILD-OUTLINE-PROTOCOL.md'
 @{protocol=(Get-Content -LiteralPath $protocol -Raw);sha256=(Get-FileHash -LiteralPath $protocol).Hash}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'protocol.json')
 $artifact=Import-File (Join-Path $root 'protocol.json') application/json
 $request=@{action='create_hypothesis';mechanism='P38 isolated this-only boundary on complete f0772c8: only NoInlining on private RebuildLookup, retaining published AddRecent flag/body and all algorithms/layout/formats. Avoid P37 large-address/fifth-argument boundary; C18 selective inlining and R03 PGO constraint. No hardware/time cause established.';prediction='Feasibility only before separate full timing: exact source reversal,1203 raw/resolved IL bodies and47-type API unchanged except one implementation flag;408/409/410 tests and48 prefixes/module; sixteen complete final Tier1 callers, candidate RebuildLookup calls instead of clear sites, every body smaller and fixed rsp no larger. No source adoption or full10x claim.';evidence_ids=@($artifact.id)}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'hypothesis-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis-response.json')
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
