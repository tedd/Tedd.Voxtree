param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$names=@('Prepare-WorldOutline.py','Scenarios-world-normal.cs.txt');$frozen=@{}
foreach($n in $names){$frozen[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 foreach($n in $names){if((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash -ne $frozen[$n]){throw 'Queued outline dependency changed'}}
 & python (Join-Path $PSScriptRoot 'Prepare-WorldOutline.py') $TaskRoot
 if($LASTEXITCODE -ne 0){throw 'Original P37 source preparation failed'}
 $sdk=(Get-Content -LiteralPath (Join-Path $TaskRoot 'global.json') -Raw|ConvertFrom-Json).sdk.version
 if($sdk -ne '11.0.100-rc.2.26504.105'){throw 'Pinned compiler changed'}
 $manifest=Get-Content -LiteralPath (Join-Path $TaskRoot 'p37-source-hashes.json') -Raw|ConvertFrom-Json -AsHashtable
 $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
 $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
 $records=@()
 foreach($label in @('p37n0','p37n1')){
  $source=if($label -eq 'p37n0'){'outline-published-source'}else{'outline-source'}
  $folder=Join-Path $TaskRoot "$label-source";$bundle=Join-Path $TaskRoot "bundles/$label"
  if((Test-Path -LiteralPath $folder) -or (Test-Path -LiteralPath $bundle)){throw 'Normal outline producer exists; preserve original'}
  New-Item -ItemType Directory -Path $folder,$bundle|Out-Null
  foreach($n in $manifest[$source].Keys){
   $path=Join-Path (Join-Path $TaskRoot $source) $n
   if((Get-FileHash -LiteralPath $path).Hash.ToLowerInvariant() -ne $manifest[$source][$n]){throw 'Frozen outline source changed'}
   Copy-Item -LiteralPath $path -Destination $folder
  }
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Scenarios-world-normal.cs.txt') -Destination (Join-Path $folder 'Program.cs')
  $lab=[Security.SecurityElement]::Escape($LabDirectory.Replace('\','/'))
  $morton=[Security.SecurityElement]::Escape((Join-Path $TaskRoot 'bundles/p36n0/Tedd.MortonEncoding.dll').Replace('\','/'))
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
   if($LASTEXITCODE -ne 0){throw 'Original outline build failed; retain identity'}
  }finally{Pop-Location}
  $output=Join-Path $TaskRoot "artifacts/$label/bin/Normal/release"
  Get-ChildItem -LiteralPath $output -File|Where-Object{$_.Extension -eq '.dll' -or $_.Name -in @('WorldNormal.deps.json','WorldNormal.runtimeconfig.json')}|Copy-Item -Destination $bundle
  $files=@(Get-ChildItem -LiteralPath $bundle -File|Get-FileHash|Select-Object Path,Hash)
  $files|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json")
  $records+=@(@{label=$label;sourceName=$source;entry='WorldNormal.dll';source=$folder;files=$files;fixtureSha256=$frozen['Scenarios-world-normal.cs.txt'];runtime='10.0.13';sdk=$sdk})
 }
 $records|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p37-normal-builds.json')
 $records|ForEach-Object{Write-Output "$($_.label): WorldNormal.dll built"}
}finally{Exit-VoxtreePerformanceHost $lease}
