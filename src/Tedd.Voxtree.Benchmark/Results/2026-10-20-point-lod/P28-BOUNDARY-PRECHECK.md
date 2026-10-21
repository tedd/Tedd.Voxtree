# P28 preimplementation disposition

Not selected at the generated-code gate; no source fork, hypothesis registration,
build, test or timed candidate run was executed. Commit14a9e30 retains the
prepared design and scripts. Prepare-P28 now refuses execution rather than
spending the prospective budget on a boundary already removed by the compiler.

The complete final Tier1 ForceUInt32Scenario.AfterBatchOwned body is3876 bytes
with rsp subtraction216. Its `lod` string comparison reaches IG10; the valid
palette fallthrough IG10..IG17 contains coordinate checks, byte-index and state
loads, unsigned LOD validation, value/LOD consumption and no calls. UInt16's
corresponding2828-byte body has subtraction200 and a call-free palette LOD
fallthrough IG10..IG16. These branches already inline AsSpan, the span getter,
codec dispatch and palette reader. Retained AsSpan/Get calls elsewhere in the
same multi-operation method do not identify the executed LOD boundary.

Audit-OwnedLodBranches.py binds both complete listings by SHA-256, checks the
UTF-16 `lod` comparison, identifies the inline state-load branch, and separately
records every other AsSpan/Get call site. The original native listings remain
part of P27's fixed evidence. Diagnostics do not establish the exact quiet PGO
body, time fraction, cache behavior or a performance result for an unbuilt fork.

The additional OwnedLodSnapshotTests remain useful contract checks for later
read changes. They are committed but unexecuted while P27 occupies the host.
The next read intervention requires a distinct mechanism and protocol. P27's
original complete families continue unchanged; no observations are replaced.
