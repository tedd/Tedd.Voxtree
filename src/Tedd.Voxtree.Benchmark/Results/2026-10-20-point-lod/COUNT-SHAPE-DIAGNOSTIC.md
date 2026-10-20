# P20 short-row boundary diagnostic

The complete version-14 family reports adverse seven-element rows despite its
explicit scalar fallback. Preserve all 96 cases and their original budgets.
No new timing comparison is scheduled. On the identical p20bulk DLL, first
Prepare/execute/validate full count, then seven-element count, both variants,
UInt32 followed by UInt16, with the original three-second per-arm Prepare.
Capture the selected count/packed/RunCore/Accept/TryGet listings, exact wrapper
and bundle hashes, PID/start and joined exit.

Competing explanations: the larger dispatcher/inlining budget changes the
fallback's surviving calls or stack work; full-count PGO history makes the
fallback cold; a different caller/code-layout effect. Compare actual P19
Snapshot scalar versus P20 scalar fallback code and retain every listing.
Generated code can guide a small dispatcher/scalar boundary intervention; it
cannot establish cache misses, elapsed fractions, exact quiet JIT identity or
causality by size alone. This diagnostic neither replaces failed guards nor
adds observations to the completed performance family.
