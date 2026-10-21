param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$frozen=@{};foreach($n in @('COMPACT-WARMUP-PROTOCOL.md','CompactWarmup.cs.txt','Summarize-Native.py','Host-Lock.ps1','Lab-LocalClient.ps1')){$frozen[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 foreach($n in $frozen.Keys){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Queued warmup dependency changed'}}
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
 if((Get-Content -LiteralPath (Join-Path $TaskRoot 'global.json') -Raw|ConvertFrom-Json).sdk.version -ne '11.0.100-rc.2.26504.105'){throw 'Pinned compiler changed'}
 $root=Join-Path $TaskRoot 'p39-warmup';$source=Join-Path $TaskRoot 'p39-warmup-probe-source'
 if((Test-Path -LiteralPath $root) -or (Test-Path -LiteralPath $source)){throw 'Original warmup diagnostic exists; inspect its accepted state'}
 $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-normal-preflight.json') -Raw|ConvertFrom-Json -Depth 90
 if(-not $gate.passed -or $gate.fixtureVersion -ne '25'){throw 'Original exact modules not validated'}
 foreach($b in $gate.bundles){foreach($f in $b.files){if((Get-FileHash -LiteralPath $f.path).Hash.ToLowerInvariant() -ne $f.sha256){throw 'Original module closure changed'}}}
 New-Item -ItemType Directory -Path $root,$source|Out-Null
 & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
 if($LASTEXITCODE -ne 0){throw 'New warmup diagnostic catalog initialization failed'}
 $cases=@(foreach($mode in @('Classic32','Generic16','Generic32')){$gate.descriptors|Where-Object{$_.id -eq "compact-normal-$mode-D-from"}})
 if($cases.Count -ne 3){throw 'Exact dominant-data FromEncoded descriptors unavailable'}
 @{scope='Exact original modules, additional invocation warmup and actual code only; no comparative timing';originalPreflightSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p39-normal-preflight.json')).Hash;protocol=(Get-Content -LiteralPath (Join-Path $PSScriptRoot 'COMPACT-WARMUP-PROTOCOL.md') -Raw);protocolSha256=$frozen['COMPACT-WARMUP-PROTOCOL.md'];helperSourceSha256=$frozen['CompactWarmup.cs.txt'];originalBundles=$gate.bundles;cases=$cases;processBudget=6;minimumAdditionalCalls=4096;minimumAdditionalMilliseconds=3000;timeoutSeconds=90;comparativeTimingRecords=0}|ConvertTo-Json -Depth 90|Set-Content -LiteralPath (Join-Path $root 'inputs.json')
 $a=Import-File (Join-Path $root 'inputs.json') application/json
 $hyp=Invoke-Lab lab.experiment @{action='create_hypothesis';mechanism='Exact original P39N FromEncoded modules after explicit additional invocation/duration priming may reach optimized caller coverage missing from500ms diagnostics. P39 reduces recursive call counts; tier history and persistent generated-code cost are competing explanations for retained slower materialization despite faster validation.';prediction='Fixed six diagnostic processes: all three original modes in both modules will expose complete Tier1 RunFrom and ValidateCube after at least4096 additional calls and3000ms, with original full independent output oracle. Missing code falsifies coverage prediction. No timing/cause/adoption claim, source edit, stopped-family resume, pooling or replacement.';evidence_ids=@($a.id)}
 $hyp|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis.json')
 Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'CompactWarmup.cs.txt') -Destination (Join-Path $source 'Program.cs')
 $references=@();foreach($f in $gate.bundles[0].files|Where-Object{$_.name.EndsWith('.dll')}){$path=[Security.SecurityElement]::Escape($f.path.Replace('\','/'));$name=[IO.Path]::GetFileNameWithoutExtension($f.name);$references+=@("<Reference Include=`"$name`"><HintPath>$path</HintPath></Reference>")}
 @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><AssemblyName>CompactWarmup</AssemblyName><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><LangVersion>14.0</LangVersion><Optimize>true</Optimize><UseSharedCompilation>false</UseSharedCompilation><Deterministic>true</Deterministic><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup>$($references -join '')</ItemGroup></Project>
"@|Set-Content -LiteralPath (Join-Path $source 'Probe.csproj')
 Push-Location $TaskRoot
 try{& $dotnet build (Join-Path $source 'Probe.csproj') -c Release --artifacts-path (Join-Path $TaskRoot 'artifacts/p39-warmup') -p:ImportDirectoryBuildProps=false -p:ImportDirectoryBuildTargets=false -v minimal *> (Join-Path $root 'build.log');if($LASTEXITCODE -ne 0){Get-Content -LiteralPath (Join-Path $root 'build.log') -Tail 15;throw 'Original warmup helper build failed; preserve producer'}}finally{Pop-Location}
 $out=Join-Path $TaskRoot 'artifacts/p39-warmup/bin/Probe/release';$bundles=@()
 foreach($i in 0,1){
  $label="p39w$i";$dest=Join-Path $TaskRoot "bundles/$label";if(Test-Path -LiteralPath $dest){throw 'Original diagnostic bundle exists'};New-Item -ItemType Directory -Path $dest|Out-Null
  foreach($name in @('CompactWarmup.dll','CompactWarmup.deps.json','CompactWarmup.runtimeconfig.json')){Copy-Item -LiteralPath (Join-Path $out $name) -Destination $dest}
  foreach($f in $gate.bundles[$i].files|Where-Object{$_.name.EndsWith('.dll')}){Copy-Item -LiteralPath $f.path -Destination $dest;if((Get-FileHash -LiteralPath (Join-Path $dest $f.name)).Hash.ToLowerInvariant() -ne $f.sha256){throw 'Original binary staging mismatch'}}
  $bundles+=@(@{label=$label;files=@(Get-ChildItem -LiteralPath $dest -File|Get-FileHash|Select-Object Path,Hash)})
 }
 $bundles|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'frozen-bundles.json')
 $snapshot=Join-Path $TaskRoot 'p39-warmup-driver-source';New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($name in @('Run-CompactWarmupDiagnostic.ps1','COMPACT-WARMUP-PROTOCOL.md','CompactWarmup.cs.txt','Host-Lock.ps1','Lab-LocalClient.ps1','Summarize-Native.py')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination $snapshot}
 @{pid=$PID;startUtc=[DateTimeOffset]::UtcNow.ToString('o');driverSha256=(Get-FileHash -LiteralPath $PSCommandPath).Hash;processBudget=6;comparativeTimingRecords=0}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'driver-start.json')
 $files=@()
 foreach($case in $cases){foreach($i in 0,1){
  $label="p39w$i-$($case.spec.Mode)-from";$bundle=Join-Path $TaskRoot "bundles/p39w$i";$entry=Join-Path $bundle 'CompactWarmup.dll';$asm=Join-Path $TaskRoot "$label.asm";$files+=@("$label.asm")
  if(Test-Path -LiteralPath $asm){throw 'Original diagnostic output exists'}
  $start=[Diagnostics.ProcessStartInfo]::new($dotnet);foreach($arg in @('exec','--fx-version','10.0.13',$entry,$case.id,$case.input_hash)){$start.ArgumentList.Add($arg)}
  $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
  $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP'];$start.Environment['DOTNET_JitDisasm']='*RunFrom* *ValidateCube* *FromEncoded*';$start.Environment['DOTNET_JitDisasmAssemblies']='CompactNormal';$start.Environment['DOTNET_JitStdOutFile']=$asm
  $p=[Diagnostics.Process]::Start($start);$ticks=[string]$p.StartTime.ToUniversalTime().Ticks
  @{pid=$p.Id;startTicks=$ticks;scenario=$case.id;inputHash=$case.input_hash;helperSha256=(Get-FileHash -LiteralPath $entry).Hash;librarySha256=(Get-FileHash -LiteralPath (Join-Path $bundle 'CompactNormal.dll')).Hash;regime='external exact-binary additional-warmup JIT diagnostic; no quiet timing';runtime='10.0.13'}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root "$label-identity.json")
  $stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$timedOut=-not $p.WaitForExit(90000)
  if($timedOut){$p.Kill($true);if(-not $p.WaitForExit(10000)){throw 'Owned diagnostic termination unknown'}}
  $stdout.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root "$label-output.log");$stderr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root "$label-error.log")
  @{pid=$p.Id;startTicks=$ticks;joined=$p.HasExited;exitCode=$p.ExitCode;timedOut=$timedOut}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root "$label-shutdown.json")
  if($timedOut -or $p.ExitCode -ne 0){throw 'Original warmup diagnostic process failed; stop without replacement'}
  Write-Output "$label original-module code complete"
 }}
 & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase34-warmup --files @files
 if($LASTEXITCODE -ne 0){throw 'Original warmup native indexing failed'}
 @{processes=6;joined=$true;comparativeTimingRecords=0;finishedUtc=[DateTimeOffset]::UtcNow.ToString('o')}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'driver-completed.json')
}catch{if($root -and (Test-Path -LiteralPath $root)){$_.Exception.ToString()|Set-Content -LiteralPath (Join-Path $root 'driver-failure.log')};throw}finally{Exit-VoxtreePerformanceHost $lease}
