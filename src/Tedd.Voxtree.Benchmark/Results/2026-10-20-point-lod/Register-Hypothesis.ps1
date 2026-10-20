param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory,
      [Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9-]*$')][string]$Label,
      [Parameter(Mandatory)][string]$ProtocolName,[Parameter(Mandatory)][string]$Mechanism,
      [Parameter(Mandatory)][string]$Prediction)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -MeasurementOnly
try {
    $catalog=Join-Path $TaskRoot "$Label-hypothesis"
    if(Test-Path -LiteralPath $catalog){throw 'Hypothesis workspace exists; inspect its retained request before recovery'}
    $labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
    $protocol=Join-Path $PSScriptRoot $ProtocolName
    $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
    & dotnet exec --fx-version 10.0.13 $labHost init $catalog | Out-Null
    if($LASTEXITCODE -ne 0){throw 'Hypothesis catalog initialization failed'}
    @{label=$Label;protocolSha256=(Get-FileHash -LiteralPath $protocol).Hash;protocolMarkdown=(Get-Content -LiteralPath $protocol -Raw)} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $catalog 'protocol.json')
    $import=& dotnet exec --fx-version 10.0.13 $labHost import $catalog (Join-Path $catalog 'protocol.json') application/json
    if($LASTEXITCODE -ne 0){throw 'Protocol artifact import failed'}
    $artifact=$import | ConvertFrom-Json
    $import | Set-Content -LiteralPath (Join-Path $catalog 'protocol-artifact.json')
    $request=@{action='create_hypothesis';mechanism=$Mechanism;prediction=$Prediction;evidence_ids=@($artifact.id)}
    $request | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $catalog 'hypothesis-request.json')
    $response=($request | ConvertTo-Json -Compress) | & dotnet exec --fx-version 10.0.13 $labHost call $catalog lab.experiment
    $response | Set-Content -LiteralPath (Join-Path $catalog 'hypothesis-response.json')
    if($LASTEXITCODE -ne 0 -or ($response | ConvertFrom-Json).status -ne 'ok'){throw 'Hypothesis registration failed'}
    $response
} finally {Exit-VoxtreePerformanceHost $leases}
