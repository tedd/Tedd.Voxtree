param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -MeasurementOnly
$child=$null
try {
    $code=@'
$ErrorActionPreference='Stop'
$gate=[Threading.Mutex]::new($false,'Global\Tedd.DotNetLab.Measurement.v1')
try {
    if($gate.WaitOne(0)){ $gate.ReleaseMutex(); throw 'Parent did not exclude child' }
    [Console]::Out.WriteLine('blocked');[Console]::Out.Flush()
    $gate.WaitOne() | Out-Null
    try { [Console]::Out.WriteLine('admitted');[Console]::Out.Flush() }
    finally { $gate.ReleaseMutex() }
} finally {$gate.Dispose()}
'@
    $start=[Diagnostics.ProcessStartInfo]::new((Get-Command pwsh).Source)
    foreach($arg in @('-NoProfile','-NonInteractive','-EncodedCommand',[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code)))){$start.ArgumentList.Add($arg)}
    $start.UseShellExecute=$false;$start.CreateNoWindow=$true
    $start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
    $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
    $child=[Diagnostics.Process]::Start($start)
    $identity=@{pid=$child.Id;start=$child.StartTime.ToUniversalTime().ToString('O');mutex='Global\Tedd.DotNetLab.Measurement.v1';hostLockSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Host-Lock.ps1')).Hash}
    $blocked=$child.StandardOutput.ReadLine()
    if($blocked -ne 'blocked'){throw "Child exclusion failed: $blocked"}
    Exit-VoxtreePerformanceHost $lease;$lease=$null
    $admitted=$child.StandardOutput.ReadLine()
    $child.WaitForExit()
    if($admitted -ne 'admitted' -or $child.ExitCode -ne 0){throw $child.StandardError.ReadToEnd()}
    $identity.blockedWhileOwned=$true;$identity.admittedAfterRelease=$true;$identity.joined=$true;$identity.exitCode=$child.ExitCode
    $identity | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'host-admission-verification.json')
    'Cross-process shared measurement admission verified'
} finally {
    if($lease){Exit-VoxtreePerformanceHost $lease}
    if($child -and -not $child.HasExited){throw 'Admission probe remains active; inspect its identity before cleanup'}
    if($child){$child.Dispose()}
}
