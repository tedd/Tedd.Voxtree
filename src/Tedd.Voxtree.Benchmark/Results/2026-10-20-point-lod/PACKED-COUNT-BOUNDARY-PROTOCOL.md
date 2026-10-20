# P21: keep vector count expansion outside the scalar dispatcher

Control is complete P20. Its 96-case screen improved full and 17-element-row
counts, but seven-element rows regressed to 0.305/0.491 count and 0.307/0.439
miss speedups versus P19. Preserve all P20 observations and failed short guards.
The exact full-then-short probe emits P20 CountPacked bodies of 1647/1468 bytes,
with fixed rsp subtraction 136/152, versus matched P19 Snapshot 316/391 and
40/56. This is code expansion evidence, not proof of front-end stalls or cause.

C18: add NoInlining only to legacy/generic CountPackedVector. Leave executable
IL, dispatcher conditions, scalar/vector loops, validation, filters, wire,
fields, ownership and all other paths unchanged. The hypothesis is that an
explicit vector-helper boundary limits dispatcher expansion and shared stack
work on its scalar path. No blanket inlining/PGO/runtime configuration changes.

Prediction: every dominant seven-element-row count/miss takes at least 20% less
time than P20, with no >5% adverse estimate in the eight dominant full/17-row
count/miss guards. Retain all other case effects. Continued expansion, surviving
short-row loss, inadequate primary or failed guards falsify selection. Smaller
code alone is insufficient. Positive same-process evidence remains unconfirmed.

Before timing: all P20 semantic tests on .NET 8/10/11, .NET 10 intrinsics off,
all 48 point and 96 bulk oracles. Inspect the exact bulk DLL after full-then-
short Prepare history, both widths/variants, binding hashes and joined exits.
This attribute-only fork reuses the unchanged P20 encoder/format and corpus
input; original source byte hashes remain verified. Complete changed-source
corpus/fresh evidence still precedes any adoption.

Freeze the identical version-14 96-case family and existing budgets: ordinary
.NET 10.0.13 x64 tiering/PGO, affinity 4, 3-second per-arm primes, quiet profile,
twelve same-process paired blocks, four warmups, seed 20261022, 120 seconds per
plan; sixteen construction/build/size/FromEncoded, 64 copy/validation/count/miss
including clipped rows, two construction-plus-65,536-read operations. Family
96, existing 5% time policy. No exclusions, additional samples, failed-session
replacements, old-plan resumes, cross-epoch multiplication or allocation-
equivalence claims. Keep previous normal-confirmation failure unlocalized.

Use separate p21point/p21bulk identities, task-local artifacts and shared host
admission. External phases acquire the central mutex; DotNetLab controls timed
admission. Preserve every adverse result and verify worker shutdown.
