"""Validate retained archives before task workspace removal; no producer is run."""
import hashlib
import json
import zipfile
from pathlib import Path

directory = Path(__file__).resolve().parent
output = directory / 'delivery-evidence-audit.json'
assert not output.exists(), 'Inspect the original audit instead of overwriting it'
expected = {}
for path in sorted(directory.glob('*.sha256')):
    digest, name = path.read_text().split()
    assert Path(name).name == name and name not in expected
    expected[name] = digest
release = json.loads((directory / 'release-verification.json').read_text())
expected['release-verification.zip'] = release['archiveSha256']
archives = []
for path in sorted(directory.glob('*.zip')):
    with path.open('rb') as source:
        digest = hashlib.file_digest(source, 'sha256').hexdigest()
    if path.name in expected:
        assert digest == expected[path.name], path.name
    with zipfile.ZipFile(path) as archive:
        assert archive.testzip() is None, path.name
        names = archive.namelist()
        assert len(names) == len(set(names)), path.name
    archives.append(dict(name=path.name, bytes=path.stat().st_size,
                         sha256=digest, priorDigestMatched=path.name in expected))
assert set(expected).issubset({a['name'] for a in archives})
assert len(expected) == 40
result = dict(passed=True, retainedArchiveCount=len(archives),
              priorDigestMatches=len(expected), crcAndUniqueEntriesPassed=True,
              archives=archives, producersRerun=False, measurementsAdded=False)
output.write_bytes((json.dumps(result, indent=2) + '\n').encode())
print(json.dumps({k: v for k, v in result.items() if k != 'archives'}))
