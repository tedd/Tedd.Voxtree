param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Build-Rig.ps1','Inspect-Code.ps1','Summarize-Native.py','Scenarios-compact-terminal.cs.txt');$frozen=@{}
foreach($n in $names){$frozen[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Queued P39 native dependency changed'}}
 foreach($n in @('p39terminal','p39-terminal-validation.json','p39-terminal-native-identity.json')){if(Test-Path -LiteralPath (Join-Path $TaskRoot $n)){throw 'Original P39 diagnostic producer exists; preserve it'}}
 $results=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p39terminal-results') -Filter '*.trx')
 if($results.Count -ne 3){throw 'Original P39 runtime results incomplete'}
 foreach($r in $results){[xml]$x=Get-Content -LiteralPath $r.FullName;if($x.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$x.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P39 regression failed'}}
 $snapshot=Join-Path $TaskRoot 'p39-native-driver-source';New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in $names){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 Copy-Item -LiteralPath $PSCommandPath -Destination $snapshot
 @{pid=$PID;startUtc=[DateTimeOffset]::UtcNow.ToString('o');driverSha256=(Get-FileHash -LiteralPath $PSCommandPath).Hash;dependencies=$frozen;scope='Original P39 complete semantic fixture plus separate native diagnostic; no comparative timing'}|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-native-driver-start.json')
 & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p39terminal -BaselineSource (Join-Path $TaskRoot 'compact-leaf13-source') -CandidateSource (Join-Path $TaskRoot 'compact-terminal-source') -FixtureName Scenarios-compact-terminal.cs.txt *> (Join-Path $TaskRoot 'p39terminal-build.log')
 $entry=Join-Path $TaskRoot 'bundles/p39terminal/p39terminal.dll'
 $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
 foreach($arg in @('exec','--fx-version','10.0.13',$entry,'--validate')){$start.ArgumentList.Add($arg)}
 $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
 $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
 $p=[Diagnostics.Process]::Start($start);$startTicks=[string]$p.StartTime.ToUniversalTime().Ticks
 $stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$p.WaitForExit()
 $o=$stdout.GetAwaiter().GetResult();$e=$stderr.GetAwaiter().GetResult()
 $o|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-terminal-validation.log');$e|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-terminal-validation-error.log')
 $cases=@($o -split "`n"|Where-Object{$_ -like '* valid*'}).Count
 @{pid=$p.Id;startTicks=$startTicks;entrySha256=(Get-FileHash -LiteralPath $entry).Hash;runtime='10.0.13';exited=$p.HasExited;exitCode=$p.ExitCode;cases=$cases;arms=2;operationsPerCaseArm=2}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-terminal-validation.json')
 if($p.ExitCode -ne 0 -or $cases -ne 96){throw 'Original P39 bulk prefix validation failed'}
 & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot 'bundles/p39terminal') -Label p39-terminal-native -Scenario validate -Methods '*ValidateCube* *IsWellFormed* *BeforeBatch* *AfterBatch*'
 & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase31-terminal --files p39-terminal-native.asm
 if($LASTEXITCODE -ne 0){throw 'Original P39 native indexing failed'}
 @{finishedUtc=[DateTimeOffset]::UtcNow.ToString('o');driverExitedNormally=$true;comparativeTimingRecords=0}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-native-driver-completed.json')
}catch{
 $_.Exception.ToString()|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-native-driver-failure.log');throw
}finally{Exit-VoxtreePerformanceHost $lease}
