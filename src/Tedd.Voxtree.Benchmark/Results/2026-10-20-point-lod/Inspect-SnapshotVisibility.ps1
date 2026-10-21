param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Prepare-SnapshotVisibility.py','Build-Rig.ps1','PointHistoryProbe.cs.txt','Summarize-Native.py')
$hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued P33 native dependency changed'}}
    & python (Join-Path $PSScriptRoot 'Prepare-SnapshotVisibility.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'P33 source preparation failed'}
    if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p33point')){throw 'P33 point rig exists'}
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p33point -BaselineSource (Join-Path $TaskRoot 'compact-leaf13-source') -CandidateSource (Join-Path $TaskRoot 'owned-snapshot-inline-v2-source') -FixtureName Scenarios-snapshot-visibility.cs.txt *> (Join-Path $TaskRoot 'p33point-build.log')
    $schedule=Get-Content -LiteralPath (Join-Path $TaskRoot 'h2-history-schedule.json') -Raw|ConvertFrom-Json -AsHashtable -Depth 30
    $schedule.bundle='p33point';$schedule.bundleSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'bundles/p33point/p33point.dll')).Hash.ToLowerInvariant()
    $schedule.source='Original P32 order witness via H2; new version18 descriptor and P33 paired bundle; these are not new timed run IDs'
    foreach($list in @('getFirst','lodFirst')){foreach($case in $schedule[$list]){$case.version='18'}}
    $schedulePath=Join-Path $TaskRoot 'p33-history-schedule.json'
    if(Test-Path -LiteralPath $schedulePath){throw 'P33 schedule exists'}
    $schedule|ConvertTo-Json -Depth 30|Set-Content -LiteralPath $schedulePath
    $root=Join-Path $TaskRoot 'snapshot-visibility-p33-source';$probeBundle=Join-Path $TaskRoot 'bundles/p33-probe'
    if((Test-Path -LiteralPath $root) -or (Test-Path -LiteralPath $probeBundle)){throw 'P33 history probe exists'}
    New-Item -ItemType Directory -Path $root|Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PointHistoryProbe.cs.txt') -Destination (Join-Path $root 'Program.cs')
    $bundle=(Join-Path $TaskRoot 'bundles/p33point').Replace('\','/')
    @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><UseSharedCompilation>false</UseSharedCompilation><AssemblyName>P33Probe</AssemblyName><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup>
<Reference Include="p33point"><HintPath>$bundle/p33point.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Contracts"><HintPath>$bundle/Tedd.DotNetLab.Contracts.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Harness"><HintPath>$bundle/Tedd.DotNetLab.Harness.dll</HintPath></Reference>
</ItemGroup></Project>
"@|Set-Content -LiteralPath (Join-Path $root 'Probe.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $root 'Probe.csproj') -c Release -o $probeBundle -v minimal *> (Join-Path $TaskRoot 'p33-history-build.log')
        if($LASTEXITCODE -ne 0){throw 'P33 history probe build failed'}
        $entry=Join-Path $probeBundle 'P33Probe.dll'
        foreach($history in @('get-first','lod-first')){
            $label='p33-'+$history
            $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
            foreach($arg in @('exec','--fx-version','10.0.13',$entry,$history,$schedulePath)){$start.ArgumentList.Add($arg)}
            $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
            $start.Environment['DOTNET_JitDisasm']='*BeforeBatchOwned* *AfterBatchOwned* *BeforeBatchSpan* *AfterBatchSpan*'
            $start.Environment['DOTNET_JitDisasmAssemblies']='p33point';$start.Environment['DOTNET_JitStdOutFile']=Join-Path $TaskRoot "$label.asm"
            $p=[Diagnostics.Process]::Start($start);$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$clock=[Diagnostics.Stopwatch]::StartNew()
            $identity=@{history=$history;pid=$p.Id;start=$p.StartTime.ToUniversalTime().ToString('o');entrySha256=(Get-FileHash -LiteralPath $entry).Hash;bundleSha256=(Get-FileHash -LiteralPath (Join-Path $bundle 'p33point.dll')).Hash;scheduleSha256=(Get-FileHash -LiteralPath $schedulePath).Hash;sourceSha256=(Get-FileHash -LiteralPath (Join-Path $root 'Program.cs')).Hash;runtime='10.0.13';affinity=4;regime='P33 two-attribute native gate, no quiet timing'}
            $timedOut=$false
            while(-not $p.WaitForExit(1000)){if($clock.Elapsed.TotalSeconds -gt 180){$timedOut=$true;$p.Kill($true);$p.WaitForExit();break}}
            $stdout.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-output.log")
            $stderr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-error.log")
            $identity.exited=$p.HasExited;$identity.exitCode=$p.ExitCode;$identity.timedOut=$timedOut
            $identity|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-identity.json")
            if($timedOut -or $p.ExitCode -ne 0){throw 'Original P33 history diagnostic failed; preserve without replacement'}
            Get-Content -LiteralPath (Join-Path $TaskRoot "$label-output.log")|Where-Object{$_ -like '{*'}|Select-Object -Last 1
        }
        & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase21-snapshot --files p33-get-first.asm p33-lod-first.asm
        if($LASTEXITCODE -ne 0){throw 'P33 native indexing failed'}
    }finally{Pop-Location}
} finally {Exit-VoxtreePerformanceHost $lease}
