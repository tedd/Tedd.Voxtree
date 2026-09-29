param(
    [Parameter(Mandatory = $true)]
    [string] $BaselineWorktree,

    [Parameter(Mandatory = $true)]
    [string] $CandidateWorktree
)

$ErrorActionPreference = 'Stop'
$baselineRevision = 'f9d9b366ede89050800bc97df9fca2a086ab1ce2'
$candidateProductRevision = '4006838'
$fixture = 'src/Tedd.Voxtree.Benchmark/Tests/DeferredCapacityBenchmarks.cs'
$research = 'Research/2026-09-29 deferred sparse edit capacity and storage-1'
$lockRunner = Join-Path $CandidateWorktree "$research/run-exclusive-benchmark.ps1"

if ((& git -C $BaselineWorktree rev-parse HEAD) -ne $baselineRevision) {
    throw "Baseline worktree must be at $baselineRevision."
}

& git -C $BaselineWorktree diff --quiet $baselineRevision -- src
if ($LASTEXITCODE -ne 0) {
    throw "Baseline tracked product files differ from $baselineRevision."
}

$baselineUntracked = @(& git -C $BaselineWorktree ls-files --others --exclude-standard -- src)
if ($baselineUntracked.Count -ne 1 -or $baselineUntracked[0] -ne $fixture) {
    throw "Baseline src/ may contain only the source-matched benchmark fixture override: $fixture"
}

& git -C $CandidateWorktree diff --quiet $candidateProductRevision -- src
if ($LASTEXITCODE -ne 0) {
    throw "Candidate product files differ from $candidateProductRevision."
}

$candidateUntracked = @(& git -C $CandidateWorktree ls-files --others --exclude-standard -- src)
if ($candidateUntracked.Count -ne 0) {
    throw "Candidate src/ contains untracked files and is not source-exact."
}

$baselineFixture = & git -C $BaselineWorktree hash-object (Join-Path $BaselineWorktree $fixture)
$candidateFixture = & git -C $CandidateWorktree hash-object (Join-Path $CandidateWorktree $fixture)
if ($baselineFixture -ne $candidateFixture) {
    throw 'Baseline and candidate benchmark fixtures differ.'
}

$lowFilter = '*DeferredCapacityBenchmarks.DeferredEditSession*C256-W20-1of2*'
$overflowFilters = @(
    '*DeferredCapacityBenchmarks.Deferred*C20-W21-1of8*',
    '*DeferredCapacityBenchmarks.Deferred*C256-W257-1of8*',
    '*DeferredCapacityBenchmarks.Deferred*C256-W257-8of8*'
)

foreach ($tree in @($BaselineWorktree, $CandidateWorktree)) {
    Push-Location $tree
    try {
        $label = if ($tree -eq $BaselineWorktree) { 'baseline' } else { 'candidate' }
        $lowArguments = @(
            'run', '--project', '.\src\Tedd.Voxtree.Benchmark\Tedd.Voxtree.Benchmark.csproj',
            '-c', 'Release', '-f', 'net10.0', '--', '--filter', $lowFilter,
            '--job', 'medium', '--artifacts', ".\.artifacts\deferred-capacity\$label-low"
        )
        & $lockRunner -Executable dotnet -Arguments $lowArguments
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

        $overflowArguments = @(
            'run', '--project', '.\src\Tedd.Voxtree.Benchmark\Tedd.Voxtree.Benchmark.csproj',
            '-c', 'Release', '-f', 'net10.0', '--', '--filter'
        ) + $overflowFilters + @(
            '--job', 'short', '--artifacts', ".\.artifacts\deferred-capacity\$label-overflow"
        )
        & $lockRunner -Executable dotnet -Arguments $overflowArguments
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    finally {
        Pop-Location
    }
}
