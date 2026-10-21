# P23: count token lengths in the measurement-only writer

Control: f0772c8, copied independently from Git. Do not combine P22 or packed
formats. Registry A03/A09/C04: native writer loops and their repeated position/
limit/mode checks survive even when the destination is measurement-only. No
dynamic time share or hardware cause is established by those listings.

One intervention, .NET 10+: measurement-only WriteVarUInt/WriteValue compute
canonical base-128 token lengths from bit lengths and advance once. Preserve
the exact partial position on a capacity failure. Leave ordinary writes, byte
values, node traversal, leaf handling, Morton, format/storage selection, fields,
ownership and older-runtime fallback unchanged. Generic unsigned storage uses
its existing exact-width bit representation, including 128-bit cells.

Prediction: all six nonuniform real-fixture GetRequiredSize callers (UInt32/
UInt16; mixed-u16/u7/u8-air) take at least 10% less time than release. Every
other constructor/build/callerbuild/trybuild/required and buildread case must
have no >5% adverse estimate. Retain all other unchanged consumer effects.
Fewer writer iterations alone are insufficient; a primary or mandatory guard
failure prevents selection.

Before timing: tests on .NET 8/10/11, .NET 10 intrinsics off, all 48 point/88
bulk oracles and the release differential BuilderOracle (252 synthetic cases,
all storage widths/depths 0..5, byte parity, sizes, failed-buffer mutations,
copy and complete LOD comparison). Add varint bit-boundary tests, including
128-bit high words, uniform/tree/dense decisions and linear/Morton byte parity.
Inspect the exact bulk bundle's required/callerbuild native code, recording
actual tiers and frame subtractions without equating diagnostic PGO to timing.

Freeze original 88 version-13 bulk cases, bounded-consumer budget: .NET 10.0.13
x64, ordinary tiering/PGO, affinity 4, quiet-validation, 3-second per-arm primes,
twelve same-process paired blocks, four warmups, seed 20261022, 120 seconds per
plan. Sixteen construction/size/FromEncoded operations, 64 copy/validation/
count/miss, two build-plus-65,536-read operations; family 88, existing 5% policy.
No independent-block, allocation-equivalence, adoption or universal 10x claim.
Retain every failure/adverse case; no exclusions, extra samples, replacements,
old-family resumes or cross-epoch multiplication.

Use p23point/p23bulk/p23-hypothesis, p23-release-source and sizing-writer-source
identities. External phases hold the actual shared measurement mutex through
Host-Lock.ps1; timed controllers acquire it themselves. Preserve the prospective
protocol, exact source/control/bundle bindings, tests, raw observations, joined
shutdown, code and complete audit. The original P18 confirmation stays failed
and unlocalized. Any new fault reproduction is diagnostic, not replacement data.
Full immutable corpus validation and fresh ordinary callers precede adoption.
