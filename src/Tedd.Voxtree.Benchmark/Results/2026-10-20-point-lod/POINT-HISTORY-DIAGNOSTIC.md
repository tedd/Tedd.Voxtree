# H2: operation-history code diagnostic after P32

Prepared before diagnostic source/captures. Require terminal rejected original
P32 stage, unchanged hash-bound paired p32point bundle and full source/native
prerequisites. Production stays f0772c8; no P31/P32 source is promoted.
Registry R03/C18/C09: dynamic PGO, inlining and caller layout depend on training.

P32 removes emitted slice checks in isolated LOD-first captures but misses its
required quiet benefit, including UInt32 owned LOD0.673 versus P31. The quiet
family shares Before/AfterBatchOwned/Span methods across scenario instances and
executes Get before LOD. Existing native probes select one endpoint in a fresh
process. Test this competing code-shape explanation before another point edit.

One unchanged paired bundle, two fresh diagnostic processes: Get-first replays
the exact first eight original P32 scenarios and recorded within-scenario arm
order; LOD-first removes only the preceding Get cases, retaining the four LOD
cases and their recorded arm order. Read schedule from the completed frozen
plans/run records, not new random draws. Both arms keep their original Prepare,
Reset, two warmups, reset-after-warmup,2,097,152 operations, validation and Cleanup
for each of four paired blocks. Original three-second per-scenario/arm primes
remain. No stopwatch/latency/allocation capture or performance comparison is
introduced. A180-second per-process diagnostic timeout is a failure, not a
replacement observation.

Instantiate the original48 scenario objects in their original registration
order, using the same literal/interned pattern/access/op strings; select by
manifest scenario ID. Do not pass deserialized non-interned op strings into
scenario constructors, because reference-string fast paths affect training.
No fixture, caller, library, warmup count, tiering/PGO switch or CPU-affinity
change. .NET10.0.13 x64, affinity4, repository-pinned SDK. Hold shared host mutexes
across builds and both processes; native observers are isolated from quiet runs.

Capture actual Before/AfterBatchOwned/Span optimized methods for both widths.
Preserve every tier/OSR listing, native sizes/fixed frames, source/schedule/
bundle/process/runtime hashes, checks and joined exits. Index only complete
listings; incomplete/ambiguous methods cannot prove boundaries or frame sizes.

Prediction H2-boundary: candidate Get-first LOD paths retain calls on the valid
R route that are absent in LOD-first, with a differential from the P31 control.
Map the emitted "lod" dispatcher and valid R branch, not the entire method's
call list. If both histories retain equivalent call boundaries, reject that
specific explanation; examine dataflow/quiet tier evidence before selecting
another intervention. If both arms change alike, history dependence alone does
not explain their time ratio. Other code differences are reported as exploratory.

This is a diagnostic cut, not a quiet rerun or source speedup. History matching
does not establish exact quiet machine-code identity, deterministic compilation
order, dynamic branch frequency, PMU behavior, a causal time fraction or
adoption. The original P32 rejection and all adverse observations remain.
