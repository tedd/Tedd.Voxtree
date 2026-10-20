# Complete packed-leaf corpus validation

Reuse all six hash-verified files in the immutable Forcecraft snapshot s1.
No live world files, application startup, databases or network writes occur.
Run the retained offline region reader against a fresh p18census bundle with
P18 in the primary namespace and f0772c8 in Snapshot. Retain per-chunk records,
including duplicates. The earlier p18 attempt used P17 as its Snapshot control
and stopped after eleven chunks at the released-format eligibility assertion.
Its partial records remain evidence; they do not establish a candidate failure.
Expected corpus: 1,286 chunks, 686 unique dense arrays, 32 cubed cells each.

For every chunk, derive maximal aligned uniform cube LOD independently from
the original dense values. Released dense storage, if encountered, retains
its documented LOD zero semantics. Check released UInt32/UInt16/generic UInt32
against that oracle, then all candidate owned/span value and LOD reads,
compiled UInt32 lookup and three FromEncoded results. Validate complete
structures and dense copies; check CountMatches/Any for zero, maximum and
65535, including misses. No favorable selection or cached duplicate exclusion.

Independently predict format eligibility from released tree kind, exact
encoded-length threshold including header, and reserved-bit limits. Confirm
ineligible encodings retain identical bytes. Record all three encoded sizes,
UInt32 lookup payload and source-array sharing. Payload counts exclude object
headers and do not establish process retention or allocation. This diagnostic
does not measure latency, energy, access frequency or independent performance
effects. No code adoption follows from correctness alone.

Hold the shared host admission mutex across build and census. Preserve build
failures, partial CSV and logs without overwriting a label. Recheck every input
file hash against s1 before execution and before/after each scanner read.
