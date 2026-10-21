param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 $results=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p34world2-results') -Filter '*.trx')
 if($results.Count -ne 3){throw 'Expected all three runtime test results'}
 foreach($r in $results){[xml]$x=Get-Content -LiteralPath $r.FullName;if($x.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$x.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P34 tests failed'}}
 $bundle=Join-Path $TaskRoot 'bundles/p34world'
 foreach($f in (Get-Content -LiteralPath (Join-Path $TaskRoot 'p34world-hashes.json') -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'P34 paired bundle changed'}}
 $label='p34world';$entry=Join-Path $bundle "$label.dll"
 if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p34-world-validation.json')){throw 'P34 validation already exists'}
 $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
 foreach($arg in @('exec','--fx-version','10.0.13',$entry,'--validate')){$start.ArgumentList.Add($arg)}
 $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
 $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
 $p=[Diagnostics.Process]::Start($start);$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$p.WaitForExit()
 $o=$stdout.GetAwaiter().GetResult();$e=$stderr.GetAwaiter().GetResult()
 $o|Set-Content -LiteralPath (Join-Path $TaskRoot 'p34-world-validation.log');$e|Set-Content -LiteralPath (Join-Path $TaskRoot 'p34-world-validation-error.log')
 $cases=@($o -split "`n"|Where-Object{$_ -like '* valid*'}).Count
 @{pid=$p.Id;entrySha256=(Get-FileHash -LiteralPath $entry).Hash;runtime='10.0.13';exited=$p.HasExited;exitCode=$p.ExitCode;cases=$cases;arms=2;operationsPerCaseArm=16384}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p34-world-validation.json')
 if($p.ExitCode -ne 0 -or $cases -ne 40){throw 'P34 world semantic fixture failed'}
 & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle $bundle -Label p34-world-native -Scenario repeated -Methods '*BeforeBatch* *AfterBatch* *TryGetValue*'
 & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase23-world --files p34-world-native.asm
 if($LASTEXITCODE -ne 0){throw 'P34 native indexing failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
