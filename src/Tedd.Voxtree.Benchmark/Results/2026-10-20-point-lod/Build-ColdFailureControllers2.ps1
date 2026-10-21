param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -DriverPath $PSCommandPath
try {
    $root=Join-Path $TaskRoot 'coldlog-controller-source'
    foreach($name in @('base2-out','logged2-out')){if(Test-Path -LiteralPath (Join-Path $root $name)){throw 'L1 output exists; inspect before recovery'}}
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP;$env:NUGET_HTTP_CACHE_PATH=Join-Path $TaskRoot 'nuget-http'
    $env:DOTNET_CLI_USE_MSBUILD_SERVER='0';$env:MSBUILDDISABLENODEREUSE='1'
    $buildRoot=Join-Path $TaskRoot 'coldlog-build2-artifacts'
    Push-Location $root
    try {
        foreach($variant in @('base','logged')){
            if($variant -eq 'logged'){
                & python (Join-Path $PSScriptRoot 'Patch-ColdFailureController.py') $TaskRoot
                if($LASTEXITCODE -ne 0){throw 'Cold catch patch failed'}
            }
            $output=Join-Path $root "$variant`2-out"
            & dotnet build (Join-Path $root 'src/Tedd.DotNetLab.Host/Tedd.DotNetLab.Host.csproj') -c Release "-p:DotNetLabBuildRoot=$buildRoot" -p:RuntimeFrameworkVersion=10.0.13 -p:UseSharedCompilation=false -v minimal *> (Join-Path $TaskRoot "coldlog-$variant-build2.log")
            if($LASTEXITCODE -ne 0){throw "L1 $variant build failed; retain output"}
            $built=Join-Path $buildRoot 'bin/Tedd.DotNetLab.Host/Release/net10.0'
            if(-not (Test-Path -LiteralPath (Join-Path $built 'Tedd.DotNetLab.Host.dll'))){throw 'Ordinary host output missing'}
            Copy-Item -LiteralPath $built -Destination $output -Recurse
            Get-ChildItem -LiteralPath $output -File -Recurse|Get-FileHash|Select-Object Path,Hash|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root "$variant`2-bundle-hashes.json")
        }
        & dotnet --version | Set-Content -LiteralPath (Join-Path $root 'sdk-version.txt')
    } finally {Pop-Location}
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'COLD-FAILURE-LOG-PROTOCOL.md') -Destination (Join-Path $root 'protocol.txt')
    Get-Content -LiteralPath (Join-Path $root 'patch-review.json') -Raw
} finally {Exit-VoxtreePerformanceHost $leases}
