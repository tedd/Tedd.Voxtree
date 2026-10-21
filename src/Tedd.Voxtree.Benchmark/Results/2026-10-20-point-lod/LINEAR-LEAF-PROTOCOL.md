# P22: specialize the linear builder's bottom level

Control: released f0772c8, independently snapshotted from Git; no packed-format
or count prototype is combined. Registry A09/M25/C18. Retained builder native
code calls BuildLinearSubtree recursively even at level one and allocates eight
summary records. Static listings establish surviving work, not its time share.
RTree's disassembly/specialization studies motivate preserving complete caller
cost and unchanged representations rather than inferring benefit from code size.

One intervention: at linear level one, read the eight Z-first child values,
collapse if equal, otherwise emit mask 255 and their original canonical value
tokens directly. Keep the higher recursion, Morton implementation, sizing
policy, dense fallback, buffers, fields, ownership and wire versions unchanged.
No unsafe access, new ISA assumption, runtime setting, or speculative wider load.

Prediction: all ten dominant mixed-u16-air construction/build/callerbuild/
trybuild/required callers (UInt32 and UInt16) take at least 20% less time than
release. Every other construction/size and build-plus-read case must have no
greater than 5% adverse estimate. Retain unchanged consumer guards as well.
Failure of any primary or mandatory guard prevents selection. Smaller native
code or fewer recursive calls alone does not establish a useful speedup.

Before timing: repository tests on .NET 8/10/11 and .NET 10 intrinsics off;
leaf tests across all supported storage widths, uniform/nonuniform children,
varint boundaries, linear/Morton byte identity and destination capacity cases;
an external differential oracle against the exact release across depths 0..5,
including uniform, sparse-first/last, per-leaf and fragmented inputs. Check exact
owned/rebuild/caller/TryBuild bytes and sizing, short-buffer mutations and LODs.
Then all 88 existing version-13 bulk oracles and a native-only exact-bundle
required/callerbuild probe for both variants and widths. Corpus entries remain
offline immutable fixtures; no server/game/database is started.

Freeze the original 88-case version-13 consumer family and bounded-consumer
budgets: .NET 10.0.13 x64, ordinary tiering/PGO, affinity 4, quiet-validation,
3-second per-arm prime, twelve same-process paired blocks, four warmups,
seed 20261022, 120 seconds per plan; sixteen construction/build/size/FromEncoded,
64 copy/validation/count/miss and two construction-plus-65,536-read operations.
Family 88, existing 5% policy. Same-process blocks are not independent. All
failures/adverse results remain; no added samples, exclusions or replacements.
This screen cannot qualify adoption or universal 10x. Any normal confirmation
is separately frozen after localizing the original unrelated P18 family fault.

Use p22point/p22bulk/p22-hypothesis and linear-leaf-source identities. External
execution holds Global\Tedd.DotNetLab.Measurement.v1 through Host-Lock.ps1;
controller timing owns that mutex itself. Retain all source/bundle hashes,
protocol, tests, raw observations, joined shutdown and source review. Do not
publish the prototype. Reprofile only after complete interpretation.
