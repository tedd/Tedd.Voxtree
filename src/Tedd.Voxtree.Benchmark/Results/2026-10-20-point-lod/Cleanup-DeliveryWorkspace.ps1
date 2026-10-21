param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
$expected='D:\Workspaces\AI\voxtree-point-lod-20261020'
$resolved=(Resolve-Path -LiteralPath $TaskRoot).Path.TrimEnd('\')
if($resolved -cne $expected -or [IO.Path]::GetDirectoryName($resolved) -cne 'D:\Workspaces\AI'){throw 'Resolved cleanup target is not the specific task workspace'}
if((Get-Item -LiteralPath $resolved).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Cleanup target is a reparse point'}
$recordPath=Join-Path $PSScriptRoot 'workspace-cleanup.json'
if(Test-Path -LiteralPath $recordPath){throw 'Inspect original cleanup record instead of repeating deletion'}
$audit=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'delivery-evidence-audit.json') -Raw|ConvertFrom-Json
$package=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'published-package-verification.json') -Raw|ConvertFrom-Json
$release=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'release-outcome.json') -Raw|ConvertFrom-Json
if(-not $audit.passed -or -not $package.passed -or $release.deployConclusion -ne 'success' -or -not $release.nugetIndexContainsVersion){throw 'Preservation/publication prerequisites incomplete'}
$repo=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
if((& git -C $repo branch --show-current) -ne 'main'){throw 'Original integration branch not restored'}
& git -C $repo merge-base --is-ancestor $release.releaseCommit main
if($LASTEXITCODE -ne 0){throw 'Release commit not integrated into main'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try{
 $live=@(Get-CimInstance Win32_Process|Where-Object {$_.ProcessId -ne $PID -and $_.CommandLine -like ('*'+$resolved+'*')})
 if($live.Count){throw ('Workspace is referenced by live processes: '+(($live|Select-Object -ExpandProperty ProcessId)-join ','))}
 $links=@(Get-ChildItem -LiteralPath $resolved -Recurse -Force -Attributes ReparsePoint)
 if($links.Count){throw 'Workspace contains reparse points; inspect before removal'}
 Remove-Item -LiteralPath $resolved -Recurse -Force
 if(Test-Path -LiteralPath $resolved){throw 'Task workspace remains after cleanup'}
 @{removedUtc=[DateTime]::UtcNow.ToString('o');removedPath=$resolved;resolvedTargetVerified=$true;liveWorkspaceProcesses=0;reparsePoints=0;deliverablesPreserved=$true;originalBranch='main';taskWorktreesCreated=0;otherWorktreesUntouched=$true;unrelatedDocsArticlesUntouched=$true}|ConvertTo-Json|Set-Content -LiteralPath $recordPath
}finally{Exit-VoxtreePerformanceHost $leases}
