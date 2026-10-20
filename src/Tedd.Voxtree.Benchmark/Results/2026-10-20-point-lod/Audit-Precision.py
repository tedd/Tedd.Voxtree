"""Audit the complete frozen unchanged-source confirmation, without altering it."""
import argparse
import json
from pathlib import Path
parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
root = args.task_root / 'precision-control'
identities, failures, rows = set(), [], []
def unwrap(v):
    return json.loads(v['json']) if isinstance(v, dict) and 'json' in v else v
for path in sorted(root.glob('precision-*-sessions.json')):
    sessions = [unwrap(v) for v in json.loads(path.read_text(encoding='utf-8-sig'))]
    if len(sessions) != 24:
        failures.append(f'{path.name}: expected 24 sessions')
    for session in sessions:
        target, measurement = session['target'], session['measurement']
        key = (target['process_id'], target['start_time_utc_ticks'])
        if key in identities:
            failures.append(f'Duplicate process/start: {key}')
        identities.add(key)
        if not (measurement['correct'] and measurement['quiescent'] and session['exit_code'] == 0
                and session['exited_at'] and int(measurement['thread_allocation_bytes']) == 0
                and target['runtime_version'] == '10.0.13' and target['architecture'] == 'X64'):
            failures.append(session['id'])
    stem = path.name.removesuffix('-sessions.json')
    objective = unwrap(json.loads((root / (stem + '-objective_vector.json')).read_text(encoding='utf-8-sig')))
    effect = next(v for v in objective['effects_without_run_ids'] if v['metric'] == 'scenario.ns_per_operation')
    rows.append(dict(scenario=stem.removeprefix('precision-'), sessions=len(sessions), effect=effect,
                     promotion_eligible=objective['promotion_eligible'], execution_id=objective['execution_id']))
if len(rows) != 6 or len(identities) != 144:
    failures.append('Frozen six-case, 144-session budget incomplete')
audit = dict(cases=rows, distinct_process_start_identities=len(identities), failures=failures,
             every_time_equivalent=all(v['effect']['equivalence_passed'] for v in rows),
             all_joined_correct_quiescent_zero_thread_allocation=not failures)
destination = args.task_root / 'precision-audit.json'
destination.write_text(json.dumps(audit, indent=2) + '\n', encoding='utf-8')
print(json.dumps({k: v for k, v in audit.items() if k != 'cases'}))
if failures:
    raise SystemExit(1)
