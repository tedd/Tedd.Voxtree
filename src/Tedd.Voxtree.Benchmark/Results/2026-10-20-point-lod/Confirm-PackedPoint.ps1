param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p18control')){throw 'Confirmation source label exists; inspect the existing run'}
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label p18control -CandidateRevision f0772c8 -PrimaryBaselineCaller -FixtureName 'Scenarios-packed-leaf.cs.txt' *> (Join-Path $TaskRoot 'p18control-build.log')
    if($LASTEXITCODE -ne 0){throw 'Control build failed'}
    Invoke-VoxtreeExternalPhase {
        foreach($file in Get-ChildItem -LiteralPath (Join-Path $TaskRoot 'leaf-helper-inline-source') -Filter '*.cs'){
            $actual=Join-Path $TaskRoot "p18census/source/$($file.Name)"
            if((Get-Content -LiteralPath $file.FullName -Raw).Trim() -ne (Get-Content -LiteralPath $actual -Raw).Trim()){throw 'Treatment source differs from selected P18'}
        }
        if((Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p18control/Program.cs')).Hash -ne (Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p18census/Program.cs')).Hash){throw 'Fixture differs'}
        foreach($label in @('p18control','p18census')){
            & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --validate *> (Join-Path $TaskRoot "$label-normal-validation.log")
            if($LASTEXITCODE -ne 0){throw 'Normal-build oracle failed'}
        }
    }
    & (Join-Path $PSScriptRoot 'Audit-Callers.ps1') -TaskRoot $TaskRoot -Label caller-audit-p18normal -BundleLabels @('p18control','p18census')
    Invoke-VoxtreeExternalPhase {
        $audit=@(Get-Content -LiteralPath (Join-Path $TaskRoot 'caller-audit-p18normal.json') -Raw|ConvertFrom-Json -Depth 60)
        if($audit.Count -ne 2 -or $audit[0].methods.Count -ne 8 -or $audit[1].methods.Count -ne 8){throw 'Unexpected caller count'}
        for($i=0;$i -lt 8;$i++){
            if($audit[0].methods[$i].method -ne $audit[1].methods[$i].method -or $audit[0].methods[$i].resolvedIlSha256 -ne $audit[1].methods[$i].resolvedIlSha256){throw 'Resolved primary caller differs'}
        }
        $before=Join-Path $TaskRoot 'bundles/p18control';$after=Join-Path $TaskRoot 'bundles/p18census'
        foreach($file in Get-ChildItem -LiteralPath $before -Filter '*.dll'|Where-Object{$_.Name -ne 'p18control.dll'}){
            if((Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath (Join-Path $after $file.Name)).Hash){throw 'Dependency differs'}
        }
        if((Get-Content -LiteralPath (Join-Path $before 'p18control.runtimeconfig.json') -Raw) -ne (Get-Content -LiteralPath (Join-Path $after 'p18census.runtimeconfig.json') -Raw)){throw 'Runtime settings differ'}
        $patch=& git diff --no-index -- (Join-Path $TaskRoot 'p18control/source') (Join-Path $TaskRoot 'p18census/source')
        if($LASTEXITCODE -ne 1){throw 'Expected a nonempty source patch'}
        $patch | Set-Content -LiteralPath (Join-Path $TaskRoot 'p18normal-source.diff')
        @{protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'PACKED-POINT-CONFIRMATION.md')).Hash;selectedSource='leaf-helper-inline-source';baselineSource='f0772c8';canonicalCallers=8;rawCallersEqual=@($audit[0].methods|Where-Object{$m=$_;@($audit[1].methods|Where-Object{$_.method -eq $m.method -and $_.rawIlSha256 -eq $m.rawIlSha256}).Count -eq 1}).Count;dependencyHashesMatched=$true;runtimeSettingsMatched=$true;fixtureMatched=$true} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $TaskRoot 'p18normal-binding.json')
    }
    $scenarios=@(foreach($type in @('UInt16','UInt32')){foreach($access in @('owned','span')){foreach($op in @('get','lod')){"point-Force$type-L5-mixed-u16-air-$access-$op"}}})
    & (Join-Path $PSScriptRoot 'Confirm.ps1') -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot 'p18-screen') -BaselineBundle (Join-Path $TaskRoot 'bundles/p18control') -CandidateBundle (Join-Path $TaskRoot 'bundles/p18census') -Scenarios $scenarios -ExplorationLabel p18 -Label p18normal -Budget point-window -SourcePatchFile (Join-Path $TaskRoot 'p18normal-source.diff') -SourceEquivalenceRationale 'Fresh complete-source confirmation against f0772c8: both measured variants invoke the same primary-namespace AfterBatch caller. Eight resolved opcode/operand bodies match; raw token hashes are retained separately. The control define maps baseline to AfterBatch outside read loops. The treatment is complete P18 source (P15 packed words, P17 reader split, P18 helper hints); preceding P18 exploration used P17 as control and is not pooled with this epoch. Actual primary-snapshot diff includes every library change and added helper. Exact selected-source binding, matching fixture, dependency DLL hashes and runtime settings are retained. All 48 oracles passed per build. Full offline census passed 1286 chunks and 42139648 cells. Version 12 declares one public read per operation. C3 precision and fallback/build/bulk/query/allocation limitations remain unresolved; this eight-case point family alone cannot authorize adoption.'
} finally {Exit-VoxtreePerformanceHost $leases}
