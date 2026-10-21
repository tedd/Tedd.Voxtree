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
Encoded UInt32 bytes alone increase from 13,693,396 to 68,784,288 (5.02x).
The combined figure applies when distinct compiled lookup payload is also
retained; it must not describe an encoded-only application's footprint.

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

All eight confirmation cases completed, with 192 distinct fresh process/start
identities and eight joined controllers. All measurements are correct,
quiescent and observe zero measured-thread allocation. All eight plans were
frozen before the first session. No retries, replacements or old-family data
enter this family. Construction, bulk, fallback, memory and broader public-API
guards remain unresolved; no source adoption or new package is claimed.
The full goal remains active. The designated task workspace is retained for active inputs and runs;
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

| Complete public read | Speedup | Family-adjusted interval |
|---|---:|---:|
| UInt16 owned Get | 15.630 | 14.484..16.866 |
| UInt16 owned LOD | 13.524 | 12.785..14.306 |
| UInt16 borrowed Get | 16.975 | 15.118..19.060 |
| UInt16 borrowed LOD | 14.331 | 13.502..15.211 |
| UInt32 owned Get | 13.307 | 12.216..14.496 |
| UInt32 owned LOD | 11.361 | 10.332..12.493 |
| UInt32 borrowed Get | 14.852 | 13.029..16.929 |
| UInt32 borrowed LOD | 13.200 | 11.957..14.572 |

Every lower bound exceeds ten under the frozen paired-independence assumptions.
Interval coverage is 0.996875 per frozen family adjustment. This applies to
the selected dominant terrain sample and repeated 1,024-point set, not every
chunk, an observed game trace, cold access, individual-call tails or all APIs.
Uncontrolled environmental drift remains a limitation. Every allocation model
is descriptive_only with degenerate_variance; zero observations are not
converted to inferential equivalence. All eight promotion decisions are false.
The time primary is supported; overall adoption remains inconclusive.

The scoped phase-ten supplement preserves 826 logical paths as 684 content
blobs, two closed catalog exports and sixteen objective rows (one per new
objective, not duplicate comparison/vector projections). Size 2,846,937 bytes;
SHA-256 be7609b4f377d21f6e7af8644f0c840364be050d825a855f4962206a4f165f8b.
Every blob hash/length, CRC, mapping, catalog table and required record passed.
This supplement retains new P24 sources, builds, tests, census, diagnostics and
confirmation. Earlier source/controller/region provenance remains in phase
nine; the smaller archive does not replace that reproduction chain. Catalogs
in phase ten precede the separately retained post-confirmation disposition.
