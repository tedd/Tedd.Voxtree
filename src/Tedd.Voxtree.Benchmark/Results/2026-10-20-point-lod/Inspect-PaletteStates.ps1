param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $root=Join-Path $TaskRoot 'palette-state-j1-source';$output=Join-Path $TaskRoot 'forcecraft-census-palette-j1'
    if((Test-Path -LiteralPath $root) -or (Test-Path -LiteralPath $output) -or (Test-Path -LiteralPath (Join-Path $TaskRoot 'j1-hypothesis'))){throw 'J1 identity exists; preserve original work'}
    & (Join-Path $PSScriptRoot 'Register-Hypothesis.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label j1 -ProtocolName 'PALETTE-STATE-CENSUS-PROTOCOL.md' -Mechanism 'A12/M05/M25: byte joint value/LOD state indexes may reduce the expanded P24 word payload while preserving every value bit. Measure full-corpus state cardinality and a prespecified table/index layout before selecting or implementing it.' -Prediction 'The preselected dominant mixed-u16-air sample fits <=256 exact joint states, released maximum capacity and <=1.25 released encoded bytes. Preserve every excluded chunk and all raw cardinalities. Projection supplies no point/build/query speed or promotion claim.'
    $archive=Join-Path $PSScriptRoot 'evidence-phase10.zip'
    $expected=((Get-Content -LiteralPath (Join-Path $PSScriptRoot 'evidence-phase10.sha256') -Raw).Split(' ',[StringSplitOptions]::RemoveEmptyEntries))[0]
    if((Get-FileHash -LiteralPath $archive).Hash.ToLowerInvariant() -ne $expected){throw 'Parent archive changed'}
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip=[IO.Compression.ZipFile]::OpenRead($archive)
    try {
        $reader=[IO.StreamReader]::new($zip.GetEntry('manifest.json').Open())
        try {$manifest=$reader.ReadToEnd()|ConvertFrom-Json -Depth 20} finally {$reader.Dispose()}
        $entries=@($manifest|Where-Object{$_.path.StartsWith('bundles/p24census/')})
        $bundle=Join-Path $TaskRoot 'bundles/p24census'
        if(@(Get-ChildItem -LiteralPath $bundle -File).Count -ne $entries.Count -or $entries.Count -ne 7){throw 'Parent bundle closure changed'}
        foreach($entry in $entries){if((Get-FileHash -LiteralPath (Join-Path $TaskRoot $entry.path)).Hash.ToLowerInvariant() -ne $entry.sha256){throw 'Parent bundle hash mismatch'}}
    } finally {$zip.Dispose()}
    $snapshot=Join-Path $TaskRoot 'forcecraft-snapshot-s1'
    $regions=@(Get-Content -LiteralPath (Join-Path $TaskRoot 'forcecraft-snapshot-s1.json') -Raw|ConvertFrom-Json)
    if(@(Get-ChildItem -LiteralPath $snapshot -Filter '*.region' -Recurse).Count -ne $regions.Count){throw 'Region snapshot inventory changed'}
    foreach($region in $regions){$file=Join-Path $snapshot $region.region;if((Get-Item -LiteralPath $file).Length -ne $region.bytes -or (Get-FileHash -LiteralPath $file).Hash -ne $region.sha256){throw 'Region snapshot hash mismatch'}}
    New-Item -ItemType Directory -Path $root|Out-Null
    $program=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Scan-Forcecraft.cs.txt') -Raw
    foreach($anchor in @('var cache = new Dictionary<string, Statistics>();','if (!cache.TryGetValue(hash, out var stats))','csv.Flush();')){if(([regex]::Matches($program,[regex]::Escape($anchor))).Count -ne 1){throw 'Scanner hook changed'}}
    $program=$program.Replace('var cache = new Dictionary<string, Statistics>();',"PaletteStateCensus.Begin(output);`nvar cache = new Dictionary<string, Statistics>();")
    $program=$program.Replace('if (!cache.TryGetValue(hash, out var stats))',"PaletteStateCensus.Check(voxels, relative, slot, hash);`n        if (!cache.TryGetValue(hash, out var stats))")
    $program=$program.Replace('csv.Flush();',"csv.Flush();`nPaletteStateCensus.Finish();")
    $program|Set-Content -LiteralPath (Join-Path $root 'Program.cs')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PaletteStateCensus.cs.txt') -Destination (Join-Path $root 'PaletteStateCensus.cs')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'PALETTE-STATE-CENSUS-PROTOCOL.md') -Destination (Join-Path $TaskRoot 'j1-frozen-protocol.txt')
    foreach($name in @('BlockTypeArrayCodec.cs','ChunkScratch.cs','Layout.cs')){Copy-Item -LiteralPath (Join-Path $TaskRoot "forcecraft-scanner-s2/$name") -Destination (Join-Path $root $name)}
    $bundleXml=[Security.SecurityElement]::Escape($bundle.Replace('\','/'))
    @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><LangVersion>14.0</LangVersion><Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings><UseSharedCompilation>false</UseSharedCompilation><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup>
<Reference Include="p24census"><HintPath>$bundleXml/p24census.dll</HintPath></Reference><Reference Include="Tedd.MortonEncoding"><HintPath>$bundleXml/Tedd.MortonEncoding.dll</HintPath></Reference><PackageReference Include="K4os.Compression.LZ4" Version="1.3.8"/>
</ItemGroup></Project>
"@|Set-Content -LiteralPath (Join-Path $root 'Census.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $root 'Census.csproj') -c Release -o (Join-Path $root 'out') -v minimal *> (Join-Path $TaskRoot 'j1-build.log')
        if($LASTEXITCODE -ne 0){throw 'J1 census build failed'}
        if((Get-FileHash -LiteralPath (Join-Path $root 'out/p24census.dll')).Hash -ne (Get-FileHash -LiteralPath (Join-Path $bundle 'p24census.dll')).Hash){throw 'J1 resolved a different library'}
        & dotnet exec --fx-version 10.0.13 (Join-Path $root 'out/Census.dll') $snapshot $output *> (Join-Path $TaskRoot 'j1-census.log')
        if($LASTEXITCODE -ne 0){throw 'J1 census failed; retain partial output'}
        @{entrySha256=(Get-FileHash -LiteralPath (Join-Path $root 'out/Census.dll')).Hash;parentArchiveSha256=$expected;parentBundle=$entries;exitCode=0;joined=$true;scope='Offline semantic/cardinality census; no latency or allocation claim';sources=@(Get-ChildItem -LiteralPath $root -File|Get-FileHash|Select-Object Path,Hash)}|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'j1-identity.json')
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $lease}
