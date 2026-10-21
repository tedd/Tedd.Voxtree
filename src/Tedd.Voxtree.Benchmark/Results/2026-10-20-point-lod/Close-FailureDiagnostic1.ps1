param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $root=Join-Path $TaskRoot 'p18-failure-diagnostic-1'
    $state=Get-Content -LiteralPath (Join-Path $root 'controller-shutdown.json') -Raw|ConvertFrom-Json
    if(-not $state.joined -or $state.exitCode -ne 0){throw 'D1 controller not joined'}
    $workers=@(Get-CimInstance Win32_Process|Where-Object {$_.Name -match '^(dotnet|testhost|MSBuild|VBCSCompiler|python)\.exe$' -and $_.CommandLine -like '*voxtree-point-lod-20261020*'})
    if($workers.Count){throw 'D1/task workers remain; verify actual identities before auditing'}
    & python (Join-Path $PSScriptRoot 'Audit-FailureDiagnostic1.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'D1 audit failed; preserve raw evidence'}
    foreach($pair in @(@('failure-diagnostic-1-audit.json','failure-diagnostic-1-audit.json'),@('exception-recorder-v2-source/selftest-proof.json','exception-recorder-v2-selftest.json'))){
        $destination=Join-Path $PSScriptRoot $pair[1]
        if(Test-Path -LiteralPath $destination){throw 'Permanent D1 evidence exists'}
        Copy-Item -LiteralPath (Join-Path $TaskRoot $pair[0]) -Destination $destination
    }
} finally {Exit-VoxtreePerformanceHost $leases}
