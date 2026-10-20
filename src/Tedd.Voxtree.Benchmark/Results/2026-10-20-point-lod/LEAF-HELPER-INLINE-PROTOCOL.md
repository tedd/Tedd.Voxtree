# P18: remove remaining word/value helper calls

P17 passed all 48 terrain oracles and 404/405/406 .NET 8/10/11 tests. Its actual
Tier1 caller incorporates the codec dispatch, but the hot reader still contains
calls to PackedLeafEncoding<uint>.ReadWord and Value. The dispatcher falls from
798 to 456 native bytes and fixed rsp subtraction 104 -> 80; the owned caller
grows 3222 -> 3787 bytes and subtraction changes 296 -> 224. Early LOD estimates
vary substantially by owned/borrowed and UInt16/UInt32 caller. Preserve the
complete family and do not attribute a measured fraction to these calls.

Hypothesis C18: add AggressiveInlining only to the private ReadWord and Value
methods in the frozen P17 helper. No executable IL, format, validation, public
getter hint, dispatch algorithm, ownership or footprint changes. This is a
separate intervention from P16's ineffective public getter hints, motivated by
two actual remaining call sites. Inspect actual callers to verify removal;
attributes alone prove neither inlining nor latency improvement.

Control P17; new source fork and new target. Required before timing: all 48
independent terrain oracles and .NET 8/10/11 tests. Freeze all 48 version-12
terrain cases, twelve same-process paired blocks, four warmups, seed 20261022,
family 48, quiet profile, .NET 10.0.13, affinity 4, three-second primes,
120-second limit, no exclusions. Use P17's bounded-point budget: 2,097,152 reads,
256 constructors, 16 compile-plus-65,536-read operations. Timed admission is
owned by DotNetLab; external phases wait for the same central mutex.

Falsifiers: calls remain, no useful reader improvement, or adverse other cases.
No cross-epoch multiplication, missing-as-pass guard, or promotion from this
exploratory family. C3 did not establish 5% timing equivalence. Fresh normal
builds against f0772c8 and complete encoding/read plus bulk-consumer costs
remain required before adopting the format or making a qualified speed claim.
