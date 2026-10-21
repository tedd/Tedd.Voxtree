param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $root=Join-Path $TaskRoot 'exception-capture-selftest-source'
    if(Test-Path -LiteralPath $root){throw 'Observer self-test exists; inspect before recovery'}
    New-Item -ItemType Directory -Path $root | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'ExceptionCapture.cs.txt') -Destination (Join-Path $root 'Program.cs')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'EXCEPTION-CAPTURE-PROTOCOL.md') -Destination (Join-Path $root 'protocol.txt')
    $escapedLab=[Security.SecurityElement]::Escape($LabDirectory.Replace('\','/'))
    @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><TargetFramework>net10.0</TargetFramework><OutputType>Exe</OutputType><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><LangVersion>14.0</LangVersion><UseSharedCompilation>false</UseSharedCompilation><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup>
<Reference Include="Microsoft.Diagnostics.NETCore.Client"><HintPath>$escapedLab/Microsoft.Diagnostics.NETCore.Client.dll</HintPath></Reference>
<Reference Include="Microsoft.Diagnostics.Tracing.TraceEvent"><HintPath>$escapedLab/Microsoft.Diagnostics.Tracing.TraceEvent.dll</HintPath></Reference>
</ItemGroup></Project>
"@ | Set-Content -LiteralPath (Join-Path $root 'Probe.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $root 'Probe.csproj') -c Release -o (Join-Path $root 'out') -v minimal *> (Join-Path $TaskRoot 'exception-capture-build.log')
        if($LASTEXITCODE -ne 0){throw 'Exception observer build failed'}
        Get-ChildItem -LiteralPath (Join-Path $root 'out') -File | Get-FileHash | Select-Object Path,Hash | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root 'bundle-hashes.json')
        & dotnet exec --fx-version 10.0.13 (Join-Path $root 'out/Probe.dll') (Join-Path $root 'evidence') *> (Join-Path $TaskRoot 'exception-capture-selftest.log')
        if($LASTEXITCODE -ne 0){throw 'Exception observer self-test failed; retain evidence'}
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $leases}
