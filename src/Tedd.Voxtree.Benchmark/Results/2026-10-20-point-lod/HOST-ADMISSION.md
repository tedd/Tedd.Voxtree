# Shared Windows admission

The user identified `Global\Tedd.DotNetLab.Measurement.v1`. Installed DotNetLab
revision 9c233691210187340963f53ca98c640e2b0cc75e uses that mutex in
`MachineMutex.AcquireAsync`, reached through `ParserMeasurementGate.EnterAsync`.
`MeasurementScheduling.ExecuteMeasuredAsync` acquires it before target work;
`ConfirmationService.RunNormalSessionAsync` acquires it before staging and
launching each fresh process. Mutex ownership belongs to a dedicated controller
thread, not the PowerShell driver's thread. Holding it outside while awaiting
those operations would deadlock; Windows mutex recursion is thread-specific.

Host-Lock.ps1 now defaults to the two legacy pipeline mutexes followed by the
central measurement mutex. Standalone builds, tests, validation and assembly
inspection use that default. Coordinating/timing drivers use ControllerAdmission
for their outer pipeline lease, acquire the central mutex for external phases
and controller preparation, release it, then delegate timed admission to
DotNetLab. MeasurementOnly permits independent bookkeeping to wait for the
central slot without acquiring another driver's pipeline lease. Never acquire
pipeline locks after taking a MeasurementOnly lease.

Verify-HostAdmission.ps1 checked exclusion across actual processes: an owned
child could not acquire while its parent held the central mutex, acquired
after release, returned exit code zero, and was joined. The recorded child was
PID 61448, start 2026-10-20T20:07:14.8204874Z. Raw JSON is retained with research
evidence. The dense-byte P6b build, oracle and 1,197-test validation completed
using central admission. Fresh C3 sessions also reached execution without an
outer/controller mutex deadlock.

Historical DotNetLab timed runs already used the central mutex. Their external
prerequisite phases used only the two legacy locks. Retain those observations
with this limitation; the correction does not establish a cause for prior
variance, invalidate every timed observation, or qualify an inconclusive guard.
No unrelated application, system power policy or affinity was changed.
