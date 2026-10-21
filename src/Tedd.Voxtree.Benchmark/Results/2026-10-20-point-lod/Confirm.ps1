param(
    [Parameter(Mandatory)][string]$LabHost,
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$BaselineBundle,
    [Parameter(Mandatory)][string]$CandidateBundle,
    [Parameter(Mandatory)][string[]]$Scenarios,
    [string]$Label = 'confirmation',
    [string]$ExplorationLabel = 'g3',
    [ValidateSet('original','precision','long-window','grouped-window','point-window')][string]$Budget = 'original',
    [string]$SourcePatchFile='',
    [string]$SourceEquivalenceRationale=''
)
$ErrorActionPreference = 'Stop'
$dotnetExecutable = (Get-Command dotnet).Source
$controller = $null; $rpcSequence = 0
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$hostLeases = Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
$preparationLeases = $null
try {
    $preparationLeases = Enter-VoxtreePerformanceHost
    $driverSnapshot=Join-Path $Workspace "$Label-driver-source"
    New-Item -ItemType Directory -Path $driverSnapshot -Force|Out-Null
    Get-ChildItem -LiteralPath $PSScriptRoot -File|Where-Object{$_.Extension -eq '.ps1' -or $_.Name.EndsWith('.cs.txt') -or $_.Name -eq 'protocol.md'}|Copy-Item -Destination $driverSnapshot
    function Invoke-Rpc([string]$Method,$Parameters) {
        $script:rpcSequence++; $rpcId = $script:rpcSequence
        $controller.StandardInput.WriteLine((@{jsonrpc='2.0';id=$rpcId;method=$Method;params=$Parameters} | ConvertTo-Json -Depth 60 -Compress))
        $controller.StandardInput.Flush()
        while ($true) {
            $line = $controller.StandardOutput.ReadLine()
            if (-not $line) { throw 'Controller exited; inspect the accepted operation journal.' }
            $message = $line | ConvertFrom-Json -Depth 70
            if ($message.id -eq $rpcId) {
                if ($message.error) { throw ($message.error | ConvertTo-Json -Depth 30) }
                return $message.result
            }
        }
    }
    function Invoke-Lab([string]$Tool,$Request) {
        @{tool=$Tool;request=$Request} | ConvertTo-Json -Depth 60 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-last-request.json")
        $ordered = [ordered]@{}
        if ($Request.ContainsKey('action')) { $ordered.action=$Request.action }
        foreach ($key in $Request.Keys) { if (-not $ordered.Contains($key)) { $ordered[$key]=$Request[$key] } }
        if ($controller) {
            $result = Invoke-Rpc 'tools/call' @{name=$Tool;arguments=@{request=$ordered}}
            $response = if ($result.structuredContent) { $result.structuredContent } else { $result.content[0].text | ConvertFrom-Json -Depth 60 }
        } else {
            $text = ($ordered | ConvertTo-Json -Depth 60 -Compress) | & $dotnetExecutable exec --fx-version 10.0.13 $LabHost call $Workspace $Tool
            $response = $text | ConvertFrom-Json -Depth 70
            if ($LASTEXITCODE -ne 0) { throw $text }
        }
        if ($response.status -ne 'ok') { throw ($response | ConvertTo-Json -Depth 50) }
        return $response.data
    }
    function Import-File([string]$Path,[string]$MediaType) {
        $text = & $dotnetExecutable exec --fx-version 10.0.13 $LabHost import $Workspace $Path $MediaType
        if ($LASTEXITCODE -ne 0) { throw $text }
        return $text | ConvertFrom-Json -Depth 30
    }
    $planFile = Join-Path $Workspace "$Label-plans.json"
    if (Test-Path -LiteralPath $planFile) {
        $selected = @(Get-Content -LiteralPath $planFile -Raw | ConvertFrom-Json -Depth 70)
    } else {
    $builds = @()
    foreach ($bundle in @($BaselineBundle,$CandidateBundle)) {
        $files = @()
        foreach ($file in Get-ChildItem -LiteralPath $bundle -File | Sort-Object Name) {
            $mediaType = if ($file.Extension -eq '.dll') { 'application/vnd.microsoft.portable-executable' } else { 'application/json' }
            $artifact = Import-File $file.FullName $mediaType
            $files += @{name=$file.Name;artifact_id=$artifact.id}
        }
        $entry = (Get-ChildItem -LiteralPath $bundle -Filter '*.runtimeconfig.json').Name.Replace('.runtimeconfig.json','.dll')
        $builds += Invoke-Lab 'lab.experiment' @{action='register_normal_build';entry_assembly=$entry;files=$files}
    }
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    $patchPath = Join-Path $Workspace "$Label-source.diff"
    if($SourcePatchFile){Copy-Item -LiteralPath $SourcePatchFile -Destination $patchPath}
    else {& git -C $repoRoot diff f0772c8 -- src/Tedd.Voxtree | Set-Content -LiteralPath $patchPath}
    $source = Import-File $patchPath 'text/x-diff'
    $candidate = Invoke-Lab 'lab.experiment' @{action='create_candidate';name=$Label;build_identity=$builds[1].content_hash;components=@()}
    $selected = @()
    foreach ($scenario in $Scenarios) {
        $explorationFile = Join-Path $Workspace "$ExplorationLabel-$scenario-execution.json"
        $exploration = (Get-Content -LiteralPath $explorationFile -Raw | ConvertFrom-Json).json | ConvertFrom-Json
        $explorationPlan = Invoke-Lab 'lab.inspect' @{action='record';id=$exploration.plan_id}
        $prior = $explorationPlan.json | ConvertFrom-Json -AsHashtable -Depth 50
        $experiment = [ordered]@{}
        foreach ($key in $prior.Keys) { $experiment[$key]=$prior[$key] }
        $experiment.id='prospective-confirmation'; $experiment.fresh_normal_build=$true
        $experiment.confirmatory=$true; $experiment.independent_blocks=$true
        $experiment.independence_justification='Each paired block uses two newly launched and joined normal-build processes. No mutable fixture, heap, JIT or PGO state crosses sessions; fixed randomized arm order and a shared host driver lock control drift. Independence assumes residual environmental errors after pairing are uncorrelated; hardware state and unrelated load remain limitations.'
        $experiment.seed='20261023'; $experiment.warmup_batches=8; $experiment.maximum_duration_seconds=600
        $experiment.operations_per_run = if($scenario -like 'point-*') {
            if($scenario -like '*-create'){16}elseif($scenario -like '*-lifecycle'){2}else{65536}
        } elseif($scenario -like 'query-*' -and ($scenario -like '*-count' -or $scenario -like '*-miss')) { 64 }
        elseif ($scenario -like '*-random-*') { 256 } elseif ($scenario -like '*-uniform-*') { 8192 } else { 1024 }
        if($Budget -eq 'precision') {
            $experiment.operations_per_run = if($scenario -like '*-create'){4096}
                elseif($scenario -like '*-lifecycle'){128}
                elseif($scenario -like '*-compiled-*' -or $scenario -like '*-uniform-*' -or $scenario -like '*-dense-*'){33554432}
                elseif($scenario -like '*-Huge-*-long-*'){1048576}
                elseif($scenario -like '*-sparse-*'){4194304}else{2097152}
        }
        if($Budget -eq 'long-window') {
            throw 'Historical C2 budget exceeds the installed plan limits; use the prospectively defined C3 grouped-window fixture.'
            $experiment.warmup_batches=1
        }
        if($Budget -eq 'grouped-window') {
            # Version 11 declares sixteen public reads per logical operation.
            # Counts and reported units must not be used with older fixtures.
            if($experiment.scenario_version -ne '11'){throw 'Grouped budget requires version-11 sixteen-read units'}
            $experiment.warmup_batches=1
            $experiment.maximum_duration_seconds=600
            $experiment.operations_per_run=if($scenario -like '*-compiled-*'){33554432}
                elseif($scenario -like '*-Huge-*-long-*'){1048576}
                elseif($scenario -like '*-Wide-*-long-*'){2097152}else{4194304}
        }
        if($Budget -eq 'point-window') {
            if($experiment.scenario_version -ne '12' -or $scenario -notmatch '^point-ForceUInt(16|32)-L5-mixed-u16-air-(owned|span)-(get|lod)$'){
                throw 'Point window requires the frozen version-12 eight-read family'
            }
            $experiment.blocks=12
            $experiment.operations_per_run=8388608
            $experiment.warmup_batches=1
            $experiment.maximum_duration_seconds=600
        }
        $experiment.analysis.family_size=2*$Scenarios.Count
        if($scenario -like '*-create'){$experiment.analysis.meaningful_regression_ratio=1.25}
        $experiment.guardrail_metrics=@('scenario.thread_allocation_bytes_per_operation')
        $experiment.guardrail_policies=@(@{
            metric='scenario.thread_allocation_bytes_per_operation';unit='bytes/operation';observation_kind='batch_normalized_allocation_delta'
            direction='lower_is_better';scale='absolute_difference';equivalence_lower=-0.01;equivalence_upper=0.01
            useful_improvement=-0.01;meaningful_regression=0.01;minimum_blocks=10;descriptive_only=$false
        })
        $rationale=if($SourceEquivalenceRationale){$SourceEquivalenceRationale}else{'Both entry assemblies compile the complete source and identical harness. The baseline label is compile-time mapped to AfterBatch in the control build. The candidate label invokes AfterBatch in the treatment build. The AfterBatch caller IL hashes match exactly across builds; both invoke the ordinary Tedd.Voxtree namespace. This dispatch difference occurs once per batch, outside the identical read loops. The baseline entry compiles f0772c8 there; the treatment entry compiles the selected implementation there. Snapshot helpers are correctness and screening controls only. The attached source patch records every library change; entry identities differ. Dependency DLLs and runtime settings match; Prepare checks encoded byte parity and independent dense-value or query oracles before timing.'}
        if($experiment.operations_per_run -gt 100000000 -or $experiment.maximum_duration_seconds -gt 600){throw 'Plan exceeds installed revision 9c23369 limits'}
        $plan = Invoke-Lab 'lab.experiment' @{
            action='create_confirmation_plan';selected_candidate_id=$candidate.id;source_patch_artifact_id=$source.id
            source_equivalence_rationale=$rationale
            baseline_build_id=$builds[0].id;candidate_build_id=$builds[1].id;baseline_variant='baseline';candidate_variant='candidate'
            experiment=$experiment;exploratory_evidence_ids=@($exploration.id)
        }
        $selected += [pscustomobject]@{scenario=$scenario;plan=$plan}
    }
    $selected | ConvertTo-Json -Depth 60 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-plans.json")
    }
    $grants = @{}
    foreach ($item in $selected) {
        $operationPath = Join-Path $Workspace "$Label-$($item.scenario)-operation.json"
        if (Test-Path -LiteralPath $operationPath) { continue }
        $text = & $dotnetExecutable exec --fx-version 10.0.13 $LabHost grant-confirmation $Workspace $item.plan.id 3600 24
        if ($LASTEXITCODE -ne 0) { throw $text }
        $grants[$item.plan.id] = $text | ConvertFrom-Json
    }
    $start = [Diagnostics.ProcessStartInfo]::new($dotnetExecutable)
    foreach ($argument in @('exec','--fx-version','10.0.13',$LabHost,'serve',$Workspace)) { $start.ArgumentList.Add($argument) }
    $start.UseShellExecute=$false; $start.CreateNoWindow=$true
    $start.RedirectStandardInput=$true; $start.RedirectStandardOutput=$true; $start.RedirectStandardError=$true
    $controller = [Diagnostics.Process]::Start($start); $errors = $controller.StandardError.ReadToEndAsync()
    Invoke-Rpc 'initialize' @{protocolVersion='2025-03-26';capabilities=@{};clientInfo=@{name='voxtree-confirmation';version='1'}} | Out-Null
    $controller.StandardInput.WriteLine('{"jsonrpc":"2.0","method":"notifications/initialized"}')
    Exit-VoxtreePerformanceHost $preparationLeases
    $preparationLeases = $null
    foreach ($item in $selected) {
        $operationPath = Join-Path $Workspace "$Label-$($item.scenario)-operation.json"
        if (Test-Path -LiteralPath $operationPath) {
            $accepted = Get-Content -LiteralPath $operationPath -Raw | ConvertFrom-Json
            $op = Invoke-Lab 'lab.run' @{action='status';operation_id=$accepted.id}
        } else {
            $request = @{action='start_confirmation';plan_id=$item.plan.id;grant_id=$grants[$item.plan.id].id;idempotency_key="$Label-$($item.scenario)"}
            $request | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-request.json")
            $op = Invoke-Lab 'lab.run' $request
            $op | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $operationPath
        }
        while ($op.state -notin 'completed','failed','tainted','cancelled','interrupted','lost') {
            Start-Sleep -Milliseconds 100
            $op = Invoke-Lab 'lab.run' @{action='status';operation_id=$op.id}
        }
        $op | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-terminal.json")
        if ($op.state -ne 'completed') {
            if($op.result_id){
                $failure=Invoke-Lab 'lab.inspect' @{action='record';id=$op.result_id}
                $failure | ConvertTo-Json -Depth 65 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-failed-execution.json")
            }
            throw ($op | ConvertTo-Json -Depth 30)
        }
        $record = Invoke-Lab 'lab.inspect' @{action='record';id=$op.result_id}
        $execution = $record.json | ConvertFrom-Json
        $sessions = foreach ($sessionId in $execution.session_ids) { Invoke-Lab 'lab.inspect' @{action='record';id=$sessionId} }
        $sessions | ConvertTo-Json -Depth 65 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-sessions.json")
        $record | ConvertTo-Json -Depth 60 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-execution.json")
        $comparison = Invoke-Lab 'lab.compare' @{execution_id=$op.result_id;normal_build_confirmation=$true}
        $comparison | ConvertTo-Json -Depth 65 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-decision.json")
        foreach ($evidenceId in @($comparison.comparison_id,$comparison.objective_vector_id) | Where-Object { $_ }) {
            $evidence = Invoke-Lab 'lab.inspect' @{action='record';id=$evidenceId}
            $evidence | ConvertTo-Json -Depth 65 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-$($evidence.kind).json")
        }
        Write-Output ($item.scenario + ' confirmation completed')
    }
}
finally {
    if ($controller -and -not $controller.HasExited) {
        $controller.StandardInput.Close()
        if (-not $controller.WaitForExit(30000)) { throw 'Controller did not exit; preserve workspace.' }
    }
    if($controller){
        # Persist stderr even when the controller exited before this finally.
        if($errors){$errors.GetAwaiter().GetResult() | Set-Content -LiteralPath (Join-Path $Workspace "$Label-controller.log")}
        @{controllerPid=$controller.Id;controllerExited=$controller.HasExited;exitCode=if($controller.HasExited){$controller.ExitCode}else{$null};checkedAt=[DateTimeOffset]::UtcNow.ToString('o');sessionJoinEvidence='Inspect each retained normal-build session; controller exit alone does not prove child quiescence'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $Workspace "$Label-controller-shutdown.json")
    }
    if ($preparationLeases) { Exit-VoxtreePerformanceHost $preparationLeases }
    Exit-VoxtreePerformanceHost $hostLeases
}
