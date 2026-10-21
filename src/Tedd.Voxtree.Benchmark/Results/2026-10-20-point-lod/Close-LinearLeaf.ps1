param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
# Wait behind the complete original pipeline; do not interleave its timed arms.
$leases=Enter-VoxtreePerformanceHost
try {
    $shutdown=Get-Content -LiteralPath (Join-Path $TaskRoot 'p22bulk-screen/p22bulk-shutdown.json') -Raw|ConvertFrom-Json
    if(-not $shutdown.targetExited -or -not $shutdown.controllerExited -or $shutdown.targetExitCode -ne 0){throw 'Original family not joined'}
    $binding=Get-Content -LiteralPath (Join-Path $TaskRoot 'p22bulk-binding.json') -Raw|ConvertFrom-Json
    if($binding.protocolSha256 -ne (Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p22-frozen-protocol.txt')).Hash){throw 'Frozen protocol mismatch'}
    & python (Join-Path $PSScriptRoot 'Audit-BulkConsumers.py') $TaskRoot --label p22bulk
    if($LASTEXITCODE -ne 0){throw 'P22 full-family audit failed'}
    & python (Join-Path $PSScriptRoot 'Review-CountSource.py') $TaskRoot --labels p22
    if($LASTEXITCODE -ne 0){throw 'P22 source review failed'}
    & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase6-builders --files p22builder-code-code.asm --include-fullopts
    if($LASTEXITCODE -ne 0){throw 'P22 native indexing failed'}
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'RELEASE-BUILDER-CENSUS.md') -Destination (Join-Path $TaskRoot 'p22-census-protocol.txt')
    & (Join-Path $PSScriptRoot 'Inspect-PackedCorpus.ps1') -TaskRoot $TaskRoot -Label p22bulk -ReleaseBuilder
    & python (Join-Path $PSScriptRoot 'Audit-PackedCorpus.py') $TaskRoot --bundle-label p22bulk
    if($LASTEXITCODE -ne 0){throw 'P22 corpus audit failed'}
    foreach($name in @('p22-source-review.json','p22-source-review.diff','p22bulk-audit.json','p22bulk-audit-corpus.json','native-summary-phase6-builders.json')){
        $destination=Join-Path $PSScriptRoot $name
        if(Test-Path -LiteralPath $destination){throw 'Permanent P22 evidence exists'}
        Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination $destination
    }
    & (Join-Path $PSScriptRoot 'Finalize-BuilderHypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory
} finally {Exit-VoxtreePerformanceHost $leases}
