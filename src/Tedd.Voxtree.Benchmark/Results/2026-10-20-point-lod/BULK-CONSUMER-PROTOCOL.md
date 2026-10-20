# P18 complete-operation guard screen

No implementation change. Compare complete P18 primary source against f0772c8
in Snapshot. This is an exploratory semantic/cost screen, separate from the
eight-read fresh confirmation and its fixed sixteen-objective family.

Freeze all 88 cases before results: UInt16 and legacy UInt32, all four existing
hash-verified terrain samples, and eleven operations: owned construction,
owned Build, caller-buffer Build, TryBuild, GetRequiredSize, FromEncoded, CopyTo,
IsWellFormed, zero CountMatches, 65535 CountMatches (miss in these samples),
and owned construction plus 65,536 sequential public Get-with-LOD reads.
Construction/owned Build/FromEncoded include one first-voxel Get to consume the
result. Caller builds consume used length and validate all used bytes outside
timing; sizes may differ by representation. Copies consume element 2047 and
validate the entire destination. Full value/LOD/structure oracles run outside
timing. Build/read includes original encoding, not merely CreateLookup over
prebuilt data. Caller buffers and copy destinations are preallocated; owned
construction and FromEncoded include their allocations. No allocation pass is
inferred from latency.

Fixture version 13. One logical operation is the complete described operation.
Ordinary tiering/PGO, .NET 10.0.13 x64, affinity 4, three-second per-arm primes.
Twelve paired same-process blocks, four warmups, seed 20261022, quiet profile,
120 seconds maximum per plan. Per batch: sixteen construction/build/size/
FromEncoded operations; 64 copy/validation/count operations; two complete
build/read operations. Family size 88, existing 5% time policy, no exclusions,
replacement failures, added samples or favorable case selection. Same-process
blocks remain non-independent and JIT history can accumulate across cases.
Keep effects and raw allocations descriptive; no source adoption from this
screen. Preserve all adverse results and failures; do not resume tainted targets.

Use the inspected shared-lock driver. Wait for the active fresh-confirmation
pipeline to release its outer lease before building/testing/timing. External
prerequisites acquire the central mutex; DotNetLab controls timed admission.

## Selected-binary diagnostic continuation

Observed dominant CountMatches estimates are adverse for both widths. After
the frozen family ends, run two separate CPU-diagnostic cases on the exact
p18bulk bundle, with the same bounded-consumer counts and correctness gates.
Retain both captures, analyses, self/inclusive rankings and selected JIT listings
for CountMatches/CountDense/ReadDenseValue/ReadWord/AfterBatch. Timing under this
observer is diagnostic and is not pooled with quiet cases. Three-second primes
and untimed semantic checks contribute CPU samples; samples do not establish
per-call latency, complete-operation fractions, cache misses or PMU causes.
Also retain UInt16/UInt32 owned-LOD caller listings from both exact normal
builds. These isolated diagnostics do not prove the timed JIT bodies after a
different scenario history. No new implementation or repeated decision samples.

The first selector covers CountMatches callers but omits VisitPacked. Retain
that original capture and add a native-only body probe on the identical p18bulk
DLL: both widths, both variants, existing three-second Prepare primes, 64
complete calls followed by semantic validation. Select VisitPacked/Execute/
TryGet/Matches and bind wrapper/bundle hashes, PID/start and exit. No latency
comparison or additional decision observations are exported from this probe.

That first body selector named VisitPacked/Execute; source inspection establishes
the actual methods are Packed/RunCore. Preserve the first native-only probe and
collect a separately labeled body2 probe with Packed/RunCore/Accept/TryGet.
The executable scenario, useful work, semantic checks and selected bulk DLL are
unchanged. This corrects diagnostic coverage, not a performance sampling budget.
