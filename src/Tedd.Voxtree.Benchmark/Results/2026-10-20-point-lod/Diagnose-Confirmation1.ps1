param([Parameter(Mandatory)][string]$TaskRoot,[Parameter(Mandatory)][string]$LabDirectory)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
$preparation=$null;$controller=$null;$observer=$null;$sequence=0;$operationActive=$false;$submissionUnknown=$false
$root=Join-Path $TaskRoot 'p18-failure-diagnostic-1'
$dotnet=(Get-Command dotnet).Source;$labHost=Join-Path $LabDirectory 'Tedd.DotNetLab.Host.dll'
$env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
$outcomes=@();$failure=$null
try {
    $preparation=Enter-VoxtreePerformanceHost
    & python (Join-Path $PSScriptRoot 'Prepare-FailureDiagnostic1.py') $TaskRoot
    if($LASTEXITCODE -ne 0){throw 'D1 input binding failed'}
    $snapshot=Join-Path $root 'driver-source';New-Item -ItemType Directory -Path $snapshot|Out-Null
    foreach($name in @('Diagnose-Confirmation1.ps1','Prepare-FailureDiagnostic1.py','FAILURE-DIAGNOSTIC-1.md','Host-Lock.ps1','ControllerExceptionRecorder.cs.txt')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination $snapshot}
    & $dotnet exec --fx-version 10.0.13 $labHost init $root | Out-Null
    if($LASTEXITCODE -ne 0){throw 'D1 catalog initialization failed'}
    function Invoke-Rpc([string]$Method,$Parameters){
        $script:sequence++;$id=$script:sequence
        $controller.StandardInput.WriteLine((@{jsonrpc='2.0';id=$id;method=$Method;params=$Parameters}|ConvertTo-Json -Depth 70 -Compress));$controller.StandardInput.Flush()
        while($true){
            $line=$controller.StandardOutput.ReadLine();if(-not $line){throw 'D1 controller exited; inspect original accepted journal'}
            $message=$line|ConvertFrom-Json -Depth 80
            if($message.id -eq $id){if($message.error){throw ($message.error|ConvertTo-Json -Depth 40)};return $message.result}
        }
    }
    function Invoke-Lab([string]$Tool,$Request){
        $ordered=[ordered]@{};if($Request.ContainsKey('action')){$ordered.action=$Request.action}
        foreach($key in $Request.Keys){if(-not $ordered.Contains($key)){$ordered[$key]=$Request[$key]}}
        @{tool=$Tool;request=$ordered}|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'last-request.json')
        if($controller){
            $rpc=Invoke-Rpc 'tools/call' @{name=$Tool;arguments=@{request=$ordered}}
            $response=if($rpc.structuredContent){$rpc.structuredContent}else{$rpc.content[0].text|ConvertFrom-Json -Depth 80}
        }else{
            $raw=($ordered|ConvertTo-Json -Depth 70 -Compress)|& $dotnet exec --fx-version 10.0.13 $labHost call $root $Tool
            if($LASTEXITCODE -ne 0){throw ($raw|Out-String)};$response=$raw|ConvertFrom-Json -Depth 80
        }
        if($response.status -ne 'ok'){throw ($response|ConvertTo-Json -Depth 50)}
        return $response.data
    }
    function Import-File([string]$Path,[string]$MediaType){
        $raw=& $dotnet exec --fx-version 10.0.13 $labHost import $root $Path $MediaType
        if($LASTEXITCODE -ne 0){throw 'D1 import failed'};return $raw|ConvertFrom-Json
    }
    $inputs=Get-Content -LiteralPath (Join-Path $root 'inputs.json') -Raw|ConvertFrom-Json -Depth 40
    $evidence=Import-File (Join-Path $root 'inputs.json') application/json
    $hypothesis=Invoke-Lab lab.experiment @{action='create_hypothesis';mechanism='D1: generic normal-session failure may arise after launch in readiness, execution, artifact/catalog writes or cleanup. A controller exception observer and retained operation/launch chronology distinguish these paths; admission cancellation is separate.';prediction='A reproduced generic failure has an attributable exception type/message and launch/session chronology. No failure within the fixed 192-session budget means unreproduced, not fixed; all D1 measurements are excluded from promotion/performance comparisons.';evidence_ids=@($evidence.id)}
    $hypothesis|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'hypothesis.json')
    $builds=@()
    foreach($bundle in $inputs.bundles){
        $files=@(foreach($file in $bundle.files){$artifact=Import-File $file.path $(if($file.name.EndsWith('.dll')){'application/vnd.microsoft.portable-executable'}else{'application/json'});@{name=$file.name;artifact_id=$artifact.id}})
        $builds+=Invoke-Lab lab.experiment @{action='register_normal_build';entry_assembly=$bundle.entry;files=$files}
    }
    $builds|ConvertTo-Json -Depth 50|Set-Content -LiteralPath (Join-Path $root 'builds.json')
    $patch=Import-File (Join-Path $root 'source.diff') text/x-diff
    $candidate=Invoke-Lab lab.experiment @{action='create_candidate';name='D1 original-source lifecycle diagnostic only';build_identity=$builds[1].content_hash;components=@()}
    $selected=@()
    foreach($item in @(Get-Content -LiteralPath (Join-Path $root 'experiments.json') -Raw|ConvertFrom-Json -AsHashtable -Depth 70)){
        $plan=Invoke-Lab lab.experiment @{action='create_confirmation_plan';selected_candidate_id=$candidate.id;source_patch_artifact_id=$patch.id;
            source_equivalence_rationale='D1 failure diagnostic only, never performance/promotion evidence. Exact original archived p18control/p18census entry bundles, source patch, matching dependencies/runtime settings and original version-12 callers are verified against phase-seven hashes. No source rebuild or old-plan resume; twelve fresh pairs per original case, new fixed seed. API-required normal-confirmation flags do not establish observer-free inference. Controller-only EventPipe exceptions perturb this diagnostic regime.';
            baseline_build_id=$builds[0].id;candidate_build_id=$builds[1].id;baseline_variant='baseline';candidate_variant='candidate';experiment=$item.experiment;exploratory_evidence_ids=@($hypothesis.id)}
        $selected+=@{scenario=$item.scenario;plan=$plan}
    }
    $selected|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'plans.json')
    $grants=@{}
    foreach($item in $selected){
        $raw=& $dotnet exec --fx-version 10.0.13 $labHost grant-confirmation $root $item.plan.id 3600 24
        if($LASTEXITCODE -ne 0){throw 'D1 launch grant failed'};$grants[$item.plan.id]=$raw|ConvertFrom-Json
    }
    $grants|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'grants.json')
    $recorder=Join-Path $TaskRoot 'exception-recorder-v2-source/out/Probe.dll'
    $proof=Get-Content -LiteralPath (Join-Path $TaskRoot 'exception-recorder-v2-source/selftest-proof.json') -Raw|ConvertFrom-Json
    if(-not $proof.complete -or $proof.markerEvents -ne 1 -or $proof.eventsLost -ne 0 -or -not $proof.childJoined -or -not $proof.observerJoined -or (Get-FileHash -LiteralPath $recorder).Hash -ne $proof.entrySha256){throw 'D1 recorder is not the tested record-mode executable'}
    $start=[Diagnostics.ProcessStartInfo]::new($dotnet)
    foreach($arg in @('exec','--fx-version','10.0.13',$labHost,'serve',$root)){$start.ArgumentList.Add($arg)}
    $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardInput=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true;$start.WorkingDirectory=$root
    $start.Environment['DOTNET_EnableDiagnostics']='1'
    $controller=[Diagnostics.Process]::Start($start);$controllerErrors=$controller.StandardError.ReadToEndAsync()
    @{pid=$controller.Id;startTicks=[string]$controller.StartTime.ToUniversalTime().Ticks;entry=$labHost;entrySha256=(Get-FileHash -LiteralPath $labHost).Hash;runtime='10.0.13';owned=$true;workspace=$root}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'controller.json')
    Invoke-Rpc initialize @{protocolVersion='2025-03-26';capabilities=@{};clientInfo=@{name='voxtree-failure-diagnostic';version='1'}}|Out-Null
    $controller.StandardInput.WriteLine('{"jsonrpc":"2.0","method":"notifications/initialized"}')
    $observerRoot=Join-Path $root 'observer'
    $start=[Diagnostics.ProcessStartInfo]::new($dotnet)
    foreach($arg in @('exec','--fx-version','10.0.13',$recorder,[string]$controller.Id,[string]$controller.StartTime.ToUniversalTime().Ticks,$observerRoot)){$start.ArgumentList.Add($arg)}
    $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
    $observer=[Diagnostics.Process]::Start($start);$observerOut=$observer.StandardOutput.ReadToEndAsync();$observerErr=$observer.StandardError.ReadToEndAsync()
    $clock=[Diagnostics.Stopwatch]::StartNew()
    while(-not (Test-Path -LiteralPath (Join-Path $observerRoot 'ready.json'))){
        if($observer.HasExited -or $clock.Elapsed.TotalSeconds -gt 25){throw 'D1 observer did not become ready'};Start-Sleep -Milliseconds 100
    }
    $ready=Get-Content -LiteralPath (Join-Path $observerRoot 'ready.json') -Raw|ConvertFrom-Json
    if($ready.targetPid -ne $controller.Id -or $ready.targetStartTicks -ne $controller.StartTime.ToUniversalTime().Ticks -or $ready.entrySha256 -ne $proof.entrySha256){throw 'D1 observer binding mismatch'}
    Exit-VoxtreePerformanceHost $preparation;$preparation=$null
    foreach($item in $selected){
        if($observer.HasExited){throw 'D1 observer ended before next submission'}
        $request=@{action='start_confirmation';plan_id=$item.plan.id;grant_id=$grants[$item.plan.id].id;idempotency_key='D1-'+$item.scenario}
        $request|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-request.json'))
        $submissionUnknown=$true;$op=Invoke-Lab lab.run $request;$submissionUnknown=$false;$operationActive=$true
        $op|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-operation.json'))
        while($op.state -notin 'completed','failed','tainted','cancelled','interrupted','lost'){
            Start-Sleep -Milliseconds 200;$op=Invoke-Lab lab.run @{action='status';operation_id=$op.id}
        }
        $operationActive=$false
        $op|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-terminal.json'))
        $sessions=@();$execution=$null
        if($op.result_id){
            $record=Invoke-Lab lab.inspect @{action='record';id=$op.result_id}
            $record|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-execution.json'))
            $execution=$record.json|ConvertFrom-Json -Depth 50
            foreach($id in $execution.session_ids){$sessions+=Invoke-Lab lab.inspect @{action='record';id=$id}}
            $sessions|ConvertTo-Json -Depth 80|Set-Content -LiteralPath (Join-Path $root ($item.scenario+'-sessions.json'))
        }
        $outcomes+=@{scenario=$item.scenario;operationId=$op.id;state=$op.state;errorCode=$op.error_code;sessions=$sessions.Count;diagnosticOnly=$true}
        $outcomes|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'outcomes.json')
        Write-Output ($item.scenario+' diagnostic '+$op.state+' sessions='+$sessions.Count)
        if($op.state -ne 'completed'){break}
    }
} catch {
    $failure=$_.Exception.ToString()
    if(Test-Path -LiteralPath $root){$failure|Set-Content -LiteralPath (Join-Path $root 'driver-failure.log')}
    throw
} finally {
    if($observer){
        if(-not $observer.HasExited -and (Test-Path -LiteralPath (Join-Path $root 'observer'))){'stop'|Set-Content -LiteralPath (Join-Path $root 'observer/stop.txt')}
        if(-not $observer.WaitForExit(30000)){throw 'D1 observer did not join; preserve process identity'}
        $observerOut.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root 'observer-output.log')
        $observerErr.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root 'observer-error.log')
        @{pid=$observer.Id;startTicks=[string]$observer.StartTime.ToUniversalTime().Ticks;joined=$observer.HasExited;exitCode=$observer.ExitCode}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'observer-shutdown.json')
    }
    if($controller){
        if($operationActive -or $submissionUnknown){throw 'D1 acceptance/operation is unresolved; inspect retained controller/journal before shutdown'}
        if(-not $controller.HasExited){$controller.StandardInput.Close();if(-not $controller.WaitForExit(30000)){throw 'D1 controller did not join'}}
        $controllerErrors.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root 'controller.log')
        @{pid=$controller.Id;startTicks=[string]$controller.StartTime.ToUniversalTime().Ticks;joined=$controller.HasExited;exitCode=$controller.ExitCode}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'controller-shutdown.json')
    }
    if($preparation){Exit-VoxtreePerformanceHost $preparation}
    Exit-VoxtreePerformanceHost $leases
}
