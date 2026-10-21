param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    if(-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase13-verified.json'))){throw 'Original P27 family must be closed first'}
    foreach($file in (Get-Content -LiteralPath (Join-Path $TaskRoot 'p27setup-hashes.json') -Raw|ConvertFrom-Json)){
        if((Get-FileHash -LiteralPath $file.Path).Hash -ne $file.Hash){throw 'Selected P27 bundle changed'}
    }
    foreach($access in @('owned','span')){
        & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot 'bundles/p27setup') -Label "p29-precheck-UInt32-$access-get" -Scenario "point-ForceUInt32-L5-mixed-u16-air-$access-get" -Methods '*TryGet* *TryReadState* *ReadEntry* *AfterBatch* *GetUnchecked*'
    }
    & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label p29-read-precheck --files p29-precheck-UInt32-owned-get.asm p29-precheck-UInt32-span-get.asm --include-fullopts
    if($LASTEXITCODE -ne 0){throw 'Read-path diagnostic indexing failed'}
} finally {Exit-VoxtreePerformanceHost $lease}
