# Additional P22 correctness gate

After the frozen exploratory family joins, run the existing offline census
against the exact p22bulk bundle: primary P22, Snapshot f0772c8. This is added
semantic coverage, not additional timing samples or a change to the frozen
performance primary/guards. RELEASE_BUILDER_CENSUS selects exact byte identity
instead of the incompatible packed-format eligibility oracle. All independent
dense/LOD checks, owned/span/lookup/FromEncoded reads, copy, full validation,
Count/Any and original row/hash identity remain required for every chunk.

Read only the hash-verified forcecraft-snapshot-s1 copies. Decode every one of
the existing 1,286 chunks, retaining duplicates, with the original region/CRC/
palette/LZ4 decoder. Check all 42,139,648 cells, all three encoded APIs and exact
release bytes. Payloads and lookup payloads must match release; this census
claims no allocation, timing, access frequency, atomic-world snapshot or native
PGO identity. External execution holds the shared measurement mutex and retains
its actual source/compiler define and selected bundle hashes. Stop on failure;
retain partial output and do not substitute a different source or oracle.
