param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($label in @('p36n0','p36n1')){
  $identity=Join-Path $TaskRoot "$label-validation.json";if(Test-Path -LiteralPath $identity){throw 'Normal semantic identity exists; preserve original'}
  foreach($f in (Get-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json") -Raw|ConvertFrom-Json)){if((Get-FileHash -LiteralPath $f.Path).Hash -ne $f.Hash){throw 'Normal bundle changed'}}
  $entry=Join-Path $TaskRoot "bundles/$label/WorldNormal.dll"
  $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
  foreach($arg in @('exec','--fx-version','10.0.13',$entry,'--validate')){$start.ArgumentList.Add($arg)}
  $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
  $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
  $p=[Diagnostics.Process]::Start($start);$pidValue=$p.Id;$ticks=[string]$p.StartTime.ToUniversalTime().Ticks
  $stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$p.WaitForExit()
  $o=$stdout.GetAwaiter().GetResult();$e=$stderr.GetAwaiter().GetResult()
  $o|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-validation.log");$e|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-validation-error.log")
  $cases=@($o -split "`n"|Where-Object{$_ -like '* valid*'}).Count
  @{pid=$pidValue;startTicks=$ticks;entrySha256=(Get-FileHash -LiteralPath $entry).Hash;runtime='10.0.13';exited=$p.HasExited;exitCode=$p.ExitCode;cases=$cases;labels=2;operationsPerCaseLabel=16384;scope='Independent prefix oracles on this single-library normal module; labels select process source, not different implementations inside one module.'}|ConvertTo-Json|Set-Content -LiteralPath $identity
  if($p.ExitCode -ne 0 -or $cases -ne 48){throw 'Original normal semantic producer failed; no replacement'}
  Write-Output "${label}: 48 cases valid"
 }
}finally{Exit-VoxtreePerformanceHost $lease}
