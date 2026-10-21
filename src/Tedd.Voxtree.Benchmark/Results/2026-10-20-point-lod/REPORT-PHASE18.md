# Compact checked-read prerequisites

Integration branch main, starting commit f2fd8d5. Production remains f0772c8 /
NuGet 2.0.28. P32 hypothesis hyp-c9d70e07404c4522816cef68dad9458a tests one
private reader change on complete, unpromoted P31. No validator, format,
ownership, field, encoder or public API change is combined. The full public
method 10x objective remains active.

The retained P31 precheck identifies the actual UInt32/UInt16 owned LOD
fallthrough via the emitted "lod" dispatch and IG10 loop. IG14 contains
voxel-index bounds, explicit byte-offset/remaining-length checks and an
additional slice check before the word load. Calls on other operation/error
branches are not substituted for this path. This follows the RTree disassembly
study's distinction between an emitted operation, caller changes and complete
measured benefit. Registry R13 (surviving range checks) is the direct mapping;
A03 and parent representation coverage remain relevant. No hardware cost share
is inferred from instruction counts.

For nonnegative span length L, the old byte predicate accepts exactly offsets
in [0,L-2]. The candidate checks L>=2 and unsigned offset<=L-2, then loads
exactly two bytes with a managed byref and Unsafe.ReadUnaligned<ushort>.
The voxel-index guard and stored-LOD check remain. Big-endian targets explicitly
reverse the loaded word. The byte interval proof is independent of coordinate
validation, header contents and borrowed-buffer immutability. No widened,
speculative or unchecked data-derived access is introduced. Adoption still
requires a measured benefit sufficient to justify the lower-level read.

The one-file source review matches every candidate snapshot and each complete
P31 control. New fixture version17 changes only version strings; registered
caller/checksum bodies and input metadata remain identical. Distinct test-source
namespaces separate published release semantic controls from P31 private-reader
controls, avoiding replacement of the independent byte oracle with a prototype.

Framework suites pass 413/414/415 tests on .NET8/10/11, plus414 on .NET10 with
hardware intrinsics disabled. Added tests compare both actual private readers
against a byte oracle across aligned/odd/short spans, header/index extremes,
levels0/3/6/8 and boundary capacities. A separate arithmetic oracle checks the
interval predicates against widened mathematical bounds. Original mutation,
exception, generic-bit and canonical-format checks remain.

All48 point and96 bulk semantic cases pass. The writer oracle again passes
378 cases,16,178,022 cells and2,920 capacities. The full immutable-world census
checks all1286 chunks/42139648 cells with published release semantic/fallback
controls and an aliased exact P31 byte witness. Every row, encoding length,
selection and lookup-sharing payload equals P31. No new memory claim follows.

Eight isolated source-bound native captures index108 optimized listings.
The eight complete final Tier1 candidate owned/span Get/LOD callers contain
the combined remaining-byte interval comparison and exact word load, without
the previous additional slice check. Their index and LOD checks remain.
Selected native bytes/fixed rsp reservations are retained per caller; for
example UInt32 owned LOD is3718bytes/224bytes and UInt16 owned LOD2838/200.
These are whole multi-operation callers, not total stack use, dynamic cost
fractions or exact quiet-code identities. Native size alone does not establish
efficacy, and other operation paths can grow despite the local check removal.

Phase18 preserves prerequisites only:2,263,045bytes, SHA256
f4c28017b9d0749863d18ab170718c16c306ec07d736f89e696c2dcdd57e4c54,
528paths,331unique blobs,one catalog,zero metric rows. Full CRC, blob hashes,
lengths, unique maps, catalog schema and required source/native/corpus records
verify. The source/measurement dependencies are frozen before timing.

Next: the preregistered48-case rejection stage, four same-process pairs/two
warmups, seed20261105, original bounded-lifecycle operations. Keep the qualified
analysis policy's minimum10 blocks; resulting insufficient-independent-evidence
flags remain, and only descriptive estimates drive this rejection decision.
Both dominant UInt32 LOD estimates must reach1.10, six other dominant points
must stay within1.05 cost and40 other guards within1.10. All48 cases run even
after a miss. Only a complete pass selects the separate full point48/bulk96
families with their already frozen budgets/seeds. No source adoption or
direct-release10x inference follows from either stage alone.

Subsequent phase19 completes and rejects the original four-pair stage. Its
conditional full families are not selected; see REPORT-PHASE19.

The active workspace D:\Workspaces\AI\voxtree-point-lod-20261020 remains needed.
No temporary worktree or branch was created.
