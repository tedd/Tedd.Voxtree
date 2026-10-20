# P9: joint value and stored-LOD states

Objective remains 10x across the public API, prioritizing .NET 10 steady-state
point and LOD reads. P9 targets the existing UInt32 compiled API; it does not
substitute that subset for the full objective. Use a new isolated source fork
and the frozen version-6 terrain callers. Serialized bytes are unchanged.

P7w still calculates two grid indices and reads a value-index word, an LOD word
and the value palette. Investigate joining the immutable value and stored LOD
into a palette state, then storing one byte-sized state index per voxel.
This deliberately spends more grid bytes to remove the independent LOD index
and address calculation. Require total payload to fit the original node index
budget. No additional public object fields or per-query allocation are allowed.

Each state is the exact pair (UInt32 value, stored leaf LOD). Collect at most
256 states; reject the 257th rather than truncate. Store full-width values and
LOD integers in the prefix of one UInt32 array, then four byte indices per
remaining word. An existing private field records the prefix word count when
the node array is present; zero still means the original node layout. Uniform,
dense and fully expanded paths retain their representations. Source snapshots
are copied into the private array and concurrent readers need no locks.

First reject depths below 3 or volumes whose minimum grid-plus-two-states cost
exceeds nodeCount*36. After collecting states, check the exact
N+stateCount*8-byte payload against that bound before allocating. Use logical
shifts to avoid byte-order assumptions. Construction may become slower through
state collection and grid expansion; count its complete allocation and latency
and measure compile+65,536-read lifecycle, rather than claiming a point-only
gain establishes adoption.

Semantic gates: every real-world value and LOD; exactly 255/256/257 states;
same value at different leaf depths; uint.MaxValue; coarse/fine boundaries;
borrowed storage reuse, rebuilding the source and parallel readers; out-of-range
failure outputs; sparse/uniform/full/dense fallback controls. Preserve all
earlier failures and epochs. Inspect actual default-tiered x64 point callers,
loads, bounds checks, code sizes and fixed stack reservations.

Compare P9 to frozen P7w with all 16 compiled terrain scenarios, quiet profile,
12 paired blocks, 3-second per-variant primes and the already declared bounded
lifecycle budget (33,554,432 reads; 256 constructors; 16 compile/read lifecycles).
Family size 16; same 5% exploratory thresholds. Use a new target and catalog;
do not pool screens or continue a tainted target. Do not claim promotion or
5% equivalence from failed host-precision controls. A selected candidate must
also be confirmed against the original API baseline with identical callers,
fresh sessions and the complete fallback/lifecycle guard matrix.

The first P9 build passed all 48 terrain fixtures and all five new state
boundary/ownership tests. Existing `NearlyFullTreeRetainsItsCoarserLeafLod`
failed solely at its 36-bytes-per-node payload assertion (2,592 expected, 776
actual) before reaching its value/LOD loop. Preserve the original three-runtime
failure results. P9b changes only the isolated copy of that one representation
assertion to the exact new 512+33*8-byte payload; all semantic checks stay
unchanged. It does not modify the candidate binary or repository unit test.
Re-run the complete suites, then inspect and screen only after they pass.
