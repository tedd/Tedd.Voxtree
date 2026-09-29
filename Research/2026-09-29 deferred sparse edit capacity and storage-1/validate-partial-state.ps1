$ErrorActionPreference = 'Stop'
& dotnet test '.\src\Tedd.Voxtree.sln' -c Release --nologo
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& dotnet run --project '.\src\Tedd.Voxtree.Benchmark\Tedd.Voxtree.Benchmark.csproj' -c Release -f net10.0 -- --filter '*DeferredCapacityBenchmarks.DeferredEditSession*C20-W20-1of2*' '*DeferredCapacityBenchmarks.DeferredEditSession*C32-W20-1of2*' '*DeferredCapacityBenchmarks.DeferredEditSession*C64-W20-1of2*' '*DeferredCapacityBenchmarks.DeferredEditSession*C256-W20-1of2*' --job short --artifacts '.\Research\2026-09-29 deferred sparse edit capacity and storage-1\raw\partial-state-hotpath'
exit $LASTEXITCODE
