param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
    $directory=Join-Path $TaskRoot 'core-probe-c2'
    if(Test-Path -LiteralPath $directory){throw 'Core probe exists; inspect prior selection before recovery'}
    New-Item -ItemType Directory -Path $directory | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'HostTopology.cs.txt') -Destination (Join-Path $directory 'Program.cs')
@'
<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><TargetFramework>net10.0</TargetFramework><OutputType>Exe</OutputType><ImplicitUsings>enable</ImplicitUsings><Nullable>enable</Nullable><UseSharedCompilation>false</UseSharedCompilation></PropertyGroup></Project>
'@ | Set-Content -LiteralPath (Join-Path $directory 'Probe.csproj')
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    Push-Location $TaskRoot
    try {
        & dotnet build (Join-Path $directory 'Probe.csproj') -c Release -o (Join-Path $directory 'out') -v minimal *> (Join-Path $TaskRoot 'core-probe-c2-build.log')
        if($LASTEXITCODE -ne 0){throw 'Core probe build failed'}
        & dotnet exec --fx-version 10.0.13 (Join-Path $directory 'out/Probe.dll') (Join-Path $TaskRoot 'core-topology-c2.json') *> (Join-Path $TaskRoot 'core-topology-c2.log')
        if($LASTEXITCODE -ne 0){throw 'Core topology query failed'}
    } finally {Pop-Location}
    $samples=for($i=0;$i -lt 3;$i++) {
        Start-Sleep -Milliseconds 1000
        $rows=Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Processor -OperationTimeoutSec 10 | Where-Object {$_.Name -match '^\d+$'} | ForEach-Object {[pscustomobject]@{logical=[int]$_.Name;percent=[double]$_.PercentProcessorTime}}
        [pscustomobject]@{utc=[DateTime]::UtcNow.ToString('O');rows=@($rows)}
    }
    $samples | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $TaskRoot 'core-load-c2.json')
    $cores=Get-Content -LiteralPath (Join-Path $TaskRoot 'core-topology-c2.json') -Raw | ConvertFrom-Json
    $scores=foreach($core in $cores) {
        if($core.group -ne 0 -or $core.logical -contains 0){continue}
        $maxima=foreach($sample in $samples) {
            $loads=foreach($logical in $core.logical) {
                $row=@($sample.rows | Where-Object logical -eq $logical)
                if($row.Count -ne 1){throw 'Missing or duplicate logical CPU sample'}
                $row[0].percent
            }
            ($loads | Measure-Object -Maximum).Maximum
        }
        [pscustomobject]@{logical=@($core.logical);selectedLogical=($core.logical | Measure-Object -Minimum).Minimum;score=($maxima | Measure-Object -Average).Average}
    }
    $selected=$scores | Sort-Object score,selectedLogical | Select-Object -First 1
    if(-not $selected -or $selected.selectedLogical -ge 63){throw 'No supported group-zero control core'}
    $affinity=[long]1 -shl [int]$selected.selectedLogical
    @{rule='Lowest three-sample mean of maximum sibling CPU percentages; exclude physical core containing logical 0; group zero only; ties choose lowest logical index';scores=@($scores);selected=$selected;affinity=$affinity;scope='future task-owned targets only; no global affinity or process changes'} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $TaskRoot 'core-selection-c2.json')
    Write-Output "C2 affinity selected: $affinity"
} finally {Exit-VoxtreePerformanceHost $leases}
