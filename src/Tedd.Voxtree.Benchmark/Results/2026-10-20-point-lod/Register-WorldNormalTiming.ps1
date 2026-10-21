param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Validated controller changed'}
 & python (Join-Path $PSScriptRoot 'Prepare-WorldNormalTiming.py') $TaskRoot
 if($LASTEXITCODE -ne 0){throw 'Normal first-family binding failed'}
 $root=Join-Path $TaskRoot 'p36-normal-screen'
 & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
 if($LASTEXITCODE -ne 0){throw 'Normal first-family catalog initialization failed'}
 $inputs=Get-Content -LiteralPath (Join-Path $root 'inputs.json') -Raw|ConvertFrom-Json -Depth 80
 $artifact=Import-File (Join-Path $root 'inputs.json') application/json
 $hypothesis=Invoke-Lab lab.experiment @{action='create_hypothesis';mechanism='Selected P36 before new time data: exact ordered incremental cache maintenance removes full rebuild work, with unchanged fields/read source and canonical probe counts. Version22 single-library normal modules share caller IL, assembly identity, deps/runtime settings; no namespace arm or P34/P35 source. Hash seeds/heap placement remain fresh-process nuisance variables.';prediction='Complete fixed first normal family: six cycling12 primary speedups target1.10; six repeated-hit cost guards1.05; retain allocation policy/flags. Twelve fresh paired blocks per case,288 joined correct sessions. Classify futility/guarded harm only from usable frozen intervals, never four-pair point estimates. No source adoption or full10x claim; all remaining qualifications stay open.';evidence_ids=@($artifact.id)}
 $hypothesis|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis.json')
 $builds=@()
 foreach($bundle in $inputs.bundles){
  $files=@(foreach($file in $bundle.files){
   if((Get-FileHash -LiteralPath $file.path).Hash.ToLowerInvariant() -ne $file.sha256){throw 'Frozen normal bundle changed'}
   $a=Import-File $file.path $(if($file.name.EndsWith('.dll')){'application/vnd.microsoft.portable-executable'}else{'application/json'})
   @{name=$file.name;artifact_id=$a.id}
  })
  $builds+=Invoke-Lab lab.experiment @{action='register_normal_build';entry_assembly=$bundle.entry;files=$files}
 }
 $builds|ConvertTo-Json -Depth 60|Set-Content -LiteralPath (Join-Path $root 'builds.json')
 $patch=Import-File (Join-Path $root 'source.diff') text/x-diff
 $candidate=Invoke-Lab lab.experiment @{action='create_candidate';name='P36 ordered maintenance, selected before first normal family';build_identity=$builds[1].content_hash;components=@()}
 $candidate|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'candidate.json')
 $selected=@()
 foreach($item in @(Get-Content -LiteralPath (Join-Path $root 'experiments.json') -Raw|ConvertFrom-Json -AsHashtable -Depth 80)){
  $plan=Invoke-Lab lab.experiment @{action='create_confirmation_plan';selected_candidate_id=$candidate.id;source_patch_artifact_id=$patch.id;source_equivalence_rationale='Complete f0772c8 source control and source-selected P36 differ only in AddRecent maintenance/two helpers; fields/read bodies/52 other files unchanged. Exhaustive/random canonical-index models,409 .NET10 tests (408/410 other targets),collision/full-table/rollover/storage tests and48 two-arm prefixes pass. Distinct WorldNormal entry modules share exact Program.cs, resolved IL for eight separate-operation callers/implementation flags, dependency DLLs and runtime/deps JSON. Both single-library modules pass48 independent prefix oracles; no namespace treatment selector. This is the prospectively bounded first normal family, not full adoption: all original remaining guards and full10x qualification remain open; old observations excluded.';baseline_build_id=$builds[0].id;candidate_build_id=$builds[1].id;baseline_variant='baseline';candidate_variant='candidate';experiment=$item.experiment;exploratory_evidence_ids=@($hypothesis.id)}
  $selected+=@{scenario=$item.scenario;primary=$item.primary;plan=$plan}
 }
 $selected|ConvertTo-Json -Depth 80|Set-Content -LiteralPath (Join-Path $root 'plans.json')
 $names=@('WORLD-NORMAL-PROTOCOL.md','Scenarios-world-normal.cs.txt','Prepare-WorldNormalTiming.py','Lab-LocalClient.ps1','Host-Lock.ps1')
 $hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
 $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'frozen-dependencies.json')
 @{hypothesis=$hypothesis.id;candidate=$candidate.id;plans=$selected.Count;maximumSessions=288;timeRecords=0}|ConvertTo-Json
}finally{Exit-VoxtreePerformanceHost $lease}
