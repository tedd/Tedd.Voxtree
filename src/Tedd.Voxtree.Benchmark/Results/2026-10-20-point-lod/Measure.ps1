param(
    [Parameter(Mandatory)][string]$Rig,
    [Parameter(Mandatory)][string]$LabHost,
    [Parameter(Mandatory)][string]$Workspace,
    [string]$Filter = '*',
    [string[]]$SelectedScenarios = @(),
    [string]$Label = 'exploration',
    [ValidatePattern('^[0-9]+$')][string]$Seed = '20261022',
    [ValidateRange(1,12)][int]$Blocks = 12,
    [ValidateRange(0,4)][int]$WarmupBatches = 4,
    [ValidateSet('fixed','scaled','precision','bounded-lifecycle','bounded-point','bounded-consumer','bounded-consumer-v14','bounded-consumer-v16','bounded-consumer-v17')][string]$Budget = 'fixed',
    [ValidateSet('quiet-validation','cpu-diagnostic')][string]$Profile = 'quiet-validation',
    [string]$JitDisasm = '',
    [string]$JitAssembly = '',
    [string]$JitOutput = ''
)
$ErrorActionPreference = 'Stop'
$dotnetExecutable = (Get-Command dotnet).Source
$env:TEMP = Join-Path $Workspace 'temp'
$env:TMP = $env:TEMP
New-Item -ItemType Directory -Path $Workspace,$env:TEMP -Force | Out-Null
$driverSnapshot = Join-Path $Workspace 'driver-source'
New-Item -ItemType Directory -Path $driverSnapshot -Force | Out-Null
Get-ChildItem -LiteralPath $PSScriptRoot -File | Where-Object { $_.Extension -eq '.ps1' -or $_.Name.EndsWith('.cs.txt') -or $_.Name -eq 'protocol.md' } | Copy-Item -Destination $driverSnapshot
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$hostLeases = Enter-VoxtreePerformanceHost -ControllerAdmission
$targetProcess = $null
$controller = $null
$rpcSequence = 0
$preparationLeases = $null
try {
    $preparationLeases = Enter-VoxtreePerformanceHost
    function Invoke-Rpc([string]$Method, $Parameters) {
        $script:rpcSequence++
        $rpcId = $script:rpcSequence
        $rpc = @{jsonrpc='2.0';id=$rpcId;method=$Method;params=$Parameters} | ConvertTo-Json -Depth 60 -Compress
        $controller.StandardInput.WriteLine($rpc); $controller.StandardInput.Flush()
        while ($true) {
            $line = $controller.StandardOutput.ReadLine()
            if (-not $line) { throw 'Owned MCP controller exited unexpectedly; inspect its journal.' }
            $message = $line | ConvertFrom-Json -Depth 70
            if ($message.id -eq $rpcId) {
                if ($message.error) { throw ($message.error | ConvertTo-Json -Depth 30) }
                return $message.result
            }
        }
    }
    function Invoke-Lab([string]$Tool, $Request) {
        $ordered = [ordered]@{}
        if ($Request.ContainsKey('action')) { $ordered.action = $Request.action }
        if ($Request.ContainsKey('view')) { $ordered.view = $Request.view }
        foreach ($key in $Request.Keys) { if (-not $ordered.Contains($key)) { $ordered[$key] = $Request[$key] } }
        $payload = $ordered | ConvertTo-Json -Depth 40 -Compress
        if ($controller) {
            $rpcResult = Invoke-Rpc 'tools/call' @{name=$Tool;arguments=@{request=$ordered}}
            if ($rpcResult.structuredContent) { $parsed = $rpcResult.structuredContent }
            else { $parsed = $rpcResult.content[0].text | ConvertFrom-Json -Depth 60 }
            if ($parsed.status -ne 'ok') { throw ($parsed | ConvertTo-Json -Depth 40) }
            return $parsed.data
        }
        $response = $payload | & $dotnetExecutable exec --fx-version 10.0.13 $LabHost call $Workspace $Tool
        $parsed = $response | ConvertFrom-Json -Depth 50
        if ($LASTEXITCODE -ne 0 -or $parsed.status -ne 'ok') { throw ($response -join "`n") }
        return $parsed.data
    }
    & $dotnetExecutable exec --fx-version 10.0.13 $LabHost init $Workspace | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Catalog initialization failed' }
    $start = [Diagnostics.ProcessStartInfo]::new($dotnetExecutable)
    $start.ArgumentList.Add('exec'); $start.ArgumentList.Add('--fx-version'); $start.ArgumentList.Add('10.0.13')
    $start.ArgumentList.Add($Rig); $start.ArgumentList.Add('--harness'); $start.ArgumentList.Add($Workspace)
    $start.UseShellExecute = $false; $start.CreateNoWindow = $true
    $start.RedirectStandardInput = $true; $start.RedirectStandardOutput = $true; $start.RedirectStandardError = $true
    if($JitDisasm) {
        if($Profile -ne 'cpu-diagnostic' -or -not $JitOutput){throw 'JIT output requires a CPU diagnostic profile and explicit output file'}
        $start.Environment['DOTNET_JitDisasm']=$JitDisasm
        $start.Environment['DOTNET_JitDisasmAssemblies']=$JitAssembly
        $start.Environment['DOTNET_JitStdOutFile']=$JitOutput
        @{scope='owned_target_only';methods=$JitDisasm;assembly=$JitAssembly;output=$JitOutput}|
            ConvertTo-Json|Set-Content -LiteralPath (Join-Path $Workspace "$Label-target-diagnostics.json")
    }
    $startupLeases = Enter-VoxtreePerformanceHost
    try {
    $targetProcess = [Diagnostics.Process]::Start($start)
    $identityLine = $targetProcess.StandardOutput.ReadLine()
    if (-not $identityLine) { throw $targetProcess.StandardError.ReadToEnd() }
    $identity = $identityLine | ConvertFrom-Json
    } finally { Exit-VoxtreePerformanceHost $startupLeases }
    $identityLine | Set-Content -LiteralPath (Join-Path $Workspace "$Label-target.json")
    $discovery = Invoke-Lab 'lab.discover' @{action='targets';limit=1000}
    $discovered = @($discovery.rows | Where-Object process_id -EQ $identity.process_id)
    if ($discovered.Count -ne 1 -or $discovered[0].target_id -ne $identity.id) { throw 'Harness/discovery identity mismatch' }
    $capabilities = Invoke-Lab 'lab.discover' @{action='capabilities';target_id=$identity.id}
    $capabilities | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-capabilities.json")
    $scenarioDiscovery = Invoke-Lab 'lab.discover' @{action='scenarios';target_id=$identity.id}
    $scenarioDiscovery | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-scenarios.json")
    $scenarios = @($scenarioDiscovery.scenarios)
    $selected = @($scenarios | Where-Object { $_.id -Like $Filter -and ($SelectedScenarios.Count -eq 0 -or $_.id -in $SelectedScenarios) })
    if ($selected.Count -eq 0) { throw "No scenarios matched $Filter" }
    $plans = @()
    foreach ($scenario in $selected) {
        $operations = 256
        if ($Budget -eq 'scaled') {
            $operations = if ($scenario.id -like 'point-*') { if($scenario.id -like '*-create'){8}elseif($scenario.id -like '*-lifecycle'){1}else{16384} } elseif ($scenario.id -like 'query-*') { 16 } elseif ($scenario.id -like '*-random-*') { 16 } elseif ($scenario.id -like '*-uniform-*') { 4096 } elseif ($scenario.id -like '*-clustered-*') { 1024 } elseif ($scenario.id -like '*-sparse-*') { 128 } else { 256 }
        }
        if ($Budget -in @('precision','bounded-lifecycle')) {
            $operations = if($scenario.id -like '*-create'){if($Budget -eq 'bounded-lifecycle'){256}else{4096}}
                elseif($scenario.id -like '*-lifecycle'){if($Budget -eq 'bounded-lifecycle'){16}else{128}}
                elseif($scenario.id -like '*-compiled-*' -or $scenario.id -like '*-uniform-*' -or $scenario.id -like '*-dense-*'){33554432}
                elseif($scenario.id -like '*-Huge-*-long-*'){1048576}
                elseif($scenario.id -like '*-sparse-*'){4194304}else{2097152}
        }
        if ($Budget -eq 'bounded-point') {
            $operations=if($scenario.id -like '*-create'){256}elseif($scenario.id -like '*-lifecycle'){16}else{2097152}
        }
        if ($Budget -eq 'bounded-consumer') {
            if($scenario.version -ne '13' -or $scenario.id -notlike 'bulk-*'){throw 'Consumer budget requires version-13 bulk fixtures'}
            $operations=if($scenario.id -like '*-buildread'){2}elseif($scenario.id -match '-(copy|validate|count|miss)$'){64}else{16}
        }
        if ($Budget -eq 'bounded-consumer-v14') {
            if($scenario.version -ne '14' -or $scenario.id -notlike 'bulk-*'){throw 'Version-14 consumer budget requires its frozen fixture'}
            $operations=if($scenario.id -like '*-buildread'){2}elseif($scenario.id -match '-(copy|validate|count|miss|count7|miss7|count17|miss17)$'){64}else{16}
        }
        if ($Budget -eq 'bounded-consumer-v16') {
            if($scenario.version -ne '16' -or $scenario.id -notlike 'bulk-*'){throw 'Version-16 consumer budget requires its frozen compact fixture'}
            $operations=if($scenario.id -like '*-buildread'){2}elseif($scenario.id -match '-(copy|validate|count|miss|count7|miss7|count17|miss17)$'){64}else{16}
        }
        if ($Budget -eq 'bounded-consumer-v17') {
            if($scenario.version -ne '17' -or $scenario.id -notlike 'bulk-*'){throw 'Version-17 consumer budget requires its frozen bounds fixture'}
            $operations=if($scenario.id -like '*-buildread'){2}elseif($scenario.id -match '-(copy|validate|count|miss|count7|miss7|count17|miss17)$'){64}else{16}
        }
        $plan = Invoke-Lab 'lab.experiment' @{
            action='create_plan';scenario_id=$scenario.id;scenario_version=$scenario.version;input_hash=$scenario.input_hash
            variants=@('baseline','candidate');blocks=$Blocks;operations_per_run=$operations;warmup_batches=$WarmupBatches;seed=$Seed
            profile=$Profile;independent_blocks=$false;confirmatory=$false;maximum_duration_seconds=120
            target_runtime_version='10.0.13'
            analysis=@{alpha_family=0.05;family_size=$selected.Count;equivalence_lower_ratio=0.95;equivalence_upper_ratio=1.05;useful_improvement_ratio=0.95;meaningful_regression_ratio=1.05;minimum_blocks=10}
        }
        $plans += [pscustomobject]@{scenario=$scenario.id;plan=$plan}
    }
    $plans | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-plans.json")
    $runBudget = 2 * $Blocks * $selected.Count
    $grantText = & $dotnetExecutable exec --fx-version 10.0.13 $LabHost grant $Workspace $identity.process_id execute_registered_scenario 3600 $runBudget
    if ($LASTEXITCODE -ne 0) { throw $grantText }
    $grant = $grantText | ConvertFrom-Json
    $grantText | Set-Content -LiteralPath (Join-Path $Workspace "$Label-grant.json")
    $observationGrant = $null
    if ($Profile -ne 'quiet-validation') {
        $observationText = & $dotnetExecutable exec --fx-version 10.0.13 $LabHost grant $Workspace $identity.process_id observe 3600 $selected.Count
        if ($LASTEXITCODE -ne 0) { throw $observationText }
        $observationGrant = $observationText | ConvertFrom-Json
        $observationText | Set-Content -LiteralPath (Join-Path $Workspace "$Label-observation-grant.json")
    }
    $controllerStart = [Diagnostics.ProcessStartInfo]::new($dotnetExecutable)
    foreach ($argument in @('exec','--fx-version','10.0.13',$LabHost,'serve',$Workspace)) { $controllerStart.ArgumentList.Add($argument) }
    $controllerStart.UseShellExecute=$false; $controllerStart.CreateNoWindow=$true
    $controllerStart.RedirectStandardInput=$true; $controllerStart.RedirectStandardOutput=$true; $controllerStart.RedirectStandardError=$true
    $controller = [Diagnostics.Process]::Start($controllerStart)
    $controllerErrors = $controller.StandardError.ReadToEndAsync()
    Invoke-Rpc 'initialize' @{protocolVersion='2025-03-26';capabilities=@{};clientInfo=@{name='voxtree-performance';version='1'}} | Out-Null
    $controller.StandardInput.WriteLine('{"jsonrpc":"2.0","method":"notifications/initialized"}')
    Invoke-Lab 'lab.discover' @{action='scenarios';target_id=$identity.id} | Out-Null
    Exit-VoxtreePerformanceHost $preparationLeases
    $preparationLeases = $null
    foreach ($item in $plans) {
        $request = @{action='start';target_id=$identity.id;expected_target_epoch=[string]$identity.epoch;plan_id=$item.plan.id;grant_id=$grant.id;idempotency_key="$Label-$($item.scenario)"}
        if ($observationGrant) { $request.observation_grant_id=$observationGrant.id }
        $request | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-request.json")
        $op = Invoke-Lab 'lab.run' $request
        $op | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-operation.json")
        while ($op.state -notin 'completed','failed','cancelled','lost','tainted','interrupted') {
            Start-Sleep -Milliseconds 100
            $op = Invoke-Lab 'lab.run' @{action='status';operation_id=$op.id}
        }
        $op | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-terminal.json")
        if ($op.state -ne 'completed') {
            if ($op.result_id) {
                Invoke-Lab 'lab.inspect' @{action='record';id=$op.result_id} |
                    ConvertTo-Json -Depth 60 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-failed-execution.json")
            }
            throw ($op | ConvertTo-Json -Depth 30)
        }
        $result = Invoke-Lab 'lab.inspect' @{action='record';id=$op.result_id}
        $execution = $result.json | ConvertFrom-Json -Depth 50
        if ($execution.capture_id) {
            $stackOperation=Invoke-Lab 'lab.run' @{action='analyze_stacks';capture_id=$execution.capture_id;idempotency_key="$Label-$($item.scenario)-stacks"}
            while ($stackOperation.state -notin 'completed','failed','tainted','cancelled','lost') {
                Start-Sleep -Milliseconds 100
                $stackOperation=Invoke-Lab 'lab.run' @{action='status';operation_id=$stackOperation.id}
            }
            $stackOperation | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-stack-operation.json")
            if ($stackOperation.state -ne 'completed') { throw 'Stack analysis failed; preserve capture and operation.' }
            foreach ($ranking in @('self','inclusive')) {
                Invoke-Lab 'lab.query' @{view='hotspots';result_id=$stackOperation.result_id;ranking=$ranking;limit=30} |
                    ConvertTo-Json -Depth 60 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-hotspots-$ranking.json")
            }
        }
        $runs = foreach ($runId in $execution.run_ids) { Invoke-Lab 'lab.inspect' @{action='record';id=$runId} }
        $runs | ConvertTo-Json -Depth 60 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-runs.json")
        $comparison = Invoke-Lab 'lab.compare' @{execution_id=$op.result_id;include_objectives=$true}
        $result | ConvertTo-Json -Depth 60 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-execution.json")
        $comparison | ConvertTo-Json -Depth 60 | Set-Content -LiteralPath (Join-Path $Workspace "$Label-$($item.scenario)-comparison.json")
        $effect = $comparison.effects_without_run_ids[0].effect
        Write-Output ($item.scenario + ' speedup=' + [Math]::Round(1 / $effect, 3))
    }
}
finally {
    if ($controller -and -not $controller.HasExited) {
        $controller.StandardInput.Close()
        if (-not $controller.WaitForExit(30000)) { throw 'Owned controller did not exit; preserve its workspace.' }
        $controllerErrors.GetAwaiter().GetResult() | Set-Content -LiteralPath (Join-Path $Workspace "$Label-controller.log")
    }
    if ($targetProcess -and -not $targetProcess.HasExited) {
        $targetProcess.StandardInput.WriteLine('shutdown'); $targetProcess.StandardInput.Close()
        if (-not $targetProcess.WaitForExit(30000)) { throw 'Owned harness did not exit; preserve its workspace.' }
    }
    @{targetId=$identity.id;targetPid=$(if($targetProcess){$targetProcess.Id}else{$null});
        targetExited=$(if($targetProcess){$targetProcess.HasExited}else{$null});
        targetExitCode=$(if($targetProcess -and $targetProcess.HasExited){$targetProcess.ExitCode}else{$null});
        controllerPid=$(if($controller){$controller.Id}else{$null});
        controllerExited=$(if($controller){$controller.HasExited}else{$null});
        checkedAt=[DateTimeOffset]::UtcNow.ToString('O')} | ConvertTo-Json |
        Set-Content -LiteralPath (Join-Path $Workspace "$Label-shutdown.json")
    if ($preparationLeases) { Exit-VoxtreePerformanceHost $preparationLeases }
    Exit-VoxtreePerformanceHost $hostLeases
}
