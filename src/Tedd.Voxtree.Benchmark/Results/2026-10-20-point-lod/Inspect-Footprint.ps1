param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9-]*$')][string]$Label)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    $root=Join-Path $TaskRoot "footprint-$Label"
    if(Test-Path -LiteralPath $root){throw 'Footprint label exists; preserve previous observations'}
    New-Item -ItemType Directory -Path $root | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'FootprintHarness.cs.txt') -Destination (Join-Path $root 'Program.cs')
    $bundle=(Join-Path $TaskRoot "bundles/$Label").Replace('\','/')
    @"
<Project Sdk="Microsoft.NET.Sdk">
 <PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><LangVersion>14.0</LangVersion><Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings><UseSharedCompilation>false</UseSharedCompilation><RollForward>Disable</RollForward><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion></PropertyGroup>
 <ItemGroup><Reference Include="$Label"><HintPath>$bundle/$Label.dll</HintPath></Reference><Reference Include="Tedd.MortonEncoding"><HintPath>$bundle/Tedd.MortonEncoding.dll</HintPath></Reference></ItemGroup>
</Project>
"@ | Set-Content -LiteralPath (Join-Path $root 'Footprint.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $root 'Footprint.csproj') -c Release --artifacts-path (Join-Path $TaskRoot "footprint-artifacts-$Label") -v minimal *> (Join-Path $TaskRoot "$Label-footprint-build.log")
        if($LASTEXITCODE -ne 0){throw 'Footprint build failed'}
        $entry=Join-Path $TaskRoot "footprint-artifacts-$Label/bin/Footprint/release/Footprint.dll"
        & dotnet exec --fx-version 10.0.13 $entry (Join-Path $PSScriptRoot 'forcecraft-corpus.zip') *> (Join-Path $TaskRoot "$Label-footprint.json")
        if($LASTEXITCODE -ne 0){throw 'Footprint oracle failed'}
        @{label=$Label;bundleEntrySha256=(Get-FileHash -LiteralPath (Join-Path $bundle "$Label.dll")).Hash;sourceSha256=(Get-FileHash -LiteralPath (Join-Path $root 'Program.cs')).Hash;observer='external footprint and allocation diagnostic, not quiet latency';joined=$true} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-footprint-identity.json")
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $leases}
