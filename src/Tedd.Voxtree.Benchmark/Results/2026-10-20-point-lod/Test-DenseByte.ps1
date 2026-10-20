param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
$validation=Join-Path $TaskRoot 'dense-byte-validation'
New-Item -ItemType Directory -Path $validation,(Join-Path $validation 'tests') -Force|Out-Null
$escapedRepo=[Security.SecurityElement]::Escape($repoRoot.Replace('\','/'))
@'
<Project Sdk="Microsoft.NET.Sdk">
 <PropertyGroup><TargetFrameworks>net11.0;net10.0;netstandard2.1</TargetFrameworks><LangVersion>14.0</LangVersion><Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings><EnableDefaultCompileItems>false</EnableDefaultCompileItems><UseSharedCompilation>false</UseSharedCompilation><AssemblyName>Tedd.Voxtree</AssemblyName></PropertyGroup>
 <ItemGroup><Compile Include="../dense-byte-source/*.cs"/><PackageReference Include="Tedd.MortonEncoding" Version="1.0.1"/></ItemGroup>
 <ItemGroup Condition="'$(TargetFramework)'=='netstandard2.1'"><PackageReference Include="System.Runtime.CompilerServices.Unsafe" Version="6.1.2"/></ItemGroup>
</Project>
'@|Set-Content (Join-Path $validation 'Library.csproj')
@"
<Project Sdk="Microsoft.NET.Sdk">
 <PropertyGroup><TargetFrameworks>net11.0;net10.0;net8.0</TargetFrameworks><LangVersion>12.0</LangVersion><Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings><EnableDefaultCompileItems>false</EnableDefaultCompileItems><IsPackable>false</IsPackable><IsTestProject>true</IsTestProject><UseSharedCompilation>false</UseSharedCompilation></PropertyGroup>
 <ItemGroup>
  <Compile Include="$escapedRepo/src/Tedd.Voxtree.Tests/*.cs" Exclude="$escapedRepo/src/Tedd.Voxtree.Tests/CompiledLeafGridTests.cs"/>
  <Compile Include="$escapedRepo/src/Shared/SimulationWorkload.cs"/>
  <ProjectReference Include="../Library.csproj"/>
  <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1"/>
  <PackageReference Include="xunit" Version="2.9.3"/>
  <PackageReference Include="xunit.runner.visualstudio" Version="3.1.5"/>
 </ItemGroup>
</Project>
"@|Set-Content (Join-Path $validation 'tests/Tests.csproj')
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    Push-Location $TaskRoot
    try {
        & dotnet test (Join-Path $validation 'tests/Tests.csproj') -c Release --artifacts-path (Join-Path $TaskRoot 'tests-dense-byte') --logger trx --results-directory (Join-Path $TaskRoot 'dense-byte-results') -v minimal *> (Join-Path $TaskRoot 'dense-byte-tests.log')
        $testExit=$LASTEXITCODE
        Get-Content (Join-Path $TaskRoot 'dense-byte-tests.log') -Tail 30
        if($testExit -ne 0){throw 'Prototype regression failures retained for localization'}
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $leases}
