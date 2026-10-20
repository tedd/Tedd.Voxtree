"""Audit C3's frozen complete fresh-session budget; never add or select samples."""
import argparse
import json
from pathlib import Path
import statistics

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
root = task / 'control-c3'
output = task / 'control-c3-audit.json'
if output.exists():
    raise SystemExit('C3 audit exists; preserve original result')
expected = {
    'point-Legacy-L5-full-owned-get': 4194304,
    'point-Legacy-L5-full-owned-lod': 4194304,
    'point-Legacy-L5-full-compiled-get': 33554432,
    'point-Legacy-L5-sparse-compiled-get': 33554432,
    'point-Wide-L5-long-owned-lod': 2097152,
    'point-Huge-L5-long-owned-lod': 1048576,
}

def unwrap(value):
    return json.loads(value['json']) if isinstance(value, dict) and 'json' in value else value

identities, failures, rows = set(), [], []
for scenario, count in expected.items():
    stem = root / ('c3-' + scenario)
    path = Path(str(stem) + '-sessions.json')
    if not path.exists():
        failures.append(f'{scenario}: missing completed sessions export')
        continue
    sessions = [unwrap(v) for v in json.loads(path.read_text(encoding='utf-8-sig'))]
    if len(sessions) != 24:
        failures.append(f'{scenario}: expected 24 sessions, found {len(sessions)}')
    blocks = {}
    observations = {'baseline': [], 'candidate': []}
    regimes = set()
    for session in sessions:
        target, measured = session['target'], session['measurement']
        key = (target['process_id'], target['start_time_utc_ticks'])
        if key in identities:
            failures.append(f'{scenario}: reused process/start {key}')
        identities.add(key)
        blocks.setdefault(session['block_ordinal'], []).append(session['variant'])
        regimes.add(session['compilation_regime'])
        if not (measured['correct'] and measured['quiescent'] and session['exit_code'] == 0 and
                session['exited_at'] and int(measured['completed_operations']) == count and
                int(measured['thread_allocation_bytes']) == 0 and measured['scenario_version'] == '11' and
                measured['start_thread_id'] == measured['end_thread_id'] and
                target['runtime_version'] == '10.0.13' and target['architecture'] == 'X64'):
            failures.append(f'{scenario}: invalid session {session["id"]}')
        observations[session['variant']].append(float(measured['nanoseconds_per_operation']) / 16)
    if len(blocks) != 12 or any(sorted(arms) != ['baseline', 'candidate'] for arms in blocks.values()):
        failures.append(f'{scenario}: incomplete frozen paired blocks')
    objective = unwrap(json.loads(Path(str(stem) + '-objective_vector.json').read_text(encoding='utf-8-sig')))
    time = next(v for v in objective['effects_without_run_ids'] if v['metric'] == 'scenario.ns_per_operation')
    allocation = next(v for v in objective['effects_without_run_ids'] if v['metric'] == 'scenario.thread_allocation_bytes_per_operation')
    rows.append(dict(scenario=scenario, sessions=len(sessions), logical_operations_per_session=count,
        declared_public_reads_per_session=count * 16, raw_metric_unit='ns/sixteen-read group',
        descriptive_median_ns_per_read={arm: statistics.median(v) for arm, v in observations.items()},
        compilation_regimes=sorted(regimes), time=time, allocation=allocation,
        promotion_eligible=objective['promotion_eligible'], execution_id=objective['execution_id']))
if len(rows) != 6 or len(identities) != 144:
    failures.append('Frozen six-case, 144-session budget incomplete')
audit = dict(epoch='C3', source_revision='f0772c8', reads_per_logical_operation=16,
    distinct_process_start_identities=len(identities), cases=rows, failures=failures,
    complete_joined_correct_quiescent_zero_thread_allocation=not failures,
    every_time_equivalent=not failures and all(row['time']['equivalence_passed'] for row in rows))
output.write_text(json.dumps(audit, indent=2) + '\n', encoding='utf-8')
print(json.dumps({k: v for k, v in audit.items() if k != 'cases'}))
if failures:
    raise SystemExit(1)
