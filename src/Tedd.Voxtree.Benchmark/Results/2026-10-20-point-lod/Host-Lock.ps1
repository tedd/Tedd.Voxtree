function Enter-VoxtreePerformanceHost {
    $leases = [Collections.Generic.List[Threading.Mutex]]::new()
    try {
        foreach ($name in @('Global\Tedd.RTree.PerformanceHost','Global\Tedd.Voxtree.Performance.v1')) {
            $gate = [Threading.Mutex]::new($false,$name)
            $waited = 0
            $held = $false
            while (-not $held) {
                try { $held = $gate.WaitOne(1000) }
                catch [Threading.AbandonedMutexException] {
                    $gate.ReleaseMutex(); $gate.Dispose()
                    throw 'Shared host lock was abandoned; verify prior worker quiescence before measuring.'
                }
                if ($held) { break }
                $waited++
                if ($waited % 30 -eq 0) { Write-Host "Waiting for shared performance host: $name" }
            }
            $leases.Add($gate)
        }
        return ,$leases
    } catch {
        foreach ($lease in $leases) { $lease.ReleaseMutex(); $lease.Dispose() }
        throw
    }
}
function Exit-VoxtreePerformanceHost($Leases) {
    for ($index=$Leases.Count-1; $index -ge 0; $index--) {
        $Leases[$index].ReleaseMutex(); $Leases[$index].Dispose()
    }
}
