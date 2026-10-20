param([Parameter(Mandatory)][string]$TaskRoot,
      [ValidatePattern('^[a-z][a-z0-9-]*$')][string]$Label='p18count-body2',
      [ValidatePattern('^[a-z][a-z0-9-]*$')][string]$BundleLabel='p18bulk',
      [ValidateSet('CountBodyProbe.cs.txt','CountShapeProbe.cs.txt')][string]$ProbeSource='CountBodyProbe.cs.txt')
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost
try {
    $root=Join-Path $TaskRoot "count-body-$Label-source"
    if(Test-Path -LiteralPath $root){throw 'Native body probe exists'}
    New-Item -ItemType Directory -Path $root|Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $ProbeSource) -Destination (Join-Path $root 'Program.cs')
    $bundle=(Join-Path $TaskRoot "bundles/$BundleLabel").Replace('\','/')
    @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><UseSharedCompilation>false</UseSharedCompilation><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup>
<Reference Include="$BundleLabel"><HintPath>$bundle/$BundleLabel.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Contracts"><HintPath>$bundle/Tedd.DotNetLab.Contracts.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Harness"><HintPath>$bundle/Tedd.DotNetLab.Harness.dll</HintPath></Reference>
</ItemGroup></Project>
"@|Set-Content -LiteralPath (Join-Path $root 'Probe.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $root 'Probe.csproj') -c Release -o (Join-Path $root 'out') -v minimal *> (Join-Path $TaskRoot "$Label-build.log")
        if($LASTEXITCODE -ne 0){throw 'Native body probe build failed'}
        $entry=Join-Path $root 'out/Probe.dll'
        $start=[Diagnostics.ProcessStartInfo]::new((Get-Command dotnet).Source)
        foreach($argument in @('exec','--fx-version','10.0.13',$entry)){$start.ArgumentList.Add($argument)}
        $start.UseShellExecute=$false;$start.CreateNoWindow=$true
        $start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
        $start.Environment['DOTNET_JitDisasm']='*Packed* *Count* *RunCore* *Accept* *TryGet*'
        $start.Environment['DOTNET_JitDisasmAssemblies']=$BundleLabel
        $start.Environment['DOTNET_JitStdOutFile']=Join-Path $TaskRoot "$Label-code.asm"
        $p=[Diagnostics.Process]::Start($start);$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync()
        $identity=@{pid=$p.Id;start=$p.StartTime.ToUniversalTime().ToString('o');probeSource=$ProbeSource;sourceSha256=(Get-FileHash -LiteralPath (Join-Path $root 'Program.cs')).Hash;entrySha256=(Get-FileHash -LiteralPath $entry).Hash;selectedBundle=$BundleLabel;selectedBundleSha256=(Get-FileHash -LiteralPath (Join-Path $bundle "$BundleLabel.dll")).Hash;regime='isolated native-only count traversal probe; not quiet timing';runtime='10.0.13';affinity=4}
        while(-not $p.WaitForExit(1000)){}
        $stdout.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-output.log")
        $stderr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-error.log")
        $identity.exited=$p.HasExited;$identity.exitCode=$p.ExitCode
        $identity|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-identity.json")
        if($p.ExitCode -ne 0){throw 'Native count-body probe failed'}
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $lease}
