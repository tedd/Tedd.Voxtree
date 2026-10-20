# P19: specialize packed CountMatches

Control: complete frozen P18 source (leaf-helper-inline-source). Treatment
changes only the packed Count mode in legacy and generic query implementations.
No format, ownership, fields, builder, point read, Any, collect, copy or nearest
algorithm changes. Production remains f0772c8; this is an isolated source fork.

A09/C18: general State.Accept dispatch and VoxelBox construction remain in each
packed voxel iteration in actual x64 Tier1 code. Source Count can use the clipped
coordinates directly and add one per matching voxel. Introduce a dedicated
CountPacked loop, selecting Count once before traversal. Keep the existing
PackedLeafEncoding.TryGet call, bounds/LOD checks, filter predicate, iteration
order and FormatException behavior. Row hoisting, SIMD, leaf-LOD traversal and
Any specialization are separate candidates, not part of this intervention.
Header revalidation was a refuted hypothesis and is not a claimed mechanism.

Prediction: each dominant UInt16/UInt32 count and miss caller takes at most half
P18's elapsed time in the fixed exploratory screen. Falsifiers include persistent
general Accept dispatch on this count path, no useful complete-caller reduction,
semantic mismatch or adverse required guards. No measured cost share or PMU
cause is inferred from static call counts or sample shares.

Before timing: all original framework tests plus packed tests for arbitrary
boxes, every filter mode, reserved-bit predicates, all three supported APIs,
malformed LOD inside/outside the query and empty boxes. Both point bundles must
validate the complete 48-case terrain oracle. Both bulk arms validate all 88
complete-operation cases and byte parity. Inspect the exact new bulk DLL's
native count path; no unsafe pointer loads are introduced.

Freeze the full existing version-13, 88-case bulk family, including every
unchanged-format and noncount guard. .NET 10.0.13 x64, ordinary tiering/PGO,
affinity 4, 3-second per-arm primes, quiet profile, twelve paired same-process
blocks, four warmups, seed 20261022, 120 seconds per plan. Counts remain sixteen
construction/build/size/FromEncoded, 64 copy/validation/count/miss, two complete
construction-plus-65,536-read operations. Family size 88 and existing 5% time
policy. No added samples, favorable selection, failed-session replacement,
cross-epoch pooling or multiplication of speedups. Same-process blocks remain
non-independent; guards and allocation observations remain exploratory.

Use separate p19point and p19bulk labels, P18 controls, task-local sources/builds
and the actual shared measurement mutex. External phases hold central admission;
DotNetLab owns timed admission. Retain all failures and verify joined shutdown.
P18's incomplete fresh family and its unresolved confirmation_failed cause are
not retried or erased. A positive screen still requires full-corpus changed-
consumer checks, selected-source fresh confirmation and complete adoption guards.
