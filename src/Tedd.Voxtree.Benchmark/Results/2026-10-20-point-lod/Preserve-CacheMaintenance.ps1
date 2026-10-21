param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
$controller=$null;$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
try{
 $gate=Get-Content -LiteralPath (Join-Path $TaskRoot 'p36-prerequisite-audit.json') -Raw|ConvertFrom-Json -Depth 80
 if(-not $gate.passed -or -not $gate.fieldsAndReadBodiesUnchanged -or $gate.callerCases -ne 48){throw 'P36 feasibility gate incomplete'}
 $destination=Join-Path $TaskRoot 'bundles/p36-tests';if(Test-Path -LiteralPath $destination){throw 'Original P36 test snapshot exists'}
 $records=@();$required=@()
 foreach($tfm in @('net8.0','net10.0','net11.0')){
  $original=Join-Path $TaskRoot "tests-packed-lookup-p36world/bin/Tests/release_$tfm";$copy=Join-Path $destination $tfm
  New-Item -ItemType Directory -Path $copy|Out-Null
  $files=@(Get-ChildItem -LiteralPath $original -File|Where-Object{$_.Extension -eq '.dll' -or $_.Name -in @('Tests.runtimeconfig.json','Tests.deps.json')})
  if(-not ($files.Name -contains 'Tests.dll') -or -not ($files.Name -contains 'Tedd.Voxtree.dll')){throw 'Original P36 test modules missing'}
  foreach($f in $files){
   $h=(Get-FileHash -LiteralPath $f.FullName).Hash;Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $copy $f.Name)
   if((Get-FileHash -LiteralPath (Join-Path $copy $f.Name)).Hash -ne $h){throw 'Original P36 test module changed'}
   $records+=@(@{original=$f.FullName;copy="bundles/p36-tests/$tfm/$($f.Name)";sha256=$h;bytes=$f.Length;originalLastWriteUtc=$f.LastWriteTimeUtc.ToString('o');scope='Original completed test output; no rebuild or rerun'})
  }
  foreach($n in @('Tests.dll','Tedd.Voxtree.dll','Tests.runtimeconfig.json','Tests.deps.json')){$required+=@("bundles/p36-tests/$tfm/$n")}
 }
 $records|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p36-test-binary-bindings.json')
 $root=Join-Path $TaskRoot 'p36-hypothesis';$path=Join-Path $TaskRoot 'p36-feasibility-disposition.json'
 if(Test-Path -LiteralPath $path){throw 'P36 disposition exists; inspect original accepted state'}
 @{state='supported';scope='Algorithm/source/semantic/native feasibility only';normalConfirmation=$false;comparativeTimingRecords=0;promotionEligible=$false;sourceAdopted=$false;next='Freeze a separately budgeted fresh-normal time/guardrail protocol before new data; no source or 10x claim.'}|ConvertTo-Json|Set-Content -LiteralPath $path
 $created=Get-Content -LiteralPath (Join-Path $root 'hypothesis-response.json') -Raw|ConvertFrom-Json
 $record=Invoke-Lab lab.inspect @{action='record';id=$created.id};$prior=$record.json|ConvertFrom-Json
 $evidence=@();foreach($file in @($path,(Join-Path $TaskRoot 'p36-prerequisite-audit.json'),(Join-Path $TaskRoot 'p36-model-audit.json'))){$evidence+=@((Import-File $file application/json).id)}
 $request=@{action='revise_hypothesis';id=$prior.id;expected_revision=[string]$record.revision;mechanism=$prior.mechanism;prediction=$prior.prediction;state='supported';evidence_ids=@($prior.evidence_ids)+$evidence}
 $request|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'feasibility-revision-request.json')
 $result=Invoke-Lab lab.experiment $request
 $result|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'feasibility-revision-response.json')
 foreach($n in @('p36-model-audit.json','p36-prerequisite-audit.json','p36-source.diff','p36-test-binary-bindings.json','p36-feasibility-disposition.json','native-summary-phase26-cache.json')){Copy-Item -LiteralPath (Join-Path $TaskRoot $n) -Destination (Join-Path $PSScriptRoot $n)}
 $arguments=@((Join-Path $PSScriptRoot 'Preserve.py'),$TaskRoot,$PSScriptRoot,'--label','phase26','--content-addressed')
 foreach($prefix in @('p36','cache-maintenance-source','bundles/p36','packed-lookup-validation-p36world','packed-lookup-p36world','packed-lookup-tests-p36world','packed-lookup-test-options-p36world','native-summary-phase26-cache')){$arguments+=@('--include-prefix',$prefix)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P36 feasibility preservation failed'}
 $arguments=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase26','--prerequisites-only','--require','p36-prerequisite-audit.json','--require','p36-model-audit.json','--require','p36-cache-native.asm','--require','p36-hypothesis/catalog-export.json','--require','p36-hypothesis/feasibility-revision-response.json','--require','bundles/p36world/p36world.dll','--require','cache-maintenance-source/WorldEntity.cs','--require','p36-test-binary-bindings.json')
 foreach($p in $required){$arguments+=@('--require',$p)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'P36 feasibility archive verification failed'}
 $result|ConvertTo-Json -Depth 12
}finally{Exit-VoxtreePerformanceHost $lease}
