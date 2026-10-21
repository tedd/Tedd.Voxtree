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
 $audit=Get-Content -LiteralPath (Join-Path $TaskRoot 'p37-prerequisite-audit.json') -Raw|ConvertFrom-Json -Depth 80
 if($audit.comparativeRecords -ne 0 -or $audit.libraryIlBodiesUnchanged -ne 1203){throw 'P37 prerequisite audit is incomplete'}
 $root=Join-Path $TaskRoot 'p37-hypothesis';$path=Join-Path $TaskRoot 'p37-feasibility-disposition.json'
 if(Test-Path -LiteralPath $path){throw 'P37 disposition exists; inspect original accepted state'}
 $destination=Join-Path $TaskRoot 'bundles/p37-tests'
 if(Test-Path -LiteralPath $destination){throw 'P37 original test snapshot exists'}
 $bindings=@();$required=@()
 foreach($tfm in @('net8.0','net10.0','net11.0','netstandard2.1')){
  $original=if($tfm -eq 'netstandard2.1'){Join-Path $TaskRoot "tests-packed-lookup-p37world/bin/Library/release_$tfm"}else{Join-Path $TaskRoot "tests-packed-lookup-p37world/bin/Tests/release_$tfm"}
  $copy=Join-Path $destination $tfm;New-Item -ItemType Directory -Path $copy|Out-Null
  $files=@(Get-ChildItem -LiteralPath $original -File|Where-Object{$_.Extension -eq '.dll' -or $_.Name -in @('Tests.runtimeconfig.json','Tests.deps.json','Tedd.Voxtree.deps.json')})
  if(-not ($files.Name -contains 'Tedd.Voxtree.dll') -or ($tfm -ne 'netstandard2.1' -and -not ($files.Name -contains 'Tests.dll'))){throw 'Original P37 test modules missing'}
  foreach($f in $files){
   $hash=(Get-FileHash -LiteralPath $f.FullName).Hash
   Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $copy $f.Name)
   if((Get-FileHash -LiteralPath (Join-Path $copy $f.Name)).Hash -ne $hash){throw 'Original test snapshot mismatch'}
   $bindings+=@(@{original=$f.FullName;copy="bundles/p37-tests/$tfm/$($f.Name)";sha256=$hash;bytes=$f.Length;originalLastWriteUtc=$f.LastWriteTimeUtc.ToString('o');scope='Original completed P37 test output; no rebuild or rerun'})
  }
  $required+=@("bundles/p37-tests/$tfm/Tedd.Voxtree.dll")
  if($tfm -ne 'netstandard2.1'){$required+=@("bundles/p37-tests/$tfm/Tests.dll")}
 }
 $bindings|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p37-test-binary-bindings.json')
 @{state=$audit.state;feasibilityPassed=$audit.passed;promotionEligible=$false;sourceAdoption=$false;comparativeRecords=0;scope='P37 NoInlining only on complete published source. Native feasibility includes the frozen all-callers fixed-rsp guard; no time or hardware-causal claim. Full public10x objective remains open.'}|ConvertTo-Json|Set-Content -LiteralPath $path
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $evidence=@();foreach($f in @($path,(Join-Path $TaskRoot 'p37-prerequisite-audit.json'))){$evidence+=@((Import-File $f application/json).id)}
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state=$audit.state;evidence_ids=@($prior.evidence_ids)+$evidence}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 60|Set-Content -LiteralPath (Join-Path $root 'disposition-revision-response.json')
 foreach($n in @('p37-prerequisite-audit.json','p37-feasibility-disposition.json','p37-source.diff','p37-test-binary-bindings.json','native-summary-phase29-outline.json','caller-audit-p37library-identity.json','caller-audit-p37world-identity.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase29','--content-addressed')
 foreach($prefix in @('p37','outline-source','outline-published-source','outline-control-source','bundles/p37','caller-audit-p37','packed-lookup-validation-p37world','packed-lookup-p37world-results','packed-lookup-tests-p37world.log','packed-lookup-test-options-p37world.json','native-summary-phase29-outline.json')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P37 preservation failed; retain all originals'}
 $arguments=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase29','--prerequisites-only')
 foreach($p in $required+@('p37-hypothesis/catalog-export.json','p37-hypothesis/disposition-revision-response.json','p37-prerequisite-audit.json','p37-test-binary-bindings.json','bundles/p37n0/WorldNormal.dll','bundles/p37n1/WorldNormal.dll','caller-audit-p37library/out/Audit.dll','caller-audit-p37library.json','caller-audit-p37world.json','p37n0-native.asm','p37n1-native.asm')){$arguments+=@('--require',$p)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P37 archive verification failed'}
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
