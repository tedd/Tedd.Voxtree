param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Build-Rig.ps1','Inspect-PackedCorpus.ps1','Scenarios-compact-leaf.cs.txt','CompactCorpus.cs.txt','Scan-Forcecraft.cs.txt');$frozen=@{}
foreach($n in $names){$frozen[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Queued P39 corpus dependency changed'}}
 foreach($n in @('p39census','packed-corpus-p39census-source','forcecraft-census-packed-p39census','p39-corpus-driver-start.json')){if(Test-Path -LiteralPath (Join-Path $TaskRoot $n)){throw 'Original P39 corpus producer exists; inspect it'}}
 $snapshot=Join-Path $TaskRoot 'p39-corpus-driver-source';New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in $names){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 Copy-Item -LiteralPath $PSCommandPath -Destination $snapshot
 @{pid=$PID;startUtc=[DateTimeOffset]::UtcNow.ToString('o');driverSha256=(Get-FileHash -LiteralPath $PSCommandPath).Hash;dependencies=$frozen;scope='Original P39 full immutable corpus; published baseline plus exact P31 byte witness; no timing'}|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-corpus-driver-start.json')
 & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p39census -CandidateSource (Join-Path $TaskRoot 'compact-terminal-source') -FixtureName Scenarios-compact-leaf.cs.txt *> (Join-Path $TaskRoot 'p39census-build.log')
 & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p39census -CompactLeaf -ExactParentBundle p31census
 @{finishedUtc=[DateTimeOffset]::UtcNow.ToString('o');driverExitedNormally=$true;comparativeTimingRecords=0}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-corpus-driver-completed.json')
}catch{
 $_.Exception.ToString()|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-corpus-driver-failure.log');throw
}finally{Exit-VoxtreePerformanceHost $lease}
