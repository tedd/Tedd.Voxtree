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
 $root=Join-Path $TaskRoot 'p39-normal';$out=Join-Path $TaskRoot 'p39-normal-cleanup-failure.json'
 if(Test-Path -LiteralPath $out){throw 'Original cleanup-failure inspection exists'}
 $name='compact-normal-Generic16-F-get'
 $terminal=Get-Content -LiteralPath (Join-Path $root "$name-terminal.json") -Raw|ConvertFrom-Json
 $shutdown=Get-Content -LiteralPath (Join-Path $root "$name-controller-shutdown.json") -Raw|ConvertFrom-Json
 if($terminal.state -ne 'failed' -or -not $shutdown.joined -or $shutdown.exitCode -ne 0){throw 'Original failure or joined controller not verified'}
 $orphan='normal-session-c9c46c4bc80b4371a55ff1c993cac45c'
 $launch=Invoke-Lab lab.inspect @{action='record';id=$orphan+'-launch'}
 $identity=$launch.json|ConvertFrom-Json
 if($identity.execution_id -ne $terminal.result_id -or $identity.session_id -ne $orphan){throw 'Original launch does not bind failed execution'}
 $live=Get-Process -Id $identity.process_id -ErrorAction SilentlyContinue
 $originalLive=$live -and ([string]$live.StartTime.ToUniversalTime().Ticks -eq [string]$identity.start_time_utc_ticks)
 if($originalLive){throw 'Original orphan process remains live'}
 $controllerLive=Get-Process -Id $shutdown.pid -ErrorAction SilentlyContinue
 if($controllerLive -and [string]$controllerLive.StartTime.ToUniversalTime().Ticks -eq [string]$shutdown.startTicks){throw 'Original controller remains live'}
 $directory=[IO.Path]::GetFullPath((Join-Path $root "launches/$orphan"))
 $prefix=[IO.Path]::GetFullPath((Join-Path $root 'launches'))+[IO.Path]::DirectorySeparatorChar
 if(-not $directory.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'Residual launch path escaped task root'}
 $files=@(Get-ChildItem -LiteralPath $directory -File -Force|ForEach-Object{@{name=$_.Name;bytes=$_.Length;attributes=[string]$_.Attributes;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}})
 $launch|ConvertTo-Json -Depth 60|Set-Content -LiteralPath (Join-Path $root 'failed-cleanup-orphan-launch.json')
 $log=Get-Content -LiteralPath (Join-Path $root "$name-controller.log")
 $errors=@($log|Where-Object{$_.StartsWith('DOTNETLAB_CONFIRMATION_FAILURE ')}|ForEach-Object{$_.Substring('DOTNETLAB_CONFIRMATION_FAILURE '.Length)|ConvertFrom-Json})
 if($errors.Count -ne 1 -or $errors[0].exception_type -ne 'System.UnauthorizedAccessException'){throw 'Expected exact retained cleanup failure'}
 @{failedOperation=$terminal.id;failedExecution=$terminal.result_id;failedScenario=$name;error=$errors[0];residualDirectory=$directory;residualFiles=$files;orphanLaunch=$identity;orphanProcessNotLive=$true;completedOrphanSessionRecordAbsent=$true;controllerJoined=$shutdown;restartedOrReplaced=$false;remainingCasesNotStarted=15;qualification='Cleanup threw UnauthorizedAccessException in finally after the original process was stopped; no retained measurement/session exists for this tenth launch. Nine listed sessions are retained separately. Cleanup may mask an earlier startup/execution failure; no cause, correctness or exit-code conclusion is established for the tenth launch. Residual directory retained; no lock-owner attribution or deletion attempted.'}|ConvertTo-Json -Depth 90|Set-Content -LiteralPath $out
 Write-Output 'Original cleanup failure and unmeasured launch inspected; no process restarted and no residual file deleted'
}finally{Exit-VoxtreePerformanceHost $lease}
