param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    & python (Join-Path $PSScriptRoot 'Audit-PaletteReturnNative.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'P29 code gate did not pass; retain original listings'}
    & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase14-read --files p29-UInt32-owned-get-code.asm p29-UInt32-owned-lod-code.asm p29-UInt32-span-get-code.asm p29-UInt32-span-lod-code.asm --include-fullopts
    if($LASTEXITCODE -ne 0){throw 'P29 native indexing failed'}
} finally {Exit-VoxtreePerformanceHost $lease}
