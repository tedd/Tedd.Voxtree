# Point caller history: native diagnostic cut

Integration branch main; starting commit0e7fefc. Production remains f0772c8 /
NuGet2.0.28. H2 hypothesis hyp-8c106c363d704c58bdc43f17be35648a tests a
differential call-boundary explanation for the rejected P32 stage. No library,
fixture, tiering, PGO or caller source changes are made. No new timing observations
or source adoption occur. The full public-method10x objective remains active.

The same hash-bound paired p32point bundle is used in two fresh native-only
processes. Get-first replays the original first eight P32 cases and actual
chronological arm order; LOD-first removes only the preceding Get cases. The
original48 scenario objects and literal string identities are retained. Each
selected case uses its original four paired blocks, two warmups, reset-after-
warmup,2,097,152-read batches, three-second per-scenario/arm priming, validation
and Cleanup. No deserialized op strings replace the original interned literals.

Both processes complete correctly and join: eight cases/64 replayed run sequences
and four cases/32 sequences. Declared read batches total134,217,728 and67,108,864;
these counts exclude primes, warmups and oracle work. No latency or allocation
capture is collected. Native observers are isolated from quiet measurements;
shared host locks cover the build and both histories on .NET10.0.13 x64/affinity4.

Forty-eight optimized tier/OSR listings are indexed. Sixteen complete final Tier1
callers are mapped from the emitted "lod" dispatcher to the valid R read or the
codec boundary. The next-operation branch is excluded; exception and alternate
operation calls are not substituted for the selected route. Span AsSpan preambles
are outside the per-read loop.

| History | UInt32 owned, control/candidate | UInt16 owned | Span, both widths |
|---|---|---|---|
| Get-first | 1 / 1: AsSpan | 2 / 2: AsSpan + codec | 0 / 0 |
| LOD-first | 0 / 0 | 0 / 0 | 0 / 0 |

Entries are static call sites on the mapped valid LOD route, not sampled dynamic
call counts or measured cost shares. Both arms change alike. H2's proposed
differential call-boundary explanation is therefore **not_supported**; common
history dependence is established but does not explain the P32 time ratio.

| UInt32 owned caller context | Control native bytes/fixed rsp | Candidate |
|---|---:|---:|
| Get-first | 3310 / 232 | 3261 / 232 |
| LOD-first | 3833 / 216 | 3718 / 224 |

The Get-first candidate R route jumps to IG50..IG54; the control reaches its
decode in IG29. Metadata dataflow also differs. These are diagnostic code-layout
facts, not a cache/stack/hardware attribution. Fixed reservations exclude pushes
and callees. Different compilation schedules, controller activity and GC/JIT
timing prevent a claim of exact quiet machine-code identity.

The old P28 precheck remains valid for its isolated LOD-first context, where the
owned snapshot boundary disappears. It does not establish that the boundary is
absent after Get-first training. Future point candidates must check both histories
before extrapolating an isolated instruction/call removal to the shared caller.
An owned snapshot visibility intervention, if pursued, must use complete P31
without P32's rejected unaligned load, retain atomic snapshots/error outputs,
and pass both context/native and full performance gates. The terminal-validator
candidate remains a separate mechanism. Register any new source experiment first.

Phase20 preserves native/source/schedule/catalog evidence:124,326bytes, SHA256
343b5c9708ee6c6bb7964aed435a47fa5104ccdd70066a7be89456555ce8d8f0,
27paths,24unique blobs,one catalog,zero metric rows. An explicit archive-content
inspection found that the source-directory filter omitted the new probe DLL
category despite required-record verification passing. The original archive
remains immutable. A separate phase20-binary supplement preserves the original
probe and dependency binaries without rebuilding or recapturing:
288,056bytes, SHA256
197d2bd9bd801f02facfd033f459e33b0a6b4102ef0ad1c8e3e4504eb5487014,
nine paths/blobs,zero catalogs/metrics. Probe entry hashes match both original
process identities, and copied bytes match their original output files. Both
archives pass CRC, blob length/hash, unique mapping and required-path checks.
The verification scope and binary supplement are explicit; a green subset check
alone does not prove complete artifact coverage.

The active workspace D:\Workspaces\AI\voxtree-point-lod-20261020 remains needed.
No temporary worktree or branch was created.
