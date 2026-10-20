param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    if((Test-Path -LiteralPath (Join-Path $TaskRoot 'p18bulk')) -or (Test-Path -LiteralPath (Join-Path $TaskRoot 'p18bulk-screen'))){throw 'Bulk label exists; inspect retained operations before recovery'}
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p18bulk -CandidateSource (Join-Path $TaskRoot 'leaf-helper-inline-source') -FixtureName 'Scenarios-bulk.cs.txt' *> (Join-Path $TaskRoot 'p18bulk-build.log')
    if($LASTEXITCODE -ne 0){throw 'Bulk fixture build failed'}
    Invoke-VoxtreeExternalPhase {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot 'bundles/p18bulk/p18bulk.dll') --validate *> (Join-Path $TaskRoot 'p18bulk-validation.log')
        if($LASTEXITCODE -ne 0){throw 'Bulk full-operation oracle failed'}
        @{fixtureSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Scenarios-bulk.cs.txt')).Hash;protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'BULK-CONSUMER-PROTOCOL.md')).Hash;baseline='f0772c8';candidate='leaf-helper-inline-source';cases=88;budget='bounded-consumer';independentBlocks=$false} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'p18bulk-binding.json')
    }
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p18bulk/p18bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p18bulk-screen') -Filter 'bulk-*' -Label p18bulk -Budget bounded-consumer
} finally {Exit-VoxtreePerformanceHost $leases}
