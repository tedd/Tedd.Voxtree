param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 $root=Join-Path $TaskRoot 'p36-normal-screen'
 if(@(Get-ChildItem -LiteralPath $root -Filter '*-operation.json').Count -ne 0 -or (Test-Path -LiteralPath (Join-Path $root 'run-driver-start.json'))){throw 'Normal prerequisite archive must precede timing'}
 $plans=@(Get-Content -LiteralPath (Join-Path $root 'plans.json') -Raw|ConvertFrom-Json -Depth 90)
 if($plans.Count -ne 12){throw 'Normal first-family plans incomplete'}
 $frozen=Get-Content -LiteralPath (Join-Path $root 'frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
 foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Frozen normal dependency changed'}}
 foreach($label in @('p36n0','p36n1')){foreach($f in (Get-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json") -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'Normal source build changed'}}}
 foreach($n in @('p36-normal-preflight.json','p36-normal-scenarios.json','caller-audit-p36normal.json','caller-audit-p36normal-identity.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase27','--content-addressed')
 foreach($prefix in @('p36-normal','p36n0','p36n1','p36-inventory','bundles/p36n0','bundles/p36n1','bundles/p36-inventory','caller-audit-p36normal')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'First normal-family prereq preservation failed'}
 & python (Join-Path $PSScriptRoot 'Verify-Evidence.py') $PSScriptRoot --label phase27 --prerequisites-only --require p36-normal-screen/catalog-export.json --require p36-normal-screen/plans.json --require p36-normal-screen/inputs.json --require p36-normal-preflight.json --require bundles/p36n0/WorldNormal.dll --require bundles/p36n1/WorldNormal.dll --require bundles/p36-inventory/WorldScenarioInventory.dll --require caller-audit-p36normal/out/Audit.dll --require caller-audit-p36normal.json
 if($LASTEXITCODE -ne 0){throw 'First normal-family prereq verification failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
