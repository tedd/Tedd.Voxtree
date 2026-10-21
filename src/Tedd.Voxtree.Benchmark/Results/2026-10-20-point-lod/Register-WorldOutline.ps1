param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$root=Join-Path $TaskRoot 'p37-hypothesis';$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
try{
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
 if(Test-Path -LiteralPath $root){throw 'P37 metadata exists; inspect original accepted state'}
 New-Item -ItemType Directory -Path $root|Out-Null
 & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
 if($LASTEXITCODE -ne 0){throw 'P37 catalog initialization failed'}
 . (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
 $protocol=Join-Path $PSScriptRoot 'WORLD-OUTLINE-PROTOCOL.md'
 @{protocol=(Get-Content -LiteralPath $protocol -Raw);sha256=(Get-FileHash -LiteralPath $protocol).Hash}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'protocol.json')
 $artifact=Import-File (Join-Path $root 'protocol.json') application/json
 $request=@{action='create_hypothesis';mechanism='P37 isolated compiler boundary on complete f0772c8: only NoInlining on private AddRecent; no P36 algorithm/state/layout/format/body changes. Published optimized callers inline maintenance; smaller hot callers may help, while miss/constructor/mutation paths pay a call. C18 selective inlining; R03 representative PGO constraint. Time share and hardware cause unmeasured.';prediction='Feasibility only before separately frozen timing: exact source/IL/body/public-surface equality except one implementation flag; original full regressions and48 prefixes/module pass; eight actual normal Tier1 callers/module complete, candidate clear sites removed and AddRecent calls present, every candidate native body smaller and fixed rsp no larger. No time, application or full10x/adoption claim.';evidence_ids=@($artifact.id)}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'hypothesis-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis-response.json')
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
