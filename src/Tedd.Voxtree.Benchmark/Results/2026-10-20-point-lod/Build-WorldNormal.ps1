param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$fixture=Join-Path $PSScriptRoot 'Scenarios-world-normal.cs.txt';$fixtureHash=(Get-FileHash -LiteralPath $fixture).Hash
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 if((Get-FileHash -LiteralPath $fixture).Hash -ne $fixtureHash){throw 'Queued normal fixture changed'}
 $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p36-prerequisite-audit.json') -Raw|ConvertFrom-Json
 if(-not $gate.passed){throw 'P36 feasibility gate missing'}
 $repo=(Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
 $sdk=(Get-Content -LiteralPath (Join-Path $TaskRoot 'global.json') -Raw|ConvertFrom-Json).sdk.version
 if($sdk -ne '11.0.100-rc.2.26504.105'){throw 'Pinned compiler changed'}
 $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
 $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
 $records=@()
 foreach($label in @('p36n0','p36n1')){
  $folder=Join-Path $TaskRoot "$label-source";$bundle=Join-Path $TaskRoot "bundles/$label"
  if((Test-Path -LiteralPath $folder) -or (Test-Path -LiteralPath $bundle)){throw 'Normal build identity exists; do not overwrite'}
  New-Item -ItemType Directory -Path $folder,$bundle|Out-Null
  $names=@(Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'cache-maintenance-source') -Filter '*.cs'|Select-Object -ExpandProperty Name)
  foreach($n in $names){
   $text=if($label -eq 'p36n0'){(& git -C $repo show "f0772c8:src/Tedd.Voxtree/$n") -join "`n"}else{Get-Content -LiteralPath (Join-Path (Join-Path $TaskRoot 'cache-maintenance-source') $n) -Raw}
   if($LASTEXITCODE -ne 0){throw 'Cannot read published source'}
   Set-Content -LiteralPath (Join-Path $folder $n) -Value $text
  }
  Copy-Item -LiteralPath $fixture -Destination (Join-Path $folder 'Program.cs')
  $lab=[Security.SecurityElement]::Escape($LabDirectory.Replace('\','/'))
  $morton=[Security.SecurityElement]::Escape((Join-Path $TaskRoot 'bundles/p36world/Tedd.MortonEncoding.dll').Replace('\','/'))
  @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><AssemblyName>WorldNormal</AssemblyName><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><LangVersion>14.0</LangVersion><Optimize>true</Optimize><UseSharedCompilation>false</UseSharedCompilation><Deterministic>true</Deterministic><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup>
<Reference Include="Tedd.MortonEncoding"><HintPath>$morton</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Harness"><HintPath>$lab/Tedd.DotNetLab.Harness.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Contracts"><HintPath>$lab/Tedd.DotNetLab.Contracts.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Transport.Local"><HintPath>$lab/Tedd.DotNetLab.Transport.Local.dll</HintPath></Reference>
</ItemGroup></Project>
"@|Set-Content -LiteralPath (Join-Path $folder 'Normal.csproj')
  Push-Location $TaskRoot
  try{
   & dotnet build (Join-Path $folder 'Normal.csproj') -c Release --artifacts-path (Join-Path $TaskRoot "artifacts/$label") -p:ImportDirectoryBuildProps=false -p:ImportDirectoryBuildTargets=false -v minimal *> (Join-Path $TaskRoot "$label-build.log")
   if($LASTEXITCODE -ne 0){throw 'Normal build failed; preserve original label'}
  }finally{Pop-Location}
  $output=Join-Path $TaskRoot "artifacts/$label/bin/Normal/release"
  Get-ChildItem -LiteralPath $output -File|Where-Object{$_.Extension -eq '.dll' -or $_.Name -in @('WorldNormal.deps.json','WorldNormal.runtimeconfig.json')}|Copy-Item -Destination $bundle
  $files=@(Get-ChildItem -LiteralPath $bundle -File|Get-FileHash|Select-Object Path,Hash)
  $files|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json")
  $records+=@(@{label=$label;entry='WorldNormal.dll';source=$folder;files=$files;fixtureSha256=$fixtureHash;runtime='10.0.13';sdk=$sdk})
 }
 $records|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p36-normal-builds.json')
 $records|ForEach-Object{Write-Output "$($_.label): WorldNormal.dll built"}
}finally{Exit-VoxtreePerformanceHost $lease}
