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
 $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p39-prerequisite-audit.json') -Raw|ConvertFrom-Json -Depth 90
 if(-not $audit.passed -or $audit.comparativeTimingRecords -ne 0 -or $audit.actualLibraryIlBodyCount -ne 1236){throw 'Original P39 prerequisites incomplete'}
 $root=Join-Path $TaskRoot 'p39-hypothesis';$path=Join-Path $TaskRoot 'p39-feasibility-disposition.json'
 if(Test-Path -LiteralPath $path){throw 'Original P39 disposition exists; inspect accepted state'}
 $destination=Join-Path $TaskRoot 'bundles/p39-tests'
 if(Test-Path -LiteralPath $destination){throw 'Original P39 test snapshot exists'}
 $bindings=@();$required=@()
 foreach($tfm in @('net8.0','net10.0','net11.0','netstandard2.1')){
  $original=if($tfm -eq 'netstandard2.1'){Join-Path $TaskRoot "tests-packed-lookup-p39terminal/bin/Library/release_$tfm"}else{Join-Path $TaskRoot "tests-packed-lookup-p39terminal/bin/Tests/release_$tfm"}
  $copy=Join-Path $destination $tfm;New-Item -ItemType Directory -Path $copy|Out-Null
  $files=@(Get-ChildItem -LiteralPath $original -File|Where-Object{$_.Extension -eq '.dll' -or $_.Name -in @('Tests.runtimeconfig.json','Tests.deps.json','Tedd.Voxtree.deps.json')})
  if(-not ($files.Name -contains 'Tedd.Voxtree.dll') -or ($tfm -ne 'netstandard2.1' -and -not ($files.Name -contains 'Tests.dll'))){throw 'Original P39 test modules missing'}
  foreach($f in $files){
   $hash=(Get-FileHash -LiteralPath $f.FullName).Hash;Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $copy $f.Name)
   if((Get-FileHash -LiteralPath (Join-Path $copy $f.Name)).Hash -ne $hash){throw 'Original test snapshot mismatch'}
   $bindings+=@(@{original=$f.FullName;copy="bundles/p39-tests/$tfm/$($f.Name)";sha256=$hash;bytes=$f.Length;originalLastWriteUtc=$f.LastWriteTimeUtc.ToString('o');scope='Original completed P39 test output; no rebuild or rerun'})
  }
  $required+=@("bundles/p39-tests/$tfm/Tedd.Voxtree.dll")
  if($tfm -ne 'netstandard2.1'){$required+=@("bundles/p39-tests/$tfm/Tests.dll")}
 }
 $tool=Join-Path $TaskRoot 'caller-audit-p38library/out'
 $toolCopy=Join-Path $TaskRoot 'bundles/p39-audit-tool';New-Item -ItemType Directory -Path $toolCopy|Out-Null
 Get-ChildItem -LiteralPath $tool -File|Where-Object{$_.Extension -in '.dll','.json'}|Copy-Item -Destination $toolCopy
 $toolIdentity=Get-Content -LiteralPath (Join-Path $TaskRoot 'caller-audit-p39bodies-identity.json') -Raw|ConvertFrom-Json
 if((Get-FileHash -LiteralPath (Join-Path $toolCopy 'Audit.dll')).Hash -ne $toolIdentity.toolSha256){throw 'Original metadata tool snapshot mismatch'}
 $snapshot=Join-Path $TaskRoot 'p39-prerequisite-driver-source';New-Item -ItemType Directory -Path $snapshot|Out-Null
 foreach($n in @('Audit-CompactTerminal.py','Audit-CompactTerminal-initial.py.txt','Audit-CompactTerminal-second.py.txt','Prepare-CompactTerminal.py','Register-CompactTerminal.ps1','Inspect-CompactTerminalBodies.ps1','Preserve-CompactTerminal.ps1','Test-PackedLookup.ps1','CompactLeafTests.cs.txt','CompactTerminalTests.cs.txt','COMPACT-TERMINAL-PROTOCOL.md','COMPACT-TERMINAL-IL-COVERAGE.md','Host-Lock.ps1','Lab-LocalClient.ps1')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $n) -Destination $snapshot}
 Copy-Item -LiteralPath (Join-Path $TaskRoot 'caller-audit-p38library/Program.cs') -Destination (Join-Path $snapshot 'OriginalLibraryAudit.cs.txt')
 Copy-Item -LiteralPath (Join-Path $TaskRoot 'caller-audit-p38library-selftest.log') -Destination (Join-Path $TaskRoot 'p39-metadata-selftest.log')
 $bindings|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p39-test-binary-bindings.json')
 @{state='supported';qualification='Model/source/compiled correctness/corpus/native prerequisites only';promotionEligible=$false;sourceAdoption=$false;comparativeTimingRecords=0;actualLibraryBodies=1236;unchangedLibraryBodies=1235;partialRecursiveInliningObserved=$true;scope='P39 terminal specialization on exact unpromoted P31. Four checked row pairs remove repeated leaf validation in direct/inlined paths; eight source child invocations do not imply eight native recursive calls. All performance/original-release/consumer/allocation/full10x qualifications remain open.'}|ConvertTo-Json|Set-Content -LiteralPath $path
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $evidence=@();foreach($f in @($path,(Join-Path $TaskRoot 'p39-prerequisite-audit.json'))){$evidence+=@((Import-File $f application/json).id)}
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism+' Actual code partially inlines recursion: qualified work removal is repeated leaf validation/span-helper work in direct and inlined terminal regions, not a uniform eight native recursive calls.';prediction=$prior.prediction;state='supported';evidence_ids=@($prior.evidence_ids)+$evidence}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
 foreach($n in @('p39-terminal-model.json','p39-source-origin.json','p39-source-review.diff','p39-prerequisite-audit.json','p39-feasibility-disposition.json','p39-test-binary-bindings.json','p39-initial-audit-failure.json','p39-second-audit-failure.json','native-summary-phase31-terminal.json','caller-audit-p39bodies-identity.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase31','--content-addressed')
 foreach($prefix in @('p39','compact-terminal','compact-leaf13-source','bundles/p39','bundles/p31census','p31census-hashes.json','caller-audit-p39','packed-lookup-validation-p39terminal','packed-lookup-p39terminal-results','packed-lookup-tests-p39terminal.log','packed-lookup-test-options-p39terminal.json','packed-corpus-p39census-source','forcecraft-census-packed-p39census','forcecraft-census-packed-p31census2/packed-corpus.json','forcecraft-snapshot-s1.json','native-summary-phase31-terminal.json','k2-audit.json')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P39 preservation failed; retain every original'}
 $arguments=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase31','--prerequisites-only')
 foreach($p in $required+@('p39-hypothesis/catalog-export.json','p39-hypothesis/coverage-addendum.json','p39-hypothesis/disposition-revision-response.json','p39-terminal-model.json','p39-source-origin.json','p39-prerequisite-audit.json','p39-test-binary-bindings.json','p39-initial-audit-failure.json','p39-second-audit-failure.json','caller-audit-p39bodies.json','bundles/p39-audit-tool/Audit.dll','bundles/p31census/p31census.dll','bundles/p39census/p39census.dll','bundles/p39terminal/p39terminal.dll','packed-corpus-p39census-source/out/Census.dll','forcecraft-census-packed-p39census/packed-corpus.json','p39-terminal-native.asm','p39-model-source/Model-CompactTerminal.py','p39-prerequisite-driver-source/Audit-CompactTerminal-initial.py.txt','p39-prerequisite-driver-source/Audit-CompactTerminal-second.py.txt')){$arguments+=@('--require',$p)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P39 archive verification failed'}
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
