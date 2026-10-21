param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Inspect-Code.ps1','Summarize-Native.py');$hashes=@{}
foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'P35 queued dependency changed'}}
 $results=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p35world-results') -Filter '*.trx')
 if($results.Count -ne 3){throw 'Expected all three P35 runtime test results'}
 foreach($r in $results){[xml]$x=Get-Content -LiteralPath $r.FullName;if($x.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$x.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P35 tests failed'}}
 foreach($f in (Get-Content -LiteralPath (Join-Path $TaskRoot 'p35world-hashes.json') -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'P35 paired bundle changed'}}
 $bundle=Join-Path $TaskRoot 'bundles/p35world';$entry=Join-Path $bundle 'p35world.dll'
 if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p35-world-validation.json')){throw 'P35 validation exists; inspect original state'}
 $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
 foreach($arg in @('exec','--fx-version','10.0.13',$entry,'--validate')){$start.ArgumentList.Add($arg)}
 $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
 $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
 $p=[Diagnostics.Process]::Start($start);$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$p.WaitForExit()
 $o=$stdout.GetAwaiter().GetResult();$e=$stderr.GetAwaiter().GetResult()
 $o|Set-Content -LiteralPath (Join-Path $TaskRoot 'p35-world-validation.log');$e|Set-Content -LiteralPath (Join-Path $TaskRoot 'p35-world-validation-error.log')
 $cases=@($o -split "`n"|Where-Object{$_ -like '* valid*'}).Count
 @{pid=$p.Id;entrySha256=(Get-FileHash -LiteralPath $entry).Hash;runtime='10.0.13';exited=$p.HasExited;exitCode=$p.ExitCode;cases=$cases;arms=2;operationsPerCaseArm=16384}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p35-world-validation.json')
 if($p.ExitCode -ne 0 -or $cases -ne 60){throw 'P35 caller semantic fixture failed'}
 & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle $bundle -Label p35-world-native -Scenario repeated -Methods '*BeforeBatch* *AfterBatch* *TryGetValue*'
 & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase24-world --files p35-world-native.asm
 if($LASTEXITCODE -ne 0){throw 'P35 native indexing failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
