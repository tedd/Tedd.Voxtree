param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
 $root=Join-Path $TaskRoot 'p39-normal'
 $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-normal-family-audit.json') -Raw|ConvertFrom-Json -Depth 90
 if(-not $audit.complete -or $audit.completed_cases -ne 107 -or $audit.distinct_process_start_identities -ne 2568 -or $audit.joined_controllers -ne 107 -or $audit.cleaned_timing_storage_roots -ne 72){throw 'Original compact normal family incomplete; retain original operation state'}
 $path=Join-Path $TaskRoot 'p39-normal-family-disposition.json'
 if(Test-Path -LiteralPath $path){throw 'Original disposition exists; inspect accepted state'}
 @{state=$audit.disposition;complete=$true;cases=107;sessions=2568;primaryFutilityCount=$audit.primary_futility_count;guardedHarmCount=$audit.guarded_harm_count;promotionEligible=$false;sourceAdoption=$false;scope='P39/P31-local first normal family only. Original interval/allocation policies unchanged. P31 remains unpromoted; original-release/consumer/full API/memory/format/allocation/original10x qualification remain open.'}|ConvertTo-Json|Set-Content -LiteralPath $path
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $evidence=@();foreach($file in @($path,(Join-Path $TaskRoot 'p39-normal-family-audit.json'))){$evidence+=@((Import-File $file application/json).id)}
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$audit.disposition;evidence_ids=@($prior.evidence_ids)+$evidence}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
 $snapshot=Join-Path $TaskRoot 'p39-normal-family-driver-source'
 if(Test-Path -LiteralPath $snapshot){throw 'Original family audit source snapshot exists'}
 New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in @('Audit-CompactNormalFamily.py','Preserve-CompactNormalFamily.ps1','Run-CompactNormal.ps1','COMPACT-TERMINAL-NORMAL-PROTOCOL.md','Host-Lock.ps1','Lab-LocalClient.ps1','Preserve.py','Verify-Evidence.py')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 foreach($n in @('p39-normal-family-audit.json','p39-normal-family-disposition.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $argsList=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase33','--content-addressed')
 foreach($prefix in @('p39-normal','p39n2','p39n3','bundles/p39n2','bundles/p39n3','caller-audit-p39normalstorage','native-summary-phase32-normal-storage.json')){$argsList+=@('--include-prefix',$prefix)}
 & python @argsList
 if($LASTEXITCODE -ne 0){throw 'Compact normal family preservation failed; preserve original evidence'}
 $argsList=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase33')
 foreach($required in @('p39-normal/catalog-export.json','p39-normal/disposition-revision-response.json','p39-normal/run-driver-start.json','p39-normal/run-driver-completed.json','p39-normal-family-audit.json','p39-normal-family-disposition.json','p39-normal-family-driver-source/Audit-CompactNormalFamily.py','bundles/p39n2/CompactNormal.dll','bundles/p39n3/CompactNormal.dll','native-summary-phase32-normal-storage.json')){$argsList+=@('--require',$required)}
 foreach($item in @(Get-Content -LiteralPath (Join-Path $root 'plans.json') -Raw|ConvertFrom-Json -Depth 90)){
  foreach($suffix in @('-operation','-terminal','-execution','-sessions','-objective_vector','-controller-shutdown')){$argsList+=@('--require',"p39-normal/$($item.scenario)$suffix.json")}
 }
 & python @argsList
 if($LASTEXITCODE -ne 0){throw 'Compact normal family archive verification failed'}
 $verified=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase33-verified.json') -Raw|ConvertFrom-Json
 if($verified.metric_rows -ne 214){throw 'Expected exactly214 inferential time/allocation rows'}
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
