# Failure-only controller logging

Integration branch main, starting research commit c12fcd4. Production library
source remains f0772c8. This phase removes an observability barrier; it does not
establish a voxel-method speedup or repair the unlocalized historic failure.

L1 pins DotNetLab 9c233691210187340963f53ca98c640e2b0cc75e in a source-only task
copy. The original checkout had advanced independently to a5f97d6 and was not
edited. Original installations/client configuration and old catalogs remain
unchanged. The task copy uses SDK 10.0.402 and runtime 10.0.13 for both control
and candidate. The sole C# source delta adds bounded JSON stderr details inside
the existing confirmation-failure catch; successful-path source and failure
classification remain unchanged. A logging exception cannot replace the original
failure, except the already excluded OutOfMemory scope. Detail truncation is
explicit at 32,768 characters. The exact patch and source review are retained.

Initial RID publication failed with NETSDK1152 because TraceWorker RID/non-RID
outputs collided. No controller was started. Failed logs/output are retained;
fresh ordinary build outputs were created rather than suppressing the conflict.
Both ordinary builds complete with zero warnings/errors. Among 69 DLLs per
output, Application, Host and MCP differ; the other 66 match exactly. This is a
source intervention with dependent rebuilds, not a one-DLL binary replacement.

An initial proof setup attempted unsupported text/markdown import and stopped
before registering records or operations. Read-only inspection confirmed an
empty Record table and zero Operation rows. Fresh proof2 catalogs use a JSON
protocol artifact. No launch/session was replaced or added to a prior budget.
The earlier one-DLL-only audit assumption was incorrect; actual binary
differences are retained explicitly, with source and functional verification.

L1's fixed functional proof passes both controller arms. Each rejects one
deliberately all-zero input hash with invalid_plan, one launch and no returned
measurement session. Each then completes all 24 valid sessions. Across both:
48 correct/quiescent/joined exit-zero valid sessions, 50 launches, two expected
rejections, both controllers joined exit zero. Exact original archived target
bundles are verified. No EventPipe/profiler is attached and no comparison,
objective-vector or promotion record is produced. All timings are excluded from
optimization decisions.

Only the logging candidate emits one DOTNETLAB_CONFIRMATION_FAILURE line. Its
operation/plan/execution identities, original invalid_plan code, exception type,
message and RunNormalSessionAsync stack match the controlled failure, with
detail_truncated=false. No failure line is emitted for the successful operation.
The unchanged controller has no structured detail line. This validates future
failure evidence, not a remedy or diagnosis for the historic generic failure.

The reusable confirmation driver now persists stderr even if its owned
controller exited before finally, and rejects its own source changed while
queued. Previously frozen driver snapshots and original failed families remain
unchanged. A future independent decision family may explicitly select the isolated
logged controller at coldlog-controller-source/logged2-out/Tedd.DotNetLab.Host.dll;
no shared installation has been silently replaced and L1 supplies no performance
confirmation for any candidate.

The full public-method objective remains active. Workspace
D:\Workspaces\AI\voxtree-point-lod-20261020 is retained for active immutable
inputs and isolated controller/source evidence. No branch or worktree was created;
unrelated docs/articles and the original DotNetLab restart-codex.bat are untouched.

The closed phase-nine archive retains 40,916 logical paths as 33,930 unique
blobs, 42 catalogs and the unchanged 1,050 cumulative comparison-metric rows.
No L1 functional timing comparison was added. Every mapping, blob length/hash,
CRC, catalog table and required source/build/proof record passed verification;
controlled failure operation/plan/execution bindings also pass. Archive size
98,626,824 bytes, SHA-256
7cf285f39e0f7d7b4f8831ce902617576eceb0695c6c7e5814547c6bf90ff592.
The companion verification record lists required paths. All research PowerShell/
Python parses and whitespace checks pass; production library source still
matches f0772c8. Raw functional records remain excluded from speedup claims.
