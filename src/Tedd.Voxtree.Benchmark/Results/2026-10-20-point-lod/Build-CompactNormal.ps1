param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$fixture=Join-Path $PSScriptRoot 'Scenarios-compact-normal-storage.cs.txt';$frozen=(Get-FileHash -LiteralPath $fixture).Hash
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 if((Get-FileHash -LiteralPath $fixture).Hash -ne $frozen){throw 'Queued fixture changed'}
 $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-prerequisite-audit.json') -Raw|ConvertFrom-Json -Depth 90
 if(-not $gate.passed -or $gate.comparativeTimingRecords -ne 0){throw 'Original P39 prerequisites incomplete'}
 $origin=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-source-origin.json') -Raw|ConvertFrom-Json -Depth 60
 $sdk=(Get-Content -LiteralPath (Join-Path $TaskRoot 'global.json') -Raw|ConvertFrom-Json).sdk.version
 if($sdk -ne '11.0.100-rc.2.26504.105'){throw 'Pinned compiler changed'}
 $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
 $records=@()
 foreach($label in @('p39n2','p39n3')){
  $source=if($label -eq 'p39n2'){'compact-leaf13-source'}else{'compact-terminal-source'}
  $folder=Join-Path $TaskRoot "$label-source";$bundle=Join-Path $TaskRoot "bundles/$label"
  if((Test-Path -LiteralPath $folder) -or (Test-Path -LiteralPath $bundle)){throw 'Original compact normal build exists; preserve it'}
  New-Item -ItemType Directory -Path $folder,$bundle|Out-Null
  foreach($row in $origin.manifest){
   $path=Join-Path (Join-Path $TaskRoot $source) $row.file;$expected=if($label -eq 'p39n2'){$row.beforeSha256}else{$row.afterSha256}
   if((Get-FileHash -LiteralPath $path).Hash.ToLowerInvariant() -ne $expected){throw 'Selected source changed'}
   Copy-Item -LiteralPath $path -Destination $folder
  }
  Copy-Item -LiteralPath $fixture -Destination (Join-Path $folder 'Program.cs')
  $lab=[Security.SecurityElement]::Escape($LabDirectory.Replace('\','/'))
  $morton=[Security.SecurityElement]::Escape((Join-Path $TaskRoot 'bundles/p39census/Tedd.MortonEncoding.dll').Replace('\','/'))
  @"
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework><AssemblyName>CompactNormal</AssemblyName><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><LangVersion>14.0</LangVersion><Optimize>true</Optimize><UseSharedCompilation>false</UseSharedCompilation><Deterministic>true</Deterministic><RuntimeFrameworkVersion>10.0.13</RuntimeFrameworkVersion><RollForward>Disable</RollForward></PropertyGroup><ItemGroup>
<Reference Include="Tedd.MortonEncoding"><HintPath>$morton</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Harness"><HintPath>$lab/Tedd.DotNetLab.Harness.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Contracts"><HintPath>$lab/Tedd.DotNetLab.Contracts.dll</HintPath></Reference>
<Reference Include="Tedd.DotNetLab.Transport.Local"><HintPath>$lab/Tedd.DotNetLab.Transport.Local.dll</HintPath></Reference>
</ItemGroup></Project>
"@|Set-Content -LiteralPath (Join-Path $folder 'Normal.csproj')
  Push-Location $TaskRoot
  try{
   & dotnet build (Join-Path $folder 'Normal.csproj') -c Release --artifacts-path (Join-Path $TaskRoot "artifacts/$label") -p:ImportDirectoryBuildProps=false -p:ImportDirectoryBuildTargets=false -v minimal *> (Join-Path $TaskRoot "$label-build.log")
   if($LASTEXITCODE -ne 0){Get-Content -LiteralPath (Join-Path $TaskRoot "$label-build.log") -Tail 12;throw 'Original compact normal build failed; preserve identity'}
  }finally{Pop-Location}
  $output=Join-Path $TaskRoot "artifacts/$label/bin/Normal/release"
  Get-ChildItem -LiteralPath $output -File|Where-Object{$_.Extension -eq '.dll' -or $_.Name -in @('CompactNormal.deps.json','CompactNormal.runtimeconfig.json')}|Copy-Item -Destination $bundle
  $files=@(Get-ChildItem -LiteralPath $bundle -File|Get-FileHash|Select-Object Path,Hash);$files|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot "$label-hashes.json")
  $records+=@(@{label=$label;entry='CompactNormal.dll';sourceName=$source;source=$folder;files=$files;fixtureSha256=$frozen;runtime='10.0.13';sdk=$sdk})
 }
 $records|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-normal-storage-builds.json')
 $records|ForEach-Object{Write-Output "$($_.label): CompactNormal.dll built"}
}finally{Exit-VoxtreePerformanceHost $lease}
