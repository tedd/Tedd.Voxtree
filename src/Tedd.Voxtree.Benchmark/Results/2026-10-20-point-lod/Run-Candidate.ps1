param(
    [Parameter(Mandatory)][string]$TaskRoot,
    [Parameter(Mandatory)][string]$LabDirectory,
    [Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9-]*$')][string]$Label,
    [Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9-]*$')][string]$SourceDirectoryName,
    [string]$BaselineSource='',
    [Parameter(Mandatory)][string]$FixtureName,
    [Parameter(Mandatory)][string]$TestFixture,
    [string]$ScenarioFilter='*compiled*',
    [string[]]$SelectedScenarios=@(),
    [string]$CodeScenario='point-ForceUInt32-L5-mixed-u16-air-compiled-get',
    [string]$CodeMethods='*GetPacked* *GetDirectState* *GetUnchecked*',
    [ValidateSet('bounded-lifecycle','bounded-point')][string]$Budget='bounded-lifecycle',
    [switch]$WordStorage,
    [switch]$JointStates,
    [switch]$DirectStates,
    [switch]$ByteEncoding,
    [switch]$PackedLeaf,
    [switch]$CorrectnessOnly
)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
if((Test-Path -LiteralPath (Join-Path $TaskRoot $Label)) -or (Test-Path -LiteralPath (Join-Path $TaskRoot "$Label-screen"))){throw 'Candidate label exists; inspect original operation before recovery'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission
try {
    @{label=$Label;candidateSource=$SourceDirectoryName;baselineSource=$BaselineSource;fixture=$FixtureName;fixtureSha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $FixtureName)).Hash;testFixture=$TestFixture;filter=$ScenarioFilter;selectedScenarios=$SelectedScenarios;codeScenario=$CodeScenario;wordStorage=[bool]$WordStorage;jointStates=[bool]$JointStates;budget=$Budget;continuousPipelineLease=$true;externalMeasurementAdmission=$true;controllerOwnsTimedAdmission=$true;directStates=[bool]$DirectStates;byteEncoding=[bool]$ByteEncoding;packedLeaf=[bool]$PackedLeaf;codeMethods=$CodeMethods;correctnessOnly=[bool]$CorrectnessOnly} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $TaskRoot "$Label-driver-settings.json")
    & (Join-Path $PSScriptRoot 'Build-Rig.ps1') -TaskRoot $TaskRoot -LabDirectory $LabDirectory -Label $Label -BaselineSource $BaselineSource -CandidateSource (Join-Path $TaskRoot $SourceDirectoryName) -FixtureName $FixtureName *> (Join-Path $TaskRoot "$Label-build.log")
    if($LASTEXITCODE -ne 0){throw 'Candidate build failed'}
    $bundle=Join-Path $TaskRoot "bundles/$Label"
    Invoke-VoxtreeExternalPhase {
    & dotnet exec --fx-version 10.0.13 (Join-Path $bundle "$Label.dll") --validate *> (Join-Path $TaskRoot "$Label-validation.log")
    if($LASTEXITCODE -ne 0){throw 'Candidate semantic oracle failed'}
    & dotnet exec --fx-version 10.0.13 (Join-Path $bundle "$Label.dll") --callers *> (Join-Path $TaskRoot "$Label-callers.json")
    if($LASTEXITCODE -ne 0){throw 'Candidate caller inventory failed'}
    }
    & (Join-Path $PSScriptRoot 'Test-PackedLookup.ps1') -TaskRoot $TaskRoot -Label $Label -SourceDirectoryName $SourceDirectoryName -FixtureName $TestFixture -WordStorage:$WordStorage -JointStates:$JointStates -DirectStates:$DirectStates -ByteEncoding:$ByteEncoding -PackedLeaf:$PackedLeaf
    if($CorrectnessOnly){return}
    & (Join-Path $PSScriptRoot 'Inspect-Code.ps1') -TaskRoot $TaskRoot -Bundle $bundle -Label "$Label-code" -Scenario $CodeScenario -Methods $CodeMethods
    & (Join-Path $PSScriptRoot 'Measure.ps1') -Rig (Join-Path $bundle "$Label.dll") -LabHost (Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll') -Workspace (Join-Path $TaskRoot "$Label-screen") -Filter $ScenarioFilter -SelectedScenarios $SelectedScenarios -Label $Label -Budget $Budget *> (Join-Path $TaskRoot "$Label-screen.log")
} finally {Exit-VoxtreePerformanceHost $leases}
