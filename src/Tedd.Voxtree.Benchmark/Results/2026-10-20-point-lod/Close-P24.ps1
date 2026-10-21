param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
# Closed-catalog bookkeeping only; never hold this lease while submitting timing.
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly -DriverPath $PSCommandPath
try {
    & python (Join-Path $PSScriptRoot 'Audit-P24Confirmation.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'P24 confirmation audit failed; preserve originals'}
    $prefixes=@('p24','bundles/p24','packed-word-format-source','packed-corpus-p24census-source','forcecraft-census-packed-p24census','caller-audit-p24normal','packed-lookup-validation-p24point','packed-lookup-p24point','packed-lookup-test-options-p24point','packed-lookup-tests-p24point')
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase10','--content-addressed')
    foreach($prefix in $prefixes){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'P24 scoped preservation failed; never overwrite partial archives'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase10 --require 'p24-confirmation/catalog-export.json' --require 'p24-confirmation/plans.json' --require 'p24-confirmation/inputs.json' --require 'p24-confirmation/source.diff' --require 'p24-confirmation/driver-source/Confirm-P24.ps1' --require 'p24-confirmation-audit.json' --require 'p24-source-origin.json' --require 'p24-native-audit-v2.json' --require 'bundles/p24control/p24control.dll' --require 'bundles/p24census/p24census.dll' --require 'forcecraft-census-packed-p24census/packed-corpus.json' --require 'packed-word-format-source/PackedLeafEncoding.cs' --require 'p24-hypothesis/catalog-export.json'
    if($LASTEXITCODE -ne 0){throw 'P24 archive verification failed'}
    Copy-Item -LiteralPath (Join-Path $TaskRoot 'p24-confirmation-audit.json') -Destination (Join-Path $PSScriptRoot 'p24-confirmation-audit.json')
} finally {Exit-VoxtreePerformanceHost $lease}
