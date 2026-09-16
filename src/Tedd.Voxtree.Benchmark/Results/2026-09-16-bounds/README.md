# Bounds-check and managed-reference experiments — 2026-09-16

These measurements follow the [access-pattern experiments](../2026-09-16-access/README.md). The starting point includes that work's SIMD filters and compiled point lookup. It is not the unmodified Git HEAD.

## Decisions

- Cache the outer-world node span once per traversal in both `OctreeWorld` implementations. Keep all index bounds checks and the existing synchronization.
- Retain checked compiled-node access. Replacing it with `Unsafe.Add(ref ...)` removed checks but did not produce a consistent throughput improvement.
- Retain checked linear/Morton conversion. Prevalidated row slices and unchecked references both had regressions.
- Keep linear scans expressed over a local array/span and its length. The JIT already removes checks in this form; unchecked arithmetic is unnecessary merely to obtain a check-free loop.
- The SIMD filter introduced in the preceding experiment already uses managed references and bounds-proven vector loads. It needs no additional unsafe rewrite.

## Method and scope

BenchmarkDotNet 0.16.0-preview.1; Ryzen 9 5950X; Windows 11; .NET 10.0.12 and .NET 11 preview. Complete host/runtime identifiers, uncertainty, code size and allocation columns are in each raw report. No benchmarks ran concurrently with builds/tests from this task.

The initial screening used one launch, three warmups and five 200 ms iterations. The production comparison used two launches, five warmups and ten 300 ms iterations. Several screening cases had substantial variance; small mean differences are not treated as improvements.

Traversal setup checks every voxel against the source, not just the timed query sample. Both traversal patterns use 1,024 queries per invocation at depth five. Sequential samples cover the first 1,024 cells; random samples are deterministic. These are warm working-set measurements, not an exhaustive cache/NUMA study. Conversion candidates verify their complete output against the production converter.

`CheckedLookupBaseline` freezes the previous production access path. `UncheckedLookupCandidate` reproduces its layout and validation, replacing only compiled-node reads with managed-reference arithmetic. Reflection is confined to benchmark setup to share an already validated private index; production uses no reflection.

## Linear scans

| Full-array scan | Repeated field access | Local array reference | Time reduction |
| --- | ---: | ---: | ---: |
| 4,109 UInt32 values | 2.653 µs | 1.531 µs | 42% |
| 32,781 UInt32 values | 20.211 µs | 11.330 µs | 44% |

The array has `Count + 13` elements. Full-array methods process the entire array; prefix methods process `Count`. Compare the full-array pair to each other and prefix methods to each other, rather than treating all printed ratios as equal workloads.

The .NET 10 disassembly shows:
- `FieldLength`: 64 bytes, including an element bounds check inside the loop.
- `LocalLength`: 30 bytes; pointer increment, accumulation and loop control, with no per-element range check.
- `CheckedPrefix`: an upfront count check plus a JIT-generated fast loop without per-element checks; a checked fallback remains in the emitted code.
- `SlicedPrefix`: one validated slice, followed by a check-free loop.
- `RefPrefix`: no consistent advantage over the safe forms.

The relevant mechanism is giving the JIT a stable buffer and a provable range. A local reference does not itself prove a data-dependent tree index is valid. Likewise, a local `List<T>` reference does not establish that its mutable count and backing storage remain unchanged.

## Compiled point lookup

The same .NET 10 confirmation job compared the frozen checked implementation with an experimental unchecked production implementation:

| Pattern / query | Checked | Managed-reference arithmetic | Ratio |
| --- | ---: | ---: | ---: |
| Sparse / sequential | 8.875 ns | 8.490 ns | 0.96 |
| Sparse / random | 8.192 ns | 8.408 ns | 1.03 |
| Clustered / sequential | 3.347 ns | 3.279 ns | 0.98 |
| Clustered / random | 3.746 ns | 3.736 ns | 1.00 |

Differences overlap uncertainty and include a regression. No unchecked production access is retained. These are comparisons between compiled indexes; the much larger gain from avoiding encoded-tree decoding was measured separately in the preceding report.

The .NET 11 confirmation likewise showed no consistent gain: sparse random reads were 7.446 ns checked versus 8.298 ns unchecked; the other pairs were approximately equal, with particularly high variance in clustered random reads.

A nine-word node slice was also tested. Its disassembly retained the child-index check in addition to slice validation, and its timings showed no consistent advantage.

## World traversal

`Find` now obtains `_nodes.Span` once when the root is a branch, then traverses that local span. Empty/unloaded collapsed roots still return without acquiring a span. Each node index remains checked, and read/write locks remain unchanged. The generic implementation uses the same transformation.

Two-launch .NET 10 runs, each using five warmups and ten 300 ms iterations:

| Operation | Original span access | Cached local span | Change |
| --- | ---: | ---: | ---: |
| Read each | 41.235 ns | 39.399 ns | 4.5% lower |
| Read batch | 31.143 ns | 31.693 ns | 1.8% higher |
| Retained chunk control | 3.068 ns | 3.184 ns | 3.8% higher |
| Write each | 42.633 ns | 38.800 ns | 9.0% lower |
| Write batch | 31.548 ns | 24.428 ns | 22.6% lower |

The write improvement is the reason for retaining this change. Small read differences, including the unchanged retained-chunk control, indicate measurement drift/noise rather than a general read-speed claim. These workloads replace one existing chunk and traverse seven outer levels; the numbers do not characterize lock contention or arbitrary world mutations.

## Morton conversion

At 32³ UInt32 values, unchecked references took 29.82 µs versus 27.38 µs for the checked linear-to-Morton converter, and 36.88 µs versus 28.58 µs in the reverse direction. A small 8³ linear-to-Morton case improved, but that did not justify a broadly applied unchecked implementation. Row slicing also traded improvements for regressions. Both remain benchmark-only candidates.

Conversion candidates are UInt32 prototypes with input validation; their method shapes differ from the generic production helper. This is additional reason not to adopt the isolated small-block win without further evidence.

## Validation

All 783 tests passed: 260 on .NET 8 hosting the .NET Standard asset, 261 on .NET 10, and 262 on .NET 11. The benchmark project also builds for all three hosts with zero errors; its 12 warnings are in the unchanged archived Morton baseline. The five runs executed 82 benchmark cases, including the production checks and parity-checked candidates. No benchmark reported managed allocations in the timed operations.

The final world implementation was also measured on .NET 11: 35.255 ns per individual read, 27.917 ns per batched read, 32.767 ns per replacement write and 22.504 ns per batched replacement write. There is no paired .NET 11 world baseline in this experiment, so these results establish the measured final performance, not a claimed .NET 11 speedup. Generic world correctness is covered by the test suite; its performance was not separately measured.

## Reference lifetime

The two requested articles supply the hypotheses:
- [Faster C# array access](https://blog.tedd.no/2020/06/01/faster-c-array-access/): local buffers and range proofs can enable bounds-check elimination.
- [Unsafe reference arithmetic in .NET](https://blog.tedd.no/2022/03/07/unsafe-reference-arithmetic-in-net/): investigate reference/pointer arithmetic and generated code.

Use the managed-reference overload `Unsafe.Add(ref first, offset)` when working with movable managed storage. It does not require a C# `unsafe` block. Converting to `void*` with `Unsafe.AsPointer` is different: the GC does not track that pointer, and the backing object must be pinned while it is used. [Microsoft: Unsafe.AsPointer](https://learn.microsoft.com/en-us/dotnet/api/system.runtime.compilerservices.unsafe.aspointer?view=net-10.0), [Unsafe.Add](https://learn.microsoft.com/en-us/dotnet/api/system.runtime.compilerservices.unsafe.add?view=net-10.0).

The library retains `AllowUnsafeBlocks=false`. No pinning, unmanaged allocation, pointer fields or changes to the persisted format were introduced by this follow-up.

## Evidence and reproduction

Run from `src/Tedd.Voxtree.Benchmark`, because an unrelated ignored duplicate project elsewhere in the workspace can confuse BenchmarkDotNet's project discovery from the repository root.

```powershell
dotnet run -c Release -f net10.0 -- --filter '*AccessBounds*' --job short --warmupCount 3 --iterationCount 5 --iterationTime 200
dotnet run -c Release -f net10.0 -- --filter '*AccessBoundsTraversal.CheckedProduction*' '*AccessBoundsTraversal.UncheckedProduction*' --job short --warmupCount 5 --iterationCount 10 --iterationTime 300 --launchCount 2
dotnet run -c Release -f net11.0 -- --filter '*AccessBoundsTraversal.CheckedProduction*' '*AccessBoundsTraversal.UncheckedProduction*' '*WorldSynchronization*' --job short --warmupCount 3 --iterationCount 5 --iterationTime 200
dotnet test ../Tedd.Voxtree.Tests -c Release
```

Raw run directories:
- `bounds-candidates`: initial .NET 10 loop and traversal screening, checked production lookup.
- `bounds-conversion-before`: conversion candidates and original world traversal.
- `bounds-production-candidate`: experimental unchecked production lookup and cached world span.
- `bounds-confirm`: unchecked production lookup versus frozen checked control; world traversal restored to its original code for confirmation.
- `bounds-net11`: final checked production library; explicit checked/unchecked benchmark candidates and cached world span.

In historical reports, `Production` means the library state described above. The final benchmark source exposes the rejected lookup as `UncheckedProduction`, so it remains reproducible without modifying production.

The `source-before` and `source-candidate` snapshots preserve the relevant experimental library versions as text. `source-hashes.json` identifies the final library and benchmark sources.
