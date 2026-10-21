param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Model-CompactTerminal.py','COMPACT-TERMINAL-PROTOCOL.md');$hashes=@{}
foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued P39 model dependency changed'}}
 $snapshot=Join-Path $TaskRoot 'p39-model-source'
 if(Test-Path -LiteralPath $snapshot){throw 'Original model producer exists; inspect it'}
 New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in $names){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 Copy-Item -LiteralPath $PSCommandPath -Destination $snapshot
 & python (Join-Path $PSScriptRoot 'Model-CompactTerminal.py') $TaskRoot
 if($LASTEXITCODE -ne 0){throw 'Original P39 model failed; preserve counterexample/source'}
}finally{Exit-VoxtreePerformanceHost $lease}
