# Disambiguated packed-word candidate

Integration branch: main. Production library remains f0772c8 (2.0.28).
P24 starts from complete P18, excluding P19..P23. Eight library files differ
from the release after newline normalization. The prospective protocol and
complete release-to-candidate patch accompany this checkpoint.

Packed words now use magic 0x50, version 3, kind 3. Published O/version 1/2
formats remain readable and byte-identical on fallback. Released readers
reject new P output. P24 rejects ambiguous unreleased O/version 3 layouts.
Public legacy FormatVersion constants remain 1/2; PackedLeafFormatVersion is 3.
The word-reader source after header/writer logic is identical to P18.

The initial source preparation stopped at an ordered-filename assertion:
Windows path ordering differed from the intended ordinal list. The exact
five-file delta from P18 was independently verified, then frozen without
regenerating source. No build or timing preceded that setup failure.

Tests pass 406/407/408 on .NET 8/10/11, and 407 on .NET 10 with intrinsics
disabled. Both normal bundles pass all 48 point oracles. New tests cover
literal legacy uniform/tree data and rejection of conflicting magic, version,
kind and width. The full immutable Forcecraft census checks all 1,286 chunks
and 42,139,648 cells, including independent LOD partitions and old-reader
rejection of new packed output. Eligibility and payload equal P18: UInt32
encoding plus distinct lookup storage remains 71,567,508 versus 48,861,892
released bytes, approximately 46.5% larger, excluding headers and GC overhead.

Eight canonical primary callers match. Dependency DLL closure, runtime settings
and fixture match; complete source is bound to release/P24 independently.
Selected-bundle UInt16/UInt32 owned-LOD x64 diagnostics exit zero. Static code
and frame summaries are diagnostic evidence, not elapsed-time attribution.
The RTree reports reinforce this distinction: fewer loads or smaller helper
bodies do not substitute for complete matched callers or ordinary PGO checks.

The separate P24 family freezes all eight plans before observations, twelve
fresh pairs per case, 100 million public reads per run, one warmup, .NET
10.0.13, seed 20261026 and the original sixteen-objective policies. A fresh
failure-logging controller and immediate exact 24-launch grant serve each case.
Timed work acquires Global\Tedd.DotNetLab.Measurement.v1 through the controller;
external phases use the shared admission driver. Old P18/D1/L1 observations
are excluded. The primary target is every adjusted time-speedup lower bound
at least ten; the mandatory allocation guard remains unchanged.

Confirmation is running at this checkpoint. No performance result, promotion,
source adoption or new package is claimed. Construction, bulk, fallback,
memory and broader public-API guards remain unresolved. The full goal remains
active. The designated task workspace is retained for active inputs and runs;
no alternate branch or worktree exists. Unrelated docs/articles is untouched.

The original native summary truncated generic call targets at an internal
bracket. p24-native-audit-v2.json corrects that extraction and preserves the
original record. Code sizes and frame reservations are unchanged.

P25 is a separate prospective writer-only experiment against complete P24.
It marks uniform parent anchors bottom-up using the reserved destination,
then fills canonical leaves, with no additional arrays or changed readers.
Exact differential wire/capacity/LOD tests, all framework and bulk oracles,
and two complete corpus checks precede the frozen 88-case exploratory screen.
The original 5% guard remains. The driver is queued behind the full P24 lease;
its used dependency hashes are checked before and after admission. No writer
performance result is available at this checkpoint.
