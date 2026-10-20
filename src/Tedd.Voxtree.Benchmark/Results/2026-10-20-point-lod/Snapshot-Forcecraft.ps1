param([Parameter(Mandatory)][string]$TaskRoot)
$ErrorActionPreference='Stop'
$expected='D:\Workspaces\AI\voxtree-point-lod-20261020'
if([IO.Path]::GetFullPath($TaskRoot).TrimEnd('\') -ne $expected){throw 'Unexpected task root'}
$source='D:\SourceCode\Tedd.Forcecraft10\data\Worlds'
$destination=Join-Path $TaskRoot 'forcecraft-snapshot-s1'
if(Test-Path -LiteralPath $destination){throw 'Snapshot already exists; inspect previous operation before recovery'}
New-Item -ItemType Directory -Path $destination | Out-Null
. (Join-Path $PSScriptRoot 'Host-Lock.ps1')
$leases=Enter-VoxtreePerformanceHost
try {
    $manifest=foreach($file in (Get-ChildItem -LiteralPath $source -Filter '*.region' -Recurse | Sort-Object FullName)) {
        $relative=[IO.Path]::GetRelativePath($source,$file.FullName)
        $copy=Join-Path $destination $relative
        New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($copy)) -Force | Out-Null
        $reader=[IO.File]::Open($file.FullName,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::ReadWrite)
        try {
            $before=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($reader))
            $reader.Position=0
            $writer=[IO.File]::Open($copy,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
            try {$reader.CopyTo($writer)} finally {$writer.Dispose()}
            $reader.Position=0
            $after=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($reader))
            $copied=(Get-FileHash -LiteralPath $copy -Algorithm SHA256).Hash
            if($before -ne $after -or $before -ne $copied){throw "Source changed during snapshot: $relative"}
            [pscustomobject]@{region=$relative;bytes=$reader.Length;sha256=$copied;sourceBefore=$before;sourceAfter=$after}
        } finally {$reader.Dispose()}
    }
    $manifest | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $TaskRoot 'forcecraft-snapshot-s1.json')
    & (Join-Path $PSScriptRoot 'Scan-Forcecraft.ps1') -TaskRoot $TaskRoot -WorldDirectory $destination -Epoch s1
} finally {Exit-VoxtreePerformanceHost $leases}
