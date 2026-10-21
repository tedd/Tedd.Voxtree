param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Measure.ps1','WORLD-LAYER-PROTOCOL.md','Scenarios-world-layer.cs.txt','Audit-WorldLayerStage.py');$hashes=@{}
foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'P35 queued timing dependency changed'}}
 if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p35world-screen')){throw 'P35 timing exists; inspect accepted operation state'}
 Invoke-VoxtreeExternalPhase {
  $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p35-prerequisite-audit.json') -Raw|ConvertFrom-Json
  if(-not $gate.passed -or -not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase24-verified.json'))){throw 'P35 prerequisite gate or archive missing'}
  if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p35-world-native.asm')).Hash.ToLowerInvariant() -ne $gate.nativeSha256){throw 'P35 native gate changed'}
  if((Get-FileHash -LiteralPath (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll')).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
  foreach($f in (Get-Content -LiteralPath (Join-Path $TaskRoot 'p35world-hashes.json') -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'P35 bundle changed'}}
  $manifest=Get-Content -LiteralPath (Join-Path $TaskRoot 'p35-source-hashes.json') -Raw|ConvertFrom-Json -AsHashtable
  foreach($n in $manifest.Keys){if((Get-FileHash -LiteralPath (Join-Path (Join-Path $TaskRoot 'world-layer-source') $n)).Hash.ToLowerInvariant() -ne $manifest[$n]){throw 'P35 source changed'}}
  $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p35-timing-frozen-dependencies.json')
 }
 & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p35world/p35world.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p35world-screen') -Filter 'world-*' -Label p35world -Budget bounded-point -Blocks 4 -WarmupBatches 2 -Seed '20261114'
 Invoke-VoxtreeExternalPhase {
  & python (Join-Path $PSScriptRoot 'Audit-WorldLayerStage.py') $TaskRoot
  if($LASTEXITCODE -ne 0){throw 'P35 stage audit failed; preserve original operations'}
 }
}finally{Exit-VoxtreePerformanceHost $lease}
