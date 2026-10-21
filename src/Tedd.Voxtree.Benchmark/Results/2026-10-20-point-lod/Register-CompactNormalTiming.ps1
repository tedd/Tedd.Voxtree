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
 & python (Join-Path $PSScriptRoot 'Prepare-CompactNormalTiming.py') $TaskRoot
 if($LASTEXITCODE -ne 0){throw 'Normal first-family binding failed'}
 $root=Join-Path $TaskRoot 'p39-normal'
 & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
 if($LASTEXITCODE -ne 0){throw 'Normal first-family catalog initialization failed'}
 $inputs=Get-Content -LiteralPath (Join-Path $root 'inputs.json') -Raw|ConvertFrom-Json -Depth 80
 $artifact=Import-File (Join-Path $root 'inputs.json') application/json
 $hypothesis=Invoke-Lab lab.experiment @{action='create_hypothesis';mechanism='P39 selected before timing on exact unpromoted P31: terminal compact validation replaces repeated scalar leaf validation with four checked UInt32 row pairs, metadata mask and raw-equality test. Actual parent partially inlines recursion. Source delta is one ValidateCube body; 1235 other bodies and all flags/public surfaces unchanged. Version25 single-library normal modules have35 matched NoInlining caller methods. Full corpus and independent semantics pass; real native validation callers expose code/frame growth.';prediction='Complete107-case first normal family:23 validation/materialization/chunk targets require1.25 speedup;84 point/LOD/build/query/storage/adverse guards requirecost<=1.05. Twelve fresh paired blocks,2568 joined correct sessions, family214 with original allocation policy. Classify futility/harm only from frozen usable intervals. P31-local study cannot authorize adoption, original-release benefit or original10x claims.';evidence_ids=@($artifact.id)}
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
 $candidate=Invoke-Lab lab.experiment @{action='create_candidate';name='P39 terminal validation, selected before first normal family';build_identity=$builds[1].content_hash;components=@()}
 $candidate|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'candidate.json')
 $selected=@()
 foreach($item in @(Get-Content -LiteralPath (Join-Path $root 'experiments.json') -Raw|ConvertFrom-Json -AsHashtable -Depth 80)){
  $plan=Invoke-Lab lab.experiment @{action='create_confirmation_plan';selected_candidate_id=$candidate.id;source_patch_artifact_id=$patch.id;source_equivalence_rationale='Exact unpromoted P31 control and selected P39 differ in one ValidateCube body;54 of55 source files,1235 of1236 compiled bodies, all flags and47 public types unchanged. Model2629760 cases,37440 aligned cubes,417/418/419 tests and1286 real chunks42139648 cells pass independent oracles and exact P31 bytes. Both new version25 CompactNormal modules share Program/project/dependencies/runtime/deps and35 resolved caller IL bodies/flags;107 full semantic cases each and six private storage cleanups pass. Initial version24 load-caller failure preserved; no timing preceded correction. Native diagnostics retain real code/frame growth and missing FromEncoded Tier1 caller coverage. This107-case P31-local first family cannot adopt: independent original-release, actual consumer, full API/memory/format/allocation/original10x qualifications remain.';baseline_build_id=$builds[0].id;candidate_build_id=$builds[1].id;baseline_variant='baseline';candidate_variant='candidate';experiment=$item.experiment;exploratory_evidence_ids=@($hypothesis.id)}
  $selected+=@{scenario=$item.scenario;primary=$item.primary;plan=$plan}
 }
 $selected|ConvertTo-Json -Depth 80|Set-Content -LiteralPath (Join-Path $root 'plans.json')
 $names=@('COMPACT-TERMINAL-NORMAL-PROTOCOL.md','Scenarios-compact-normal-storage.cs.txt','Prepare-CompactNormalTiming.py','Register-CompactNormalTiming.ps1','Run-CompactNormal.ps1','Lab-LocalClient.ps1','Host-Lock.ps1')
 $hashes=@{};foreach($n in $names){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
 $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'frozen-dependencies.json')
 @{hypothesis=$hypothesis.id;candidate=$candidate.id;plans=$selected.Count;maximumSessions=2568;timeRecords=0}|ConvertTo-Json
}finally{Exit-VoxtreePerformanceHost $lease}
