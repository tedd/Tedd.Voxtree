# P29: value-returning palette reads

Starting integration branch main, commit 1ef37b8; unrelated docs/articles is
excluded. Production remains f0772c8. Previous turn: progress, with P27's complete
136-case disposition, immutable evidence and a verified preimplementation rejection
of P28. The full public-method 10x objective remains unchanged.

Selected source parent: complete P27 byte-palette-source. RTree's retained work
distinguishes actual library interventions from faster consumers and requires
complete emitted callers. P29 retains the exact point fixture/checksum. The
P27 owned UInt32 value-only diagnostic already inlines the reader, but its
IG09..IG11 stores and reloads temporary value/LOD outputs and propagates a
success flag. These observations motivate a falsifying intervention; they do
not measure a time fraction, PMU event or exact quiet PGO body. P28's rejected
call-boundary premise is not reused.

Registry C18/A11: specialize throwing Get paths for palette storage, returning
the loaded state/value directly instead of routing it through boolean/out-value
interfaces. Packed storage is tested before the existing general fallback;
that dispatch order is part of this intervention. The state reader returns an
all-one invalid sentinel after the same checked index/table accesses. Every
legal state has LOD <= depth, so the sentinel cannot consume valid raw value
bits. Throwing value-only Get need not materialize a discarded LOD output.
Boolean TryGet, encoders, wire bytes, fields, ownership, validation, copy,
queries and compiled lookup retain their exact P27 implementation.

Prediction: all four dominant UInt32 owned/span Get/value-with-LOD callers
improve by at least 10% over complete P27. All other 44 point/compiled/create/
lifecycle cases retain candidate/control cost <= 1.05. Report all allocation
observations and adverse cases. No independent source contribution is attributed
to dispatch order versus output representation in this combined direct path.
P29 is one complete throwing-palette-path intervention, not an isolated claim
that a specific store or instruction causes its entire measured effect.

Invariants: identical coordinate/initialization order; one owned volatile array
snapshot; same exception types/messages, out-LOD zero on built failure and caller
out state on unbuilt failure; full UInt16/UInt32 bits and natural stored LOD;
range-checked captured byte index before a table read; high unsigned invalid LOD
and all-one words rejected; unsupported widths and legacy formats use the old
fallback; no borrowed-buffer overread. No unsafe pointer read or heap cache.

Before timing: register hypothesis, generate a distinct source with a complete
hash manifest; match actual paired snapshots. Run all original/palette/owned
contract tests on .NET8/10/11 plus .NET10 intrinsics-off, adding explicit legal
maximum raw-value states and all-one/high-LOD malformed throwing reads. Run all
48 version15 point oracles and 88 complete-operation oracles. A separate release-
control corpus bundle checks all 1,286 chunks/42,139,648 cells, exact P27 wire
bytes and independent value/LOD/copy/query behavior. No world/app startup/write.

Collect matched selected-bundle native-only owned/span Get/LOD diagnostics for
UInt32, including control and treatment callers, before quiet timing. Inspect
the executed palette branch, retaining tiers/OSR and fixed frame reservations.
The code gate requires a matched final optimized valid-palette branch to remove
at least one temporary value store/reload, discarded-LOD store or boolean-success
propagation present in the control. If none changes, stop and revise the
hypothesis without spending its timing budget. Do not substitute the whole
method's call list for a hot-branch review.

Fixed exploratory screen: unchanged Scenarios-byte-palette.cs.txt version15,
all48 cases, 12 same-process paired blocks, four warmups, seed20261101, family48
time comparisons, bounded-lifecycle counts (256 create,16 lifecycle with65536
reads each,33554432 compiled/uniform reads,2097152 other reads). .NET10.0.13 x64,
ordinary tiering/PGO, affinity4, three-second primes, quiet-validation,120s/case.
Freeze all plans before the first observation. Full budget, no source changes,
extra favorable samples, replacements, resumed old families or pooled old data.
Stop a failed/tainted operation and inspect its original accepted state.

Use shared Windows admission across builds/tests/diagnostics/dependent windows;
release external central admission before controllers acquire
Global\Tedd.DotNetLab.Measurement.v1 for timing. Only task-local catalogs/builds
and immutable fixture reads; do not reconfigure the shared installation.

Any primary failure is not_supported. A primary pass with unresolved guards is
inconclusive for adoption. Same-process dependence and namespace/code-layout
effects remain explicit. Direct-release fresh normal confirmation is required
before any 10x claim; do not multiply P27/P29 ratios. P27's unresolved build,
count, fallback, memory/allocation and complete API guards remain open. This
screen cannot promote the complete library or establish the full objective.
