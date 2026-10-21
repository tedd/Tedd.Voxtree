# Current investigation gate

Original integration branch: main. Full public-method objective remains active.
No prototype source is adopted into the production library. Current continuation
evidence is REPORT-PHASE6.md; earlier failed gates remain retained. P19 is
not_supported; P20/P21 remain inconclusive after complete 88/96/96-case screens.

1. Localize the fresh confirmation failure before another normal-build family.
   Six original cases completed; the seventh failed after 22 completed sessions
   and a later launch without a completed session record. All 166 retained
   sessions passed correctness/quiescence/shutdown checks. Launch PID 6636 has
   exited. The generic confirmation_failed code does not identify its cause.
   Preserve original plans, execution and launch records; do not resume or
   replace sessions, silently complete the eighth case, or call the original
   family complete. Any failure reproduction is a separate diagnostic, not
   additional favorable decision samples.
   The installed source records a launch only after staging returns; cleanup
   can replace an earlier exception. Remaining launch files alone cannot
   localize the fault to staging, startup or cleanup.
2. Preserve the count tradeoffs. P19 scalar specialization fails its UInt16
   primary despite removing general dispatch. P20 validated masked-vector counts
   improve dominant full callers 9.6..181.8x versus P19 but regress short rows.
   P21's two NoInlining flags shrink dispatchers and improve short rows about
   2x versus P20, with adverse full-miss guards. Do not multiply these epochs.
   Before selecting a complete source, use direct matched comparisons, resolve
   short/full tradeoffs and verify ordinary fresh callers. The two vector bodies
   have identical resolved IL across P20/P21; raw hashes differ. Header
   revalidation was a refuted hypothesis. No PMU or causal-time share is proved.
3. Investigate caller-buffer Build/TryBuild separately: the prototype emits a
   speculative legacy tree before overwriting it with packed words. Avoiding
   redundant writes is a hypothesis, not a measured remedy. Preserve exact
   format selection, required sizes, insufficient-buffer behavior, fallback
   bytes and original dense-storage LOD zero semantics. An early sizing cutoff
   must not misclassify a tree that would ultimately choose legacy dense storage.
   The unchanged builder native probe retains recursive linear-subtree and
   writer calls, plus eight-summary stack scratch: Tier0-FullOpts frames subtract
   152/136 bytes and another 96/64 at scratch allocation. WriteByte is inlined.
   A separate leaf-level specialization can avoid eight level-zero summary
   calls while preserving exact old/Morton bytes and uniform collapse. Measure
   sizing-only changes separately; do not assume static calls establish cost.
   P22 now isolates direct linear-leaf emission on f0772c8. All 88 cases/2,112
   records complete; dominant construction/size estimates improve 2.46..3.17x,
   but eight of 38 mandatory guards are adverse. Retain its byte-preserving
   fork, do not adopt it or combine epochs. Parent native frames remain large,
   and the new UInt16 leaf is 2304 bytes with a 160-byte fixed subtraction.
   A sizing-only writer shortcut is still a separate, unimplemented hypothesis.
   P22's complete 1,286-chunk/42,139,648-cell census passes with exact release
   bytes and unchanged encoded/lookup payload for all three encoder APIs.
4. Preserve the full-corpus result: 1,286 chunks, 686 unique arrays, all 42,139,648
   cells checked; UInt32/UInt16 eligibility 517/574. Combined UInt32 encoded plus
   distinct lookup payload grows from 48,861,892 to 71,567,508 bytes. The selected
   four strata are not an observed access trace. Recheck changed consumers on
   this immutable snapshot; never start the game/server or write world data.
5. Reprofile retained changes and validate combinations. Keep P10a's private
   array storage, prior compiled layouts and P1/P3/P5 separate until selected
   combinations have complete caller/guard evidence. The retained P1/P3/P5 patch
   and tests are reviewable, while production source matches committed release
   behavior. Complete x64 caller listings do not prove exact timed PGO bodies.
6. Before adoption, resolve construction/bulk/query/fallback guards, unfinished
   format constants/discrimination and compatibility. C3 did not qualify a full
   5% time-equivalence regime; degenerate allocation models remain unresolved.
   Five completed point cases exceeded a tenfold adjusted lower bound under
   declared assumptions, but neither that subset nor point estimates establish
   the full public API objective. Retain the broader catalogue.

Task scratch remains D:\Workspaces\AI\voxtree-point-lod-20261020 while work
continues. It holds immutable region copies and source/binary/control inputs.
After completed integration and verified worker shutdown, preserve remaining
requested evidence and clean only this task-owned workspace under the personal
lifecycle instructions. No temporary worktree or branch was created.
