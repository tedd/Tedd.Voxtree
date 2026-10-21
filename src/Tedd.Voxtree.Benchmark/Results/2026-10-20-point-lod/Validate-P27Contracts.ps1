param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$test=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../Tedd.Voxtree.Tests/OwnedLodSnapshotTests.cs')).Path
$paths=@($test,(Join-Path $PSScriptRoot 'PaletteLeafTests.cs.txt'),(Join-Path $PSScriptRoot 'Test-PackedLookup.ps1'))
$hashes=@{};foreach($path in $paths){$hashes[$path]=(Get-FileHash -LiteralPath $path).Hash}
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    foreach($path in $paths){if((Get-FileHash -LiteralPath $path).Hash -ne $hashes[$path]){throw 'Queued contract test dependency changed'}}
    if(Test-Path -LiteralPath (Join-Path $TaskRoot 'packed-lookup-validation-p27contracts')){throw 'Contract validation exists; inspect original results'}
    $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $TaskRoot 'p27contracts-dependencies.json')
    Copy-Item -LiteralPath $test -Destination (Join-Path $TaskRoot 'p27contracts-OwnedLodSnapshotTests.cs.txt')
    & (Join-Path $PSScriptRoot 'Test-PackedLookup.ps1') -TaskRoot $TaskRoot -Label p27contracts -SourceDirectoryName byte-palette-source -FixtureName PaletteLeafTests.cs.txt -PaletteLeaf
} finally {Exit-VoxtreePerformanceHost $lease}
