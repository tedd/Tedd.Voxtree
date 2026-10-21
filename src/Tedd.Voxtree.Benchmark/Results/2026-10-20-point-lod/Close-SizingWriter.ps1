param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
# Wait behind the complete original pipeline; do not interleave its timed arms.
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $shutdown=Get-Content -LiteralPath (Join-Path $TaskRoot 'p23bulk-screen/p23bulk-shutdown.json') -Raw|ConvertFrom-Json
    if(-not $shutdown.targetExited -or -not $shutdown.controllerExited -or $shutdown.targetExitCode -ne 0){throw 'Original family not joined'}
    $binding=Get-Content -LiteralPath (Join-Path $TaskRoot 'p23bulk-binding.json') -Raw|ConvertFrom-Json
    if($binding.protocolSha256 -ne (Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p23-frozen-protocol.txt')).Hash){throw 'Frozen protocol mismatch'}
    & python (Join-Path $PSScriptRoot 'Audit-BulkConsumers.py') $TaskRoot --label p23bulk
    if($LASTEXITCODE -ne 0){throw 'P23 full-family audit failed'}
    & python (Join-Path $PSScriptRoot 'Review-CountSource.py') $TaskRoot --labels p23
    if($LASTEXITCODE -ne 0){throw 'P23 source review failed'}
    & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase7-builders --files p23builder-code-code.asm --include-fullopts
    if($LASTEXITCODE -ne 0){throw 'P23 native indexing failed'}
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'SIZING-WRITER-CENSUS.md') -Destination (Join-Path $TaskRoot 'p23-census-protocol.txt')
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p23bulk -ReleaseBuilder
    & python (Join-Path $PSScriptRoot 'Audit-PackedCorpus.py') $TaskRoot --bundle-label p23bulk
    if($LASTEXITCODE -ne 0){throw 'P23 corpus audit failed'}
    foreach($name in @('p23-source-review.json','p23-source-review.diff','p23bulk-audit.json','p23bulk-audit-corpus.json','native-summary-phase7-builders.json')){
        $destination=Join-Path $PSScriptRoot $name
        if(Test-Path -LiteralPath $destination){throw 'Permanent P23 evidence exists'}
        Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination $destination
    }
    & (Join-Path $PSScriptRoot 'Finalize-SizingHypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory
} finally {Exit-VoxtreePerformanceHost $leases}
