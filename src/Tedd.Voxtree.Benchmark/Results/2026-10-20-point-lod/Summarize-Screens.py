"""Retain complete and partial screening families without selecting observations."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
output = task / 'screen-summary-phase3.json'
if output.exists():
    raise SystemExit('Screen summary exists; preserve the original')
definitions = [('p7-bounded', 'f0772c8', 16), ('p7w', 'P7', 16), ('p9', 'P7w', 16),
    ('p10a', 'f0772c8', 16), ('p10b', 'P9', 16), ('p13b', 'P10b', 16),
    ('p15', 'f0772c8', 48), ('p16', 'P15', 48), ('p17', 'P15', 48), ('p18', 'P17', 48)]
families = []
for label, control, expected in definitions:
    directory = task / (label + '-screen')
    rows = []
    for path in sorted(directory.glob('*comparison.json')):
        value = json.loads(path.read_text(encoding='utf-8-sig'))
        if 'json' in value:
            value = json.loads(value['json'])
        time = next(effect for effect in value['effects_without_run_ids'] if effect['metric'] == 'scenario.ns_per_operation')
        rows.append(dict(file=path.relative_to(task).as_posix(), sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
            speedup=1 / time['effect'], time_effect=time))
    failures = []
    for path in directory.glob('*failed-execution*.json'):
        value = json.loads(path.read_text(encoding='utf-8-sig'))
        if 'json' in value:
            value = json.loads(value['json'])
        failures.append(dict(file=path.relative_to(task).as_posix(), execution=value))
    families.append(dict(label=label, control=control, planned_cases=expected, completed_comparisons=len(rows),
        complete_family=len(rows) == expected, independent_process_blocks=False,
        inference='Exploratory same-process paired blocks; not promotion or guard qualification',
        cases=rows, retained_failures=failures))
output.write_text(json.dumps(dict(families=families, ratios_must_not_be_multiplied_across_epochs=True), indent=2) + '\n', encoding='utf-8')
print(json.dumps([dict(label=f['label'], complete=f['complete_family'], completed=f['completed_comparisons'], planned=f['planned_cases']) for f in families]))
