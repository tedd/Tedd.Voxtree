param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 $native=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-native-p39g0-selftest.json') -Raw|ConvertFrom-Json
 $absent=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-logger-p39g0-selftest.json') -Raw|ConvertFrom-Json
 if(-not $native.joined -or $native.exitCode -ne 0 -or -not $absent.joined -or $absent.exitCode -eq 0 -or -not ((Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-logger-p39g0-selftest-error.log') -Raw).Contains('New logger absent'))){throw 'Original preflight identities or failure not retained'}
 $bundles=@(Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-native-controller-bundles.json') -Raw|ConvertFrom-Json -Depth 50)
 foreach($b in $bundles){foreach($f in $b.files){if((Get-FileHash -LiteralPath $f.path).Hash -ne $f.sha256){throw 'Original native controller closure changed'}}}
 foreach($mode in @('native','logger')){
  $label="p39-first-failure-$mode-p39g1-selftest";$output=Join-Path $TaskRoot "$label.json";if(Test-Path -LiteralPath $output){throw 'Original new-arm preflight exists; inspect it without restart'}
  $entry=Join-Path $TaskRoot 'bundles/p39g1/FirstFailureWorker.dll';$start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
  foreach($arg in @('exec','--fx-version','10.0.13',$entry,"--$mode-selftest")){$start.ArgumentList.Add($arg)}
  $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true;$start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
  $p=[Diagnostics.Process]::Start($start);$ticks=[string]$p.StartTime.ToUniversalTime().Ticks;$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync()
  if(-not $p.WaitForExit(30000)){$p.Kill($true);$p.WaitForExit();throw 'Owned remaining preflight exceeded ceiling'}
  $stdout.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$label.log");$stderr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-error.log")
  @{pid=$p.Id;startTicks=$ticks;joined=$p.HasExited;exitCode=$p.ExitCode;workerSha256=(Get-FileHash -LiteralPath $entry).Hash;mode=$mode}|ConvertTo-Json|Set-Content -LiteralPath $output
  if($p.ExitCode -ne 0){throw 'Original remaining preflight failed; preserve result without replacement'}
 }
 Write-Output 'Remaining two preflights passed; original native pass and old-logger absence failure retained separately'
}finally{Exit-VoxtreePerformanceHost $lease}
