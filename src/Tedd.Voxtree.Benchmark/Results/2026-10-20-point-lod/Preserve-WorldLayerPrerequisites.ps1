param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p35-prerequisite-audit.json') -Raw|ConvertFrom-Json -Depth 80
 if(-not $gate.passed -or -not $gate.sourceReversalExact -or -not $gate.compiledSourcesMatch -or $gate.callerCases -ne 60){throw 'P35 gate incomplete'}
 if(Test-Path -LiteralPath (Join-Path $TaskRoot 'p35world-screen')){throw 'Timing must follow prerequisite preservation'}
 $destination=Join-Path $TaskRoot 'bundles/p35-tests';if(Test-Path -LiteralPath $destination){throw 'Original P35 test snapshot exists'}
 $records=@();$required=@()
 foreach($tfm in @('net8.0','net10.0','net11.0')){
  $original=Join-Path $TaskRoot "tests-packed-lookup-p35world/bin/Tests/release_$tfm";$copy=Join-Path $destination $tfm
  New-Item -ItemType Directory -Path $copy|Out-Null
  $files=@(Get-ChildItem -LiteralPath $original -File|Where-Object{$_.Extension -eq '.dll' -or $_.Name -in @('Tests.runtimeconfig.json','Tests.deps.json')})
  if(-not ($files.Name -contains 'Tests.dll') -or -not ($files.Name -contains 'Tedd.Voxtree.dll')){throw 'Original P35 test modules missing'}
  foreach($f in $files){
   $h=(Get-FileHash -LiteralPath $f.FullName).Hash;Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $copy $f.Name)
   if((Get-FileHash -LiteralPath (Join-Path $copy $f.Name)).Hash -ne $h){throw 'Original P35 test copy hash mismatch'}
   $records+=@(@{original=$f.FullName;copy="bundles/p35-tests/$tfm/$($f.Name)";sha256=$h;bytes=$f.Length;originalLastWriteUtc=$f.LastWriteTimeUtc.ToString('o');scope='Original completed test output; no rebuild or rerun'})
  }
  foreach($n in @('Tests.dll','Tedd.Voxtree.dll','Tests.runtimeconfig.json','Tests.deps.json')){$required+=@("bundles/p35-tests/$tfm/$n")}
 }
 $records|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p35-test-binary-bindings.json')
 foreach($n in @('p35-prerequisite-audit.json','p35-world-source.diff','p35-test-binary-bindings.json','native-summary-phase24-world.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase24','--content-addressed')
 foreach($prefix in @('p35','world-layer-source','bundles/p35','packed-lookup-validation-p35world','packed-lookup-p35world','packed-lookup-tests-p35world','packed-lookup-test-options-p35world','native-summary-phase24-world')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P35 prerequisite preservation failed'}
 $arguments=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase24','--prerequisites-only','--require','p35-prerequisite-audit.json','--require','p35-world-native.asm','--require','p35-hypothesis/catalog-export.json','--require','bundles/p35world/p35world.dll','--require','world-layer-source/WorldEntity.cs','--require','p35world-baseline/WorldEntity.cs','--require','p35-test-binary-bindings.json')
 foreach($p in $required){$arguments+=@('--require',$p)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P35 prerequisite archive verification failed'}
}finally{Exit-VoxtreePerformanceHost $lease}
