# P17: split tagged fast paths from tree traversal

P16's initial complete-stratum LOD estimates are near one against P15. Actual
Tier1 BeforeBatchOwned/AfterBatchOwned listings contain codec calls in both
variants; the four getter hints grow caller code 3222 -> 3433 bytes and fixed
rsp subtraction 296 -> 312 bytes. Both codec readers remain 798 native bytes
with 104-byte fixed subtraction. This supports moving the investigation to
the codec boundary; it does not attribute a measured percentage to call cost.

Hypothesis C09/C18/A09: leave the uniform, dense and packed dispatch in a
bounded reader marked AggressiveInlining, and move the unchanged tree walk
into a private NoInlining helper. This gives the JIT visibility into direct
reads without pulling tree traversal into every caller. Preserve exact checks,
out-parameter initialization order, malformed-data behavior, encoded bytes and
ownership. Control is the frozen P15 source; do not include P16 getter hints.

Correctness gate: all 48 terrain oracles and the full .NET 8/10/11 suites.
Generated-code gate: actual owned/span BeforeBatch/AfterBatch loops, codec
dispatcher and tree helper, default tiering/PGO, dominant UInt32 owned LOD.
Record whether direct reads actually inline, remaining calls, code bytes and
fixed stack reservations. No hardware attribution from code counts alone.

Before any P17 observations freeze all 48 version-12 terrain cases, twelve
same-process paired blocks, four warmups, seed 20261022, family 48, quiet
profile, .NET 10.0.13, affinity 4, three-second variant primes, 120-second plan
limit, no exclusions. New bounded-point budget: 2,097,152 reads for every point
case, 256 complete lookup constructors, 16 compile-plus-65,536-read operations.
The earlier distribution-based 33,554,432 uniform-read budget timed out in P15;
preserve that failed plan and tainted target, do not resume or append to it.
The smaller, prospectively fixed budget is a new experiment, not a correction
to old observations. It trades precision on fast paths for a bounded complete
family. C3's unresolved 5% time equivalence remains explicit; all P17 ratios
are exploratory and no cross-epoch ratios are multiplied.

Falsifiers: direct reader still does not inline, material LOD cost remains,
or legacy fallback/compiled paths regress. Complete build/read and bulk/query
consumer costs and fresh normal-build confirmation remain adoption gates.
