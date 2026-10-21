param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
function Revise-OwnedHypothesis([string]$Name,[string]$State,[string]$Path){
    $script:root=Join-Path $TaskRoot ($Name+'-hypothesis')
    $created=(Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json).data
    $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
    $artifact=Import-File $Path application/json
    $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$State;evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
    $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
    $result=Invoke-Lab lab.experiment $request
    $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
}
try {
    $shutdown=Get-Content -LiteralPath (Join-Path $TaskRoot 'p26bulk-screen/p26bulk-shutdown.json') -Raw|ConvertFrom-Json
    if(-not $shutdown.targetExited -or -not $shutdown.controllerExited -or $shutdown.targetExitCode -ne 0){throw 'P26 family not joined'}
    $binding=Get-Content -LiteralPath (Join-Path $TaskRoot 'p26bulk-binding.json') -Raw|ConvertFrom-Json
    if($binding.protocolSha256 -ne (Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p26-frozen-protocol.txt')).Hash){throw 'Frozen P26 protocol changed'}
    & python (Join-Path $PSScriptRoot 'Audit-BulkConsumers.py') $TaskRoot --label p26bulk
    if($LASTEXITCODE -ne 0){throw 'P26 full-family audit failed'}
    & python (Join-Path $PSScriptRoot 'Review-CountSource.py') $TaskRoot --labels p26
    if($LASTEXITCODE -ne 0){throw 'P26 source review failed'}
    & python (Join-Path $PSScriptRoot 'Audit-PackedWriterCensus.py') $TaskRoot --label p26bulk --parent-label p25bulk
    if($LASTEXITCODE -ne 0){throw 'P26 exact-parent census audit failed'}
    & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase12-leaf-stop --files p26builder-code-code.asm --include-fullopts
    if($LASTEXITCODE -ne 0){throw 'P26 native indexing failed'}
    $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p26bulk-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $primary=@($audit.cases|Where-Object{$_.scenario -match '^bulk-UInt(16|32)-L5-mixed-u16-air-(construct|callerbuild|trybuild)$'})
    $guards=@($audit.cases|Where-Object{$_.scenario -notin $primary.scenario})
    if($primary.Count -ne 6 -or $guards.Count -ne 82){throw 'P26 primary/guard mismatch'}
    $passed=@($primary|Where-Object{$_.descriptive_speedup -lt 1.25}).Count -eq 0
    $state=if($passed){'inconclusive'}else{'not_supported'}
    $adverse=@($guards|Where-Object{$_.descriptive_speedup -lt (1/1.05)})
    $disposition=Join-Path $TaskRoot 'p26-disposition.json';if(Test-Path -LiteralPath $disposition){throw 'P26 disposition exists'}
    @{state=$state;primaryPassed=$passed;primary=$primary;adverseOriginalGuards=$adverse;guardCount=82;promotionEligible=$false;scope='Full exploratory family, not fresh confirmation; no multiplication with older ratios or source adoption'}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $disposition
    Revise-OwnedHypothesis p26 $state $disposition
    & (Join-Path $PSScriptRoot 'Inspect-PaletteStates.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory
    & python (Join-Path $PSScriptRoot 'Audit-PaletteStates.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'J1 audit failed'}
    $j1=Get-Content -LiteralPath (Join-Path $TaskRoot 'j1-audit.json') -Raw|ConvertFrom-Json -Depth 80
    Revise-OwnedHypothesis j1 $(if($j1.preselected_sample_fits_all_three_apis){'supported'}else{'not_supported'}) (Join-Path $TaskRoot 'j1-audit.json')
    foreach($name in @('p26-source-origin.json','p26-source-review.json','p26-source-review.diff','p26bulk-audit.json','p26bulk-census-audit.json','native-summary-phase12-leaf-stop.json','p26-disposition.json','j1-audit.json','j1-identity.json')){
        $destination=Join-Path $PSScriptRoot $name;if(Test-Path -LiteralPath $destination){throw 'Permanent phase12 record exists'}
        Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination $destination
    }
    $prefixes=@('p26','j1','native-summary-phase12-leaf-stop.json','bundles/p26','packed-leaf-stop-source','packed-corpus-p26','forcecraft-census-packed-p26','packed-lookup-validation-p26point','packed-lookup-p26point','packed-lookup-test-options-p26point','packed-lookup-tests-p26point','count-body-p26','palette-state-j1-source','forcecraft-census-palette-j1')
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase12','--content-addressed')
    foreach($prefix in $prefixes){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'Phase12 preservation failed; preserve partial output'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase12 --require 'p26bulk-screen/catalog-export.json' --require 'p26-hypothesis/disposition-revision-response.json' --require 'j1-hypothesis/disposition-revision-response.json' --require 'p26bulk-audit.json' --require 'p26bulk-census-audit.json' --require 'packed-leaf-stop-source/PackedLeafEncoding.cs' --require 'bundles/p26bulk/p26bulk.dll' --require 'forcecraft-census-palette-j1/palette-states.json' --require 'palette-state-j1-source/PaletteStateCensus.cs' --require 'j1-audit.json'
    if($LASTEXITCODE -ne 0){throw 'Phase12 verification failed'}
    @{p26State=$state;p26AdverseGuards=$adverse.Count;j1PreselectedSampleFits=$j1.preselected_sample_fits_all_three_apis}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $lease}
