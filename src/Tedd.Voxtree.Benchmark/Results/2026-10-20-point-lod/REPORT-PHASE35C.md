# Final first-error diagnostic results

The five frozen deterministic tests pass their original predictions. This
supports task-local diagnostic logging before cleanup can mask the primary
exception. It establishes no additional Voxtree speedup or source adoption.

| Original test | Observed result | Launches | Retained measured sessions |
| --- | --- | ---: | ---: |
| original-masked | Cleanup error masks the absent-scenario error; no primary log | 1 | 0 |
| logged-masked | Primary absent-scenario error logged before cleanup error | 1 | 0 |
| logged-cleanup | Valid session, cleanup error, no primary-error log | 1 | 1 |
| logged-primary | Primary absent-scenario error preserved; cleanup succeeds | 1 | 0 |
| logged-success | All paired sessions complete without failure logs | 24 | 24 |

All 28 original target PID/start identities are no longer live. Five original
workers joined. All 25 retained measured sessions are correct, quiescent, and
exited. Scoped grant consumption is exactly 1/1/1/1/24; the original unused
startup grant remains unused. The three injected cleanup failures leave staged
directories whose bytes and paths are preserved. Diagnostic clocks are retained
without any comparative timing records, objective vectors, or promotion claim.

The 47 original Application source files contain one modified file and 46
byte-identical files, plus the new logger source. The inserted catch logs and
rethrows before the original finally block. Measurement, cleanup, original normal
source, and original normal binaries remain unchanged. Each controller arm has
the same complete dependency/native closure; only Application.dll differs. This
does not establish native-code or performance equivalence between controllers.
The shared DotNetLab service and Voxtree runtime source are unchanged.

The aggregate auditor initially assumed SQLite row enumeration matched the
paired arm order. Its source and failure are retained. The corrected auditor
checks sorted arm ordinals and the variant set independently. This offline audit
correction restarts no producer and replaces no target observation. Earlier
worker compile, native startup, and original-logger preflight failures also
remain failures in the evidence. Parent and five child hypotheses are supported
for the deterministic diagnostic claim only, through supported CLI revisions.

The controlled open handle explains the injected cleanup failures only. It does
not identify the cause of the original intermittent P39N failure. That stopped
family remains incomplete and inconclusive; it was not resumed, replaced, pooled,
or promoted. Extended priming established optimized caller availability in a
separate epoch, without resolving the old timing result. P31/P39 and other
unconfirmed library prototypes remain isolated. The full public-method 10x
objective is unmet.

Phase35c preserves 569 paths, 368 unique blobs, six catalogs and zero comparative
rows in 26,254,648 bytes. CRC, every content hash/length, unique mappings, catalog
tables and required paths pass verification. SHA256:
`b7ddafb768342d99cce01335d75d1686b0d2e62352023313dd1f3e5bede59bbc`.
Phase35a/35b and all original evidence remain unchanged.

The user requested final tests and release, ending further optimization for this
delivery. Next gate: final production solution build/tests/package verification,
commit and push to the original main branch, then the authorized deploy workflow.
The patch retains the previously validated runtime implementation. Research is
integrated into main; unrelated docs/articles is excluded. No task branch or
worktree exists. The task workspace remains required until release verification
and preservation finish; cleanup follows verified worker shutdown.
