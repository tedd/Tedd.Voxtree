param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$frozen=@{};foreach($n in @('Prepare-FirstFailure.py','FIRST-FAILURE-PROTOCOL.md','NormalSessionPrimaryFailure.cs.txt','FirstFailureWorker.cs.txt')){$frozen[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Queued failure-diagnostic dependency changed'}}
 if((Get-Content -LiteralPath (Join-Path $TaskRoot 'global.json') -Raw|ConvertFrom-Json).sdk.version -ne '11.0.100-rc.2.26504.105'){throw 'Pinned compiler changed'}
 $initial=Join-Path $TaskRoot 'first-failure-worker-source'
 $source=Join-Path $TaskRoot 'first-failure-worker2-source'
 if(Test-Path -LiteralPath $source){throw 'Corrected worker source exists; preserve original producer'}
 $log=Join-Path $TaskRoot 'p39-first-failure-worker-build.log'
 if(-not ((Get-Content -LiteralPath $log -Raw).Contains('CS0136'))){throw 'Original pre-execution compiler failure not retained'}
 $before=Get-Content -LiteralPath (Join-Path $initial 'Program.cs') -Raw
 $after=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'FirstFailureWorker.cs.txt') -Raw
 if($before.Replace('const string prefix=','const string logPrefix=').Replace('StartsWith(prefix)','StartsWith(logPrefix)').Replace('text[prefix.Length..]','text[logPrefix.Length..]') -ne $after){throw 'Expected only logger-prefix local rename'}
 New-Item -ItemType Directory -Path $source|Out-Null
 Copy-Item -LiteralPath (Join-Path $initial 'Worker.csproj') -Destination $source
 Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'FirstFailureWorker.cs.txt') -Destination (Join-Path $source 'Program.cs')
 @{originalWorkerSourceSha256=(Get-FileHash -LiteralPath (Join-Path $initial 'Program.cs')).Hash;correctedWorkerSourceSha256=(Get-FileHash -LiteralPath (Join-Path $source 'Program.cs')).Hash;originalBuildLogSha256=(Get-FileHash -LiteralPath $log).Hash;change='Rename selftest logger-prefix local only; no target launched by original failed build';applicationRebuilt=$false}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-worker-repair.json')
 $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
 Push-Location $TaskRoot
 try{& dotnet build (Join-Path $source 'Worker.csproj') -c Release --artifacts-path (Join-Path $TaskRoot 'artifacts/p39-first-failure-worker2') -p:ImportDirectoryBuildProps=false -p:ImportDirectoryBuildTargets=false -v minimal *> (Join-Path $TaskRoot 'p39-first-failure-worker2-build.log');if($LASTEXITCODE -ne 0){Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-worker2-build.log') -Tail 15;throw 'Corrected worker build failed; preserve identity'}}finally{Pop-Location}
 $original=Join-Path $TaskRoot 'coldlog-controller-source/logged2-out'
 $patch=Join-Path $TaskRoot 'artifacts/p39-first-failure-application/bin/Application/release/Tedd.DotNetLab.Application.dll'
 $helper=Join-Path $TaskRoot 'artifacts/p39-first-failure-worker2/bin/Worker/release'
 $records=@()
 foreach($i in 0,1){
  $dest=Join-Path $TaskRoot "bundles/p39f$i";if(Test-Path -LiteralPath $dest){throw 'Original diagnostic controller bundle exists'};New-Item -ItemType Directory -Path $dest|Out-Null
  foreach($item in Get-ChildItem -LiteralPath $original -Force){if($item.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Controller source contains reparse point'};Copy-Item -LiteralPath $item.FullName -Destination $dest -Recurse}
  foreach($name in @('FirstFailureWorker.dll','FirstFailureWorker.deps.json','FirstFailureWorker.runtimeconfig.json')){Copy-Item -LiteralPath (Join-Path $helper $name) -Destination $dest}
  if($i -eq 1){Copy-Item -LiteralPath $patch -Destination (Join-Path $dest 'Tedd.DotNetLab.Application.dll')}
  $files=@(Get-ChildItem -LiteralPath $dest -File -Recurse|ForEach-Object{@{name=[IO.Path]::GetRelativePath($dest,$_.FullName);path=$_.FullName;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}})
  $records+=@(@{label="p39f$i";files=$files})
 }
 $a=@{};foreach($f in $records[0].files){$a[$f.name]=$f.sha256};$b=@{};foreach($f in $records[1].files){$b[$f.name]=$f.sha256}
 if(@($a.Keys|Where-Object{$a[$_] -ne $b[$_]}).Count -ne 1 -or $a['Tedd.DotNetLab.Application.dll'] -eq $b['Tedd.DotNetLab.Application.dll']){throw 'Expected only Application.dll delta in full controller closure'}
 $records|ConvertTo-Json -Depth 35|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-controller-bundles.json')
 $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source);foreach($arg in @('exec','--fx-version','10.0.13',(Join-Path $TaskRoot 'bundles/p39f1/FirstFailureWorker.dll'),'--logger-selftest')){$start.ArgumentList.Add($arg)}
 $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true;$start.Environment['TEMP']=$env:TEMP;$start.Environment['TMP']=$env:TMP
 $p=[Diagnostics.Process]::Start($start);$ticks=[string]$p.StartTime.ToUniversalTime().Ticks;$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync()
 if(-not $p.WaitForExit(30000)){$p.Kill($true);$p.WaitForExit();throw 'Owned logger selftest exceeded ceiling'}
 $stdout.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-logger-selftest.log');$stderr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-logger-selftest-error.log')
 @{pid=$p.Id;startTicks=$ticks;joined=$p.HasExited;exitCode=$p.ExitCode;workerSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'bundles/p39f1/FirstFailureWorker.dll')).Hash;applicationSha256=$b['Tedd.DotNetLab.Application.dll']}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-logger-selftest.json')
 if($p.ExitCode -ne 0){throw 'Original logger selftest failed'}
 Write-Output 'Diagnostic controller closure differs only in Application.dll; bounded/writer-failure logger selftests passed'
}finally{Exit-VoxtreePerformanceHost $lease}
