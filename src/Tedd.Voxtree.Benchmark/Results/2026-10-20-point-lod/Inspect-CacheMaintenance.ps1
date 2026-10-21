param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Inspect-Code.ps1','Summarize-Native.py');$hashes=@{}
foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'P36 queued native dependency changed'}}
 $results=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'packed-lookup-p36world-results') -Filter '*.trx')
 if($results.Count -ne 3){throw 'Expected all three P36 runtime test results'}
 foreach($r in $results){[xml]$x=Get-Content -LiteralPath $r.FullName;if($x.TestRun.ResultSummary.outcome -ne 'Completed' -or [int]$x.TestRun.ResultSummary.Counters.failed -ne 0){throw 'P36 tests failed'}}
 foreach($f in (Get-Content -LiteralPath (Join-Path $TaskRoot 'p36world-hashes.json') -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'P36 paired bundle changed'}}
 $bundle=Join-Path $TaskRoot 'bundles/p36world';$entry=Join-Path $bundle 'p36world.dll'
 if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p36-world-validation.json')){throw 'P36 semantic producer exists; inspect original state'}
 $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
 foreach($arg in @('exec','--fx-version','10.0.13',$entry,'--validate')){$start.ArgumentList.Add($arg)}
 $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
 $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
 $p=[Diagnostics.Process]::Start($start);$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$p.WaitForExit()
 $o=$stdout.GetAwaiter().GetResult();$e=$stderr.GetAwaiter().GetResult()
 $o|Set-Content -LiteralPath (Join-Path $TaskRoot 'p36-world-validation.log');$e|Set-Content -LiteralPath (Join-Path $TaskRoot 'p36-world-validation-error.log')
 $cases=@($o -split "`n"|Where-Object{$_ -like '* valid*'}).Count
 @{pid=$p.Id;entrySha256=(Get-FileHash -LiteralPath $entry).Hash;runtime='10.0.13';exited=$p.HasExited;exitCode=$p.ExitCode;cases=$cases;arms=2;operationsPerCaseArm=16384}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p36-world-validation.json')
 if($p.ExitCode -ne 0 -or $cases -ne 48){throw 'P36 separate-operation semantic fixture failed'}
 $methods='*AddRecent* *InsertRecentLookup* *RemoveRecentLookup* *RebuildLookup* *BeforeGet* *AfterGet* *BeforeLod* *AfterLod* *BeforeChunk* *AfterChunk* *BeforeTopology* *AfterTopology*'
 & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle $bundle -Label p36-cache-native -Scenario cycle12 -Methods $methods
 & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase26-cache --files p36-cache-native.asm
 if($LASTEXITCODE -ne 0){throw 'P36 native indexing failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
