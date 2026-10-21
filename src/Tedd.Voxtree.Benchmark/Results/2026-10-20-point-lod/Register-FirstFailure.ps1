param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $TaskRoot 'coldlog-controller-source/logged2-out/Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 $main=Join-Path $TaskRoot 'p39-first-failure';if(Test-Path -LiteralPath $main){throw 'Original diagnostic registration exists'}
 if((Get-FileHash -LiteralPath $labHost).Hash.ToLowerInvariant() -ne 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'){throw 'Original controller changed'}
 $self=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-logger-selftest.json') -Raw|ConvertFrom-Json
 if(-not $self.joined -or $self.exitCode -ne 0){throw 'Original logger selftest incomplete'}
 $closures=@(Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-controller-bundles.json') -Raw|ConvertFrom-Json -Depth 50)
 foreach($b in $closures){foreach($f in $b.files){if((Get-FileHash -LiteralPath $f.path).Hash -ne $f.sha256){throw 'Frozen diagnostic closure changed'}}}
 $root=$main;& $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null;if($LASTEXITCODE -ne 0){throw 'Private diagnostic catalog initialization failed'}
 $testCases=@(
  @{name='original-masked';controller='p39f0';missing=$true;hold='hold';expectedState='failed';expectedPrimary=0;expectedSessions=0;expectedLaunches=1;expectedCode='confirmation_failed'},
  @{name='logged-masked';controller='p39f1';missing=$true;hold='hold';expectedState='failed';expectedPrimary=1;expectedSessions=0;expectedLaunches=1;expectedCode='confirmation_failed'},
  @{name='logged-cleanup';controller='p39f1';missing=$false;hold='hold';expectedState='failed';expectedPrimary=0;expectedSessions=1;expectedLaunches=1;expectedCode='confirmation_failed'},
  @{name='logged-primary';controller='p39f1';missing=$true;hold='free';expectedState='failed';expectedPrimary=1;expectedSessions=0;expectedLaunches=1;expectedCode='scenario_not_found'},
  @{name='logged-success';controller='p39f1';missing=$false;hold='free';expectedState='completed';expectedPrimary=0;expectedSessions=24;expectedLaunches=24;expectedCode=$null}
 )
 $normal=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-normal-preflight.json') -Raw|ConvertFrom-Json -Depth 90
 $descriptor=$normal.descriptors|Where-Object{$_.id -eq 'compact-normal-Classic32-E-validate'}
 if($descriptor.version -ne '25'){throw 'Original empty-validation descriptor unavailable'}
 @{protocol=(Get-Content -LiteralPath (Join-Path $PSScriptRoot 'FIRST-FAILURE-PROTOCOL.md') -Raw);protocolSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'FIRST-FAILURE-PROTOCOL.md')).Hash;sourceManifestSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-source.json')).Hash;workerRepairSha256=(Get-FileHash -LiteralPath (Join-Path $TaskRoot 'p39-first-failure-worker-repair.json')).Hash;controllerClosures=$closures;normalBundles=$normal.bundles;descriptor=$descriptor;cases=$testCases;maximumTargetLaunches=28;maximumDiagnosticMeasuredSessions=25;comparativeTimingRecords=0}|ConvertTo-Json -Depth 90|Set-Content -LiteralPath (Join-Path $root 'inputs.json')
 $a=Import-File (Join-Path $root 'inputs.json') application/json
 $hyp=Invoke-Lab lab.experiment @{action='create_hypothesis';mechanism='Primary normal-session exceptions can be hidden by finally-cleanup failures. A failure-only catch logs the original bounded exception before rethrow and unchanged cleanup, preserving first-failure evidence without a normal-path logging call. Existing staging hook deterministically holds only private CompactNormal.dll against delete.';prediction='Five frozen controls will distinguish masked primary, cleanup-only, primary-only and complete success. Original masked controller has no primary log; new masked controller logs scenario_not_found before cleanup error. New cleanup-only has no primary log and one correct exited orphan session; primary-only preserves scenario_not_found; success completes24 correct joined sessions without failure logs. Fixed maximum28 targets,25 diagnostic measured sessions, no comparisons/adoption or original-cause inference.';evidence_ids=@($a.id)}
 $hyp|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis.json')
 $selected=@()
 foreach($test in $testCases){
  $root=Join-Path $main $test.name;& $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null;if($LASTEXITCODE -ne 0){throw 'Private test catalog initialization failed'}
  $test|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'test-inputs.json')
  $a=Import-File (Join-Path $root 'test-inputs.json') application/json
  $h=Invoke-Lab lab.experiment @{action='create_hypothesis';mechanism='Deterministic task-local normal-session failure/control test under existing staging callback and exact CLI grant; no performance comparison.';prediction="Frozen $($test.name): $($test.expectedState), primary logs $($test.expectedPrimary), catalogued measured sessions $($test.expectedSessions), target launches $($test.expectedLaunches). Stop study on mismatch.";evidence_ids=@($a.id)}
  $h|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'hypothesis.json')
  $builds=@()
  foreach($b in $normal.bundles){
   $files=@(foreach($f in $b.files){if((Get-FileHash -LiteralPath $f.path).Hash.ToLowerInvariant() -ne $f.sha256){throw 'Original normal modules changed'};$a=Import-File $f.path $(if($f.name.EndsWith('.dll')){'application/vnd.microsoft.portable-executable'}else{'application/json'});@{name=$f.name;artifact_id=$a.id}})
   $builds+=Invoke-Lab lab.experiment @{action='register_normal_build';entry_assembly='CompactNormal.dll';files=$files}
  }
  $builds|ConvertTo-Json -Depth 60|Set-Content -LiteralPath (Join-Path $root 'builds.json')
  $patch=Import-File (Join-Path $TaskRoot 'p39-source-review.diff') text/x-diff
  $candidate=Invoke-Lab lab.experiment @{action='create_candidate';name='Original P39 normal module, diagnostic test only';build_identity=$builds[1].content_hash;components=@()}
  $candidate|ConvertTo-Json -Depth 40|Set-Content -LiteralPath (Join-Path $root 'candidate.json')
  $scenario=if($test.missing){'p39-first-failure-deliberately-absent'}else{$descriptor.id}
  $experiment=@{id='prospective-P39F-diagnostic';scenario_id=$scenario;scenario_version='25';input_hash=$descriptor.input_hash;variants=@('baseline','candidate');blocks=12;operations_per_run=32;warmup_batches=1;seed='20261119';profile='quiet-validation';independent_blocks=$true;independence_justification='Public confirmation API requires fresh paired session design. This deterministic diagnostic tests failures and joins, uses no comparison or inferential independence claim; successful processes have independent heaps/JIT state but residual environmental dependence is not assessed.';confirmatory=$true;maximum_duration_seconds=120;analysis=@{alpha_family=0.05;family_size=10;equivalence_lower_ratio=0.95;equivalence_upper_ratio=1.05;useful_improvement_ratio=0.95;meaningful_regression_ratio=1.05;minimum_blocks=10};primary_metric='scenario.ns_per_operation';fresh_normal_build=$true;guardrail_metrics=@('scenario.thread_allocation_bytes_per_operation');guardrail_policies=@(@{metric='scenario.thread_allocation_bytes_per_operation';unit='bytes/operation';observation_kind='batch_normalized_allocation_delta';direction='lower_is_better';scale='absolute_difference';equivalence_lower=-0.01;equivalence_upper=0.01;useful_improvement=-0.01;meaningful_regression=0.01;minimum_blocks=10;descriptive_only=$false});target_runtime_version='10.0.13'}
  $plan=Invoke-Lab lab.experiment @{action='create_confirmation_plan';selected_candidate_id=$candidate.id;source_patch_artifact_id=$patch.id;source_equivalence_rationale='Exact original validated P31/P39 version25 normal modules with unchanged dependencies/runtime and47-type API are retained solely as diagnostic targets. This test evaluates controller first-error retention, owned-process cleanup and success, with deliberately absent or actual empty-validation registry selection. No normal module is rebuilt, no comparison/performance inference/adoption occurs, and old failed operations are not resumed.';baseline_build_id=$builds[0].id;candidate_build_id=$builds[1].id;baseline_variant='baseline';candidate_variant='candidate';experiment=$experiment;exploratory_evidence_ids=@($h.id)}
  $plan|ConvertTo-Json -Depth 90|Set-Content -LiteralPath (Join-Path $root 'plan.json')
  $selected+=@(@{test=$test;root=$root;plan=$plan})
 }
 $selected|ConvertTo-Json -Depth 90|Set-Content -LiteralPath (Join-Path $main 'plans.json')
 $hashes=@{};foreach($n in @('FIRST-FAILURE-PROTOCOL.md','FirstFailureWorker.cs.txt','NormalSessionPrimaryFailure.cs.txt','Run-FirstFailure.ps1','Check-FirstFailureCase.py','Host-Lock.ps1','Lab-LocalClient.ps1')){$hashes[$n]=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $n)).Hash}
 $hashes|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $main 'frozen-dependencies.json')
 Write-Output "Five diagnostic plans frozen; parent hypothesis $($hyp.id); no target launch grant or operation submitted"
}finally{Exit-VoxtreePerformanceHost $lease}
