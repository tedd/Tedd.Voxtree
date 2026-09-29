param(
    [Parameter(Mandatory = $true)]
    [string] $Executable,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Arguments
)

$lockPath = 'D:\Temp\BenchmarkLock.txt'
$stream = $null
try {
    $stream = [System.IO.File]::Open(
        $lockPath,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::Read)
    $metadata = [ordered]@{
        owner = 'Codex deferred-capacity investigation'
        pid = $PID
        worktree = (Get-Location).Path
        command = $Executable
        arguments = $Arguments
        acquiredUtc = [DateTime]::UtcNow.ToString('O')
    } | ConvertTo-Json -Depth 3
    $writer = [System.IO.StreamWriter]::new($stream, [System.Text.UTF8Encoding]::new($false), 1024, $true)
    $writer.Write($metadata)
    $writer.Flush()
    $writer.Dispose()
    & $Executable @Arguments
    exit $LASTEXITCODE
}
catch [System.IO.IOException] {
    Write-Error "Benchmark lease is held at $lockPath. No timed command was started."
    exit 73
}
finally {
    if ($null -ne $stream) {
        $stream.Dispose()
        Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue
    }
}
