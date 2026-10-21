param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Inspect-Code.ps1','Summarize-Native.py')
$hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued native dependency changed'}}
    foreach($type in @('UInt32','UInt16')){foreach($access in @('owned','span')){foreach($op in @('get','lod')){
        $label='p32-native-'+$type.ToLowerInvariant()+'-'+$access+'-'+$op
        & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot 'bundles/p32point') -Label $label -Scenario "point-Force$type-L5-mixed-u16-air-$access-$op" -Methods '*AfterBatchOwned* *AfterBatchSpan* *BeforeBatchOwned* *BeforeBatchSpan* *TryGet* *GetUnchecked*'
    }}}
    $files=@(Get-ChildItem -LiteralPath $TaskRoot -Filter 'p32-native-*.asm'|Select-Object -ExpandProperty Name)
    if($files.Count -ne 8){throw 'Incomplete native family'}
    & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase18-bounds --include-fullopts --files @files
    if($LASTEXITCODE -ne 0){throw 'Native indexing failed'}
} finally {Exit-VoxtreePerformanceHost $lease}
