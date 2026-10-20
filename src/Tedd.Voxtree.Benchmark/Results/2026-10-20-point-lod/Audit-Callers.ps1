param([Parameter(Mandatory)][string]$TaskRoot,
      [ValidatePattern('^caller-audit[a-z0-9-]*$')][string]$Label='caller-audit',
      [string[]]$BundleLabels=@('p7w','p9','p10a','p10b'))
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    $directory=Join-Path $TaskRoot $Label
    if((Test-Path -LiteralPath $directory) -or (Test-Path -LiteralPath (Join-Path $TaskRoot "$Label.json"))){throw 'Caller audit label exists; preserve previous evidence'}
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'CallerAudit.cs.txt') -Destination (Join-Path $directory 'Program.cs')
@'
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><TargetFramework>net10.0</TargetFramework><OutputType>Exe</OutputType><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><UseSharedCompilation>false</UseSharedCompilation></PropertyGroup></Project>
'@ | Set-Content -LiteralPath (Join-Path $directory 'Audit.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $directory 'Audit.csproj') -c Release -o (Join-Path $directory 'out') -v minimal *> (Join-Path $TaskRoot "$Label-build.log")
        if($LASTEXITCODE -ne 0){Get-Content -LiteralPath (Join-Path $TaskRoot "$Label-build.log") -Tail 20;throw 'Caller audit build failed'}
        & dotnet exec --fx-version 10.0.13 (Join-Path $directory 'out/Audit.dll') --selftest *> (Join-Path $TaskRoot "$Label-selftest.log")
        if($LASTEXITCODE -ne 0){Get-Content -LiteralPath (Join-Path $TaskRoot "$Label-selftest.log");throw 'Caller audit falsification failed'}
        $bundles=@($BundleLabels | ForEach-Object {
            if($_ -notmatch '^[a-z][a-z0-9-]*$'){throw 'Invalid bundle label'}
            $path=Join-Path $TaskRoot "bundles/$_/$_.dll"
            if(-not(Test-Path -LiteralPath $path)){throw "Missing caller bundle: $_"}
            $path
        })
        & dotnet exec --fx-version 10.0.13 (Join-Path $directory 'out/Audit.dll') (Join-Path $TaskRoot "$Label.json") @bundles
        if($LASTEXITCODE -ne 0){throw 'Caller audit failed'}
        @{runtime='10.0.13';sourceSha256=(Get-FileHash -LiteralPath (Join-Path $directory 'Program.cs')).Hash;toolSha256=(Get-FileHash -LiteralPath (Join-Path $directory 'out/Audit.dll')).Hash;selftestPassed=$true;bundleLabels=$BundleLabels;observer='metadata-only caller identity audit; no fixture executed'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-identity.json")
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $leases}
