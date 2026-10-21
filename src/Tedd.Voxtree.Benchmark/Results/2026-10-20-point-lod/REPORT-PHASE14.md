# Direct throwing palette reads

Integration branch: main. Starting commit 1ef37b8; preparation committed as
d02a24f. Production library remains f0772c8 and package2.0.28. No research source
is adopted or published. The full public-method10x objective remains active.

The previous turn completed P27 and rejected P28 before implementation because
its proposed call boundary was already inlined. P29 tests a distinct mechanism:
the optimized value-only caller still stored/reloaded temporary value/LOD outputs
and propagated a boolean success flag. Returning the checked palette word/value
directly can remove those intermediates. Packed dispatch before the existing
fallback is explicitly part of this intervention. The point fixture and checksum
remain unchanged; this is a library-source experiment, not a faster consumer.

P29 changes six private-source files on complete P27. Throwing owned/span Get
uses direct value-returning palette methods. Bounds failures return an all-one
internal sentinel; its invalid LOD distinguishes it from every legal state,
including maximum raw UInt16/UInt32 values. The public throwing path preserves
coordinate/output/exception order, unsigned LOD validation and single-snapshot
publication. Existing boolean TryGet readers, fields, encoders, format selection,
copy, queries and compiled lookup retain their exact source. No heap cache or
unchecked pointer read is introduced.

The independent new tests exercise legal maximum-value/LOD states, raw signed and
floating bits, malformed indexes, high/all-one LOD fields, owned/borrowed mutation,
failure output state and coordinate precedence. Both complete P27 control and
P29 candidate pass407/408/409 tests on .NET8/10/11; candidate hardware-off passes
408. All48 point and88 complete-operation semantic scenarios pass. The three
selected rig builds have zero warnings/errors. The offline corpus helper retains
three nullable warnings in copied sample support code.

The census checks all1286 chunks/42139648 cells and686 unique arrays against the
independent dense value/natural-LOD oracle and f0772c8. A separately aliased exact
P27 assembly additionally constructs every chunk through all three APIs and
compares every encoding byte. All checks pass. Eligibility remains132/142/132;
classic encoded-plus-distinct-lookup payload remains40325678 bytes. This is
payload evidence, excluding CLR headers/GC retention, not a new allocation or
access-frequency claim. Paired and corpus source snapshots match the full diff.

The matched final Tier1 UInt32 owned Get valid palette branch removes its temporary
value store/reload, discarded LOD store and success-flag propagation. Whole caller
code changes3336 to3237 bytes; fixed rsp subtraction increases232 to248. The
prespecified generated-code gate therefore passes. All four owned/span Get/LOD
diagnostics retain132 optimized versions, with OSR and complete/incomplete listings
distinguished. These diagnostics establish neither a causal time fraction nor
total stack usage, PMU behavior or exact quiet-run code identity.

The full fixed48-case exploratory family completes1152 correct/quiescent records.
Target, controller and outer driver join/exit successfully. All plans precede
observations; source remains frozen, and no old observations or failed-run
replacements enter the new family. Control is complete P27, not f0772c8.

| Dominant UInt32 caller | Speedup over P27 | Primary>=1.10 |
|---|---:|---|
| Owned Get |1.317|pass|
| Owned Get with LOD |1.057|fail|
| Span Get |1.165|pass|
| Span Get with LOD |0.998|fail|

Two of four primary estimates fail;20 of44 guards are adverse under the original
1.05 cost rule. Retain the entire guard family, including uniform UInt16 owned Get
0.470, span Get0.432 and span LOD0.392. Smaller hot-path output handling does not
qualify a universal improvement. The hypothesis is revised to not_supported;
no part is promoted from favorable estimates alone. Same-process namespace,
code-layout, PGO history and residual host-load effects limit attribution,
particularly for unchanged-source guards. No ratio is multiplied with P27,
and no new direct-release10x or normal-build confirmation is claimed.

The verified phase14 supplement contains2157 logical paths,1955 content blobs,
two catalog exports and48 new exploratory metric rows. Size5392344 bytes;
SHA-256 ec871fbfa4280b07af92ba2e545a33ddc5546e80a0919a45e5ed0f8f8c451df1.
Every CRC, mapping, blob length/hash, catalog table and required path passes.
It also preserves the post-phase13 p27contracts source/TRX/log evidence and the
P29 value-only precheck diagnostics. Earlier immutable archives remain the parent
reproduction chain.

The next prepared, unexecuted hypothesis is per-call build-plan reuse on complete
P27. Eligible owned tree fallback already has a plan but remeasures it in TryBuild.
A shared private validated write core can reuse that plan without altering public
caller-buffer validation or writes. The prospective protocol requires all original
capacity/tail/failure mutations. A concrete corpus case proves why simply writing
a legacy tree before the smaller selected palette is invalid:34116 versus33300
bytes would risk816 bytes of successful-output tail corruption. The prepared
generator does not implement that speculative policy.

All execution respects the shared Windows host/measurement mutex. No world,
production database, shared installation or unrelated docs/articles is changed.
No alternate branch/worktree was created. The task workspace remains retained
for immutable inputs and continued work on the active full objective.
