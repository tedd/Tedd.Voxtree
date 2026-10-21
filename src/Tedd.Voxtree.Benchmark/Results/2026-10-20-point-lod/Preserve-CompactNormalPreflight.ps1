param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 $root=Join-Path $TaskRoot 'p39-normal'
 $plans=@(Get-Content -LiteralPath (Join-Path $root 'plans.json') -Raw|ConvertFrom-Json -Depth 90)
 if($plans.Count -ne 107 -or @(Get-ChildItem -LiteralPath $root -Filter '*-operation.json').Count -ne 0){throw 'Expected107 pre-timing plans and no accepted timing operations'}
 $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-normal-preflight.json') -Raw|ConvertFrom-Json -Depth 90
 if(-not $gate.passed -or $gate.comparativeRecords -ne 0){throw 'Original compact normal preflight incomplete'}
 $frozen=Get-Content -LiteralPath (Join-Path $root 'frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
 foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Frozen preflight dependency changed'}}
 $snapshot=Join-Path $TaskRoot 'p39-normal-preflight-driver-source'
 if(Test-Path -LiteralPath $snapshot){throw 'Original preflight snapshot exists'}
 New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in @('Generate-CompactNormal.py','Build-CompactNormal.ps1','Inspect-CompactNormal.ps1','Audit-CompactNormal.py','Prepare-CompactNormalTiming.py','Register-CompactNormalTiming.ps1','Run-CompactNormal.ps1','Preserve-CompactNormalPreflight.ps1','Scenarios-compact-normal-storage.cs.txt','COMPACT-TERMINAL-NORMAL-PROTOCOL.md','Audit-Callers.ps1','CallerAudit.cs.txt','Inspect-Code.ps1','Summarize-Native.py','Host-Lock.ps1','Lab-LocalClient.ps1','Preserve.py','Verify-Evidence.py')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 $allTraces=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'p39-normal-storage/traces') -File|ForEach-Object{@{file=$_.Name;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash;record=(Get-Content -LiteralPath $_.FullName -Raw|ConvertFrom-Json)}})
 if($allTraces.Count -ne 7){throw 'Expected initial failed plus six successful storage preflight traces'}
 $allTraces|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-normal-initial-storage-traces.json')
 foreach($name in @('p39-normal-preflight.json','p39-normal-storage-preflight.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $name) -Destination (Join-Path $PSScriptRoot $name)}
 $argsList=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase32','--content-addressed')
 foreach($prefix in @('p39-normal','p39n','bundles/p39n','caller-audit-p39normal','native-summary-phase32','p39-source-origin.json','p39-source-review.diff','p39-prerequisite-audit.json','compact-terminal-source','compact-leaf13-source')){$argsList+=@('--include-prefix',$prefix)}
 & python @argsList
 if($LASTEXITCODE -ne 0){throw 'Compact normal prerequisite preservation failed'}
 $argsList=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase32','--prerequisites-only')
 foreach($required in @('p39-normal/catalog-export.json','p39-normal/plans.json','p39-normal/frozen-dependencies.json','p39-normal-preflight.json','p39-normal-storage-preflight.json','p39-normal-initial-storage-traces.json','p39n0-validate.json','p39n0-validate-error.log','p39n-initial-failure-driver-source/Generate-CompactNormal.py','p39n2-source/Program.cs','p39n3-source/Program.cs','bundles/p39n2/CompactNormal.dll','bundles/p39n3/CompactNormal.dll','caller-audit-p39normalstorage.json','caller-audit-p39normalstorage-library.json','caller-audit-p39normalstorage/out/Audit.dll','native-summary-phase32-normal-storage.json','p39-normal-preflight-driver-source/Run-CompactNormal.ps1')){$argsList+=@('--require',$required)}
 & python @argsList
 if($LASTEXITCODE -ne 0){throw 'Compact normal prerequisite archive verification failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
