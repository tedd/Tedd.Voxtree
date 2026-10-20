param(
    [Parameter(Mandatory)][string]$TaskRoot,
    [Parameter(Mandatory)][string]$LabDirectory,
    [string]$Label = 'rig',
    [string]$BaselineRevision = 'f0772c8',
    [string]$CandidateRevision = '',
    [string]$BaselineSource = '',
    [string]$CandidateSource = '',
    [switch]$PrimaryBaselineCaller,
    [string]$Sdk = '11.0.100-rc.2.26504.105'
)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
$TaskRoot = [IO.Path]::GetFullPath($TaskRoot)
if (-not $TaskRoot.StartsWith('D:\Workspaces\AI\', [StringComparison]::OrdinalIgnoreCase)) { throw 'TaskRoot must be under D:\Workspaces\AI' }
$rigDirectory = Join-Path $TaskRoot $Label
$baselineDirectory = Join-Path $TaskRoot "$Label-baseline"
$candidateDirectory = Join-Path $rigDirectory 'source'
New-Item -ItemType Directory -Path $rigDirectory,$baselineDirectory,$candidateDirectory,(Join-Path $TaskRoot 'temp') -Force | Out-Null
$env:TEMP = Join-Path $TaskRoot 'temp'; $env:TMP = $env:TEMP
$env:NUGET_HTTP_CACHE_PATH = Join-Path $TaskRoot 'nuget-http'
@{sdk=@{version=$Sdk;rollForward='disable'}} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'global.json')
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$hostLeases = Enter-VoxtreePerformanceHost
try {
    $baselineFiles = @(& git -C $repoRoot ls-tree -r --name-only $BaselineRevision -- src/Tedd.Voxtree)
    $candidateFiles = if ($CandidateRevision) { @(& git -C $repoRoot ls-tree -r --name-only $CandidateRevision -- src/Tedd.Voxtree) } else { @() }
    foreach ($file in Get-ChildItem (Join-Path $repoRoot 'src/Tedd.Voxtree') -Filter '*.cs') {
        $relative = 'src/Tedd.Voxtree/' + $file.Name
        if ($baselineFiles -contains $relative) {
            if ($BaselineSource) {
                $original = Get-Content -LiteralPath (Join-Path $BaselineSource $file.Name) -Raw
            } else {
                $original = (& git -C $repoRoot show "${BaselineRevision}:$relative") -join "`n"
                if ($LASTEXITCODE -ne 0) { throw "Cannot snapshot $relative" }
            }
            $original.Replace('Tedd.Voxtree','Snapshot.Voxtree') | Set-Content -LiteralPath (Join-Path $baselineDirectory $file.Name)
        }
        if ($CandidateSource) {
            $current = Get-Content -LiteralPath (Join-Path $CandidateSource $file.Name) -Raw
        } elseif ($CandidateRevision) {
            if ($candidateFiles -notcontains $relative) { continue }
            $current = (& git -C $repoRoot show "${CandidateRevision}:$relative") -join "`n"
            if ($LASTEXITCODE -ne 0) { throw "Cannot snapshot $relative" }
        } else { $current = Get-Content -LiteralPath $file.FullName -Raw }
        Set-Content -LiteralPath (Join-Path $candidateDirectory $file.Name) -Value $current
    }
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Scenarios.cs.txt') -Destination (Join-Path $rigDirectory 'Program.cs')


    $escapedLab = [Security.SecurityElement]::Escape($LabDirectory.Replace('\','/'))
    $escapedBaseline = [Security.SecurityElement]::Escape($baselineDirectory.Replace('\','/'))
    $callerDefine = if($PrimaryBaselineCaller){'<DefineConstants>PRIMARY_BASELINE_CALLER</DefineConstants>'}else{''}
    @"
<Project Sdk="Microsoft.NET.Sdk">
<PropertyGroup><TargetFramework>net10.0</TargetFramework><OutputType>Exe</OutputType><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><LangVersion>14.0</LangVersion><Optimize>true</Optimize><UseSharedCompilation>false</UseSharedCompilation><AssemblyName>$Label</AssemblyName><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward>$callerDefine</PropertyGroup>
<ItemGroup><Compile Include="$escapedBaseline/*.cs"/></ItemGroup>
<ItemGroup><PackageReference Include="Tedd.MortonEncoding" Version="1.0.1"/>
<Reference Include="Tedd.DotNetLab.Harness"><HintPath>$escapedLab/Tedd.DotNetLab.Harness.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Contracts"><HintPath>$escapedLab/Tedd.DotNetLab.Contracts.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Transport.Local"><HintPath>$escapedLab/Tedd.DotNetLab.Transport.Local.dll</HintPath></Reference>
</ItemGroup></Project>
"@ | Set-Content -LiteralPath (Join-Path $rigDirectory 'Rig.csproj')
    Push-Location $TaskRoot
    try {
        dotnet build (Join-Path $rigDirectory 'Rig.csproj') -c Release --artifacts-path (Join-Path $TaskRoot "artifacts/$Label") --nologo -v q
        if ($LASTEXITCODE -ne 0) { throw 'Rig build failed' }
    } finally { Pop-Location }
    $outputDirectory = Join-Path $TaskRoot "artifacts/$Label/bin/Rig/release"
    $bundle = Join-Path $TaskRoot "bundles/$Label"
    New-Item -ItemType Directory -Path $bundle -Force | Out-Null
    Get-ChildItem $outputDirectory -File | Where-Object { $_.Extension -eq '.dll' -or $_.Name -in "$Label.deps.json","$Label.runtimeconfig.json" } |
        Copy-Item -Destination $bundle
    $depsPath = Join-Path $bundle "$Label.deps.json"
    $deps = Get-Content -LiteralPath $depsPath -Raw | ConvertFrom-Json -AsHashtable -Depth 60
    foreach ($target in $deps.targets.Values) {
        foreach ($library in $target.Values) {
            if ($library.ContainsKey('runtime')) {
                $flat = [ordered]@{}
                foreach ($asset in $library.runtime.Keys) { $flat[[IO.Path]::GetFileName($asset)] = $library.runtime[$asset] }
                $library.runtime = $flat
            }
        }
    }
    $deps | ConvertTo-Json -Depth 60 | Set-Content -LiteralPath $depsPath
    Get-ChildItem $bundle -File | Get-FileHash -Algorithm SHA256 | Select-Object Hash,Path |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-hashes.json")
    Write-Output (Join-Path $bundle "$Label.dll")
} finally { Exit-VoxtreePerformanceHost $hostLeases }
