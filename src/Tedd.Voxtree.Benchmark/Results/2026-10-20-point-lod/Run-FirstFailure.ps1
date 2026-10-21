param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
$preparation=$null;$activeWorker=$null
try{
 $preparation=Enter-VoxtreePerformanceHost
 $main=Join-Path $TaskRoot 'p39-first-failure'
 if((Test-Path -LiteralPath (Join-Path $main 'driver-start.json')) -or (Get-ChildItem -LiteralPath $main -Filter 'worker-accepted.json' -Recurse).Count -gt 0){throw 'Original diagnostic producer exists; inspect accepted operations'}
 if(-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase35a-verified.json'))){throw 'Frozen diagnostic prerequisites not archived'}
 $frozen=Get-Content -LiteralPath (Join-Path $main 'frozen-dependencies.json') -Raw|ConvertFrom-Json -AsHashtable
 foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Frozen diagnostic driver changed'}}
 $inputs=Get-Content -LiteralPath (Join-Path $main 'inputs.json') -Raw|ConvertFrom-Json -Depth 90
 foreach($b in $inputs.controllerClosures){foreach($f in $b.files){if((Get-FileHash -LiteralPath $f.path).Hash -ne $f.sha256){throw 'Frozen diagnostic controller closure changed'}}}
 $plans=@(Get-Content -LiteralPath (Join-Path $main 'plans.json') -Raw|ConvertFrom-Json -Depth 90);if($plans.Count -ne 5){throw 'Expected all five frozen tests'}
 @{pid=$PID;startUtc=[DateTimeOffset]::UtcNow.ToString('o');driverSha256=(Get-FileHash -LiteralPath $PSCommandPath).Hash;tests=5;maximumTargetLaunches=28;maximumDiagnosticMeasuredSessions=25;comparativeTimingRecords=0}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $main 'driver-start.json')
 Exit-VoxtreePerformanceHost $preparation;$preparation=$null
 foreach($item in $plans){
  $preparation=Enter-VoxtreePerformanceHost
  $originalHost=Join-Path $TaskRoot 'coldlog-controller-source/logged2-out/Tedd.DotNetLab.Host.dll'
  $raw=& dotnet exec --fx-version 10.0.13 $originalHost grant-confirmation $item.root $item.plan.id 600 24
  if($LASTEXITCODE -ne 0){throw 'Exact diagnostic launch grant failed'}
  $grant=$raw|ConvertFrom-Json;$raw|Set-Content -LiteralPath (Join-Path $item.root 'grant.json')
  $bundle=Join-Path $TaskRoot "bundles/$($item.test.controller)";$entry=Join-Path $bundle 'FirstFailureWorker.dll'
  $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
  foreach($arg in @('exec','--fx-version','10.0.13',$entry,$item.root,$item.plan.id,$grant.id,('P39F-'+$item.test.name),$item.test.hold)){$start.ArgumentList.Add($arg)}
  $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true;$start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
  Exit-VoxtreePerformanceHost $preparation;$preparation=$null
  $activeWorker=[Diagnostics.Process]::Start($start);$ticks=[string]$activeWorker.StartTime.ToUniversalTime().Ticks
  @{pid=$activeWorker.Id;startTicks=$ticks;workerSha256=(Get-FileHash -LiteralPath $entry).Hash;applicationSha256=(Get-FileHash -LiteralPath (Join-Path $bundle 'Tedd.DotNetLab.Application.dll')).Hash;runtime='10.0.13';test=$item.test.name}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $item.root 'worker-identity.json')
  $stdout=$activeWorker.StandardOutput.ReadToEndAsync();$stderr=$activeWorker.StandardError.ReadToEndAsync();$watch=[Diagnostics.Stopwatch]::StartNew()
  while(-not $activeWorker.WaitForExit(1000)){if($watch.Elapsed.TotalSeconds -gt 200){break}}
  $timedOut=-not $activeWorker.HasExited
  if($timedOut){$activeWorker.Kill($true);if(-not $activeWorker.WaitForExit(10000)){throw 'Owned diagnostic worker quiescence unknown'}}
  $stdout.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $item.root 'worker-output.log');$stderr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $item.root 'worker-error.log')
  @{pid=$activeWorker.Id;startTicks=$ticks;joined=$activeWorker.HasExited;exitCode=$activeWorker.ExitCode;timedOut=$timedOut}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $item.root 'worker-shutdown.json')
  if($timedOut -or $activeWorker.ExitCode -ne 0){throw 'Original diagnostic worker failed; inspect accepted operation and stop study'}
  $activeWorker=$null;$preparation=Enter-VoxtreePerformanceHost
  & python (Join-Path $PSScriptRoot 'Check-FirstFailureCase.py') $item.root *> (Join-Path $item.root 'case-check.log')
  if($LASTEXITCODE -ne 0){Get-Content -LiteralPath (Join-Path $item.root 'case-check.log') -Tail 10;throw 'Original deterministic test differed from frozen prediction; stop without replacement'}
  $audit=Get-Content -LiteralPath (Join-Path $item.root 'case-audit.json') -Raw|ConvertFrom-Json -Depth 90
  $checks=@(foreach($launch in $audit.launches){$p=Get-Process -Id $launch.process_id -ErrorAction SilentlyContinue;$same=$p -and ([string]$p.StartTime.ToUniversalTime().Ticks -eq [string]$launch.start_time_utc_ticks);if($same){throw 'Original target remains live'};@{pid=$launch.process_id;startTicks=$launch.start_time_utc_ticks;originalProcessNotLive=$true}})
  $checks|ConvertTo-Json -Depth 30 -AsArray|Set-Content -LiteralPath (Join-Path $item.root 'quiescence.json')
  Write-Output "$($item.test.name): frozen deterministic prediction passed"
  Exit-VoxtreePerformanceHost $preparation;$preparation=$null
 }
 $preparation=Enter-VoxtreePerformanceHost
 @{tests=5;allPredictionsPassed=$true;maximumTargetLaunches=28;maximumDiagnosticMeasuredSessions=25;comparativeTimingRecords=0;finishedUtc=[DateTimeOffset]::UtcNow.ToString('o')}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $main 'driver-completed.json')
}catch{if($main -and (Test-Path -LiteralPath $main)){$_.Exception.ToString()|Set-Content -LiteralPath (Join-Path $main 'driver-failure.log')};throw}finally{
 if($activeWorker -and -not $activeWorker.HasExited){Write-Output 'Owned worker still active; preserve original process/operation identity for inspection'}
 if($preparation){Exit-VoxtreePerformanceHost $preparation};Exit-VoxtreePerformanceHost $leases
}
