# L1: isolated failure-only controller logging

D1 exhausted its 192-session diagnostic budget without reproducing the historic
generic fault. Do not repeat it, resume its plans or use its timings. L1 adds
future failure details without a continuously attached observer. It does not
claim to repair the historic fault or establish application performance.

Pin DotNetLab 9c23369. Create a source-only task copy; do not edit the original
repository, installed controllers, client configuration or old catalogs. Build
an unchanged control and a candidate with the same SDK/runtime/build paths.
Only ConfirmationService's existing failure catch gains bounded JSON stderr
details: operation/plan/execution, original failure code, type, HResult, exception
text/stack and truncation flag. A logger exception must not replace the original
failure. Preserve the successful path and existing failure codes/records.
Retain exact source diff, build recipe, SDK overrides and binary manifests.

Functional proof uses two new catalogs, one per controller. Register the exact
archived p18control/p18census target bundles. Freeze two plans for the original
UInt16 owned-get scenario: first a deliberately incorrect all-zero input hash,
then the correct original hash. Both use twelve pairs, original 8,388,608 reads,
one warmup and 600-second limit; seed 20261025. API flags are required nominal
normal-confirmation flags; these are functional tests and excluded from all
performance/promotion comparisons. Supported scoped launch grants only.

The incorrect-hash plan must fail on its first launch with invalid_plan before
measurement, zero returned sessions and joined target/controller lifecycle.
Both controllers must retain that same failure code. Only the logging candidate
must emit one complete structured failure line with matching identities, message
and nonempty stack. Then each controller must complete all 24 valid sessions,
correct/quiescent/exit zero, without a failure log for the successful operation.
Maximum total: 48 measured functional sessions plus two rejected launches;
no extra sessions, replacements, timing comparisons or promotion. A different
outcome stops that arm and remains explicit. No EventPipe/profiler attachment.

Parent holds legacy pipeline admission; external builds/preparation use the
actual central mutex, released before controller normal-session operations.
All cloned source, builds, catalogs, staging and stderr logs stay inside the
existing dedicated task workspace. Targets are the already inspected offline
voxel fixture; no server/game/world/production database/deployment writes.
