"""Index immutable diagnostic listings; do not equate their PGO history to timing."""
import argparse
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
output = task / 'native-summary-phase3.json'
if output.exists():
    raise SystemExit('Native summary exists; preserve original evidence')
records = []
for name in ['p7-mixed-code.asm', 'p7w-mixed-code.asm', 'p9-mixed-code.asm', 'p10a-code.asm',
             'p10b-code.asm', 'p13b-code.asm', 'p15-code.asm', 'p16-code.asm', 'p17-code.asm',
             'p17-u16-code.asm', 'p18-code.asm']:
    path = task / name
    text = path.read_text(errors='replace')
    methods = []
    for part in re.split(r'(?m)^; Assembly listing for method ', text)[1:]:
        header = part.splitlines()[0]
        if '(Tier1)' not in header:
            continue
        size = re.search(r'Total bytes of code (\d+)', part)
        methods.append(dict(method=header, native_bytes=int(size[1]) if size else None,
            rsp_subtractions=[int(value, 16) if value.startswith('0x') else int(value)
                for value in re.findall(r'sub\s+rsp,\s*(0x[0-9A-Fa-f]+|\d+)', part)],
            call_sites=[line.strip() for line in part.splitlines() if re.search(r'\bcall\s', line)]))
    records.append(dict(file=name, sha256=hashlib.sha256(path.read_bytes()).hexdigest(), methods=methods))
output.write_text(json.dumps(dict(observer='External target JIT diagnostics; not quiet timing',
    limitations=['Listings come from isolated diagnostic processes, while screens accumulate scenario/JIT/PGO history.',
        'Fixed rsp subtraction is not total stack usage or a causal time fraction.',
        'Native bytes and call-site changes do not establish hardware bottlenecks or promotion.'],
    listings=records), indent=2) + '\n', encoding='utf-8')
print(json.dumps(dict(listings=len(records), tier1_methods=sum(len(row['methods']) for row in records))))
