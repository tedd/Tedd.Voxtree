param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p18count-diagnostic')){throw 'Consumer diagnostic label exists'}
    foreach($label in @('p18control','p18census')){
        foreach($type in @('UInt16','UInt32')){
            & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle (Join-Path $TaskRoot "bundles/$label") -Label "$label-$type-lod-code" -Scenario "point-Force$type-L5-mixed-u16-air-owned-lod" -Methods '*AfterBatchOwned* *TryGetUnchecked* *TryGetTreeUnchecked* *ReadWord* *Value*'
        }
    }
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $TaskRoot 'bundles/p18bulk/p18bulk.dll') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p18count-diagnostic') -SelectedScenarios @('bulk-UInt32-L5-mixed-u16-air-count','bulk-UInt16-L5-mixed-u16-air-count') -Label p18count -Budget bounded-consumer -Profile cpu-diagnostic -JitDisasm '*CountMatches* *CountDense* *ReadDenseValue* *ReadWord* *AfterBatch*' -JitAssembly p18bulk -JitOutput (Join-Path $TaskRoot 'p18count-code.asm')
} finally {Exit-VoxtreePerformanceHost $leases}
