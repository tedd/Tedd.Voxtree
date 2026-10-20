param([Parameter(Mandatory)][string]$TaskRoot,
      [string]$WorldDirectory='D:\SourceCode\Tedd.Forcecraft10\data\Worlds',
      [ValidatePattern('^[a-z][a-z0-9-]*$')][string]$Epoch='s2')
$ErrorActionPreference='Stop'
$expected='D:\Workspaces\AI\voxtree-point-lod-20261020'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne $expected){throw 'Unexpected task root'}
$scanner=Join-Path $TaskRoot "forcecraft-scanner-$Epoch"
New-Item -ItemType Directory -Path $scanner -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Scan-Forcecraft.cs.txt') -Destination (Join-Path $scanner 'Program.cs')
$forcecraft='D:\SourceCode\Tedd.Forcecraft10\src\Tedd.Forcecraft.Common'
Copy-Item -LiteralPath (Join-Path $forcecraft 'Models/BlockTypeArrayCodec.cs') -Destination (Join-Path $scanner 'BlockTypeArrayCodec.cs')
Copy-Item -LiteralPath (Join-Path $forcecraft 'ChunkScratch.cs') -Destination (Join-Path $scanner 'ChunkScratch.cs')
@'
// The offline reader is bound to layout 5, independently of the game's current build setting.
namespace Tedd.Forcecraft.Common;
public static class Constants { public const int ChunkSideLength = 32; }
public static class ChunkGeometry { public const int Side = 32; }
'@ | Set-Content -LiteralPath (Join-Path $scanner 'Layout.cs')
Get-ChildItem -LiteralPath $scanner -Filter '*.cs' | Get-FileHash -Algorithm SHA256 | Select-Object Path,Hash | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot "forcecraft-scanner-sources-$Epoch.json")
@'
<Project Sdk="Microsoft.NET.Sdk">
 <PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><UseSharedCompilation>false</UseSharedCompilation></PropertyGroup>
 <ItemGroup><PackageReference Include="K4os.Compression.LZ4" Version="1.3.8"/></ItemGroup>
</Project>
'@ | Set-Content -LiteralPath (Join-Path $scanner 'Scanner.csproj')
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $scanner 'Scanner.csproj') -c Release -o (Join-Path $scanner 'out') --ignore-failed-sources -v minimal *> (Join-Path $TaskRoot "forcecraft-scanner-build-$Epoch.log")
        if($LASTEXITCODE -ne 0){Get-Content (Join-Path $TaskRoot "forcecraft-scanner-build-$Epoch.log") -Tail 35;throw 'Scanner build failed'}
        & dotnet exec --fx-version 10.0.13 (Join-Path $scanner 'out/Scanner.dll') $WorldDirectory (Join-Path $TaskRoot "forcecraft-census-$Epoch") *> (Join-Path $TaskRoot "forcecraft-census-$Epoch.log")
        Get-Content (Join-Path $TaskRoot "forcecraft-census-$Epoch.log") -Tail 20
        if($LASTEXITCODE -ne 0){throw 'Census failed; retain partial evidence'}
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $leases}
