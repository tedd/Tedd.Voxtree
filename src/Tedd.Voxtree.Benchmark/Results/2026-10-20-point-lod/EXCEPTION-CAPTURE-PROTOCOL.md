# Controller exception diagnostics

The original P18 controller stderr log has no retained exception details for its
generic confirmation_failed code. Its source can discard the exception and
cleanup can replace an earlier failure. Do not resume or replace that family.

Prepare a separate EventPipe exception recorder with the installed, hash-bound
DiagnosticsClient and TraceEvent libraries. First validate the observer on a
new owned synthetic process: wait for explicit readiness, bind PID/start ticks,
attach before provoking one caught IOException with a fixed marker, stop and
drain the event session, parse and require the marker, then join the child.
Retain the raw nettrace, actual events/loss, source/binary hashes and exit state.
No timing or promotion comparison is produced. Stop on missing events or loss.

Only after this self-test may a separate prospectively bounded failure study
record exceptions on its own newly created controller. Match PID/start ticks
and its exact entry bundle; never attach to the installed shared MCP controller
or unrelated targets. Existing catalogs/installations/client configuration stay
unchanged. Recorded controller exceptions cannot establish target CPU/allocation
cost or prove the original historic fault. A successful self-test is not a
reproduction of that fault. Full message payloads remain inside task evidence.

All setup, raw traces, logs and output stay under the existing designated task
workspace. External build/self-test uses shared host admission after P23 joins;
no database, application service, world data, native patch or deployment write.
