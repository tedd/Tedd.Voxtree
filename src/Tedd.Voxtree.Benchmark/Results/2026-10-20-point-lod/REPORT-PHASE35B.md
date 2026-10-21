# P39F diagnostic startup: native-loader prerequisite corrected

Original/integration branch main, starting924f493. The first diagnostic worker
exits before LabService construction completes because its manually referenced
dependency manifest cannot resolve native SQLite. Original stdout/stderr,
PID/start, nonzero exit, driver failure and unused grant remain retained.
Read-only checks of all five private catalogs prove zero accepted operations,
zero grant uses and zero target launches. None of the five actual tests has run.

The original SQLite Windows-x64 asset is present in the full copied closure.
A new helper/source/build identity binds only that fixed absolute native path
to the existing provider's DllImport resolver. Its SHA256 is
b7385d722c83fb52142a00477a726723745916d22a555711ee89834c1111fb2e.
Both controller arms pass provider initialization/version reads without opening
a database. All original controller files remain unchanged except common helper
files; only Application.dll differs between arms. No global loader configuration,
shared service, normal module or cleanup behavior changes.

An initial native preflight incorrectly invokes the added logger on the original
Application, which has no such method by design. That original process fails with
"New logger absent"; its source/output/nonzero exit remain a failed implementation
preflight and are never relabeled passed. The preceding original-arm native check
passed. A separate driver executes only the two unstarted new-arm checks, without
rebuilding or rerunning original processes. Across four total preflight processes,
three succeed and one retained implementation failure demonstrates old-method
absence. Required checks now cover native resolution on both arms plus new-logger
detail truncation and throwing-writer containment. This implementation correction
precedes every target and changes no five-test prediction or performance rule.

FIRST-FAILURE-NATIVE-ADDENDUM freezes the loader correction and new worker/driver
bindings before the five original plans' first target acceptance. Plan IDs,
experiments, source/build selection, order and predictions remain unchanged.
Distinct worker output names preserve the original startup failure; new exact
CLI grants and new keys authorize the first target operations. No target/test
result, original failed P39N operation or performance observation is retried,
replaced, resumed or pooled. Maximum28 targets/25 diagnostic measured sessions
and stop-on-mismatch remain. Parent hypothesis is planned, with the new binding
artifact attached before targets.

Phase35b preserves the original startup/preflight failures, new source/helper/
full controller/native closure, unchanged plans, before-target catalog checks
and final frozen drivers:26,126,618 bytes,441 paths,264 blobs,six catalogs,
zero comparative rows. SHA256
`a232639958339e9114ae61d0019e7cb1c9d37f848fd90a2e5c938514a067f80e`.
Every CRC/hash/length/mapping/catalog/required path verifies. Phase35a stays
unchanged. Next execute only the five frozen deterministic tests, retaining
accepted IDs and all quiescence/failure evidence. No Voxtree performance benefit,
adoption or original intermittent-cause claim follows from this prerequisite.

Research integrates into main; unrelated docs/articles is untouched. No task
branch/worktree exists. The active workspace
D:\Workspaces\AI\voxtree-point-lod-20261020 remains required. Production source/
NuGet remains2.0.28; full public-method10x qualification is incomplete and active.
