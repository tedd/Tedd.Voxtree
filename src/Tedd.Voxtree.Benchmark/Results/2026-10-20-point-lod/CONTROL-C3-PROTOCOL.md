# C3: admitted, bounded long-window controls

C2 completed its six short preflight screens, but its first confirmation-plan
request was rejected as invalid before launching any confirmation session.
Installed revision 9c23369 limits operations per run to 100,000,000 and complete
plan duration to 600 seconds. Preserve C2's rejected request and all preflight
observations. No C2 confirmation observations exist to extend or select.

Freeze C3 before new data: original affinity 4, ordinary tiering/PGO, .NET
10.0.13 x64, five-second variant primes, quiet profile, six unchanged-source
cases from C1/C2, 12 fresh pairs per case, one warmup batch, seed 20261023,
family size 12 for elapsed time and thread allocation, no exclusions. Each
version-11 logical operation explicitly means **sixteen public reads**. The
wrapper multiplies the batch count outside the existing identical inner loop;
checksums and completed-read validation use the physical read count. Both
source copies are f0772c8, and all raw AfterBatch IL hashes must match. Source
hashes, units, descriptors and actual project difference bind this epoch.

Operations per batch: compiled 33,554,432 logical / 536,870,912 reads; full
owned 4,194,304 / 67,108,864; Wide long LOD 2,097,152 / 33,554,432; Huge long
LOD 1,048,576 / 16,777,216. Expected measured windows from C1 medians are
approximately 2.2, 4.6, 2.9 and 3.1 seconds. Maximum complete plan duration is
600 seconds; the budget is fixed, and timeout is retained as failure rather
than an invitation to exclude sessions. All counts fit published limits.

The preceding 256-logical-operation preflight binds each scenario to completed
exploratory evidence; its ratios are not precision qualification. Fresh-session
ratios are dimensionless; raw ns/operation means ns/sixteen-read group, not
ns/read. Any per-read report must explicitly divide by sixteen. Never pool
these observations with single-read-unit epochs.

External phases wait for `Global\Tedd.DotNetLab.Measurement.v1`. DotNetLab owns
that mutex during each measurement/fresh session, including target staging and
startup. Outer drivers retain the legacy pipeline locks but must not hold the
central mutex while awaiting a controller. No application suspension, power,
priority or affinity changes beyond the already specified owned-target mask.

All six fresh time intervals must lie within 0.95..1.05 before qualifying this
regime's latency guards. Zero observed thread allocation is reported separately
from the statistical model's degenerate-variance eligibility. Preserve every
accepted ID, session, error and joined process. C3 makes no optimization claim.
