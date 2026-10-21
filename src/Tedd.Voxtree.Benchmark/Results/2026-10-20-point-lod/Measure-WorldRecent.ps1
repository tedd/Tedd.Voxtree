param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Measure.ps1','WORLD-RECENT-PROTOCOL.md','Scenarios-world-recent.cs.txt','Audit-WorldRecentStage.py')
$hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued P34 dependency changed'}}
 if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p34world-screen')){throw 'P34 timing family exists; inspect accepted state without retry'}
 Invoke-VoxtreeExternalPhase {
  $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p34-prerequisite-audit.json') -Raw|ConvertFrom-Json
  if(-not $gate.passed){throw 'P34 prerequisite audit incomplete'}
  if((Get-FileHash -LiteralPath (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll')).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
  foreach($f in (Get-Content -LiteralPath (Join-Path $TaskRoot 'p34world-hashes.json') -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'P34 bundle changed'}}
  $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p34-timing-frozen-dependencies.json')
 }
 & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p34world/p34world.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p34world-screen') -Filter 'world-*' -Label p34world -Budget bounded-point -Blocks 4 -WarmupBatches 2 -Seed '20261113'
 Invoke-VoxtreeExternalPhase {
  & python (Join-Path $PSScriptRoot 'Audit-WorldRecentStage.py') $TaskRoot
  if($LASTEXITCODE -ne 0){throw 'P34 stage audit failed; retain original operations'}
 }
}finally{Exit-VoxtreePerformanceHost $lease}
