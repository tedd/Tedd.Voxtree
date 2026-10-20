# Forcecraft corpus

Source: the user's existing `D:/SourceCode/Tedd.Forcecraft10/data/Worlds`.
Six region files were found, 180,354,048 bytes in total. Header inspection
identified FCRG region version 1, region exponent 5, sector exponent 9, chunk
layout 5 (32³ voxels). No application startup or storage constructor is used.

The offline scanner opens each existing region with FileMode.Open,
FileAccess.Read and FileShare.Read. It validates region/table/record bounds,
CHNK magic, lengths, CRC-32, compressed envelope and payload framing. It uses
only LZ4Pickler from the existing cached K4os package, never Forcecraft code or
callbacks. Input files are hashed before and after the scan on the same handle.
It writes exclusively to the designated task workspace. Unsupported versions
or malformed records stop the census; no repairs, skipped failures or world
changes are permitted.

Retain all record identities and block distributions, including duplicate voxel
arrays. Decode mono (big endian), raw UInt16 (little endian), and packed palette
bodies independently from Forcecraft's implementation. Voxel order is
`(x*32+y)*32+z`; Voxtree linear input also uses z as the innermost coordinate.
Compute canonical stored-LOD voxel frequencies independently by recursively
testing aligned uniform cubes. Count distinct values, maxima, nonzero voxels,
linear runs and uniform aligned 2³ cubes. Preserve other payload IDs/counts/bytes
as a guide for subsequent fluid/thermal workloads, without silently treating
their encoded bytes as block values.

Before observing results, select the first ordinal region path/slot for each
semantic stratum: topology {uniform, coarse without LOD0, fully expanded, mixed},
value width {0..127, 0..255, wider}, density {empty, solid, containing air}.
Every record stays in the census regardless of selection. Samples are raw
UInt16 arrays with SHA-256 and source identities. This is a characterization
and correctness phase, not a timing comparison or a representative frequency
claim about all Forcecraft worlds.

Follow-up gates: verify selected arrays against the original Forcecraft palette
reader, validate every value and LOD against current/baseline and experimental
Voxtree representations, and freeze selected point/LOD/build/read workloads
before timing. Use actual stratum frequency to expose workload mismatches;
retain synthetic adverse cases even when absent from this corpus. P6's byte
representation requires all values <=255 and no uniform aligned 2³ cubes;
measure its real eligibility rather than assuming terrain qualifies.

The first direct census (original `forcecraft-census.log`) stopped before reading
any record: the planet region has an existing writer handle, incompatible with
FileShare.Read. Preserve that failed setup. S1 copies all six region files to a
task-local snapshot using read-only source handles with FileShare.ReadWrite;
source-before, source-after and copied SHA-256 must all match for every file.
No process is stopped and no user file is changed. Scan the copies with the
strict reader above. This detects content changes across each copy window; it
does not establish an atomic snapshot across all six world files. Timing uses
the resulting immutable voxel samples, not live files.

S1 completed: 1,286 records, every CRC valid, 686 unique voxel arrays and four
strata. 600 chunks are empty; 681 are mixed-LOD with values above 255; three are
mixed-LOD within 0..255 and two within 0..127. Maximum observed block ID is
4,514. No chunk meets P6's byte eligibility. This argues for prioritizing mixed
topology and generic UInt16 rather than adopting P6 for this corpus.

S2 reuses the exact S1 immutable region snapshot and augments the independent
palette decoder with differential comparison against the unmodified original
Forcecraft `BlockTypeArrayCodec.ReadPalette` for every palette record. The
standalone build includes that source and its `ChunkScratch` dependency with
only a 32³ compile-time geometry shim; it does not link or start Forcecraft.
Retain source SHA-256 identities and both S1 and S2 results. This is additional
correctness validation, not extra samples appended to a timing experiment.

S2 completed with all 686 palette records agreeing. Version-5 fixtures embed the
four hash-verified samples and validate every value and canonical leaf LOD in
both f0772c8 and the current P1/P3/P5 source; all 32 UInt16/UInt32 owned/span
Get/LOD scenarios passed on .NET 10.0.13. Timing selection is frozen to the eight
mixed-u16-air scenarios (two representations, owned/span, value/value+LOD),
which target the dominant nonuniform stratum. Use the existing quiet DotNetLab
12-pair screening protocol, precision-sized 2,097,152-read batches and 3-second
per-variant primes. Family size is eight for this diagnostic screen. Retain all
observations. Failed unchanged-source precision qualification prevents using
screening results as adoption evidence; no normal confirmation is implied.
