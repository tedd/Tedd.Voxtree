param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $workers=@(Get-CimInstance Win32_Process|Where-Object {$_.Name -match '^(dotnet|testhost|MSBuild|VBCSCompiler|python)\.exe$' -and $_.CommandLine -like '*voxtree-point-lod-20261020*'})
    if($workers.Count){throw 'L1/task workers remain'}
    & python (Join-Path $PSScriptRoot 'Audit-ColdFailureProof.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'L1 functional audit failed'}
    foreach($pair in @(@('coldlog-functional-audit.json','coldlog-functional-audit.json'),@('coldlog-controller-source/cold-failure-log.diff','dotnetlab-cold-failure-log.diff'),@('coldlog-controller-source/patch-review.json','dotnetlab-cold-failure-source-review.json'))){
        $dest=Join-Path $PSScriptRoot $pair[1];if(Test-Path -LiteralPath $dest){throw 'Permanent L1 evidence exists'}
        Copy-Item -LiteralPath (Join-Path $TaskRoot $pair[0]) -Destination $dest
    }
} finally {Exit-VoxtreePerformanceHost $leases}
