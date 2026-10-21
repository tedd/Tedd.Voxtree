param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Inspect-Code.ps1','Summarize-Native.py','Scenarios-world-normal.cs.txt');$frozen=@{}
foreach($n in $names){$frozen[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Queued outline inspection dependency changed'}}
 $results=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p37world-results') -Filter '*.trx')
 if($results.Count -ne 3){throw 'P37 needs all three original runtime regression results'}
 foreach($r in $results){[xml]$x=Get-Content -LiteralPath $r.FullName;if($x.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$x.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P37 regression failure'}}
 $toolIdentity=Get-Content -LiteralPath (Join-Path $TaskRoot 'caller-audit-p37library-identity.json') -Raw|ConvertFrom-Json
 $tool=Join-Path $TaskRoot 'caller-audit-p37library/out/Audit.dll'
 if(-not $toolIdentity.selftestPassed -or (Get-FileHash -LiteralPath $tool).Hash -ne $toolIdentity.toolSha256){throw 'Original audit tool changed'}
 $callerOutput=Join-Path $TaskRoot 'caller-audit-p37world.json'
 if(Test-Path -LiteralPath $callerOutput){throw 'Original world caller audit exists; preserve it'}
 & dotnet exec --fx-version 10.0.13 $tool --world-callers $callerOutput (Join-Path $TaskRoot 'bundles/p37n0/WorldNormal.dll') (Join-Path $TaskRoot 'bundles/p37n1/WorldNormal.dll')
 if($LASTEXITCODE -ne 0){throw 'Original world caller metadata audit failed'}
 $toolIdentity.mode='world-callers';$toolIdentity|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'caller-audit-p37world-identity.json')
 foreach($label in @('p37n0','p37n1')){
  foreach($f in @(Get-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json") -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'Original outline bundle changed'}}
  $bundle=Join-Path $TaskRoot "bundles/$label";$entry=Join-Path $bundle 'WorldNormal.dll'
  $identity=Join-Path $TaskRoot "$label-validation.json"
  if(Test-Path -LiteralPath $identity){throw 'Original outline semantic producer exists; preserve it'}
  $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
  foreach($arg in @('exec','--fx-version','10.0.13',$entry,'--validate')){$start.ArgumentList.Add($arg)}
  $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
  $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
  $p=[Diagnostics.Process]::Start($start);$startTicks=[string]$p.StartTime.ToUniversalTime().Ticks
  $stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$p.WaitForExit()
  $o=$stdout.GetAwaiter().GetResult();$e=$stderr.GetAwaiter().GetResult()
  $o|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-validation.log");$e|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-validation-error.log")
  $cases=@($o -split "`n"|Where-Object{$_ -like '* valid*'}).Count
  @{pid=$p.Id;startTicks=$startTicks;entrySha256=(Get-FileHash -LiteralPath $entry).Hash;runtime='10.0.13';exited=$p.HasExited;exitCode=$p.ExitCode;cases=$cases;arms=2;operationsPerCaseArm=16384}|ConvertTo-Json|Set-Content -LiteralPath $identity
  if($p.ExitCode -ne 0 -or $cases -ne 48){throw 'Original outline semantic validation failed'}
  Write-Output "${label}: all48 prefix cases passed"
 }
 $methods='*AddRecent* *RebuildLookup* *AfterGet* *AfterLod* *AfterChunk* *AfterTopology*'
 foreach($label in @('p37n0','p37n1')){
  & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot "bundles/$label") -Label "$label-native" -Scenario cycle12 -Methods $methods
 }
 & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase29-outline --files p37n0-native.asm p37n1-native.asm
 if($LASTEXITCODE -ne 0){throw 'Original outline native indexing failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
