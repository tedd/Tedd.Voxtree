function Enter-VoxtreePerformanceHost {
    param([switch]$ControllerAdmission, [switch]$MeasurementOnly)
    if ($ControllerAdmission -and $MeasurementOnly) { throw 'Admission modes are mutually exclusive.' }
    # Controllers acquire the measurement mutex on their own dedicated thread.
    # Holding it here while awaiting a controller operation would deadlock.
    $leases = [Collections.Generic.List[Threading.Mutex]]::new()
    try {
        $names = if ($MeasurementOnly) { @() } else { @('Global\Tedd.RTree.PerformanceHost','Global\Tedd.Voxtree.Performance.v1') }
        if (-not $ControllerAdmission) { $names += 'Global\Tedd.DotNetLab.Measurement.v1' }
        foreach ($name in $names) {
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
function Invoke-VoxtreeExternalPhase([scriptblock]$Body) {
    $externalLeases = Enter-VoxtreePerformanceHost
    try { & $Body } finally { Exit-VoxtreePerformanceHost $externalLeases }
}
function Exit-VoxtreePerformanceHost($Leases) {
    for ($index=$Leases.Count-1; $index -ge 0; $index--) {
        $Leases[$index].ReleaseMutex(); $Leases[$index].Dispose()
    }
}
