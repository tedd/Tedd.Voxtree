param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
$repo=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
$directory=Join-Path $TaskRoot 'final-release'
if(Test-Path -LiteralPath $directory){throw 'Original final release check exists; inspect its status without rerunning'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 New-Item -ItemType Directory -Path $directory|Out-Null
 $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
 $env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
 $env:NUGET_PACKAGES=Join-Path $TaskRoot 'nuget-packages'
 $env:DOTNET_CLI_HOME=Join-Path $TaskRoot 'dotnet-home'
 $env:DOTNET_CLI_TELEMETRY_OPTOUT='1';$env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE='1'
 $artifacts=Join-Path $directory 'artifacts';$results=Join-Path $TaskRoot 'final-release-results'
 $solution=Join-Path $repo 'src/Tedd.Voxtree.sln'
 Push-Location $TaskRoot
 try{
  dotnet --info|Set-Content -LiteralPath (Join-Path $directory 'dotnet-info.txt')
  dotnet build $solution -c Release --artifacts-path $artifacts -p:UseSharedCompilation=false --disable-build-servers --nologo -v minimal 2>&1|Tee-Object -FilePath (Join-Path $directory 'build.log')
  if($LASTEXITCODE -ne 0){throw 'Final production solution build failed'}
  dotnet test $solution -c Release --no-build --no-restore --artifacts-path $artifacts --results-directory $results --logger trx --nologo -v minimal 2>&1|Tee-Object -FilePath (Join-Path $directory 'tests.log')
  if($LASTEXITCODE -ne 0){throw 'Final production tests failed'}
  dotnet pack (Join-Path $repo 'src/Tedd.Voxtree/Tedd.Voxtree.csproj') -c Release --no-build --no-restore --artifacts-path $artifacts --output (Join-Path $directory 'packages') --nologo -v minimal 2>&1|Tee-Object -FilePath (Join-Path $directory 'pack.log')
  if($LASTEXITCODE -ne 0){throw 'Final production package check failed'}
 }finally{Pop-Location}
 @{completedUtc=[DateTime]::UtcNow.ToString('o');buildPassed=$true;testsPassed=$true;packPassed=$true;newRuntimeOptimization=$false;sourceRevision=(& git -C $repo rev-parse HEAD);sdk=(& dotnet --version)}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $directory 'completed.json')
}catch{
 $_|Out-String|Set-Content -LiteralPath (Join-Path $directory 'failure.log');throw
}finally{Exit-VoxtreePerformanceHost $leases}
