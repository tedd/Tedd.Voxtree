param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Audit-BulkConsumers.py','Register-Hypothesis.ps1','COMPACT-WORD-PROJECTION-PROTOCOL.md','Project-CompactWord.py','Preserve.py','Verify-Evidence.py')
$hashes=@{};foreach($name in $names){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
function Revise-Hypothesis([string]$Name,[string]$State,[string]$Path){
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
    foreach($name in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name)).Hash -ne $hashes[$name]){throw 'Queued P30 closing dependency changed'}}
    $shutdown=Get-Content -LiteralPath (Join-Path $TaskRoot 'p30bulk-screen/p30bulk-shutdown.json') -Raw|ConvertFrom-Json
    if(-not $shutdown.targetExited -or -not $shutdown.controllerExited -or $shutdown.targetExitCode -ne 0){throw 'P30 original family is not joined'}
    $setup=Get-Content -LiteralPath (Join-Path $TaskRoot 'p30-setup-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
    if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p30-frozen-protocol.txt')).Hash -ne $setup['BUILD-PLAN-REUSE-PROTOCOL.md']){throw 'P30 frozen protocol changed'}
    & python (Join-Path $PSScriptRoot 'Audit-BulkConsumers.py') $TaskRoot --label p30bulk
    if($LASTEXITCODE -ne 0){throw 'P30 full-family audit failed'}
    $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p30bulk-audit.json') -Raw|ConvertFrom-Json -Depth 80
    $primary=@($audit.cases|Where-Object{$_.scenario -match '^bulk-UInt(16|32)-L5-mixed-u[78]-air-(construct|build)$'})
    $guards=@($audit.cases|Where-Object{$_.scenario -notin $primary.scenario})
    if($primary.Count -ne 8 -or $guards.Count -ne 80){throw 'P30 primary/guard family mismatch'}
    $passed=@($primary|Where-Object{$_.descriptive_speedup -lt 1.2}).Count -eq 0
    $state=if($passed){'inconclusive'}else{'not_supported'}
    $adverse=@($guards|Where-Object{$_.descriptive_speedup -lt (1/1.05)})
    $disposition=Join-Path $TaskRoot 'p30-disposition.json';if(Test-Path -LiteralPath $disposition){throw 'P30 disposition exists'}
    @{state=$state;primaryPassed=$passed;primary=$primary;adverseOtherGuards=$adverse;guardCount=80;promotionEligible=$false;scope='Complete exploratory family versus P27; no independent normal confirmation, ratio multiplication or source adoption'}|ConvertTo-Json -Depth 100|Set-Content -LiteralPath $disposition
    Revise-Hypothesis p30 $state $disposition
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label k2 -ProtocolName COMPACT-WORD-PROJECTION-PROTOCOL.md -Mechanism 'M05/M17/A09/A12: retain P27 eligibility and full-value fallback while projecting a single UInt16 cell word with13 raw value bits and3 LOD bits at depths3..6. This removes a proposed state-table payload load without broad four-byte expansion. Fixed metadata arithmetic, not an implemented encoder or measured gain.' -Prediction 'All selected corpus modes and the fixed dominant sample fit13+3 bits, existing maximum size and per-selected-chunk<=2.5 released bytes. Assuming future owned lookup sharing, complete classic encoded-plus-distinct-lookup projection does not exceed release. Report encoded growth, duplicates, unique arrays and all rows; no latency or allocation inference.'
    & python (Join-Path $PSScriptRoot 'Project-CompactWord.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'K2 bound projection failed'}
    $k2=Get-Content -LiteralPath (Join-Path $TaskRoot 'k2-audit.json') -Raw|ConvertFrom-Json -Depth 80
    Revise-Hypothesis k2 $k2.state (Join-Path $TaskRoot 'k2-audit.json')
    foreach($name in @('p30-source-origin.json','p30-source-review.json','p30-source-review.diff','p30-native-audit.json','p30census-audit.json','p30bulk-audit.json','p30-disposition.json','native-summary-phase15-plan-reuse.json','k2-audit.json')){
        $destination=Join-Path $PSScriptRoot $name
        if(Test-Path -LiteralPath $destination){
            if((Get-FileHash -LiteralPath $destination).Hash -ne (Get-FileHash -LiteralPath (Join-Path $TaskRoot $name)).Hash){throw 'Permanent P30 preparation record differs'}
        }else{Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination $destination}
    }
    $prefixes=@('p30','k2','native-summary-phase15-plan-reuse.json','bundles/p30','build-plan-reuse-source','packed-corpus-p30census-source','forcecraft-census-packed-p30census','packed-lookup-validation-p30','packed-lookup-p30','packed-lookup-test-options-p30','packed-lookup-tests-p30','count-body-p30')
    $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase15','--content-addressed')
    foreach($prefix in $prefixes){$arguments+=@('--include-prefix',$prefix)}
    & python @arguments
    if($LASTEXITCODE -ne 0){throw 'P30 preservation failed; retain partial output'}
    & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase15 --require 'p30bulk-screen/catalog-export.json' --require 'p30-hypothesis/disposition-revision-response.json' --require 'p30bulk-audit.json' --require 'p30-native-audit.json' --require 'build-plan-reuse-source/GenericOctreeCodec.cs' --require 'p30-source-review.diff' --require 'bundles/p30bulk/p30bulk.dll' --require 'forcecraft-census-packed-p30census/packed-corpus.json' --require 'p30oracle-output.log' --require 'p30-native-audit-first.py.txt' --require 'k2-audit.json' --require 'k2-hypothesis/disposition-revision-response.json'
    if($LASTEXITCODE -ne 0){throw 'P30 evidence verification failed'}
    @{p30State=$state;p30PrimaryPassed=$passed;p30AdverseOtherGuards=$adverse.Count;k2State=$k2.state}|ConvertTo-Json
} finally {Exit-VoxtreePerformanceHost $lease}
