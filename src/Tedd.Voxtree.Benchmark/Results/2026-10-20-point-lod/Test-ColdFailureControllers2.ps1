param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne 'D:\Workspaces\AI\voxtree-point-lod-20261020'){throw 'Unexpected task root'}
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
. (Join-Path $PSScriptRoot 'Lab-LocalClient.ps1')
$leases=Enter-VoxtreePerformanceHost -ControllerAdmission -DriverPath $PSCommandPath
$dotnet=(Get-Command dotnet).Source
$inputs=Get-Content -LiteralPath (Join-Path $TaskRoot 'p18-failure-diagnostic-1/inputs.json') -Raw|ConvertFrom-Json -Depth 40
$all=@()
try {
    foreach($variant in @('base','logged')){
        $preparation=$null;$controller=$null;$operationActive=$false;$submissionUnknown=$false;$script:sequence=0
        $root=Join-Path $TaskRoot "coldlog-$variant-proof2"
        $labHost=Join-Path $TaskRoot "coldlog-controller-source/${variant}2-out/Tedd.DotNetLab.Host.dll"
        $results=@()
        try {
            $preparation=Enter-VoxtreePerformanceHost
            if(Test-Path -LiteralPath $root){throw 'L1 arm workspace exists; inspect before recovery'}
            foreach($bundle in $inputs.bundles){foreach($file in $bundle.files){if((Get-FileHash -LiteralPath $file.path).Hash -ne $file.sha256){throw 'Archived target bundle changed'}}}
            if(-not (Test-Path -LiteralPath $labHost)){throw 'L1 matched controller build missing'}
            New-Item -ItemType Directory -Path $root|Out-Null
            $env:TEMP=Join-Path $TaskRoot 'temp';$env:TMP=$env:TEMP
            Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'COLD-FAILURE-LOG-PROTOCOL.md') -Destination (Join-Path $root 'protocol.md')
            Copy-Item -LiteralPath (Join-Path $TaskRoot 'p18-failure-diagnostic-1/source.diff') -Destination (Join-Path $root 'target-source.diff')
            $inputs|ConvertTo-Json -Depth 50|Set-Content -LiteralPath (Join-Path $root 'target-inputs.json')
            & $dotnet exec --fx-version 10.0.13 $labHost init $root|Out-Null
            if($LASTEXITCODE -ne 0){throw 'L1 catalog initialization failed'}
            @{purpose='L1 functional proof only';protocolMarkdown=(Get-Content -LiteralPath (Join-Path $root 'protocol.md') -Raw)}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'protocol.json')
            $evidence=Import-File (Join-Path $root 'protocol.json') application/json
            $hyp=Invoke-Lab lab.experiment @{action='create_hypothesis';mechanism='L1: bounded detail logging only in the existing confirmation failure catch preserves success behavior and original failure codes while making future failures attributable.';prediction='Both producer arms reject the controlled bad hash with invalid_plan and no returned measurements, then complete 24 valid sessions. Only the changed producer emits one identity-bound, untruncated exception detail for the rejected operation. No timings are compared.';evidence_ids=@($evidence.id)}
            $hyp|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'hypothesis.json')
            $builds=@()
            foreach($bundle in $inputs.bundles){
                $files=@(foreach($file in $bundle.files){$artifact=Import-File $file.path $(if($file.name.EndsWith('.dll')){'application/vnd.microsoft.portable-executable'}else{'application/json'});@{name=$file.name;artifact_id=$artifact.id}})
                $builds+=Invoke-Lab lab.experiment @{action='register_normal_build';entry_assembly=$bundle.entry;files=$files}
            }
            $patch=Import-File (Join-Path $root 'target-source.diff') text/x-diff
            $candidate=Invoke-Lab lab.experiment @{action='create_candidate';name="L1 $variant functional target";build_identity=$builds[1].content_hash;components=@()}
            $selected=@()
            foreach($label in @('invalid','valid')){
                $prior=@(Get-Content -LiteralPath (Join-Path $TaskRoot 'p18-failure-diagnostic-1/experiments.json') -Raw|ConvertFrom-Json -AsHashtable -Depth 70)[0]
                $experiment=$prior.experiment;$experiment.seed='20261025';$experiment.id='prospective-L1-'+$label
                $experiment.independence_justification='Functional controller proof only; API-required design flags do not permit performance/promotion inference.'
                if($label -eq 'invalid'){$experiment.input_hash='0'*64}
                $plan=Invoke-Lab lab.experiment @{action='create_confirmation_plan';selected_candidate_id=$candidate.id;source_patch_artifact_id=$patch.id;
                    source_equivalence_rationale='L1 functional proof only, never performance/promotion evidence. Exact archived target bundles and source patch. Invalid hash deliberately tests rejection before execution; valid hash tests 24 complete sessions. Controllers differ only in failure-only stderr logging; no observer is attached.';
                    baseline_build_id=$builds[0].id;candidate_build_id=$builds[1].id;baseline_variant='baseline';candidate_variant='candidate';experiment=$experiment;exploratory_evidence_ids=@($hyp.id)}
                $selected+=@{label=$label;plan=$plan}
            }
            $selected|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root 'plans.json')
            $grants=@{}
            foreach($item in $selected){$raw=& $dotnet exec --fx-version 10.0.13 $labHost grant-confirmation $root $item.plan.id 3600 24;if($LASTEXITCODE -ne 0){throw 'L1 grant failed'};$grants[$item.plan.id]=$raw|ConvertFrom-Json}
            $grants|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root 'grants.json')
            $start=[Diagnostics.ProcessStartInfo]::new($dotnet)
            foreach($arg in @('exec','--fx-version','10.0.13',$labHost,'serve',$root)){$start.ArgumentList.Add($arg)}
            $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardInput=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true;$start.WorkingDirectory=$root
            $controller=[Diagnostics.Process]::Start($start);$errors=$controller.StandardError.ReadToEndAsync()
            @{pid=$controller.Id;startTicks=[string]$controller.StartTime.ToUniversalTime().Ticks;variant=$variant;entry=$labHost;entrySha256=(Get-FileHash -LiteralPath $labHost).Hash;runtime='10.0.13';regime='Functional proof only; no performance comparison'}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'controller.json')
            Invoke-Rpc initialize @{protocolVersion='2025-03-26';capabilities=@{};clientInfo=@{name='voxtree-coldlog-proof';version='1'}}|Out-Null
            $controller.StandardInput.WriteLine('{"jsonrpc":"2.0","method":"notifications/initialized"}')
            Exit-VoxtreePerformanceHost $preparation;$preparation=$null
            foreach($item in $selected){
                $request=@{action='start_confirmation';plan_id=$item.plan.id;grant_id=$grants[$item.plan.id].id;idempotency_key="L1-$variant-$($item.label)"}
                $request|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root ($item.label+'-request.json'))
                $submissionUnknown=$true;$op=Invoke-Lab lab.run $request;$submissionUnknown=$false;$operationActive=$true
                $op|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root ($item.label+'-operation.json'))
                while($op.state -notin 'completed','failed','tainted','cancelled','interrupted','lost'){Start-Sleep -Milliseconds 200;$op=Invoke-Lab lab.run @{action='status';operation_id=$op.id}}
                $operationActive=$false;$op|ConvertTo-Json -Depth 30|Set-Content -LiteralPath (Join-Path $root ($item.label+'-terminal.json'))
                $record=Invoke-Lab lab.inspect @{action='record';id=$op.result_id}
                $record|ConvertTo-Json -Depth 70|Set-Content -LiteralPath (Join-Path $root ($item.label+'-execution.json'))
                $execution=$record.json|ConvertFrom-Json -Depth 50;$sessions=@()
                foreach($id in $execution.session_ids){$sessions+=Invoke-Lab lab.inspect @{action='record';id=$id}}
                ConvertTo-Json -InputObject $sessions -Depth 80|Set-Content -LiteralPath (Join-Path $root ($item.label+'-sessions.json'))
                if($item.label -eq 'invalid'){
                    if($op.state -ne 'failed' -or $op.error_code -ne 'invalid_plan' -or $sessions.Count -ne 0){throw 'L1 controlled invalid-input outcome differs'}
                }elseif($op.state -ne 'completed' -or $sessions.Count -ne 24){throw 'L1 valid confirmation did not complete'}
                $results+=@{label=$item.label;operationId=$op.id;state=$op.state;errorCode=$op.error_code;sessions=$sessions.Count;functionalOnly=$true}
                ConvertTo-Json -InputObject $results -Depth 30|Set-Content -LiteralPath (Join-Path $root 'outcomes.json')
                Write-Output ("L1 $variant $($item.label) $($op.state) sessions=$($sessions.Count)")
            }
        } finally {
            if($controller){
                if($operationActive -or $submissionUnknown){throw 'L1 operation unresolved; inspect retained journal before shutdown'}
                if(-not $controller.HasExited){$controller.StandardInput.Close();if(-not $controller.WaitForExit(30000)){throw 'L1 controller did not join'}}
                $errors.GetAwaiter().GetResult()|Set-Content -LiteralPath (Join-Path $root 'controller.log')
                @{pid=$controller.Id;joined=$controller.HasExited;exitCode=$controller.ExitCode}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $root 'controller-shutdown.json')
                $controller=$null
            }
            if($preparation){Exit-VoxtreePerformanceHost $preparation}
        }
        $all+=@{variant=$variant;outcomes=$results}
    }
    ConvertTo-Json -InputObject $all -Depth 40|Set-Content -LiteralPath (Join-Path $TaskRoot 'coldlog-functional-outcomes2.json')
} finally {Exit-VoxtreePerformanceHost $leases}
