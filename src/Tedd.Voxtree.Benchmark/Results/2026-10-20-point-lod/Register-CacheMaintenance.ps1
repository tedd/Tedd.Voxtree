param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$root=Join-Path $TaskRoot 'p36-hypothesis';$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
try{
 if(Test-Path -LiteralPath $root){throw 'P36 metadata exists; inspect original accepted state'}
 New-Item -ItemType Directory -Path $root|Out-Null
 & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
 if($LASTEXITCODE -ne 0){throw 'P36 catalog initialization failed'}
 . (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
 $protocol=Join-Path $PSScriptRoot 'CACHE-MAINTENANCE-PROTOCOL.md'
 @{protocol=(Get-Content -LiteralPath $protocol -Raw);sha256=(Get-FileHash -LiteralPath $protocol).Hash}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'protocol.json')
 $artifact=Import-File (Join-Path $root 'protocol.json') application/json
 $request=@{action='create_hypothesis';mechanism='A03/A04/A08: replace published f0772c8 AddRecent full-table rebuild with backshift deletion and ordered insertion by recent index. Preserve canonical lookup slots/probe counts, victim selection, exact residency/access sequences, read bodies, fields and formats. Exclude P24-P35; maintenance time share is unmeasured.';prediction='Feasibility only: independent fixed exhaustive/random models and actual collision/wraparound differential tests reproduce canonical increasing-index rebuild exactly; compiled sources match; optimized AddRecent removes full-table Clear/Rebuild calls without new per-read work. All48 separate-operation caller oracles and complete runtime regressions pass before a separately frozen fresh-normal time protocol. No speedup or adoption claim in this phase.';evidence_ids=@($artifact.id)}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'hypothesis-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis-response.json')
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
