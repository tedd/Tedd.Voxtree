# K2: bounded 16-bit value/LOD word projection

Prospective metadata census only. It runs after the original P30 timing family
closes, under shared host admission. No new encoding, reader, lookup, benchmark
or performance observation is produced. Production remains f0772c8.

P24's single-word reads passed the eight direct-release time primaries but grew
classic encoded-plus-distinct-lookup payload by46.5%. P27's byte palette reduces
that payload but adds an indexed state-table load; two UInt32 owned primaries
miss10x. P29 removes output temporaries but fails LOD/guard thresholds. The next
layout candidate should address the dependent payload load without restoring
P24's broad four-byte expansion. Registry M05/M17/A09/A12; hardware causation and
latency remain unmeasured hypotheses.

Proposed representation: one UInt16 per cell, low13 raw value bits and high3 LOD
bits. Values0..8191 and LOD0..6 fit exactly. A future distinct R/0x52 v3 format
would apply only to original P27-eligible depth3..6 chunks whose raw maximum
fits13 bits. Higher values retain the complete full-value Q/legacy fallback;
no public raw-value restriction or truncation is proposed. Uniform/legacy/dense
selection and existing public GetMaximumSize bounds remain constraints.

K2 uses the existing hash-bound p27setup corpus: all1286 chunks/42139648 cells,
duplicates retained and686 unique-array summary separately. This corpus has
depth5. Retain original Q eligibility. For each selected mode with maximum<=8191,
project header+2*N bytes (header2 classic,3 generic); otherwise retain actual P27
bytes. Check the logical width2/4 maximum capacity and every selected chunk's
projected encoding<=2.5 times released bytes. That prospective2.5 bound follows
from replacing one byte plus state table with two bytes while retaining Q's
1.25 eligibility; it is an experimental policy, not a user-specified limit.

Project classic combined payload using actual P27 distinct fallback lookup bytes,
assuming a future owned compact-word lookup shares its encoded array as the
existing packed-word prototype does. Require this complete projected combined
payload to be no greater than release. Charge every chunk, retain every adverse
row and report encoded growth separately. Exclude CLR headers, GC retention,
allocator cost, compressed file size and any runtime-cache benefit; these are
not supplied by arithmetic metadata. No cross-chunk deduplication assumption.

Bind source JSON and assembly to the original audit/hash, plus phase13's immutable
archive. Freeze the preselected dominant sample hash
48A799A3EEBA729CB9DCE28F1EA54E9B19A9D46E7AA7CA8F0696E90E0F6F10FB;
region DefaultWorld/r.-2.488.-2.region, slot2714.
report it even if a bound fails. No alternative sample is selected after results.
Support is limited to representation/conditional-payload feasibility: all selected
rows fit, actual maximum-size and2.5 bounds hold, preselected sample fits, and
classic combined projection<=release. Otherwise not_supported for this design.

Also verify the proposed stable length discriminator: existing Q payload length
minus header is2 modulo4 (N is a multiple of512, table entries4/8 bytes), while
compact-word payload is0 modulo4. This may distinguish already validated Q/R
views without an additional magic-byte load. It does not replace constructor
magic/version/length/width validation or prove malformed-buffer semantics.

No timing benefit, allocation equivalence, API correctness, format implementation
or promotion follows. A positive projection still requires an independent source
protocol, complete encoders/readers/queries/lookup validation, original capacities,
native caller evidence, direct-release normal confirmation and all broader guards.
Never multiply old ratios or revise P24/P27/P29/P30 dispositions from K2.
