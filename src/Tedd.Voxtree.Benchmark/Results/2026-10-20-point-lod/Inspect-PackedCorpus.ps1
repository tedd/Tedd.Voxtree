param([Parameter(Mandatory)][string]$TaskRoot,
      [Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9-]*$')][string]$Label,
      [switch]$ReleaseBuilder)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    $root=Join-Path $TaskRoot "packed-corpus-$Label-source"
    $output=Join-Path $TaskRoot "forcecraft-census-packed-$Label"
    if((Test-Path -LiteralPath $root) -or (Test-Path -LiteralPath $output)){throw 'Census label exists; preserve previous observations'}
    $snapshot=Join-Path $TaskRoot 'forcecraft-snapshot-s1'
    $manifest=@(Get-Content -LiteralPath (Join-Path $TaskRoot 'forcecraft-snapshot-s1.json') -Raw | ConvertFrom-Json)
    if(@(Get-ChildItem -LiteralPath $snapshot -Filter '*.region' -Recurse).Count -ne $manifest.Count){throw 'Snapshot file count changed'}
    foreach($entry in $manifest){
        $path=Join-Path $snapshot $entry.region
        if((Get-Item -LiteralPath $path).Length -ne $entry.bytes -or (Get-FileHash -LiteralPath $path).Hash -ne $entry.sha256){throw 'Snapshot hash changed'}
    }
    New-Item -ItemType Directory -Path $root | Out-Null
    $program=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Scan-Forcecraft.cs.txt') -Raw
    foreach($anchor in @('var cache = new Dictionary<string, Statistics>();','if (!cache.TryGetValue(hash, out var stats))','csv.Flush();')){
        if(([regex]::Matches($program,[regex]::Escape($anchor))).Count -ne 1){throw 'Scanner hook changed'}
    }
    $program=$program.Replace('var cache = new Dictionary<string, Statistics>();','PackedCorpus.Begin(output);' + [Environment]::NewLine + 'var cache = new Dictionary<string, Statistics>();')
    $program=$program.Replace('if (!cache.TryGetValue(hash, out var stats))','PackedCorpus.Check(voxels, relative, slot, hash);' + [Environment]::NewLine + '        if (!cache.TryGetValue(hash, out var stats))')
    $program=$program.Replace('csv.Flush();','csv.Flush();' + [Environment]::NewLine + 'PackedCorpus.Finish();')
    $program | Set-Content -LiteralPath (Join-Path $root 'Program.cs')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PackedCorpus.cs.txt') -Destination (Join-Path $root 'PackedCorpus.cs')
    foreach($name in @('BlockTypeArrayCodec.cs','ChunkScratch.cs','Layout.cs')){
        Copy-Item -LiteralPath (Join-Path $TaskRoot "forcecraft-scanner-s2/$name") -Destination (Join-Path $root $name)
    }
    $bundle=(Join-Path $TaskRoot "bundles/$Label").Replace('\','/')
    $censusDefine=if($ReleaseBuilder){'<DefineConstants>RELEASE_BUILDER_CENSUS</DefineConstants>'}else{''}
    @"
<Project Sdk="Microsoft.NET.Sdk">
 <PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><LangVersion>14.0</LangVersion><Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings><UseSharedCompilation>false</UseSharedCompilation><RollForward>Disable</RollForward><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion>$censusDefine</PropertyGroup>
 <ItemGroup><Reference Include="$Label"><HintPath>$bundle/$Label.dll</HintPath></Reference><Reference Include="Tedd.MortonEncoding"><HintPath>$bundle/Tedd.MortonEncoding.dll</HintPath></Reference><PackageReference Include="K4os.Compression.LZ4" Version="1.3.8"/></ItemGroup>
</Project>
"@ | Set-Content -LiteralPath (Join-Path $root 'Census.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $root 'Census.csproj') -c Release --artifacts-path (Join-Path $TaskRoot "packed-corpus-artifacts-$Label") -v minimal *> (Join-Path $TaskRoot "$Label-packed-corpus-build.log")
        if($LASTEXITCODE -ne 0){throw 'Census build failed'}
        $entry=Join-Path $TaskRoot "packed-corpus-artifacts-$Label/bin/Census/release/Census.dll"
        $retained=Join-Path $root 'out'
        New-Item -ItemType Directory -Path $retained | Out-Null
        Get-ChildItem -LiteralPath (Split-Path $entry) -File | Where-Object{$_.Extension -in '.dll','.json'} | Copy-Item -Destination $retained
        & dotnet exec --fx-version 10.0.13 $entry $snapshot $output *> (Join-Path $TaskRoot "$Label-packed-corpus.log")
        if($LASTEXITCODE -ne 0){throw 'Census oracle failed; retain partial records'}
        $identity=@{label=$Label;bundleEntrySha256=(Get-FileHash -LiteralPath (Join-Path $bundle "$Label.dll")).Hash;diagnosticEntrySha256=(Get-FileHash -LiteralPath $entry).Hash;observer='offline semantic and payload census; no latency or allocation claim';joined=$true;exitCode=0;sources=@(Get-ChildItem -LiteralPath $root -File|Get-FileHash|Select-Object Path,Hash)}
        $identity | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-packed-corpus-identity.json")
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $leases}
