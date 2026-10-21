param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$root=Join-Path $TaskRoot 'queued-driver-proof-source'
if(Test-Path -LiteralPath $root){throw 'Queue proof exists; inspect before recovery'}
$parentLease=Enter-VoxtreePerformanceHost
try {New-Item -ItemType Directory -Path $root | Out-Null} finally {Exit-VoxtreePerformanceHost $parentLease}
$rows=@()
foreach($changed in @($false,$true)){
    $label=if($changed){'changed'}else{'unchanged'}
    $driver=Join-Path $root "$label.ps1"
    $childBody=@'
param([string]$HostFile,[string]$Output)
$ErrorActionPreference='Stop'
. $HostFile
try {
    $lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
    try { @{admitted=$true;rejected=$false} | ConvertTo-Json | Set-Content -LiteralPath $Output }
    finally {Exit-VoxtreePerformanceHost $lease}
} catch {
    if($_.Exception.Message -notlike 'queued_driver_changed:*'){throw}
    @{admitted=$false;rejected=$true;reason=$_.Exception.Message} | ConvertTo-Json | Set-Content -LiteralPath $Output
}
'@
    $childBody | Set-Content -LiteralPath $driver
    $state=Join-Path $root "$label.json"
    $parentLease=Enter-VoxtreePerformanceHost
    $child=$null
    try {
        $start=[Diagnostics.ProcessStartInfo]::new((Get-Process -Id $PID).Path)
        foreach($arg in @('-NoProfile','-File',$driver,'-HostFile',(Join-Path $PSScriptRoot 'Host-Lock.ps1'),'-Output',$state)){$start.ArgumentList.Add($arg)}
        $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
        $child=[Diagnostics.Process]::Start($start);$errors=$child.StandardError.ReadToEndAsync()
        $clock=[Diagnostics.Stopwatch]::StartNew();$identityLine=$null;$prefix=@()
        while(-not $identityLine -and $clock.Elapsed.TotalSeconds -lt 25){
            $line=$child.StandardOutput.ReadLineAsync().WaitAsync([TimeSpan]::FromSeconds(25)).GetAwaiter().GetResult()
            if($null -eq $line){throw 'Queue proof child exited before hash capture'}
            if($line -like 'Queued driver SHA256:*'){$identityLine=$line}else{$prefix+=$line}
        }
        if(-not $identityLine -or (Test-Path -LiteralPath $state)){throw 'Child did not wait behind parent lease'}
        $before=(Get-FileHash -LiteralPath $driver).Hash
        if($changed){Add-Content -LiteralPath $driver -Value '# Deliberately changed after admission hash capture.'}
        $after=(Get-FileHash -LiteralPath $driver).Hash
        Exit-VoxtreePerformanceHost $parentLease;$parentLease=$null
        if(-not $child.WaitForExit(15000)){throw 'Queue proof child did not join'}
        $tail=$child.StandardOutput.ReadToEnd();$stderr=$errors.GetAwaiter().GetResult()
        @{initialLine=$identityLine;prefix=$prefix;tail=$tail;stderr=$stderr} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root "$label-output.json")
        if($child.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $state)){throw 'Queue proof failed'}
        $v=Get-Content -LiteralPath $state -Raw|ConvertFrom-Json
        if([bool]$v.rejected -ne $changed -or [bool]$v.admitted -eq $changed){throw 'Queue admission result mismatch'}
        $rows+=@{changed=$changed;admitted=$v.admitted;rejected=$v.rejected;initialDriverSha256=$before;finalDriverSha256=$after;pid=$child.Id;joined=$child.HasExited;exitCode=$child.ExitCode}
    } finally {
        if($parentLease){Exit-VoxtreePerformanceHost $parentLease}
        if($child -and -not $child.HasExited){$child.Kill($true);$child.WaitForExit(5000)|Out-Null}
    }
}
@{cases=$rows;hostHelperSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Host-Lock.ps1')).Hash;interpretation='Real queued child processes exercise the host helper: unchanged source admitted, mutated source rejected before its body; no benchmark data.'} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $root 'proof.json')
Get-Content -LiteralPath (Join-Path $root 'proof.json') -Raw
