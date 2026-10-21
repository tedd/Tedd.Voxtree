param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    & python (Join-Path $PSScriptRoot 'Audit-BuildPlanReuseNative.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'P30 native/source gate did not pass; retain original listings'}
    & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase15-plan-reuse --files p30builder-code-code.asm --include-fullopts
    if($LASTEXITCODE -ne 0){throw 'P30 native indexing failed'}
} finally {Exit-VoxtreePerformanceHost $lease}
