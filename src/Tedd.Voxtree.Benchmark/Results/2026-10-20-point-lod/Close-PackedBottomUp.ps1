param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $shutdown=Get-Content -LiteralPath (Join-Path $TaskRoot 'p25bulk-screen/p25bulk-shutdown.json') -Raw|ConvertFrom-Json
    if(-not $shutdown.targetExited -or -not $shutdown.controllerExited -or $shutdown.targetExitCode -ne 0){throw 'Original P25 family not joined'}
    $binding=Get-Content -LiteralPath (Join-Path $TaskRoot 'p25bulk-binding.json') -Raw|ConvertFrom-Json
    if($binding.protocolSha256 -ne (Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p25-frozen-protocol.txt')).Hash){throw 'Frozen protocol mismatch'}
    & python (Join-Path $PSScriptRoot 'Audit-BulkConsumers.py') $TaskRoot --label p25bulk
    if($LASTEXITCODE -ne 0){throw 'P25 family audit failed'}
    & python (Join-Path $PSScriptRoot 'Review-CountSource.py') $TaskRoot --labels p25
    if($LASTEXITCODE -ne 0){throw 'P25 source binding failed'}
    foreach($name in @('p25-source-origin.json','p25-source-review.json','p25-source-review.diff','p25bulk-audit.json','p25census-audit.json','p25-writer-native-audit.json')){
        $destination=Join-Path $PSScriptRoot $name
        if(Test-Path -LiteralPath $destination){throw 'Permanent P25 evidence already exists'}
        Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination $destination
    }
    & (Join-Path $PSScriptRoot 'Finalize-P25Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory
    # Scoped supplement retains P25 evidence and P24 post-archive dispositions.
    $prefixes=@('p25','p24-confirmation/','p24-hypothesis/','p24-confirmation-disposition.json','bundles/p25','packed-bottom-up-source','packed-corpus-p25','forcecraft-census-packed-p25','packed-lookup-validation-p25point','packed-lookup-p25point','packed-lookup-test-options-p25point','packed-lookup-tests-p25point','count-body-p25')
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase11','--content-addressed')
    foreach($prefix in $prefixes){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'P25 scoped archive failed; preserve partial output'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase11 --require 'p25bulk-screen/catalog-export.json' --require 'p25-hypothesis/catalog-export.json' --require 'p25-hypothesis/postwriter-revision-response.json' --require 'p24-confirmation/postconfirmation-revision-response.json' --require 'p24-hypothesis/postconfirmation-revision-response.json' --require 'p25bulk-audit.json' --require 'p25-source-review.json' --require 'p25-source-review.diff' --require 'p25oracle-output.log' --require 'p25-writer-native-audit.json' --require 'packed-bottom-up-source/PackedLeafEncoding.cs' --require 'bundles/p25bulk/p25bulk.dll' --require 'forcecraft-census-packed-p25bulk/packed-corpus.json' --require 'forcecraft-census-packed-p25census/packed-corpus.json'
    if($LASTEXITCODE -ne 0){throw 'P25 archive verification failed'}
} finally {Exit-VoxtreePerformanceHost $lease}
