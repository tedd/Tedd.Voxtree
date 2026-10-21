param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$workerHash=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'FirstFailureNativeWorker.cs.txt')).Hash
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'FirstFailureNativeWorker.cs.txt')).Hash -ne $workerHash){throw 'Queued native worker changed'}
 $stop=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-startup-stop.json') -Raw|ConvertFrom-Json
 if(-not $stop.noTargetOperationAccepted -or -not $stop.noTargetLaunched){throw 'Original pre-execution state unverified'}
 $source=Join-Path $TaskRoot 'first-failure-native-worker-source';if(Test-Path -LiteralPath $source){throw 'Original native worker source exists'};New-Item -ItemType Directory -Path $source|Out-Null
 Copy-Item -LiteralPath (Join-Path $TaskRoot 'first-failure-worker2-source/Worker.csproj') -Destination $source
 Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'FirstFailureNativeWorker.cs.txt') -Destination (Join-Path $source 'Program.cs')
 $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
 Push-Location $TaskRoot
 try{& dotnet build (Join-Path $source 'Worker.csproj') -c Release --artifacts-path (Join-Path $TaskRoot 'artifacts/p39-first-failure-native-worker') -p:ImportDirectoryBuildProps=false -p:ImportDirectoryBuildTargets=false -v minimal *> (Join-Path $TaskRoot 'p39-first-failure-native-worker-build.log');if($LASTEXITCODE -ne 0){Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-native-worker-build.log') -Tail 15;throw 'Original native worker build failed; preserve producer'}}finally{Pop-Location}
 $out=Join-Path $TaskRoot 'artifacts/p39-first-failure-native-worker/bin/Worker/release';$bundles=@()
 foreach($i in 0,1){
  $old=Join-Path $TaskRoot "bundles/p39f$i";$dest=Join-Path $TaskRoot "bundles/p39g$i";if(Test-Path -LiteralPath $dest){throw 'Original native-binding controller bundle exists'};New-Item -ItemType Directory -Path $dest|Out-Null
  foreach($item in Get-ChildItem -LiteralPath $old -Force){Copy-Item -LiteralPath $item.FullName -Destination $dest -Recurse}
  foreach($name in @('FirstFailureWorker.dll','FirstFailureWorker.deps.json','FirstFailureWorker.runtimeconfig.json')){Copy-Item -LiteralPath (Join-Path $out $name) -Destination $dest}
  foreach($file in Get-ChildItem -LiteralPath $old -File -Recurse){$relative=[IO.Path]::GetRelativePath($old,$file.FullName);if($relative -notin @('FirstFailureWorker.dll','FirstFailureWorker.deps.json','FirstFailureWorker.runtimeconfig.json') -and (Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath (Join-Path $dest $relative)).Hash){throw 'Only helper files may differ from original diagnostic copy'}}
  $bundles+=@(@{label="p39g$i";files=@(Get-ChildItem -LiteralPath $dest -File -Recurse|ForEach-Object{@{name=[IO.Path]::GetRelativePath($dest,$_.FullName);path=$_.FullName;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}})})
 }
 $bundles|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-native-controller-bundles.json')
 foreach($i in 0,1){foreach($mode in @('native','logger')){
  $label="p39-first-failure-$mode-p39g$i-selftest";$entry=Join-Path $TaskRoot "bundles/p39g$i/FirstFailureWorker.dll"
  $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source);foreach($arg in @('exec','--fx-version','10.0.13',$entry,"--$mode-selftest")){$start.ArgumentList.Add($arg)}
  $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true;$start.Environment['TEMP']=$env:TEMP;$start.Environment['TMP']=$env:TMP
  $p=[Diagnostics.Process]::Start($start);$ticks=[string]$p.StartTime.ToUniversalTime().Ticks;$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync()
  if(-not $p.WaitForExit(30000)){$p.Kill($true);$p.WaitForExit();throw 'Owned native/logger preflight exceeded ceiling'}
  $stdout.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$label.log");$stderr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-error.log")
  @{pid=$p.Id;startTicks=$ticks;joined=$p.HasExited;exitCode=$p.ExitCode;workerSha256=(Get-FileHash -LiteralPath $entry).Hash;mode=$mode}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot "$label.json")
  if($p.ExitCode -ne 0){throw 'Original native/logger preflight failed; stop without replacement'}
 }}
 Write-Output 'Four original native/logger preflights passed; no database or target opened'
}finally{Exit-VoxtreePerformanceHost $lease}
