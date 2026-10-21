# P39F controller first-failure evidence

Prospective after bdef3b5; original P39N operation and residual directory remain
immutable. This is a task-local diagnostic/control study, not a Voxtree source
candidate or a resumption of any stopped timing family. Shared service/catalog,
user stores, databases and production source are unchanged.

Observed failure: original cleanup throws in RunNormalSessionAsync finally,
while the tenth launch has no retained measurement. An earlier exception can
therefore be hidden. Copy the original Application source into a new task-owned
build directory. Change only that method's catch to emit a bounded structured
primary-failure record before finally; add a private best-effort logger. Preserve
the original throw and finally cleanup/retry/measurement logic exactly. Logging
failure must not replace the original exception. Other Application source is
byte-identical. Replace only Application.dll in a copied controller closure;
retain every other original controller file byte-for-byte.

One identical diagnostic worker references the supported public LabService API
and existing normalBuildFileStaged constructor test hook. New disposable private
catalogs use supported CLI registration and exact24-launch grants. No fake grant,
private execution invocation, policy bypass or actual shared controller change.
Targets are exact original p39n2/p39n3 normal modules. Missing-scenario plans
deliberately fail their advertised-registry check before scenario execution.
Valid plans select Classic32 empty validation with32 complete operations/session;
existing500ms Prepare and one warmup batch remain diagnostic setup. No comparison
or source-performance inference is collected from these runs.

Fixed test order and expected outcomes:

| Test | Controller | Scenario | Hold staged DLL against delete | Prediction |
|---|---|---|---|---|
| original-masked | original | deliberately absent | yes | failed cleanup hides first scenario_not_found; no primary log |
| logged-masked | new | deliberately absent | yes | primary scenario_not_found log precedes cleanup failure |
| logged-cleanup | new | existing empty validation | yes | cleanup-only failure, no primary log; correct exited session remains catalogued |
| logged-primary | new | deliberately absent | no | primary scenario_not_found preserved and logged; launch directory cleaned |
| logged-success | new | existing empty validation | no | complete24 correct/quiescent/joined sessions, no failure log |

The worker's existing staging hook opens only CompactNormal.dll under its exact
private catalog/launches prefix, read-only with FileShare.ReadWrite (excluding
Delete). That deterministic Windows handle remains held until the operation is
terminal and no owned job remains, then closes. Never lock the original failed
directory or another task's files. Existing cleanup retry budget stays unchanged.
Expected cleanup exception may be IOException or UnauthorizedAccessException;
no claim about the original lock owner follows. Maximum28 launched target
processes: one for each of the first four tests,24 for success. Measured sessions
are diagnostic correctness evidence only; maximum25 retained correct sessions.

Two logger self-tests cover32768-character detail truncation and a throwing
error writer. They invoke only the new logging function, no target execution.
Stop on an unexpected test result, record original IDs/requests/outputs and
join owned workers; no retries or replacement. Each frozen plan has120 seconds;
worker wall ceiling200 seconds permits orderly deadline/cleanup/join. Grants
are issued immediately before each worker through supported CLI, exact24 launches.

Hold legacy host admission across the study. Metadata/build/staging use
Global\Tedd.DotNetLab.Measurement.v1; release external central ownership before
the public service acquires it for normal sessions. Return to central admission
for inspection/export after each worker. Bind source/patch/project/runtime/
full dependency closure, plan/grant, PID/start, operation/execution/session and
all shutdown evidence. Runtime10.0.13 x64, pinned11.0.100-rc.2.26504.105 compiler.

Passing gates support preservation of the first error before cleanup only.
They do not reproduce or explain the original intermittent cause, prove quiet
performance equivalence, change old statistics or authorize source adoption.
Only after these diagnostics may a new full timing family be independently
frozen with justified warmup, all guards and original source selection.
