# P16: expose owned and borrowed LOD readers to the actual caller

P15's complete passing semantic/footprint work is the control. Its first
exploratory dominant-stratum value screens estimate about 12x, whereas the
owned LOD screens estimate about 3..4x. This discrepancy is a bottleneck clue,
not a hardware or forwarding-cost attribution. Preserve the complete P15
family; no screen is stopped, selected away or converted into confirmation.

Hypothesis C18/M25: the forwarding owned reader and the borrowed Get overload
returning LOD do not carry the inlining hint already present on owned value
Get. Expose these four overloads (legacy owned/span and generic owned/span)
through MethodImplOptions.AggressiveInlining. Change no executable IL, checks,
exception order, stored format, layout, data ownership or query algorithm.
Generated code must show whether the actual hot caller incorporates the reader;
an attribute alone does not establish inlining or a speedup.

Prepare a separate source fork from the frozen P15 source, then run its same
48 independent value/LOD fixture oracles and full .NET 8/10/11 regression suite.
Expected serialized bytes and footprint are identical to P15. Inspect the
actual BeforeBatchOwned/AfterBatchOwned and borrowed callers with default
tiering/PGO on the dominant UInt32 owned LOD case, including reader listings,
native bytes and fixed stack reservations.

Freeze the full 48-case version-12 family before P16 observations. Use the
same 12 paired-block bounded-lifecycle screen policy as P15, four warmups,
seed 20261022, family 48, runtime 10.0.13, affinity 4, three-second primes,
120-second limit, no exclusions. Control is P15, not f0772c8. Do not multiply
ratios across epochs. CPU-heavy prerequisites wait for central admission;
DotNetLab owns timed admission. C3's unresolved 5% time equivalence remains a
limitation, so neither this screen nor code evidence permits promotion.

Falsifier: no relevant inlining/code difference, or no material LOD improvement
in the actual caller; adverse value/compiled/sparse/uniform cases remain visible.
Complete encoding-plus-read and bulk-consumer costs remain mandatory before
adopting the combined P15/P16 representation.
