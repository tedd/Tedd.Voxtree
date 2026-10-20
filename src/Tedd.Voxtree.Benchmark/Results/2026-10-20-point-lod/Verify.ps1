param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
$env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    foreach($file in Get-ChildItem (Join-Path $repoRoot 'src/Tedd.Voxtree') -Filter '*.cs') {
        $current=(Get-Content -LiteralPath $file.FullName -Raw).Replace("`r`n","`n").TrimEnd()
        $frozen=(Get-Content -LiteralPath (Join-Path $TaskRoot "n1/source/$($file.Name)") -Raw).Replace("`r`n","`n").TrimEnd()
        if($current -ne $frozen){throw "Selected source mismatch: $($file.Name)"}
    }
    foreach($label in @('n0','n1')) {
        & dotnet exec --fx-version 10.0.13 (Join-Path $TaskRoot "bundles/$label/$label.dll") --inventory > (Join-Path $TaskRoot "$label-public-api.json")
        if($LASTEXITCODE -ne 0){throw 'Public API inventory failed'}
    }
    if((Get-Content (Join-Path $TaskRoot 'n0-public-api.json') -Raw) -ne (Get-Content (Join-Path $TaskRoot 'n1-public-api.json') -Raw)){throw 'Public API changed'}
    Push-Location $TaskRoot
    try {
        & dotnet test (Join-Path $repoRoot 'src/Tedd.Voxtree.Tests/Tedd.Voxtree.Tests.csproj') -c Release --artifacts-path (Join-Path $TaskRoot 'tests-final') --logger trx --results-directory (Join-Path $TaskRoot 'tests-final-results') -p:UseSharedCompilation=false -v minimal *> (Join-Path $TaskRoot 'tests-final.log')
        if($LASTEXITCODE -ne 0){throw 'Final framework tests failed'}
        $env:DOTNET_EnableHWIntrinsic='0'
        & dotnet test (Join-Path $repoRoot 'src/Tedd.Voxtree.Tests/Tedd.Voxtree.Tests.csproj') -c Release -f net10.0 --no-build --artifacts-path (Join-Path $TaskRoot 'tests-final') --logger trx --results-directory (Join-Path $TaskRoot 'tests-disabled-results') -v minimal *> (Join-Path $TaskRoot 'tests-disabled.log')
        if($LASTEXITCODE -ne 0){throw 'Hardware-disabled tests failed'}
        Remove-Item Env:DOTNET_EnableHWIntrinsic
    } finally {Pop-Location}
    Get-Content (Join-Path $TaskRoot 'tests-final.log')|Select-String 'Passed!'
    Get-Content (Join-Path $TaskRoot 'tests-disabled.log')|Select-String 'Passed!'
    'Selected source and public API verified'
} finally {Exit-VoxtreePerformanceHost $leases}
