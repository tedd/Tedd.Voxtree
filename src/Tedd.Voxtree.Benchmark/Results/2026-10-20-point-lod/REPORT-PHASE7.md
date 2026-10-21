# Measurement-only writer and exception observability

Integration branch main, starting research commit 033da93. Production library
source remains f0772c8. The public API objective remains active; no prototype is
adopted or combined with P22 or packed formats.

P23, hypothesis hyp-9c8409d52de24704b00572d63d5627c9, tests A03/A09/C04:
calculate canonical token lengths and advance once in measurement-only writers,
instead of per-byte position/limit/mode work. Ordinary writes and older-runtime
fallback remain unchanged. Failed sizing writes retain the original partial
position. StorageInteger uses exact unsigned bit lengths, including 128 bits.
The prospective primary and complete guards are SIZING-WRITER-PROTOCOL.md.

Tests pass 397/398/399 on .NET 8/10/11, plus all 398 .NET 10 intrinsics-off
tests. Added cases cover each bit boundary of every storage width, zero and
uniform/sparse tree/dense selection, required size, actual writes and linear/
Morton parity. The external release oracle passes 252 synthetic cases,
1,572,858 cells including LODs and 1,879 destination capacities, retaining exact
bytes and failed TryBuild mutations. All 48 point oracles pass.

The frozen 88-case bulk family completed all 2,112 correct/quiescent records,
with joined target/controller shutdown. Target PID 157640, start ticks
639281398024602194. All six primary estimates miss the 10%-less-time threshold:

| GetRequiredSize input | UInt32 speedup | UInt16 speedup |
|---|---:|---:|
| mixed-u16-air | 0.998 | 1.104 |
| mixed-u7-air | 0.940 | 0.841 |
| mixed-u8-air | 1.004 | 0.980 |

Eleven of 42 mandatory guards are adverse beyond the frozen 5% estimate
threshold. All 88 effects remain in p23bulk-audit.json. These are exploratory
same-process blocks, not independent qualification. The hypothesis is revised
to not_supported with its original prediction and complete evidence retained.

The exact-bundle native probe emits LZCNT in each changed writer. UInt32
WriteVarUInt grows 140 to 166 bytes (fixed rsp subtraction 40 unchanged);
UInt16 WriteValue grows 205 to 263 bytes (56 to 64). The changed writer listings
also retain calls to WriteByte on the ordinary-write path; the controls inline
that work. Parent linear-subtree code sizes/frames remain 895/885 and 152+96/
136+64. Intrinsic work elimination therefore comes with changed code boundaries.
This isolated diagnostic history does not prove exact timed PGO, total stack,
hardware stalls or a causal share of any observed loss.

Full immutable-corpus validation passed all 1,286 chunks and 42,139,648 cells,
with exact release bytes for all three encoders, independent dense LOD checks,
owned/span/lookup/FromEncoded reads, copy, validation and Count/Any. Encoded plus
distinct UInt32 lookup payload remains 48,861,892 bytes. Result SHA-256:
15934c0d3aa1764408b8fe44591c1956bbdc32043730af6b8ee50a0ceccdaaf2.
The copied decoder retains its three nullable warnings and no build errors.

The census closure was already queued when its on-disk protocol filename was
edited. Its actual frozen p23-census-protocol.txt retains P22/p22bulk labels.
Do not replace that text or claim the intended P23-named text was frozen.
p23-census-binding-audit.json verifies that the instructions are identical
after label substitution, while the actual project, RELEASE_BUILDER_CENSUS
define, selected DLL hash and result all bind P23. The performance protocol
and its completed family are unaffected. The corrected closure is retained for
future use, separately from what this execution actually loaded.

The original P18 controller log was searched for retained exception details;
the generic failure remains unlocalized. The 3,311,022-byte log has no matches
for the bounded exception/error/failed text search. Audit-ConfirmationDiagnostics.py binds
that negative evidence to the original terminal record/log hash and actual
9c23369 source. It neither resumes the family nor supplies replacement samples.

ExceptionCapture.cs.txt separately passed its EventPipe observer self-test on
its own synthetic child, PID 20216/start ticks 639281407308498539. Attachment
precedes the fixed caught IOException marker. Exactly one matching exception
was captured, zero events reported lost, and the child joined with exit zero.
The self-test builds without warnings/errors. Raw trace SHA-256 is
1f9c05c31aa2731114c5397573bac200caac81086846fceb3280d1c6caa500a6.
This is not an original-fault reproduction or target performance measurement;
it supplies a tested observer primitive for a separate future diagnostic study.
No observer was attached to the quiet target or installed shared controller.

The host helper now optionally hashes a queued driver's source and refuses
execution if its file changes before admission. Closing/self-test drivers use
that guard. A real two-process integration proof admits unchanged source and
rejects mutated source before its body; both children join with exit zero.
queued-driver-proof.zip preserves all nine raw/source entries with lengths,
hashes and CRC verified. This post-experiment tooling proof is separate from
the immutable phase-seven archive and produces no performance samples.

Task workspace D:\Workspaces\AI\voxtree-point-lod-20261020 remains necessary
for active immutable inputs and source/binary/control evidence. No worktree or
alternate branch was created. Unrelated docs/articles remains untouched.

The closed phase-seven archive retains 40,065 logical paths as 33,260 unique
blobs, 38 catalogs and 1,050 cumulative metric rows. Every blob length/hash,
mapping, CRC, catalog table and required evidence passed verification. Observer
source/entry/trace/marker bindings also passed. Archive size 70,771,634 bytes,
SHA-256 d6c9e57201f7de83c46abeecf749e94a9824bee7b1c99c416ec4fec2fd8e52f6.
The companion verification record lists required paths; cumulative rows are
not independent experiments. Source and performance evidence are unchanged
by the later census-label audit and queued-driver proof.
