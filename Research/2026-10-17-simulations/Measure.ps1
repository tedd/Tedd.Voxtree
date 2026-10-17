param(
    [Parameter(Mandatory)][string]$Workspace,
    [ValidateSet('exploration', 'confirmation')][string]$Phase = 'exploration'
)
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath($Workspace)
if (-not $root.StartsWith('D:\Workspaces\AI\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Use a designated AI task workspace.'
}
$mutex = [Threading.Mutex]::new($false, 'Global\DotNetLab.Performance')
if (-not $mutex.WaitOne(0)) { throw 'Performance host lock is occupied.' }
try {
    $env:TEMP = $root
    $env:TMP = $root
    # Fixed optimized JIT avoids cross-case tier transitions in the short runner.
    $env:DOTNET_TieredCompilation = '0'
    $pairs = if ($Phase -eq 'exploration') { 5 } else { 3 }
    for ($pair = 0; $pair -lt $pairs; $pair++) {
        $arms = if ($pair % 2 -eq 0) { @('baseline','candidate') } else { @('candidate','baseline') }
        foreach ($arm in $arms) {
            $dll = Join-Path $root "$arm\bin\Tedd.Voxtree.Benchmark\release_net10.0\Tedd.Voxtree.Benchmark.dll"
            $output = Join-Path $root "$Phase-fullopts-$pair-$arm.jsonl"
            if (Test-Path -LiteralPath $output) { throw "Refusing to overwrite $output" }
            & dotnet exec --fx-version 10.0.13 $dll --simulation-loop 0 | Set-Content -LiteralPath $output
            if ($LASTEXITCODE -ne 0) { throw "Arm failed: $arm, pair $pair" }
            Write-Output "$Phase pair $pair $arm complete"
        }
    }
}
finally {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}
