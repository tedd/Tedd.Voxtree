# UInt32 value-only reader precheck

Diagnostic only, after original P27 closure. Inspect-P29ReadPath uses the exact
hash-bound p27setup bundle and two previously missing native scenarios: dominant
UInt32 owned Get and span Get. Both processes complete and join under shared
host admission. There is no candidate implementation or new timing observation.

The selected owned final Tier1 AfterBatchOwned body is 3,349 bytes with a fixed
rsp subtraction of 232. Its `get` string check reaches IG06; the palette path
in IG07..IG12 already inlines snapshot access, coordinate checks, storage-kind
dispatch, byte-index and state reads, LOD validation and result consumption.
There is no unresolved Get/TryReadState call to remove on this valid path.

IG08 checks storage kinds 1, 2 and 3 in that order. IG09 performs the checked
index/table loads, writes the low value to [rsp+0xC0], writes the discarded LOD
to [rsp+0xB8] and sets a success flag. IG10 tests the flag; IG11 reloads the
value before IG12 consumes it. The full final span caller is 3,950 bytes with
subtraction 216. The index retains the distinct OSR versions as well; their
849/786 and 850/787-byte bodies are not substituted for final Tier1 bodies.

A possible next intervention is a value-returning palette-state reader for
throwing Get paths, preserving boolean/out TryGet paths. An invalid-word
sentinel can be distinct from every legal full-value state because valid LOD
is bounded by depth, while an all-one word has an invalid LOD. This requires a
separate prospective protocol and hypothesis before implementation, including
all raw value bits, malformed reads, output/exception order, generic widths,
borrowed mutation checks and the unchanged complete caller. It is not yet a
selected implementation or an asserted speedup. Code size/stack reservations
and temporary stores alone do not establish a causal cost share or PMU event.

Task-local evidence to preserve in the next supplement:

- p29-precheck-UInt32-owned-get.asm and its identity/shutdown/output records;
  SHA-256 f8aec2ca7e2b4fb00dffd3b2d419d7efc4579853ddc99547984a78f84d48a36a.
- p29-precheck-UInt32-span-get.asm and its corresponding process records.
- native-summary-p29-read-precheck.json, indexing all 24 optimized versions.

These diagnostics have their own JIT/PGO history. They do not identify exact
quiet-run code or fill any portion of a future performance budget. P27 remains
not_supported and production source remains the released f0772c8.
