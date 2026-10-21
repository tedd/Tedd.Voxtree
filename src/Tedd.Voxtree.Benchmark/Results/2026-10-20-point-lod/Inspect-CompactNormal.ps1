param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Audit-Callers.ps1','CallerAudit.cs.txt','Inspect-Code.ps1','Summarize-Native.py','Scenarios-compact-normal-storage.cs.txt');$frozen=@{}
foreach($n in $names){$frozen[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
function Invoke-OwnedCompactCheck([string]$Label,[string]$Mode){
 $output=Join-Path $TaskRoot "$Label-$Mode.json"
 if(Test-Path -LiteralPath $output){throw 'Original compact check exists; preserve it'}
 $entry=Join-Path $TaskRoot "bundles/$Label/CompactNormal.dll"
 $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
 foreach($arg in @('exec','--fx-version','10.0.13',$entry,"--$Mode")){$start.ArgumentList.Add($arg)}
 $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
 $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
 $p=[Diagnostics.Process]::Start($start);$ticks=[string]$p.StartTime.ToUniversalTime().Ticks
 $stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$p.WaitForExit()
 $o=$stdout.GetAwaiter().GetResult();$e=$stderr.GetAwaiter().GetResult()
 $o|Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-$Mode.log");$e|Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-$Mode-error.log")
 @{pid=$p.Id;startTicks=$ticks;entrySha256=(Get-FileHash -LiteralPath $entry).Hash;mode=$Mode;runtime='10.0.13';exited=$p.HasExited;exitCode=$p.ExitCode}|ConvertTo-Json|Set-Content -LiteralPath $output
 if($p.ExitCode -ne 0){throw 'Original compact semantic/inventory process failed; retain its logs'}
 Write-Output "${Label}: $Mode complete"
}
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Queued compact check dependency changed'}}
 foreach($label in @('p39n2','p39n3')){foreach($f in @(Get-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json") -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'Original compact normal bundle changed'}}}
 & (Join-Path $PSScriptRoot 'Audit-Callers.ps1') -TaskRoot $TaskRoot -Label caller-audit-p39normalstorage -BundleLabels p39n2,p39n3 -Mode compact-callers -EntryAssembly CompactNormal.dll
 $tool=Join-Path $TaskRoot 'caller-audit-p39normalstorage/out/Audit.dll';$bodyOutput=Join-Path $TaskRoot 'caller-audit-p39normalstorage-library.json'
 if(Test-Path -LiteralPath $bodyOutput){throw 'Original normal library inventory exists'}
 & dotnet exec --fx-version 10.0.13 $tool --library $bodyOutput (Join-Path $TaskRoot 'bundles/p39n2/CompactNormal.dll') (Join-Path $TaskRoot 'bundles/p39n3/CompactNormal.dll')
 if($LASTEXITCODE -ne 0){throw 'Normal library body audit failed'}
 foreach($label in @('p39n2','p39n3')){Invoke-OwnedCompactCheck $label inventory;Invoke-OwnedCompactCheck $label validate}
 $traceFolder=Join-Path $TaskRoot 'p39-normal-storage/traces'
 $entryHashes=@('p39n2','p39n3'|ForEach-Object{(Get-FileHash -LiteralPath (Join-Path $TaskRoot "bundles/$_/CompactNormal.dll")).Hash})
 $traces=@(Get-ChildItem -LiteralPath $traceFolder -Filter '*.json'|ForEach-Object{
  $r=Get-Content -LiteralPath $_.FullName -Raw|ConvertFrom-Json
  if($r.entrySha256 -notin $entryHashes){return}
  $base=[IO.Path]::GetFullPath((Join-Path $TaskRoot 'p39-normal-storage'))+[IO.Path]::DirectorySeparatorChar
  if(-not ([IO.Path]::GetFullPath($r.root).StartsWith($base,[StringComparison]::OrdinalIgnoreCase)) -or $r.stage -ne 'cleaned' -or (Test-Path -LiteralPath $r.root)){throw 'Owned preflight storage cleanup failed'}
  @{file=$_.Name;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash;record=$r}
 })
 if($traces.Count -ne 6){throw 'Expected six original storage validation roots'}
 $traces|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-normal-storage-preflight.json')
 $methods='*ValidateCube* *RunValidate* *RunFrom* *RunChunkValidate* *IsWellFormed*'
 $files=@()
 foreach($label in @('p39n2','p39n3')){
  foreach($case in @('Classic32-D-validate','Generic16-D-validate','Classic32-D-from','Classic32-D-chunk-validate','Classic32-C-validate','Classic32-ME-validate')){
   $diagnostic="$label-$case-code";$files+=@("$diagnostic.asm")
   & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot "bundles/$label") -Label $diagnostic -Scenario "compact-normal-$case" -Methods $methods
  }
 }
 & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase32-normal-storage --files @files
 if($LASTEXITCODE -ne 0){throw 'Normal caller code indexing failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
