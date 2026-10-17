# Simulation access optimization

Starting revision: `239dcac3d113e9c872f8211a8ac5be6641d86b01`, integration branch `main`.
Unrelated untracked `docs/articles/` is excluded.

## Prospective protocol

Objective: reduce steady-state elapsed time of checked dense/hot voxel access,
including complete water, heat and tracer simulation callers. Workloads use fixed
initial conditions, closed boundaries, integer conservative pair fluxes, double
buffering, and linear or seeded random visitation. Random visitation changes
locality but cannot change Jacobi results. Water operates over an uneven X/Z
surface; heat and tracer diffuse in three dimensions at different rates.

Preserve exact output, conservation, coordinate/channel exceptions, committed
editor rejection, serialization, and all supported target frameworks. Timed
invocations include reset plus eight steps; allocation and output parity are
guardrails. Tests have a separate flat-array reference implementation.

Candidate A03/A09/C18: avoid revalidating immutable levels/layout on each indexed
access after construction. Retain channel/lifetime/coordinate checks. Baseline
and candidate are distinct normal Release builds with identical harness source.
External paired driver: five alternating baseline/candidate process pairs,
three warmups and five timed batches per case, fixed loops, all observations
retained. These correlated observations support descriptive conclusions only.
Adopt only with exact parity, no added per-operation allocation, >=5% median
improvement on complete simulation cases overall and no >5% median regression
in any case. Freeze a separate three-pair confirmation after source selection.
Do not extend the budget or discard slow observations. Diagnostic captures are
separate from quiet timings. No inference about cache misses from CPU samples.

Other catalogue dispositions: M08/M14 covered by linear/random contrasts;
M24 bounds remain checked; M01 scratch is already reused; M04 no new copies in
steps; SIMD/parallelism/offload deferred because indirect neighbor access and
exact integer flux semantics require separate designs. No database or external
service is used by the new simulation workloads. Builds, logs and diagnostic
catalogs belong under the task directory in `D:\Workspaces\AI`.

Initial gate: baseline fixtures and independent correctness checks.

## Epoch 1: default tiering diagnostic

All 380 .NET 10 tests passed, including seven independent simulation checks.
The frozen five-pair run completed with exact mass checksums and zero timed
allocations. Small cases showed pronounced warmup/order differences (e.g.
level-3 heat linear versus tracer linear), so steady-state attribution is
inconclusive. Preserve every raw observation. No inferential claim is made.

## Epoch 2: fixed optimized JIT protocol

Before further observations, freeze `DOTNET_TieredCompilation=0` for both arms.
Repeat the original five-pair exploration budget in this new regime, then the
separate three-pair confirmation if adoption gates pass. Same builds, workloads,
budgets, metrics, and thresholds; filenames contain `fullopts`. This controls
tier transitions but excludes dynamic-PGO behavior from the resulting claim.
Host mutex: `Global\DotNetLab.Performance`; other applications do not honor it.
Background OS load, thermal/frequency state and affinity are uncontrolled.
Epoch-2 gate: fixed optimized-JIT exploration.

Epoch-2 exploration completed all five pairs: every case improved (21.7–37.9%
median reduction), all timed allocation deltas were zero, and all checksums
matched. Select the checked-index candidate without further source changes.
Freeze confirmation now: three alternating fresh process pairs, same fullopts
regime, builds, warmups, iterations, cases and thresholds. Confirmation is an
external normal-build comparison because the treatment changes a library
dependency; it is not DotNetLab's entry-assembly promotion lane.

## Results and disposition

Retain A03/A09/C18: constructed dense views and hot editors call a shared checked
index helper without revalidating depth/layout. Coordinate validation combines
the three power-of-two bounds checks with OR. Both generic and uint surfaces
retain lifetime/channel/coordinate exception precedence. No unsafe access,
public API, storage format, or numerical contract changes.

Confirmation medians below measure **reset + eight complete steps + checksum**,
in microseconds per invocation. Each cell contains 15 batch observations from
three fresh process pairs. Small cases use 16 invocations per batch; large cases
use two. All observations, including epoch 1, remain in [evidence](evidence/).

| Levels | Workload | Access | Baseline us | Candidate us | Reduction |
| --- | --- | --- | ---: | ---: | ---: |
| 3 | Heat | Linear | 242.93 | 184.89 | 23.9% |
| 3 | Heat | Random | 240.29 | 184.36 | 23.3% |
| 3 | Tracer | Linear | 240.70 | 184.58 | 23.3% |
| 3 | Tracer | Random | 240.03 | 184.32 | 23.2% |
| 3 | Water | Linear | 48.08 | 30.08 | 37.4% |
| 3 | Water | Random | 48.14 | 30.14 | 37.4% |
| 5 | Heat | Linear | 16628.55 | 12914.80 | 22.3% |
| 5 | Heat | Random | 17081.50 | 13311.30 | 22.1% |
| 5 | Tracer | Linear | 16677.30 | 12969.60 | 22.2% |
| 5 | Tracer | Random | 17008.35 | 13347.60 | 21.5% |
| 5 | Water | Linear | 849.55 | 534.95 | 37.0% |
| 5 | Water | Random | 886.35 | 562.20 | 36.6% |

Every case passes the prospective threshold; timed allocations are zero and mass
checksums match. Independent edge-scatter tests compare every cell after each
of 24 steps at levels 2, 3, and 5 against the gather implementation, check
linear/random equivalence, conservation, spreading, symmetry, bounds and reset.
Final complete test suites pass: .NET 8 **382**, .NET 10 **383**, .NET 11 **384**.
The .NET 8 consumer exercises the actual netstandard2.1 library. Test counters,
timing distributions, process/runtime identities, build and source hashes are
retained under `evidence/`; `Summarize.py` verifies the full timing budget.

Actual optimized `SimulationWorkload.Flux` disassembly shows two ValidateLevels
calls and a GetIndex call in the baseline, all absent in the candidate. Code
size is 1014 versus 977 bytes, with frame reservations of 120 versus 88 bytes.
These are code-shape observations, not hardware-counter measurements.
Retained disassembly has trailing whitespace normalized for repository storage.

## DotNetLab evidence

Controller: installed `0b76d30`, pinned .NET 10.0.12, supported compatibility
report. Target: .NET 10.0.13 x64, PID 117944, start ticks
`639278245015198507`, epoch `0`, target ID
`target-b05536ee4c59e26df6fe50f8`. Workload process header independently binds
runtime and start time. The task-owned catalog uses only its fixed local SQLite
file; startup and catalog source were inspected before execution.

Three-second `cpu-diagnostic` capture:
`op-4367a181cdec44f7b36cfb076f12ab6d` →
`cap-b9b77b0970fa481fb09a3478eeed8dc4` (sealed).
Stack analysis `op-53900a1a36794232b7c10893395f6210` →
`stack-analysis-c7ca5d467cf74eb2bfbffa4ed1340260` (completed).
The parsed report contains 3068 samples and 40 resolved methods; symbol coverage
is 1.0, loss status is unknown, and quality is explicitly **partial**.
Step has 1173 self samples and Flux has 265; 1527 samples are in a counter-thread
wait. These are shares of all sampled stacks, including waiting threads, not
CPU-time shares, method invocation counts, or per-call durations. The complete
parsed hotspot table and record hashes are retained. The raw trace and temporary
catalog are disposable diagnostic artifacts and are not retained for reanalysis.

No cooperative harness or native profiler endpoint was installed in this target.
The bounded application-owned loop was profiled without native mutation. Quiet
external timings remain separate from this EventPipe observer regime. The local
prospective hypothesis was subsequently mirrored into a DotNetLab record; its
returned identity is retained in `evidence/hypothesis.json`.

## Scope and reproducibility

Performance evidence covers uint hot Morton storage visited in linear and
random coordinate order. Generic and dense-view changes share the same helper
and pass correctness tests; their speedup is not independently established.
`DenseSimulationAccess` provides separate Linear/Morton storage microbenchmarks.
No performance claim extends to other CPUs/runtimes, dynamic PGO, cold startup,
multi-chunk worlds, serialization, or parallel simulations. Thermal/load and
cross-process dependence remain limitations; all percentages are descriptive.
Measured host: AMD Ryzen 9 5950X, 32 logical processors, Windows build 26200;
SDK 11.0.100-rc.2.26504.105, target runtime 10.0.13, ordinary managed Release
builds (no publish/AOT/R2R step). No affinity, priority or frequency pinning.
Runtime configuration and library dependency hashes match between arms except
the changed library and rebuilt benchmark entry assembly. Their harness source
is identical; source hashes bind the final fixture as `simulation-kernel/v1`.
The library treatment changes a dependency, so no DotNetLab normal-build
promotion eligibility is claimed. Native grants/ReJIT are unnecessary here.

Build and run the reusable loop (seconds argument 0–600):

```powershell
$taskRoot = 'D:\Workspaces\AI\voxtree-simulation-run'
New-Item -ItemType Directory -Path $taskRoot -Force | Out-Null
dotnet build src/Tedd.Voxtree.Benchmark -c Release -f net10.0 --artifacts-path $taskRoot
dotnet exec --fx-version 10.0.13 "$taskRoot/bin/Tedd.Voxtree.Benchmark/release_net10.0/Tedd.Voxtree.Benchmark.dll" --simulation-loop 60
```

BenchmarkDotNet selection: `--filter '*Simulation*'` instead of
`--simulation-loop`. `Measure.ps1` compares previously built `baseline` and
`candidate` bundles under a task workspace; `AnalyzeCapture.py` analyzes a
previously sealed capture through one owned controller and retains exact MCP
payloads/operation IDs. Raw target traces are not needed by the timing summary.

Final disposition: retain the validated candidate on `main`; clean the owned
task workspace after committing the source and durable evidence.
