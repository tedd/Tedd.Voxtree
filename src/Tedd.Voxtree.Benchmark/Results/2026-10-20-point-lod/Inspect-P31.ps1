param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Inspect-Code.ps1','Inspect-CountBody.ps1','CompactFormatProbe.cs.txt')
$hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued native dependency changed'}}
    foreach($type in @('UInt32','UInt16')){foreach($access in @('owned','span')){foreach($op in @('get','lod')){
        $label='p31-native-'+$type.ToLowerInvariant()+'-'+$access+'-'+$op
        & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot 'bundles/p31setup2') -Label $label -Scenario "point-Force$type-L5-mixed-u16-air-$access-$op" -Methods '*AfterBatchOwned* *AfterBatchSpan* *TryGet* *GetUnchecked*'
    }}}
    & (Join-Path $PSScriptRoot 'Inspect-CountBody.ps1') -TaskRoot $TaskRoot -Label p31-native-format -BundleLabel p31bulk -ProbeSource CompactFormatProbe.cs.txt -Methods '*AfterBatch* *BeforeBatch* *BuildOwned* *CreateBuildPlan* *TryBuildPlanned* *Draw* *Collect* *Uniform* *ValidateCube* *CountCompact* *Count*'
    $files=@(Get-ChildItem -LiteralPath $TaskRoot -Filter 'p31-native-*.asm'|Select-Object -ExpandProperty Name)
    if($files.Count -ne 9){throw 'Incomplete compact native family'}
    & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase16-compact --include-fullopts --files @files
    if($LASTEXITCODE -ne 0){throw 'Compact native indexing failed'}
} finally {Exit-VoxtreePerformanceHost $lease}
