param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $root=Join-Path $TaskRoot 'exception-summary-d1-source'
    if(Test-Path -LiteralPath $root){throw 'D1 replay exists; inspect prior result'}
    New-Item -ItemType Directory -Path $root|Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Summarize-D1Exceptions.cs.txt') -Destination (Join-Path $root 'Program.cs')
    $escapedLab=[Security.SecurityElement]::Escape($LabDirectory.Replace('\','/'))
    @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><TargetFramework>net10.0</TargetFramework><OutputType>Exe</OutputType><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><LangVersion>14.0</LangVersion><UseSharedCompilation>false</UseSharedCompilation><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup><Reference Include="Microsoft.Diagnostics.Tracing.TraceEvent"><HintPath>$escapedLab/Microsoft.Diagnostics.Tracing.TraceEvent.dll</HintPath></Reference></ItemGroup></Project>
"@|Set-Content -LiteralPath (Join-Path $root 'Probe.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http';$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $root 'Probe.csproj') -c Release -o (Join-Path $root 'out') -v minimal *> (Join-Path $TaskRoot 'exception-summary-d1-build.log')
        if($LASTEXITCODE -ne 0){throw 'D1 replay build failed'}
        & dotnet exec --fx-version 10.0.13 (Join-Path $root 'out/Probe.dll') *> (Join-Path $TaskRoot 'exception-summary-d1.log')
        if($LASTEXITCODE -ne 0){throw 'D1 raw replay failed'}
        Get-ChildItem -LiteralPath (Join-Path $root 'out') -File|Get-FileHash|Select-Object Path,Hash|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'bundle-hashes.json')
        $destination=Join-Path $PSScriptRoot 'failure-diagnostic-1-full-exceptions.json'
        if(Test-Path -LiteralPath $destination){throw 'Permanent full exception summary exists'}
        Copy-Item -LiteralPath (Join-Path $root 'summary.json') -Destination $destination
        Get-Content -LiteralPath (Join-Path $TaskRoot 'exception-summary-d1.log') -Tail 2
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $leases}
