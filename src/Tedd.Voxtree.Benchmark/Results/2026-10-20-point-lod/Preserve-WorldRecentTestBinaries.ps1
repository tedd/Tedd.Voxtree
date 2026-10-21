param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$lease=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 $destination=Join-Path $TaskRoot 'bundles/p34-tests'
 if(Test-Path -LiteralPath $destination){throw 'P34 test module snapshot exists'}
 $records=@();$required=@()
 foreach($tfm in @('net8.0','net10.0','net11.0')){
  $original=Join-Path $TaskRoot "tests-packed-lookup-p34world2/bin/Tests/release_$tfm"
  $copy=Join-Path $destination $tfm;New-Item -ItemType Directory -Path $copy|Out-Null
  $files=@(Get-ChildItem -LiteralPath $original -File|Where-Object{$_.Extension -eq '.dll' -or $_.Name -in @('Tests.runtimeconfig.json','Tests.deps.json')})
  if(-not ($files.Name -contains 'Tests.dll') -or -not ($files.Name -contains 'Tedd.Voxtree.dll')){throw 'Original test modules missing'}
  foreach($f in $files){
   $hash=(Get-FileHash -LiteralPath $f.FullName).Hash
   Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $copy $f.Name)
   if((Get-FileHash -LiteralPath (Join-Path $copy $f.Name)).Hash -ne $hash){throw 'Original test module hash changed'}
   $records+=@(@{original=$f.FullName;copy="bundles/p34-tests/$tfm/$($f.Name)";sha256=$hash;bytes=$f.Length;originalLastWriteUtc=$f.LastWriteTimeUtc.ToString('o');scope='Copy of original completed p34world2 test output, no rebuild or rerun'})
  }
  foreach($n in @('Tests.dll','Tedd.Voxtree.dll','Tests.runtimeconfig.json','Tests.deps.json')){$required+=@("bundles/p34-tests/$tfm/$n")}
 }
 $records|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $TaskRoot 'p34-test-binary-bindings.json')
 Copy-Item -LiteralPath (Join-Path $TaskRoot 'p34-test-binary-bindings.json') -Destination (Join-Path $PSScriptRoot 'p34-test-binary-bindings.json')
 & python (Join-Path $PSScriptRoot 'Preserve.py') $TaskRoot $PSScriptRoot --label phase23-tests --content-addressed --include-prefix bundles/p34-tests --include-prefix p34-test-binary-bindings.json
 if($LASTEXITCODE -ne 0){throw 'Original P34 test binary preservation failed'}
 $arguments=@((Join-Path $PSScriptRoot 'Verify-Evidence.py'),$PSScriptRoot,'--label','phase23-tests','--prerequisites-only','--require','p34-test-binary-bindings.json')
 foreach($p in $required){$arguments+=@('--require',$p)}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw 'Original P34 test binary archive failed verification'}
}finally{Exit-VoxtreePerformanceHost $lease}
