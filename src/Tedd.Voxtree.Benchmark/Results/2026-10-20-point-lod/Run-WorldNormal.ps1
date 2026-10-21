param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
$preparation=$null;$controller=$null;$sequence=0;$operationActive=$false;$submissionUnknown=$false
$root=Join-Path $TaskRoot 'p36-normal-screen';$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
function Close-OwnedNormalController([string]$Scenario){
 if(-not $controller){return}
 if($operationActive -or $submissionUnknown){throw 'Unresolved operation/acceptance; inspect original journal before shutdown'}
 if(-not $controller.HasExited){$controller.StandardInput.Close();if(-not $controller.WaitForExit(30000)){throw 'Owned normal controller did not join'}}
 $controllerErrors.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root ($Scenario+'-controller.log'))
 @{pid=$controller.Id;startTicks=$controllerStartTicks;joined=$controller.HasExited;exitCode=$controller.ExitCode}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root ($Scenario+'-controller-shutdown.json'))
}
try{
 $preparation=Enter-VoxtreePerformanceHost
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated isolated controller changed'}
 if(-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase27-verified.json'))){throw 'Normal preflight archive not verified'}
 if((Test-Path -LiteralPath (Join-Path $root 'run-driver-start.json')) -or @(Get-ChildItem -LiteralPath $root -Filter '*-operation.json').Count -ne 0){throw 'Original normal family exists; inspect accepted operations without restart'}
 $frozen=Get-Content -LiteralPath (Join-Path $root 'frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
 foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Frozen normal dependency changed'}}
 $inputs=Get-Content -LiteralPath (Join-Path $root 'inputs.json') -Raw|ConvertFrom-Json -Depth 80
 foreach($bundle in $inputs.bundles){foreach($f in $bundle.files){if((Get-FileHash -LiteralPath $f.path).Hash.ToLowerInvariant() -ne $f.sha256){throw 'Frozen normal artifact changed'}}}
 $plans=@(Get-Content -LiteralPath (Join-Path $root 'plans.json') -Raw|ConvertFrom-Json -Depth 90);if($plans.Count -ne 12){throw 'Expected complete first normal family'}
 $snapshot=Join-Path $root 'run-driver-source';New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in @('Run-WorldNormal.ps1','Lab-LocalClient.ps1','Host-Lock.ps1','WORLD-NORMAL-PROTOCOL.md')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 @{pid=$PID;startUtc=[DateTimeOffset]::UtcNow.ToString('o');driverSha256=(Get-FileHash -LiteralPath $PSCommandPath).Hash;cases=12;maximumSessions=288;sourceSelectedBeforeData=$true}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'run-driver-start.json')
 Exit-VoxtreePerformanceHost $preparation;$preparation=$null
 foreach($item in $plans){
  $preparation=Enter-VoxtreePerformanceHost
  $raw=& $dotnet exec --fx-version 10.0.13 $labHost grant-confirmation $root $item.plan.id 3600 24
  if($LASTEXITCODE -ne 0){throw 'Exact normal launch grant failed'}
  $grant=$raw|ConvertFrom-Json;$raw|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-grant.json'))
  $start=[Diagnostics.ProcessStartInfo]::new($dotnet)
  foreach($arg in @('exec','--fx-version','10.0.13',$labHost,'serve',$root)){$start.ArgumentList.Add($arg)}
  $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardInput=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true;$start.WorkingDirectory=$root
  $controller=[Diagnostics.Process]::Start($start);$controllerErrors=$controller.StandardError.ReadToEndAsync();$controllerStartTicks=[string]$controller.StartTime.ToUniversalTime().Ticks
  @{pid=$controller.Id;startTicks=$controllerStartTicks;entry=$labHost;entrySha256=(Get-FileHash -LiteralPath $labHost).Hash;runtime='10.0.13';workspace=$root}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-controller.json'))
  Invoke-Rpc initialize @{protocolVersion='2025-03-26';capabilities=@{};clientInfo=@{name='voxtree-p36-normal';version='1'}}|Out-Null
  $controller.StandardInput.WriteLine('{"jsonrpc":"2.0","method":"notifications/initialized"}')
  Exit-VoxtreePerformanceHost $preparation;$preparation=$null
  $request=@{action='start_confirmation';plan_id=$item.plan.id;grant_id=$grant.id;idempotency_key='P36-first-'+$item.scenario}
  $request|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-request.json'))
  $submissionUnknown=$true;$op=Invoke-Lab lab.run $request;$submissionUnknown=$false;$operationActive=$true
  $op|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-operation.json'))
  while($op.state -notin 'completed','failed','tainted','cancelled','interrupted','lost'){
   Start-Sleep -Milliseconds 200;$op=Invoke-Lab lab.run @{action='status';operation_id=$op.id}
  }
  $operationActive=$false;$op|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-terminal.json'))
  if($op.result_id){
   $record=Invoke-Lab lab.inspect @{action='record';id=$op.result_id};$record|ConvertTo-Json -Depth 90|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-execution.json'))
   $execution=$record.json|ConvertFrom-Json -Depth 80
   $sessions=@(foreach($id in $execution.session_ids){Invoke-Lab lab.inspect @{action='record';id=$id}})
   $sessions|ConvertTo-Json -Depth 90|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-sessions.json'))
  }
  if($op.state -eq 'completed'){
   $comparison=Invoke-Lab lab.compare @{execution_id=$op.result_id;normal_build_confirmation=$true};$comparison|ConvertTo-Json -Depth 90|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-decision.json'))
   foreach($id in @($comparison.comparison_id,$comparison.objective_vector_id)|Where-Object{$_}){
    $record=Invoke-Lab lab.inspect @{action='record';id=$id};$record|ConvertTo-Json -Depth 90|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-'+$record.kind+'.json'))
   }
  }
  Close-OwnedNormalController $item.scenario;$controller=$null
  Write-Output ($item.scenario+' normal family '+$op.state)
  if($op.state -ne 'completed'){throw 'Normal family stopped at first noncompleted case; retain original evidence'}
 }
 @{cases=$plans.Count;maximumSessions=288;driverExitedNormally=$true;finishedUtc=[DateTimeOffset]::UtcNow.ToString('o')}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'run-driver-completed.json')
}catch{
 $_.Exception.ToString()|Set-Content -LiteralPath (Join-Path $root 'driver-failure.log');throw
}finally{
 if($controller){Close-OwnedNormalController $item.scenario}
 if($preparation){Exit-VoxtreePerformanceHost $preparation}
 Exit-VoxtreePerformanceHost $leases
}
