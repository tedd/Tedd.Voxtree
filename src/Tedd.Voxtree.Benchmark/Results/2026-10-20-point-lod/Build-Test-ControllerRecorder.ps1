param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$child=$null;$observer=$null
try {
    $root=Join-Path $TaskRoot 'exception-recorder-v2-source'
    if(Test-Path -LiteralPath $root){throw 'Recorder v2 exists; inspect prior evidence'}
    New-Item -ItemType Directory -Path $root | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'ControllerExceptionRecorder.cs.txt') -Destination (Join-Path $root 'Program.cs')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'FAILURE-DIAGNOSTIC-1.md') -Destination (Join-Path $root 'protocol.txt')
    $escapedLab=[Security.SecurityElement]::Escape($LabDirectory.Replace('\','/'))
    @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><TargetFramework>net10.0</TargetFramework><OutputType>Exe</OutputType><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><LangVersion>14.0</LangVersion><UseSharedCompilation>false</UseSharedCompilation><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup>
<Reference Include="Microsoft.Diagnostics.NETCore.Client"><HintPath>$escapedLab/Microsoft.Diagnostics.NETCore.Client.dll</HintPath></Reference>
<Reference Include="Microsoft.Diagnostics.Tracing.TraceEvent"><HintPath>$escapedLab/Microsoft.Diagnostics.Tracing.TraceEvent.dll</HintPath></Reference>
</ItemGroup></Project>
"@ | Set-Content -LiteralPath (Join-Path $root 'Probe.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {& dotnet build (Join-Path $root 'Probe.csproj') -c Release -o (Join-Path $root 'out') -v minimal *> (Join-Path $TaskRoot 'exception-recorder-v2-build.log');if($LASTEXITCODE -ne 0){throw 'Recorder v2 build failed'}} finally {Pop-Location}
    function Start-Owned([string[]]$Arguments){
        $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
        foreach($arg in $Arguments){$start.ArgumentList.Add($arg)}
        $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardInput=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
        $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP'];$start.Environment['DOTNET_EnableDiagnostics']='1'
        [Diagnostics.Process]::Start($start)
    }
    $childEntry=Join-Path $TaskRoot 'exception-capture-selftest-source/out/Probe.dll'
    $prior=Get-Content -LiteralPath (Join-Path $TaskRoot 'exception-capture-selftest-source/evidence/identity.json') -Raw|ConvertFrom-Json
    if((Get-FileHash -LiteralPath $childEntry).Hash -ne $prior.entrySha256){throw 'Synthetic child differs from prior tested executable'}
    $child=Start-Owned @('exec','--fx-version','10.0.13',$childEntry,'--throw-child');$childError=$child.StandardError.ReadToEndAsync()
    $line=$child.StandardOutput.ReadLineAsync().WaitAsync([TimeSpan]::FromSeconds(15)).GetAwaiter().GetResult()
    $ready=$line|ConvertFrom-Json
    if($ready.pid -ne $child.Id -or $ready.startTicks -ne $child.StartTime.ToUniversalTime().Ticks){throw 'Synthetic child identity mismatch'}
    $output=Join-Path $root 'selftest/evidence'
    $entry=Join-Path $root 'out/Probe.dll'
    $observer=Start-Owned @('exec','--fx-version','10.0.13',$entry,[string]$child.Id,[string]$ready.startTicks,$output)
    $observerOut=$observer.StandardOutput.ReadToEndAsync();$observerErr=$observer.StandardError.ReadToEndAsync()
    $clock=[Diagnostics.Stopwatch]::StartNew()
    while(-not (Test-Path -LiteralPath (Join-Path $output 'ready.json'))){
        if($observer.HasExited -or $clock.Elapsed.TotalSeconds -gt 20){throw 'Recorder v2 failed to become ready'}
        Start-Sleep -Milliseconds 100
    }
    $child.StandardInput.WriteLine('throw');$child.StandardInput.Flush()
    if($child.StandardOutput.ReadLineAsync().WaitAsync([TimeSpan]::FromSeconds(10)).GetAwaiter().GetResult() -ne 'caught'){throw 'Synthetic marker not acknowledged'}
    'stop' | Set-Content -LiteralPath (Join-Path $output 'stop.txt')
    if(-not $observer.WaitForExit(20000)){throw 'Recorder v2 did not drain/join'}
    $observerOut.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root 'selftest/observer-output.log')
    $observerErr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root 'selftest/observer-error.log')
    if($observer.ExitCode -ne 0){throw 'Recorder v2 exited unsuccessfully'}
    $child.StandardInput.WriteLine('shutdown');$child.StandardInput.Close()
    if(-not $child.WaitForExit(10000) -or $child.ExitCode -ne 0 -or $childError.GetAwaiter().GetResult()){throw 'Synthetic child did not join cleanly'}
    $result=Get-Content -LiteralPath (Join-Path $output 'result.json') -Raw|ConvertFrom-Json -Depth 30
    $events=@(Get-Content -LiteralPath (Join-Path $output 'events.json') -Raw|ConvertFrom-Json -Depth 30)
    if(-not $result.complete -or $result.eventsLost -ne 0 -or $result.truncated){throw 'Recorder v2 coverage invalid'}
    $markers=@($events|Where-Object {$_.ProcessID -eq $child.Id -and $_.payload.ExceptionMessage -eq 'Voxtree.ExceptionCapture.caught.v1'})
    if($markers.Count -ne 1){throw 'Recorder v2 missing/duplicate synthetic marker'}
    @{markerEvents=$markers.Count;eventsLost=$result.eventsLost;complete=$result.complete;childPid=$child.Id;childStartTicks=[string]$ready.startTicks;childJoined=$child.HasExited;childExitCode=$child.ExitCode;observerPid=$observer.Id;observerJoined=$observer.HasExited;observerExitCode=$observer.ExitCode;entrySha256=(Get-FileHash -LiteralPath $entry).Hash;traceSha256=$result.traceSha256;regime='Actual record-mode self-test; no performance claim'}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'selftest-proof.json')
    Get-ChildItem -LiteralPath (Join-Path $root 'out') -File|Get-FileHash|Select-Object Path,Hash|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'bundle-hashes.json')
    Get-Content -LiteralPath (Join-Path $root 'selftest-proof.json') -Raw
} finally {
    foreach($p in @($observer,$child)){if($p -and -not $p.HasExited){$p.Kill($true);$p.WaitForExit(5000)|Out-Null}}
    Exit-VoxtreePerformanceHost $leases
}
