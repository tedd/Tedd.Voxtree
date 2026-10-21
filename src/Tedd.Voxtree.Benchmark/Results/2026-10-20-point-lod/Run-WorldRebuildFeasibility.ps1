param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Build-WorldRebuildOutline.ps1','Prepare-WorldRebuildOutline.py','Inspect-WorldRebuildOutline.ps1','Inspect-Code.ps1','Summarize-Native.py','Audit-Callers.ps1','CallerAudit.cs.txt','Test-PackedLookup.ps1','CacheMaintenanceTests.cs.txt','WorldLayerTests.cs.txt','Scenarios-world-normal.cs.txt','WORLD-REBUILD-OUTLINE-PROTOCOL.md');$hashes=@{}
foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued P38 dependency changed'}}
 $marker=Join-Path $TaskRoot 'p38-feasibility-driver-start.json'
 if(Test-Path -LiteralPath $marker){throw 'Original P38 driver exists; inspect its original state'}
 $snapshot=Join-Path $TaskRoot 'p38-driver-source';New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in $names){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 Copy-Item -LiteralPath $PSCommandPath -Destination $snapshot
 @{pid=$PID;startUtc=[DateTimeOffset]::UtcNow.ToString('o');driverSha256=(Get-FileHash -LiteralPath $PSCommandPath).Hash;dependencies=$hashes;scope='P38 original source/build/metadata/regression/semantic/native feasibility only'}|ConvertTo-Json -Depth 30|Set-Content -LiteralPath $marker
 & (Join-Path $PSScriptRoot 'Build-WorldRebuildOutline.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory
 & (Join-Path $PSScriptRoot 'Audit-Callers.ps1') -TaskRoot $TaskRoot -Label caller-audit-p38library -BundleLabels p38n0,p38n1 -Mode library -EntryAssembly WorldNormal.dll
 if((Test-Path -LiteralPath (Join-Path $TaskRoot 'packed-lookup-validation-p38world')) -or (Test-Path -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p38world-results'))){throw 'P38 original regression identity exists'}
 & (Join-Path $PSScriptRoot 'Test-PackedLookup.ps1') -TaskRoot $TaskRoot -Label p38world -SourceDirectoryName rebuild-outline-source -FixtureName CacheMaintenanceTests.cs.txt -ExtraFixtureName WorldLayerTests.cs.txt -BaselineSourceDirectoryName rebuild-outline-control-source -PublishedFormat
 & (Join-Path $PSScriptRoot 'Inspect-WorldRebuildOutline.ps1') -TaskRoot $TaskRoot
 @{finishedUtc=[DateTimeOffset]::UtcNow.ToString('o');driverExitedNormally=$true;comparativeTimingRecords=0}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p38-feasibility-driver-completed.json')
}catch{
 $_.Exception.ToString()|Set-Content -LiteralPath (Join-Path $TaskRoot 'p38-feasibility-driver-failure.log');throw
}finally{Exit-VoxtreePerformanceHost $lease}
