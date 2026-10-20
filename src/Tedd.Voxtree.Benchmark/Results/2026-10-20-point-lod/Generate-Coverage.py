"""Inventory the full public goal without inferring coverage from a kernel gain."""
import argparse
import csv
import json
import re
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('inventory', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
types = json.loads(args.inventory.read_text(encoding='utf-8-sig'))
rows = []
for entry in types:
    for kind in ('methods', 'constructors'):
        for signature in entry[kind]:
            match = re.search(r'([A-Za-z_][A-Za-z_0-9]*)\(', signature)
            name = match[1] if match else signature
            if name in ('Get', 'GetLod', 'TryGet', 'get_Item'):
                priority, family = 1, 'point/LOD/indexer'
            elif any(word in name for word in ('Build', 'Size', 'Copy', 'Count', 'Any', 'Collect', 'Nearest')):
                priority, family = 2, 'encoding/bulk/query'
            elif name.startswith(('get_', 'set_', 'op_')):
                priority, family = 3, 'accessor/operator'
            else:
                priority, family = 3, 'other public API'
            rows.append(dict(type=entry['type'], entry_kind=kind[:-1], signature=signature,
                priority=priority, family=family, goal='10x under declared .NET 10 steady voxel workloads',
                status='not fully verified',
                evidence_required='matching baseline/candidate complete caller; useful work and invariants; independent raw data; lower speedup interval >=10; mandatory guards'))
with args.output.open('w', newline='', encoding='utf-8') as stream:
    writer = csv.DictWriter(stream, fieldnames=rows[0])
    writer.writeheader(); writer.writerows(rows)
print(json.dumps(dict(types=len(types), methods=sum(r['entry_kind']=='method' for r in rows), constructors=sum(r['entry_kind']=='constructor' for r in rows),
    note='No whole-method target is inferred from a subset of input types, branches, or distributions.')))
