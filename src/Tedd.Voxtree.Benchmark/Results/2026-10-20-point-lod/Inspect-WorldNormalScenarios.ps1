param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 $folder=Join-Path $TaskRoot 'p36-inventory-source';$bundle=Join-Path $TaskRoot 'bundles/p36-inventory'
 if((Test-Path -LiteralPath $folder) -or (Test-Path -LiteralPath $bundle)){throw 'Scenario inventory identity exists'}
 New-Item -ItemType Directory -Path $folder|Out-Null
 Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'WorldScenarioInventory.cs.txt') -Destination (Join-Path $folder 'Program.cs')
 '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><UseSharedCompilation>false</UseSharedCompilation><AssemblyName>WorldScenarioInventory</AssemblyName><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup></Project>'|Set-Content -LiteralPath (Join-Path $folder 'Inventory.csproj')
 $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
 Push-Location $TaskRoot
 try{
  & dotnet build (Join-Path $folder 'Inventory.csproj') -c Release -o $bundle -p:ImportDirectoryBuildProps=false -p:ImportDirectoryBuildTargets=false -v minimal *> (Join-Path $TaskRoot 'p36-inventory-build.log')
  if($LASTEXITCODE -ne 0){throw 'Inventory build failed'}
  & dotnet exec --fx-version 10.0.13 (Join-Path $bundle 'WorldScenarioInventory.dll') (Join-Path $TaskRoot 'p36-normal-scenarios.json') (Join-Path $TaskRoot 'bundles/p36n0/WorldNormal.dll') (Join-Path $TaskRoot 'bundles/p36n1/WorldNormal.dll') *> (Join-Path $TaskRoot 'p36-inventory.log')
  if($LASTEXITCODE -ne 0){throw 'Original scenario inventory failed; retain without replacement'}
  Get-Content -LiteralPath (Join-Path $TaskRoot 'p36-inventory.log')
 }finally{Pop-Location}
}finally{Exit-VoxtreePerformanceHost $lease}
