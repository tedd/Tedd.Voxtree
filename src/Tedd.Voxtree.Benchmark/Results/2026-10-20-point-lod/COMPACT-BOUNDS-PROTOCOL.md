# P32: compact-word checked byte interval

Prepared before implementation and new observations. Require terminal original
P31 point48/bulk96 families, its not_supported disposition and retained visited
LOD branch precheck. Integration branch main; production stays f0772c8. Control
is complete P31 compact-leaf13-source, unpromoted. No terminal-validator,
return-value, encoder, layout, ownership or public API change is combined.

Registry A03/R compiler bounds-proof cues; retain parent M05/M17/A09/A12 coverage.
The actual UInt32/UInt16 LOD fallthrough contains an index-count check, explicit
offset/remaining-byte checks and a separate Slice(offset,2) bound before one
word load. Test only the byte-range proof and load, retaining the index check,
coordinate/error order, value/LOD outputs, mask and invalid-LOD handling.

Replace the byte predicate `(uint)offset > (uint)length || length-offset < 2`
with `length < 2 || (uint)offset > (uint)(length-2)`. For every nonnegative span
length, both accept exactly offset in [0,length-2]. The old short-circuit first
guard prevents subtraction on negative/out-of-range offsets. The new first
guard handles lengths0/1 before subtraction; the unsigned second comparison
rejects negative offsets. This algebra does not rely on coordinate validation
or immutable borrowed bytes. Retain the independent voxel-index predicate.

Only after the complete byte interval is proven, load exactly two bytes via
Unsafe.ReadUnaligned<ushort> from the span reference plus offset. No raw pointer,
pin, widened/speculative load, unchecked data-derived offset or skipped LOD
validation is introduced. Explicitly reverse on big-endian targets, preserving
the little-endian wire contract. Span lifetime and ownership remain unchanged.
Do not change the one-cell validator or any other TryReadWord consumer policy.

Before timing: independent arithmetic equivalence oracle (all short spans and
offset boundaries, extreme Int32 values); isolated internal exact/short/odd/
unaligned-buffer checks if practical; all original CompactLeafTests and public
regressions on .NET8/10/11 plus .NET10 HW-off. Preserve all exact R/published
fallback bytes, full writer capacity outcomes, borrowed mutation and exception
ordering. Full1286-chunk/42139648-cell release semantic census with exact P31
bytes. Point48/bulk96 semantic checks. Review the one-file source delta and
complete compiled arms. Actual optimized owned/span Get/LOD callers for both
widths must show the guarded load and removal of the extra slice check. If the
compiler already eliminates the intended checks, stop before quiet timings.

Freeze new point/bulk fixture versions17 with unchanged caller/checksum bodies
and hashes. Do not pool P31 version16 or earlier records. .NET10.0.13 x64,
ordinary tiering/PGO, affinity4, quiet profile and three-second primes. Shared
host admission covers prerequisites and dependent windows; controllers acquire
Global\Tedd.DotNetLab.Measurement.v1 for timed operations. Preserve first errors
and accepted operation IDs; no replacement/restarted families or source changes.

First screen: all48 point cases, four paired blocks/two warmups, same bounded-
lifecycle operation counts as P31,120seconds/case, seed20261105. This fixed
exploratory rejection stage requires both dominant UInt32 owned/span LOD point
estimates>=1.10, the other six dominant point estimates>=1/1.05 and all40 other
time guard estimates>=1/1.10. Retain every case even after an early miss; no
inferential claim or source adoption from four same-process pairs.

Only if that complete stage passes, execute a separately frozen new48-case
point family (12pairs/four warmups,seed20261106) and all96 bulk cases (12pairs/
four warmups,seed20261107) on unchanged source. Require both UInt32 LOD primaries
>=1.10, all46 other point and all96 bulk time guards within1.05 cost. These are
prospective stages with separate identities; do not pool the first-stage data
or add samples after results. Report all allocation observations and model flags;
all40 steady point-read cases must observe zero allocation. Encoded and lookup
payloads must remain exactly P31; this does not qualify P31's release allocation
guard or waive any prior failed criterion.

Passing exploratory estimates remain supported-awaiting-confirmation only.
P31's unresolved format/API guards are not erased by choosing it as a control.
Fresh direct-release normal builds must still establish all eight10x adjusted
point bounds, qualified construction/query/fallback/memory guards and the full
public API objective. Do not multiply ratios or publish from these screens.
