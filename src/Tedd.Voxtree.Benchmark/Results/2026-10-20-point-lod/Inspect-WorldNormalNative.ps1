param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Inspect-Code.ps1','Summarize-Native.py');$hashes=@{}
foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued native dependency changed'}}
 $root=Join-Path $TaskRoot 'p36-normal-screen'
 if(-not (Test-Path -LiteralPath (Join-Path $root 'run-driver-completed.json'))){throw 'Quiet family must finish before separate normal native diagnostics'}
 $inputs=Get-Content -LiteralPath (Join-Path $root 'inputs.json') -Raw|ConvertFrom-Json -Depth 80
 foreach($bundle in $inputs.bundles){foreach($f in $bundle.files){if((Get-FileHash -LiteralPath $f.path).Hash.ToLowerInvariant() -ne $f.sha256){throw 'Frozen normal artifact changed'}}}
 $methods='*AddRecent* *InsertRecentLookup* *RemoveRecentLookup* *RebuildLookup* *AfterGet* *AfterLod* *AfterChunk* *AfterTopology*'
 foreach($label in @('p36n0','p36n1')){
  & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot ('bundles/'+$label)) -Label ('p36-normal-'+$label+'-native') -Scenario cycle12 -Methods $methods
 }
 & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase28-normal --files p36-normal-p36n0-native.asm p36-normal-p36n1-native.asm
 if($LASTEXITCODE -ne 0){throw 'Actual normal native indexing failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
