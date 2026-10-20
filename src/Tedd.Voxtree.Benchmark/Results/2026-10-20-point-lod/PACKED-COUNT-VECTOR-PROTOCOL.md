# P20: validate and count packed rows in bulk

Control is frozen P19 source, including its scalar CountPacked path. P19's
dominant UInt32 count estimates improve, while UInt16 estimates are adverse;
its complete 88-case budget continues unchanged. P20 does not relabel those
results or inherit a passed guard. Actual P19 CountPacked Tier1 is scalar,
340/387 native bytes for UInt32/UInt16, without general Accept calls.

A03/V03/V04: use contiguous packed-word spans, validate their LOD range with
the existing .NET 10 span range primitive, then use existing MaskedVoxelSearch
SIMD predicates with the filter mask restricted to value bits. Expected bits
outside the value range imply no equality match, but validation still runs
before predicate shortcuts. Count logical lanes, not bytes. Reuse the existing
bounded vector body and scalar tail; introduce no pointer loads or new ISA
dependency. Row/format metadata is computed outside per-voxel loops.

Only little-endian .NET 10+ with Vector128 hardware acceleration uses the new
path. Full Y/Z coverage is one contiguous interval for the selected X range.
Other boxes require at least sixteen Z values per row; shorter rows retain
P19 scalar traversal. Nonaccelerated and older targets retain scalar behavior.
Validate only queried intervals, preserving invalid LOD rejection inside the
query and ignoring malformed words outside it as before. Count alone changes;
Any, point reads, format/bytes, ownership, fields and other consumers do not.

Prediction: all four dominant count/miss callers take at most half P19's time.
Falsifiers: no useful complete-caller benefit, incorrect masks/tails/LOD behavior,
vector overread, or adverse mandatory guards. Do not infer PMU bottlenecks or
multiply preceding effects. A positive screen requires later direct release-
baseline fresh confirmation, not a portfolio of favorable old epochs.

Before timing: complete original and packed/count tests on .NET 8/10/11, plus
7/8/9/15/16/17/23/31-element cropped rows, all filter modes, and bad LOD at
vector start/end/tail. Run .NET 10 tests with intrinsics disabled. Validate
all 48 point and all 96 bulk oracles. Retain exact selected-bundle x64 listings
and hardware/fallback dispatch. Recheck all 1,286 immutable corpus chunks on
a separately bound f0772c8-control bundle; no world/application/database writes.

Freeze version 14: original 88 complete-operation cases plus eight dominant
clipped count/miss cases, both widths, Z rows of seven and seventeen elements.
Fixed family 96, all cases retained. Ordinary .NET 10.0.13 x64 tiering/PGO,
affinity 4, 3-second per-arm primes, twelve same-process paired blocks, four
warmups, seed 20261022, quiet profile, 120 seconds/plan. Batch counts remain
sixteen constructors/builds/sizes/FromEncoded, 64 copy/validation/count/miss
(including clipped counts), and two construction-plus-65,536-read operations.
Existing 5% time policy; no exclusions, extra samples, failed replacements,
or pooling with version 13. Same-process results remain exploratory; no source
adoption or allocation-equivalence claim. Preserve P18's failed fresh family.

Use new p20point/p20bulk/p20census identities and the actual shared mutex.
Wait behind P19's outer pipeline lease; release external central admission
before DotNetLab controls timed work. Retain protocol hashes, original failures,
source/binaries, all adverse observations, and joined process shutdown.
