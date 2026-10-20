param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
$fork=Join-Path $TaskRoot 'p4-source'
New-Item -ItemType Directory -Path $fork -Force|Out-Null
Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'n1/source') -Filter '*.cs'|Copy-Item -Destination $fork
$path=Join-Path $fork 'OctreeCodec.cs'
$source=Get-Content -LiteralPath $path -Raw
$start=[regex]::new('        for \(var bit = levels - 1; bit >= 0; bit--\)')
$source=$start.Replace($source,"        var key = global::Tedd.MortonEncoding.Encode((uint)z, (uint)y, (uint)x);`n        for (var bit = levels - 1; bit >= 0; bit--)",1)
$child=[regex]::new('            var child = \(\(\(x >> bit\) & 1\) << 2\) \|\s*\(\(\(y >> bit\) & 1\) << 1\) \|\s*\(\(z >> bit\) & 1\);')
if($child.Matches($source).Count -ne 2){throw 'Unexpected child-selector source shape'}
$source=$child.Replace($source,'            var child = (int)(key >> (bit * 3)) & 7;',1)
Set-Content -LiteralPath $path -Value $source
& (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p4 -BaselineSource (Join-Path $TaskRoot 'n1/source') -CandidateSource $fork
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p4/p4.dll') --validate *> (Join-Path $TaskRoot 'p4-validation.log')
    if($LASTEXITCODE -ne 0){throw 'Morton candidate differential failed'}
} finally {Exit-VoxtreePerformanceHost $leases}
& (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p4/p4.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p4-quiet') -Filter 'point-Legacy-L5-*-owned-[gl]*' -Label p4 -Budget scaled
& (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot 'bundles/p4') -Label p4-key-code -Scenario 'point-Legacy-L5-full-owned-lod'
