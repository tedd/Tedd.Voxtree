param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
$env:TEMP=Join-Path $TaskRoot 'temp'; $env:TMP=$env:TEMP
$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
New-Item -ItemType Directory -Path $env:TEMP -Force | Out-Null
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$hostLeases=Enter-VoxtreePerformanceHost
Push-Location $TaskRoot
try {
    foreach($framework in @('net10.0','net11.0','net8.0')) {
        $log=Join-Path $TaskRoot "tests-$framework.txt"
        dotnet test (Join-Path $repoRoot 'src/Tedd.Voxtree.Tests/Tedd.Voxtree.Tests.csproj') -c Release -f $framework --artifacts-path (Join-Path $TaskRoot "test-artifacts-$framework") --nologo -v minimal 2>&1 |
            Tee-Object -FilePath $log
        if($LASTEXITCODE -ne 0){throw "Tests failed for $framework"}
    }
} finally { Pop-Location; Exit-VoxtreePerformanceHost $hostLeases }
