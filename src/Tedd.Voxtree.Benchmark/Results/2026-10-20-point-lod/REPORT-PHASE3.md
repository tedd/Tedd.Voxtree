# Mixed-LOD layouts and measurement admission

Integration branch: main. Full public-method 10x objective remains active.
The layouts below are isolated experiments, not adopted production changes.
Runtime: x64 CoreCLR 10.0.13, ordinary tiering/PGO, Ryzen 9 5950X, affinity 4.
The verified Forcecraft corpus and its four deterministic strata are unchanged.

## Completed compiled-lookup screens

Each row completed the same frozen 16-case family: Get, Get with LOD,
CreateLookup, and CreateLookup plus 65,536 reads over four terrain strata.
Twelve paired blocks share a process and are explicitly non-independent.
Budget: 33,554,432 reads, 256 constructors, or 16 complete lifecycle operations
per batch. Entries below describe only the dominant mixed-u16-air stratum.
Ratios are baseline/candidate elapsed time; below one is an adverse estimate.
Controls differ by row. Do not multiply estimates across these separate epochs.

| Candidate | Actual control | Get | Get + LOD | CreateLookup | Compile + 65,536 reads |
|---|---|---:|---:|---:|---:|
| P7 bounded | f0772c8 | 1.382 | 1.258 | 0.406 | 0.956 |
| P7w packed words | P7 | 1.255 | 1.226 | 0.921 | 1.038 |
| P9 joint value/LOD states | P7w | 1.349 | 1.256 | 0.949 | 1.114 |
| P10b byte state grid | P9 | 1.132 | 1.057 | 1.098 | 1.093 |
| P13b direct UInt64 states | P10b | 0.971 | 1.049 | 1.406 | 1.286 |

Every complete family, including sparse and empty adverse estimates, remains
in raw evidence. These screens establish neither independent confirmation nor
5% regression equivalence. The earlier failed 120-second P7 plan is preserved
separately; its partial constructor observations do not replace a complete
family. P13's first build failed on a ReadOnlySpan/Span overload selection;
P13b explicitly passes AsSpan and has a distinct label.

P10a independently replaces the private ReadOnlyMemory field with the exact
byte-array storage that all internal callers actually supply, copying borrowed
spans as before. Its complete synthetic 16-case family includes full, sparse,
uniform and dense Get/LOD/create/lifecycle cases. Dense estimates were 1.386,
1.344, 1.141 and 1.325 respectively, with the same exploratory limitations.
Uniform and dense constructor observations consistently measured 48 -> 40
thread-allocated bytes; sparse 400 -> 392. Full expanded constructor records
also contain variable additional allocations, so an exact eight-byte delta is
not asserted for every full record. Field layout supports the smaller object;
latency guard qualification remains pending.

## Representation and generated code

P7 uses four-bit palette indices and four-bit LOD per aligned 2-cube. P7w packs
both into UInt32 words and keeps palette/storage in one array. P9 uses one
byte-sized index per voxel into up to 256 exact (value, LOD) states. P10b keeps
the byte grid as a byte array and the state pairs as UInt32 words. All preserve
complete UInt32 values, including uint.MaxValue; only bounded state counts are
eligible. Adverse state counts fall back to the original node index.

For the dominant sample, old node payload is 66,168 bytes, P7 is 18,488 and
P7w is 18,496. P13b's direct UInt64 grid is 262,144 bytes, approximately 3.96
times the original node payload. Its one-load source design did not improve
the screened Get estimate against P10b. Fewer dependent source loads therefore
do not establish a useful latency improvement or justify that memory cost.

Actual Tier1 GetPacked listings progress from 346 bytes (P7) to 203 (P7w), 113
(P9) and 93 (P10b). Their `sub rsp` reservations are 56, 40, 40 and 40 bytes.
P13b GetDirectState is 108 bytes with a 40-byte reservation. The P7 listing
contains the MemoryManager-capable ReadOnlyMemory.Span path; the word/array
representations remove it from this helper. These are bound helper listings,
not whole-call code size, total stack usage, PMU attribution or latency proof.

The caller audit validates resolved opcode operands rather than treating raw
metadata tokens as semantic identity. Its falsification tests distinguish
metadata reordering from changed called APIs/literals. P7w/P9 and P9/P10b have
eight matching canonical AfterBatch methods each; only five of eight raw IL
hashes match in each comparison. Future confirmation must state this distinction
and retain source/dependency bindings rather than assert false raw-IL identity.

## Correctness and current gate

Complete passing framework counts, ordered .NET 8 / 10 / 11:

| Candidate | Passed tests | Fixture oracles |
|---|---:|---:|
| P7b corrected fixture | 400 / 401 / 402 | 48 |
| P7w | 400 / 401 / 402 | 48 |
| P9b corrected payload assertion | 399 / 400 / 401 | 48 |
| P10a | 397 / 398 / 399 | 59 |
| P10b | 399 / 400 / 401 | 48 |
| P13b | 399 / 400 / 401 | 48 |
| P6b byte format | 398 / 399 / 400 | 51 |
| P15 packed leaf words | 404 / 405 / 406 | 48 |
| P16 public getter hints | 404 / 405 / 406 | 48 |
| P17 reader split | 404 / 405 / 406 | 48 |
| P18 private helper hints | 404 / 405 / 406 | 48 |

Initial fixture/assertion failures remain retained. P9's original near-full
assertion expected the old node payload and failed before its semantic loop;
P9b changes that exact private-payload expectation, with no library/binary
change. P6b retains small legacy encodings and tests all 256 byte values,
Morton conversion, full query/filter consumers, malformed headers, boundaries,
ownership and coarse-leaf exclusion. No Forcecraft sample is eligible for P6b;
it remains relevant to the full synthetic/public API objective.

The admission correction is committed as 661f85e; see HOST-ADMISSION.md.
DotNetLab already admitted timed runs through the actual central mutex. Earlier
external prerequisites used only the legacy locks. This distinction does not
prove a cause for timing variance. New external phases also wait for the central
slot, and controller-driven measurements retain controller ownership.

C2's oversized confirmation request was rejected before any fresh session.
C3 uses published limits and explicitly declares sixteen reads per logical
operation. Its frozen six-case, 144-session controls are audited separately;
raw ns/operation is ns/sixteen-read group. Do not pool this epoch with earlier
single-read observations or convert unresolved allocation models into passes.

P15 now investigates direct packed value/LOD words for existing owned/span
UInt16/UInt32 reads on mixed real terrain. It reserves four bits for exact LOD,
rejects values occupying those bits, retains legacy formats for ineligible
inputs, and bounds selection to avoid expanding sparse cases. Its payload can
be larger, while remaining within the existing dense maximum. Correctness,
actual corpus footprint and complete lifecycle evidence precede any adoption.

## C3 control result

The complete frozen budget produced 144 distinct process/start identities.
Every session was correct, quiescent, joined with exit code zero, used x64
10.0.13, and reported zero measured-thread allocation. No time contrast
established 5% equivalence. Two one-sided non-inferiority tests passed (owned
LOD and full compiled Get), but the complete guard regime did not qualify.
Allocation models retain their degenerate-variance limitations.

| Unchanged-source case | Candidate / baseline | Adjusted difference interval |
|---|---:|---:|
| Full owned Get | 1.017 | 0.931..1.112 |
| Full owned LOD | 0.943 | 0.862..1.033 |
| Full compiled Get | 0.985 | 0.935..1.038 |
| Sparse compiled Get | 0.927 | 0.811..1.058 |
| UInt64 long LOD | 0.961 | 0.831..1.111 |
| UInt128 long LOD | 1.015 | 0.877..1.175 |

Intervals have reported coverage 0.995833 for the fixed family of twelve
time/allocation contrasts. They are not proof of a frequency, SMT, scheduler,
cache or mutex defect. Raw ns/operation is per sixteen-read group; medians
reported as ns/read explicitly divide by sixteen. Earlier epochs are not pooled.

## P15 through P18

P15 changes eligible legacy/generic UInt32/UInt16 serialized trees to one word
per voxel, reserving four high bits for its exact leaf LOD. Every value must fit
the remaining bits. Only depths 3..6, existing tree storage, and sufficient
encoded density qualify. The dominant sample qualifies; the other three
retained samples keep their original bytes. Maximum caller-buffer capacity
remains the existing dense maximum. Old versions remain independently tested.

The dominant sample changes UInt32 encoded bytes 27,550 -> 131,074 and UInt16
27,551 -> 65,539. Owned lookup shares the new encoded array: its five diagnostic
constructor allocations are each 48 bytes versus 66,240 for the old node
index. This moves cost to original encoding; it does not establish a total
allocation reduction. Combined UInt32 encoded-plus-lookup payload changes
93,718 -> 131,074 bytes, approximately 40% more. The new UInt32 array was
observed in generation 2; UInt16 remained generation 0 in this diagnostic.

The following dominant-sample ratios are exploratory baseline/candidate time.
Each column has its own explicit control; do not multiply columns or present
them as a final result against f0772c8.

| Complete read | P15 vs f0772c8 | P17 vs P15 | P18 vs P17 |
|---|---:|---:|---:|
| UInt32 owned value | 12.057 | 1.135 | 0.948 |
| UInt16 owned value | 11.702 | 1.128 | 0.871 |
| UInt32 owned LOD | 4.166 | 1.563 | 1.378 |
| UInt16 owned LOD | 3.323 | 1.104 | 3.519 |
| UInt32 borrowed value | 12.196 | 1.169 | 0.940 |
| UInt16 borrowed value | 13.620 | 1.142 | 0.969 |
| UInt32 borrowed LOD | 7.658 | 1.707 | 1.092 |
| UInt16 borrowed LOD | 7.066 | 1.761 | 1.092 |

P15 and P16 completed 27 of 48 comparisons each before the uniform UInt16 owned
LOD plan ended tainted at its 120-second budget. Their failed executions retain
20 and 18 completed run records respectively. Operation IDs are
op-3e0978bc1a7d41e9bc8c2cd6cca0f6ec and op-5d763ab6976443ec8414afce50959a02;
execution IDs are exec-1579213396f54965af875b6eaff747b5 and
exec-08d2023a85ad4cb8a2a564ec2efc89e4. Original PIDs 106380/120592 and their
owned controllers were verified exited. Neither tainted target is resumed.
Several unchanged-format cases have adverse estimates; the missing 21 cases
in each family are not passed guards or complete results.

P16 adds four public getter inlining hints, with primary LOD estimates near one
against P15. Its relevant codec calls remain, caller code grows 3222 -> 3433
bytes and fixed rsp subtraction 296 -> 312. The individual hint intervention
is not selected. This does not establish that a hint is never useful in another
call graph.

P17 instead separates unchanged tree traversal from inlineable tagged dispatch,
using P15 source without P16 hints. P18 adds hints only to the two remaining
private ReadWord/Value helpers observed in actual P17 caller listings. Both
completed their new 48-case families: 2,097,152 reads uniformly, 256 constructors
or sixteen compile/read operations, with the same twelve-block policy. They do
not append observations to the failed plans. Target/controller exits are joined
and recorded. P18 has adverse value estimates and an adverse empty constructor
estimate (0.818), so its LOD result does not establish a complete candidate win.

P17's UInt32 dispatcher changes 798 -> 456 native bytes and fixed subtraction
104 -> 80; its owned caller changes 3222 -> 3787 bytes and subtraction 296 ->
224. Two private helper calls remain. In the subsequent UInt16 diagnostic,
P18 removes ReadWord/Value calls; caller bytes change 2888 -> 2764 while fixed
subtraction remains 200. Native listings are isolated diagnostics. The timing
screens accumulate earlier scenario/JIT/PGO history, so these snapshots do not
prove the exact timed body or a causal elapsed fraction. No PMU cause is claimed.

The metadata-token-resolving caller audit covers all four P15/P16/P17/P18
bundles and its falsification tests pass. Source/runtime/dependency bindings
remain required; canonical caller identity does not prove callee equivalence.
Each consecutive pair has eight matching resolved caller bodies, whereas only
five of eight raw IL hashes match. Never substitute a raw-hash identity claim.
Hypothesis registry crosswalk errors were corrected through retained revisions;
predictions, executable source and frozen timing budgets were not relabeled.

P15/P17/P18 dispositions remain inconclusive pending fresh primary-namespace
normal builds, complete build-plus-read and bulk/query consumer measurements,
actual full-corpus eligibility/footprint, and resolved guards. No production
library or package adoption follows from these exploratory estimates. The full
public-method 10x objective remains active.

## Retained checkpoint

`evidence-phase3.zip` contains 19,688 manifest entries, 26 read-only catalog
exports and the sources, binaries, failed executions and shutdown records.
`measurements-phase3.csv` contains 492 metric rows. Archive size is 52,268,987
bytes; SHA-256 is
`caa2add43d3f0e070a2289d6ec1dddc8048c44ebc4490c3eba38af07cde8e34b`.
CRC, unique names, every manifest byte count/hash, catalog schemas and required
control/failure/audit records were verified after all task workers exited.

The earlier unqualified P1/P3/P5 working-tree patch and its test are preserved
byte-for-byte in `Retained-P1-P3-P5`, with hashes and frozen-source matches.
The production library working tree now matches the committed release source.
No prototype is adopted or published. `NEXT-GATES.md` records remaining work;
the task workspace remains necessary for fresh confirmation and corpus checks.
