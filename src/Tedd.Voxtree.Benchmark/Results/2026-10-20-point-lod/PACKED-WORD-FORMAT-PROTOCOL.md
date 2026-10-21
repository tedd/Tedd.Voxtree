# P24: disambiguated packed-word format and new point confirmation

Start from complete P18, not P19..P23. Registry A12/M05 (parent representation)
and its explicit wire contract. Existing prototype magic O/version 3/kind 3
collides with an unselected byte-layout experiment. Give packed words magic
0x50 ('P'), version 3, kind 3. Preserve header widths, exact value/LOD words,
selection, capacities and all hot word-reader bodies. Published O/version 1/2
formats remain byte-identical and readable. Reject O/version 3 prototypes and
P with wrong version/kind/size/length; no implicit cross-prototype migration.

Keep public FormatVersion constants 1/2 for their legacy layouts, document
that scope, and expose PackedLeafFormatVersion=3. New packed output is not
readable by released readers: they must reject P. All compatibility statements
are directional. Do not claim this alone makes queries/builders universally fast.

Before performance: .NET 8/10/11 tests, .NET 10 intrinsics off, all 48 point
oracles; explicit literal legacy uniform/tree readers, magic/version/kind/width/
length rejection, borrowed/owned/lookup/FromEncoded, capacities and exact LOD.
Full hash-verified offline census uses P24 primary/f0772c8 Snapshot, all 1,286
chunks/42,139,648 cells and unchanged fallback bytes. P24 packed eligibility and
payload must equal the P18 census. Verify P18/P24 hot reader source equivalence
outside header logic and identical canonical normal callers/dependencies/runtime.
Capture actual selected-bundle x64 owned-LOD diagnostics for both widths.

This new source is selected before a distinct full eight-case normal family.
Old failed P18 and observed D1/L1 data remain excluded; no missing old case is
filled. Direct control f0772c8 and P24 use primary-namespace AfterBatch callers,
same fixture version 12 and one public read per operation. Freeze all eight
UInt16/UInt32 owned/span Get/value+LOD cases, twelve fresh paired blocks,
100,000,000 reads per run, one warmup, 3-second primes, affinity 4, ordinary
tiering/PGO, .NET 10.0.13 x64, 600 seconds per case, seed 20261026. Family 16
(time plus allocation); 5% time policy and original absolute allocation guard
remain. Primary target: every time speedup's adjusted lower bound >=10. No
allocation-model bypass, extra samples, replacements, exclusions or pooling.

Freeze every plan before observations. Use the validated task-local failure-
logging controller, no continuous observer; launch a fresh owned controller per
case so its exact 24-launch grant is issued immediately before the 600-second
case. Stop the family on any failed/tainted/interrupted operation and preserve
accepted IDs, stderr details and all partial sessions. No source adoption from
point-only success: constructor/query/bulk/fallback/memory/API guards and the
broader public-method goal remain required. Corpus payload growth is not hidden.

All mutable artifacts stay under the existing designated workspace. External
phases hold real central host admission; timed controllers own that mutex.
Do not change shared installations, old catalogs, world files or applications.
