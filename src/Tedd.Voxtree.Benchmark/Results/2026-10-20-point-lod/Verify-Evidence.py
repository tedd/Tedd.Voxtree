"""Verify a frozen content-addressed evidence archive without extracting it."""
import argparse
import csv
import hashlib
import json
import zipfile
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('directory', type=Path)
parser.add_argument('--label', required=True)
parser.add_argument('--require', action='append', default=[])
parser.add_argument('--prerequisites-only', action='store_true', help='Require zero comparison/objective files; permit absent measurement CSV')
args = parser.parse_args()
archive = args.directory / f'evidence-{args.label}.zip'
output = args.directory / f'evidence-{args.label}-verified.json'
if output.exists():
    raise SystemExit('Verification record already exists; inspect it instead of overwriting')
digest = hashlib.sha256(archive.read_bytes()).hexdigest()
assert (args.directory / f'evidence-{args.label}.sha256').read_text().split() == [digest, archive.name]
with zipfile.ZipFile(archive) as stream:
    names = stream.namelist()
    assert len(names) == len(set(names))
    assert stream.testzip() is None
    manifest = json.loads(stream.read('manifest.json'))
    paths = {item['path']: item for item in manifest}
    assert len(paths) == len(manifest)
    blobs = {}
    for item in manifest:
        assert item['blob'] == 'blobs/' + item['sha256']
        previous = blobs.setdefault(item['blob'], (item['bytes'], item['sha256']))
        assert previous == (item['bytes'], item['sha256'])
    assert set(names) == set(blobs) | {'manifest.json'}
    for name, (size, expected) in blobs.items():
        data = stream.read(name)
        assert len(data) == size and hashlib.sha256(data).hexdigest() == expected, name
    for required in args.require:
        assert required in paths, required
    catalogs = [item for item in manifest if item['path'].endswith('/catalog-export.json')]
    for item in catalogs:
        tables = json.loads(stream.read(item['blob']))
        assert tables and len({table['name'] for table in tables}) == len(tables)
        for table in tables:
            assert table['schema'] and table['columns']
            assert all(len(row) == len(table['columns']) for row in table['rows'])
csv_path = args.directory / f'measurements-{args.label}.csv'
if args.prerequisites_only:
    assert not any(p.endswith('comparison.json') or p.endswith('objective_vector.json') for p in paths)
    assert not csv_path.exists(), 'Prerequisite archive must have no measurement export'
    metric_rows = 0
else:
    with csv_path.open(newline='', encoding='utf-8-sig') as source:
        metric_rows = sum(1 for _ in csv.DictReader(source))
result = dict(archive_bytes=archive.stat().st_size, manifest_paths=len(manifest),
              unique_blobs=len(blobs), catalogs=len(catalogs), metric_rows=metric_rows,
              sha256=digest, required_paths=args.require,
              validation='CRC, unique mappings, every blob length/hash, catalog tables and required evidence passed')
output.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
print(json.dumps(result))
