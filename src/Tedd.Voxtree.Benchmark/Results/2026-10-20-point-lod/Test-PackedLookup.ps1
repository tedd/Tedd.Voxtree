param([Parameter(Mandatory)][string]$TaskRoot,[ValidatePattern('^[a-z][a-z0-9-]*$')][string]$Label='p7b',
      [ValidatePattern('^[a-z][a-z0-9-]*$')][string]$SourceDirectoryName='packed-lookup-source',
      [string]$FixtureName='PackedLookupTests.cs.txt',
      [switch]$JointStates,
      [switch]$DirectStates,
      [switch]$ByteEncoding,
      [switch]$PackedLeaf,
      [switch]$WordStorage)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path.Replace('\','/')
$validation=Join-Path $TaskRoot "packed-lookup-validation-$Label"
New-Item -ItemType Directory -Path $validation,(Join-Path $validation 'tests') -Force | Out-Null
$excludedTests="$repo/src/Tedd.Voxtree.Tests/CompiledLeafGridTests.cs"
Copy-Item -LiteralPath (Join-Path $PSScriptRoot $FixtureName) -Destination (Join-Path $validation 'tests/PackedLookupTests.cs')
if($WordStorage){
    $testPath=Join-Path $validation 'tests/PackedLookupTests.cs'
    $text=Get-Content -LiteralPath $testPath -Raw
    $anchor='values.Length / 2 + values.Length / 16 + entries * 4, lookup.StorageBytes'
    if(-not $text.Contains($anchor)){throw 'Packed-word test expectation anchor changed'}
    $text.Replace($anchor,'values.Length / 2 + values.Length / 16 + 64, lookup.StorageBytes') | Set-Content -LiteralPath $testPath
}
if($JointStates -or $DirectStates -or $ByteEncoding -or $PackedLeaf){
    $text=Get-Content -LiteralPath (Join-Path $repo 'src/Tedd.Voxtree.Tests/OctreeLookupTests.cs') -Raw
    $anchor='Assert.Equal(((source.Length - 1) / 7 - 1) * 36, lookup.StorageBytes);'
    if(-not $text.Contains($anchor)){throw 'Original node-payload assertion changed'}
    if($ByteEncoding -or $PackedLeaf){
        $kindAnchor='Assert.Equal(0, encoded[1] & 3);'
        if(-not $text.Contains($kindAnchor)){throw 'Original full-tree encoding assertion changed'}
        $text=$text.Replace($kindAnchor,'Assert.Equal(levels >= 3 && !wide ? 3 : 0, encoded[1] & 3);')
        if($PackedLeaf){$text=$text.Replace($anchor,'Assert.Equal(2 + source.Length * 4, lookup.StorageBytes);')}
    }else{
        $replacement=if($DirectStates){'Assert.Equal(source.Length * 8, lookup.StorageBytes);'}else{'Assert.Equal(source.Length + 33 * 8, lookup.StorageBytes);'}
        $text=$text.Replace($anchor,$replacement)
    }
    $text | Set-Content -LiteralPath (Join-Path $validation 'tests/OctreeLookupTests.cs')
    $excludedTests+=";$repo/src/Tedd.Voxtree.Tests/OctreeLookupTests.cs"
}
@{source=$SourceDirectoryName;fixture=$FixtureName;wordStorage=[bool]$WordStorage;jointStates=[bool]$JointStates;directStates=[bool]$DirectStates;byteEncoding=[bool]$ByteEncoding;packedLeaf=[bool]$PackedLeaf;testSha256=(Get-FileHash -LiteralPath (Join-Path $validation 'tests/PackedLookupTests.cs')).Hash;lookupTestsSha256=$(if($JointStates -or $DirectStates -or $ByteEncoding -or $PackedLeaf){(Get-FileHash -LiteralPath (Join-Path $validation 'tests/OctreeLookupTests.cs')).Hash}else{$null})} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot "packed-lookup-test-options-$Label.json")
@'
<Project Sdk="Microsoft.NET.Sdk">
 <PropertyGroup><TargetFrameworks>net11.0;net10.0;netstandard2.1</TargetFrameworks><LangVersion>14.0</LangVersion><Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings><EnableDefaultCompileItems>false</EnableDefaultCompileItems><UseSharedCompilation>false</UseSharedCompilation><AssemblyName>Tedd.Voxtree</AssemblyName></PropertyGroup>
 <ItemGroup><Compile Include="../packed-lookup-source/*.cs"/><PackageReference Include="Tedd.MortonEncoding" Version="1.0.1"/></ItemGroup>
 <ItemGroup Condition="'$(TargetFramework)'=='netstandard2.1'"><PackageReference Include="System.Runtime.CompilerServices.Unsafe" Version="6.1.2"/></ItemGroup>
</Project>
'@.Replace('../packed-lookup-source/',"../$SourceDirectoryName/") | Set-Content -LiteralPath (Join-Path $validation 'Library.csproj')
@"
<Project Sdk="Microsoft.NET.Sdk">
 <PropertyGroup><TargetFrameworks>net11.0;net10.0;net8.0</TargetFrameworks><LangVersion>12.0</LangVersion><Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings><IsTestProject>true</IsTestProject><UseSharedCompilation>false</UseSharedCompilation></PropertyGroup>
 <ItemGroup><Compile Include="$repo/src/Tedd.Voxtree.Tests/*.cs" Exclude="$excludedTests"/><Compile Include="$repo/src/Shared/SimulationWorkload.cs"/><ProjectReference Include="../Library.csproj"/><PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1"/><PackageReference Include="xunit" Version="2.9.3"/><PackageReference Include="xunit.runner.visualstudio" Version="3.1.5"/></ItemGroup>
</Project>
"@ | Set-Content -LiteralPath (Join-Path $validation 'tests/Tests.csproj')
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    Push-Location $TaskRoot
    try {
        & dotnet test (Join-Path $validation 'tests/Tests.csproj') -c Release --artifacts-path (Join-Path $TaskRoot "tests-packed-lookup-$Label") --logger trx --results-directory (Join-Path $TaskRoot "packed-lookup-$Label-results") -v minimal *> (Join-Path $TaskRoot "packed-lookup-tests-$Label.log")
        $result=$LASTEXITCODE
        Get-Content -LiteralPath (Join-Path $TaskRoot "packed-lookup-tests-$Label.log") -Tail 25
        if($result -ne 0){throw 'Packed-lookup regression failed; retain and localize'}
    } finally {Pop-Location}
} finally {Exit-VoxtreePerformanceHost $leases}
