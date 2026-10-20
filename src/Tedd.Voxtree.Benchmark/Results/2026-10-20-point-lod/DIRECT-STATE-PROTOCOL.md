# P13: direct value/LOD words within an explicit memory tradeoff

The user permits memory-format changes and prioritizes steady-state point/LOD
access. P13 explores the remaining dependent palette lookup rather than treating
incremental packed-index gains as a 10x result. Control is exact P10b in a new
source fork; retain every earlier source and result. This changes private
compiled storage only and keeps all public APIs and serialized formats intact.

Store one logical UInt64 (low 32 bits value, high 32 bits stored LOD) per voxel.
One validated coordinate index addresses both outputs without an index palette.
Use a UInt32 backing array viewed as UInt64 during both construction and reads;
logical-word writes/reads preserve native byte-order independence. Start with
safe Span indexing, not unchecked loads. No extra object field is introduced.

This is deliberately a different memory tradeoff: for mixed trees at depths
3..6, select the direct grid only if its 8*N-byte payload is <=4*the original
nodeCount*36-byte payload. Fully expanded/dense/uniform representations keep
their existing paths. Sparse/coarse trees that fail the bound retain P10b's
state grid or original node layout. For the selected dominant terrain sample,
the prospective direct payload is 262,144 bytes versus the old 66,168-byte node
payload (about 3.96x). Large-object-heap placement is expected under the default
threshold and must be verified on the actual runtime. Constructor allocation/GC,
retention and complete read lifecycle are mandatory costs. Assess the measured
tradeoff against the user's steady-state priority before adoption.

Prediction: removing the palette dependency and byte-index extraction should
reduce the measured read's dependent loads and code. Constructor state
collection also disappears; full grid materialization writes more bytes. Neither
prediction establishes elapsed-time gain. Inspect actual default-tiered x64
code, bounds checks, fixed stack reservation and large-object effects.

Semantic gates include every voxel and exact LOD across all four terrain
strata; arbitrary full-width values and >256 distinct joint states; coarse/fine
boundaries; source rebuild, borrowed-slice reuse and concurrent readers; invalid
coordinates; maximum supported depth fallback; sparse/uniform/dense/full guards.
Explicitly update only representation-specific assertions in isolated tests.

After correctness, use the same frozen 16 compiled real-terrain scenarios,
version-6 callers, quiet 12-pair screening, family 16, 3-second primes and
bounded-lifecycle budget. Compare to exact P10b, without pooling prior ratios or
claiming multiplicative gains. A promising result requires direct fresh
confirmation against the original API baseline, full caller/fallback/lifecycle
coverage and an explicit decision on the measured memory tradeoff. Failed host
precision controls still prevent a 5% guard claim. The all-public-method 10x
objective remains unverified.

The initial P13 build stopped before validation or timing: C# selected the
ReadOnlySpan overload of MemoryMarshal.Cast for an array argument, which could
not be passed to the writable materialization routine. Preserve that failed
build. P13b explicitly passes result.AsSpan(), in a new source fork/label; this
is a compile-time overload correction with no prior timing observations.
