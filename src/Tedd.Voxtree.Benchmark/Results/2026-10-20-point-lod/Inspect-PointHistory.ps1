param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Prepare-PointHistory.py','PointHistoryProbe.cs.txt','Summarize-Native.py')
$hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $hashes[$n]){throw 'Queued history dependency changed'}}
    $root=Join-Path $TaskRoot 'point-history-h2-source';if(Test-Path -LiteralPath $root){throw 'History probe exists; preserve original attempt'}
    & python (Join-Path $PSScriptRoot 'Prepare-PointHistory.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'History schedule failed'}
    New-Item -ItemType Directory -Path $root|Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PointHistoryProbe.cs.txt') -Destination (Join-Path $root 'Program.cs')
    $bundle=(Join-Path $TaskRoot 'bundles/p32point').Replace('\','/')
    @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><UseSharedCompilation>false</UseSharedCompilation><AssemblyName>H2Probe</AssemblyName><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup>
<Reference Include="p32point"><HintPath>$bundle/p32point.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Contracts"><HintPath>$bundle/Tedd.DotNetLab.Contracts.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Harness"><HintPath>$bundle/Tedd.DotNetLab.Harness.dll</HintPath></Reference>
</ItemGroup></Project>
"@|Set-Content -LiteralPath (Join-Path $root 'Probe.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $root 'Probe.csproj') -c Release -o (Join-Path $root 'out') -v minimal *> (Join-Path $TaskRoot 'h2-build.log')
        if($LASTEXITCODE -ne 0){throw 'History probe build failed'}
        $entry=Join-Path $root 'out/H2Probe.dll';$schedule=Join-Path $TaskRoot 'h2-history-schedule.json'
        foreach($history in @('get-first','lod-first')){
            $label='h2-'+$history
            $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
            foreach($arg in @('exec','--fx-version','10.0.13',$entry,$history,$schedule)){$start.ArgumentList.Add($arg)}
            $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
            $start.Environment['DOTNET_JitDisasm']='*BeforeBatchOwned* *AfterBatchOwned* *BeforeBatchSpan* *AfterBatchSpan*'
            $start.Environment['DOTNET_JitDisasmAssemblies']='p32point';$start.Environment['DOTNET_JitStdOutFile']=Join-Path $TaskRoot "$label.asm"
            $p=[Diagnostics.Process]::Start($start);$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync();$clock=[Diagnostics.Stopwatch]::StartNew()
            $identity=@{history=$history;pid=$p.Id;start=$p.StartTime.ToUniversalTime().ToString('o');entrySha256=(Get-FileHash -LiteralPath $entry).Hash;bundleSha256=(Get-FileHash -LiteralPath (Join-Path $bundle 'p32point.dll')).Hash;scheduleSha256=(Get-FileHash -LiteralPath $schedule).Hash;sourceSha256=(Get-FileHash -LiteralPath (Join-Path $root 'Program.cs')).Hash;runtime='10.0.13';affinity=4;regime='fresh diagnostic history cut; no quiet timing'}
            $timedOut=$false
            while(-not $p.WaitForExit(1000)){if($clock.Elapsed.TotalSeconds -gt 180){$timedOut=$true;$p.Kill($true);$p.WaitForExit();break}}
            $stdout.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-output.log")
            $stderr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-error.log")
            $identity.exited=$p.HasExited;$identity.exitCode=$p.ExitCode;$identity.timedOut=$timedOut
            $identity|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-identity.json")
            if($timedOut -or $p.ExitCode -ne 0){throw 'Original history diagnostic failed; retain without replacement'}
            Get-Content -LiteralPath (Join-Path $TaskRoot "$label-output.log") -Tail 1
        }
        & python (Join-Path $PSScriptRoot 'Summarize-Native.py') $TaskRoot --label phase20-history --files h2-get-first.asm h2-lod-first.asm
        if($LASTEXITCODE -ne 0){throw 'History native indexing failed'}
    }finally{Pop-Location}
} finally {Exit-VoxtreePerformanceHost $lease}
