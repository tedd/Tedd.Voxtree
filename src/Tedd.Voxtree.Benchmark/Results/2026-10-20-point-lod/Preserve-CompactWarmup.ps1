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
 & python (Join-Path $PSScriptRoot 'Audit-CompactWarmup.py') $TaskRoot
 if($LASTEXITCODE -ne 0){throw 'Original warmup diagnostic audit failed; retain producer outputs'}
 $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-warmup-audit.json') -Raw|ConvertFrom-Json -Depth 90
 $root=Join-Path $TaskRoot 'p39-warmup';$created=Get-Content -LiteralPath (Join-Path $root 'hypothesis.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $artifact=Import-File (Join-Path $TaskRoot 'p39-warmup-audit.json') application/json
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism+' Supported qualification is optimized-code availability under this new priming regime only; old latency cause remains unresolved.';prediction=$prior.prediction;state='supported';evidence_ids=@($prior.evidence_ids)+@($artifact.id)}
 $request|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
 $response=Invoke-Lab lab.experiment $request
 $response|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
 $snapshot=Join-Path $TaskRoot 'p39-warmup-audit-driver-source';if(Test-Path -LiteralPath $snapshot){throw 'Original warmup audit snapshot exists'};New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in @('Audit-CompactWarmup.py','Preserve-CompactWarmup.ps1','COMPACT-WARMUP-PROTOCOL.md','Preserve.py','Verify-Evidence.py')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 foreach($n in @('p39-warmup-audit.json','native-summary-phase34-warmup.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase34','--content-addressed')
 foreach($prefix in @('p39-warmup','p39w','bundles/p39w','native-summary-phase34-warmup.json','p39-normal-preflight.json')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Original warmup evidence preservation failed'}
 $arguments=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase34','--prerequisites-only')
 foreach($required in @('p39-warmup/catalog-export.json','p39-warmup/inputs.json','p39-warmup/frozen-bundles.json','p39-warmup/disposition-revision-response.json','p39-warmup-audit.json','native-summary-phase34-warmup.json','p39-warmup-probe-source/Program.cs','p39-warmup-driver-source/Run-CompactWarmupDiagnostic.ps1','p39-warmup-audit-driver-source/Audit-CompactWarmup.py','bundles/p39w0/CompactNormal.dll','bundles/p39w1/CompactNormal.dll','bundles/p39w0/CompactWarmup.dll','bundles/p39w1/CompactWarmup.dll')){$arguments+=@('--require',$required)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Original warmup evidence verification failed'}
 $response|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
