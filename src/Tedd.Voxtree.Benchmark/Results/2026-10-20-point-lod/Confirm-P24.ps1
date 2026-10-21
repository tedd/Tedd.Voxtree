param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
$preparation=$null;$controller=$null;$sequence=0;$operationActive=$false;$submissionUnknown=$false
$root=Join-Path $TaskRoot 'p24-confirmation'
$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
function Close-OwnedController([string]$Scenario){
    if(-not $controller){return}
    if($operationActive -or $submissionUnknown){throw 'Acceptance/operation unresolved: inspect original journal before shutdown'}
    if(-not $controller.HasExited){$controller.StandardInput.Close();if(-not $controller.WaitForExit(30000)){throw 'Controller did not join'}}
    $controllerErrors.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root ($Scenario+'-controller.log'))
    @{pid=$controller.Id;startTicks=[string]$controller.StartTime.ToUniversalTime().Ticks;joined=$controller.HasExited;exitCode=$controller.ExitCode}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root ($Scenario+'-controller-shutdown.json'))
}
try {
    $preparation=Enter-VoxtreePerformanceHost
    & python (Join-Path $PSScriptRoot 'Prepare-P24Confirmation.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'P24 input binding failed'}
    $snapshot=Join-Path $root 'driver-source';New-Item -ItemType Directory -Path $snapshot|Out-Null
    foreach($name in @('Confirm-P24.ps1','Prepare-P24Confirmation.py','PACKED-WORD-FORMAT-PROTOCOL.md','Host-Lock.ps1','Lab-LocalClient.ps1')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination $snapshot}
    & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
    if($LASTEXITCODE -ne 0){throw 'P24 catalog initialization failed'}
    $inputs=Get-Content -LiteralPath (Join-Path $root 'inputs.json') -Raw|ConvertFrom-Json -Depth 50
    $evidence=Import-File (Join-Path $root 'inputs.json') application/json
    $hypothesis=Invoke-Lab lab.experiment @{action='create_hypothesis';mechanism='P24 selected before new data: disambiguate packed words with magic P while retaining P18 hot reader bodies; packed value/LOD words replace dependent tree traversal. Preserve legacy wire formats and all original allocation and broad API guardrails.';prediction='In a separate complete eight-case direct release-to-P24 family, each adjusted time speedup lower bound reaches 10; correctness, corpus, dependencies and caller bindings remain valid. Old P18/D1/L1 timings are excluded. Failure or incomplete guards prevents adoption.';evidence_ids=@($evidence.id)}
    $hypothesis|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'hypothesis.json')
    $builds=@()
    foreach($bundle in $inputs.bundles){
        $files=@(foreach($file in $bundle.files){
            if((Get-FileHash -LiteralPath $file.path).Hash.ToLowerInvariant() -ne $file.sha256){throw 'Frozen bundle changed'}
            $artifact=Import-File $file.path $(if($file.name.EndsWith('.dll')){'application/vnd.microsoft.portable-executable'}else{'application/json'})
            @{name=$file.name;artifact_id=$artifact.id}
        })
        $builds+=Invoke-Lab lab.experiment @{action='register_normal_build';entry_assembly=$bundle.entry;files=$files}
    }
    $builds|ConvertTo-Json -Depth 50|Set-Content -LiteralPath (Join-Path $root 'builds.json')
    $patch=Import-File (Join-Path $root 'source.diff') text/x-diff
    $candidate=Invoke-Lab lab.experiment @{action='create_candidate';name='P24 disambiguated packed-word source';build_identity=$builds[1].content_hash;components=@()}
    $selected=@()
    foreach($item in @(Get-Content -LiteralPath (Join-Path $root 'experiments.json') -Raw|ConvertFrom-Json -AsHashtable -Depth 70)){
        $plan=Invoke-Lab lab.experiment @{action='create_confirmation_plan';selected_candidate_id=$candidate.id;source_patch_artifact_id=$patch.id;
            source_equivalence_rationale='Separate full family, never old-family continuation or pooled evidence. Complete release f0772c8 source control and complete selected P24 source are independently normalized and byte-hashed. P24 preserves P18 hot word-reader source after header logic, changes wire magic, exposes packed version, and rejects conflicting prototype headers. All eight canonical primary AfterBatch callers match; raw hashes retained. Identical fixture, dependency DLL closure and runtime settings. Both normal bundles passed all 48 oracles; P24 passed .NET8/10/11 and hardware-off tests and full 1286-chunk/42139648-cell differential census. Version12 declares one public read per operation. No observer. Every primary adjusted lower speedup must reach 10; original allocation policy remains. Point-only outcomes cannot establish broad API, construction, query, fallback or memory adoption guards.';
            baseline_build_id=$builds[0].id;candidate_build_id=$builds[1].id;baseline_variant='baseline';candidate_variant='candidate';experiment=$item.experiment;exploratory_evidence_ids=@($hypothesis.id)}
        $selected+=@{scenario=$item.scenario;plan=$plan}
    }
    $selected|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'plans.json')
    Exit-VoxtreePerformanceHost $preparation;$preparation=$null
    foreach($item in $selected){
        # Each case obtains its grant only after all plans are frozen, immediately before its own controller.
        $preparation=Enter-VoxtreePerformanceHost
        $raw=& $dotnet exec --fx-version 10.0.13 $labHost grant-confirmation $root $item.plan.id 3600 24
        if($LASTEXITCODE -ne 0){throw 'P24 exact launch grant failed'}
        $grant=$raw|ConvertFrom-Json;$grant|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-grant.json'))
        $start=[Diagnostics.ProcessStartInfo]::new($dotnet)
        foreach($arg in @('exec','--fx-version','10.0.13',$labHost,'serve',$root)){$start.ArgumentList.Add($arg)}
        $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardInput=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true;$start.WorkingDirectory=$root
        $controller=[Diagnostics.Process]::Start($start);$controllerErrors=$controller.StandardError.ReadToEndAsync()
        @{pid=$controller.Id;startTicks=[string]$controller.StartTime.ToUniversalTime().Ticks;entry=$labHost;entrySha256=(Get-FileHash -LiteralPath $labHost).Hash;runtime='10.0.13';owned=$true;workspace=$root}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-controller.json'))
        Invoke-Rpc initialize @{protocolVersion='2025-03-26';capabilities=@{};clientInfo=@{name='voxtree-p24-confirmation';version='1'}}|Out-Null
        $controller.StandardInput.WriteLine('{"jsonrpc":"2.0","method":"notifications/initialized"}')
        Exit-VoxtreePerformanceHost $preparation;$preparation=$null
        $request=@{action='start_confirmation';plan_id=$item.plan.id;grant_id=$grant.id;idempotency_key='P24-'+$item.scenario}
        $request|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-request.json'))
        $submissionUnknown=$true;$op=Invoke-Lab lab.run $request;$submissionUnknown=$false;$operationActive=$true
        $op|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-operation.json'))
        while($op.state -notin 'completed','failed','tainted','cancelled','interrupted','lost'){
            Start-Sleep -Milliseconds 200;$op=Invoke-Lab lab.run @{action='status';operation_id=$op.id}
        }
        $operationActive=$false
        $op|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-terminal.json'))
        if($op.result_id){
            $record=Invoke-Lab lab.inspect @{action='record';id=$op.result_id}
            $record|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-execution.json'))
            $execution=$record.json|ConvertFrom-Json -Depth 50
            $sessions=@(foreach($id in $execution.session_ids){Invoke-Lab lab.inspect @{action='record';id=$id}})
            $sessions|ConvertTo-Json -Depth 80|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-sessions.json'))
        }
        if($op.state -eq 'completed'){
            $comparison=Invoke-Lab lab.compare @{execution_id=$op.result_id;normal_build_confirmation=$true}
            $comparison|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-decision.json'))
            foreach($id in @($comparison.comparison_id,$comparison.objective_vector_id)|Where-Object{$_}){
                $record=Invoke-Lab lab.inspect @{action='record';id=$id}
                $record|ConvertTo-Json -Depth 80|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-'+$record.kind+'.json'))
            }
        }
        Close-OwnedController $item.scenario;$controller=$null
        Write-Output ($item.scenario+' confirmation '+$op.state)
        if($op.state -ne 'completed'){throw 'P24 family stopped at first noncompleted case; preserve partial evidence'}
    }
} catch {
    if(Test-Path -LiteralPath $root){$_.Exception.ToString()|Set-Content -LiteralPath (Join-Path $root 'driver-failure.log')}
    throw
} finally {
    if($controller){Close-OwnedController $item.scenario}
    if($preparation){Exit-VoxtreePerformanceHost $preparation}
    Exit-VoxtreePerformanceHost $leases
}
