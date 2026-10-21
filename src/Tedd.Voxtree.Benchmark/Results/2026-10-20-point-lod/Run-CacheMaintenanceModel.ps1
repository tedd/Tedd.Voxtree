param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$model=Join-Path $PSScriptRoot 'Model-CacheMaintenance.py';$hash=(Get-FileHash -LiteralPath $model).Hash
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 if((Get-FileHash -LiteralPath $model).Hash -ne $hash){throw 'Queued P36 model changed'}
 & python $model $TaskRoot
 if($LASTEXITCODE -ne 0){throw 'Original P36 model failed; retain counterexample without replacement'}
}finally{Exit-VoxtreePerformanceHost $lease}
