param(
    [Parameter(Mandatory)][string]$TaskRoot,
    [Parameter(Mandatory)][string]$Bundle,
    [Parameter(Mandatory)][string]$Label,
    [Parameter(Mandatory)][string]$Scenario,
    [string]$Methods = '*TryGetUnchecked* *SkipValue* *TryReadValue* *GetUnchecked*'
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    $entry=(Get-ChildItem -LiteralPath $Bundle -Filter '*.runtimeconfig.json').Name.Replace('.runtimeconfig.json','.dll')
    $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
    foreach($argument in @('exec','--fx-version','10.0.13',(Join-Path $Bundle $entry),'--code',$Scenario)){$start.ArgumentList.Add($argument)}
    $start.UseShellExecute=$false;$start.CreateNoWindow=$true
    $start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
    $start.Environment['TEMP']=Join-Path $TaskRoot 'temp';$start.Environment['TMP']=$start.Environment['TEMP']
    $start.Environment['DOTNET_JitDisasm']=$Methods
    $start.Environment['DOTNET_JitDisasmAssemblies']=[IO.Path]::GetFileNameWithoutExtension($entry)
    $start.Environment['DOTNET_JitStdOutFile']=Join-Path $TaskRoot "$Label.asm"
    $process=[Diagnostics.Process]::Start($start)
    $identity=@{pid=$process.Id;start=$process.StartTime.ToUniversalTime().ToString('O');entry=$entry;hash=(Get-FileHash (Join-Path $Bundle $entry)).Hash;scenario=$Scenario;regime='external-owned-JIT-diagnostic-not-quiet';methods=$Methods}
    $identity|ConvertTo-Json|Set-Content (Join-Path $TaskRoot "$Label-identity.json")
    $stdout=$process.StandardOutput.ReadToEndAsync();$stderr=$process.StandardError.ReadToEndAsync()
    while(-not $process.WaitForExit(1000)){}
    $stdout.GetAwaiter().GetResult()|Set-Content (Join-Path $TaskRoot "$Label-output.log")
    $stderr.GetAwaiter().GetResult()|Set-Content (Join-Path $TaskRoot "$Label-error.log")
    if($process.ExitCode -ne 0){throw "Diagnostic failed: $Label"}
    "$Label JIT evidence complete"
} finally {Exit-VoxtreePerformanceHost $leases}
