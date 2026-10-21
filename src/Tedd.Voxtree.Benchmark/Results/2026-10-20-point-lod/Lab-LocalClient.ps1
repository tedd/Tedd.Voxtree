# Task-local supported CLI/MCP client; caller supplies its owned controller/catalog.
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
