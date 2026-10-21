"""Preserve final release checks without rebuilding or rerunning their producers."""
import hashlib
import json
import sys
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

root = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2]).resolve()
assert root == Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
directory = root / 'final-release'
completion = json.loads((directory / 'completed.json').read_text(encoding='utf-8-sig'))
assert all(completion[k] for k in ['buildPassed', 'testsPassed', 'packPassed'])
assert not (directory / 'failure.log').exists()
tests = []
for path in sorted((root / 'final-release-results').glob('*.trx')):
    tree = ET.parse(path)
    counters = tree.find('.//{*}Counters').attrib
    assert counters['failed'] == '0' and counters['passed'] == counters['total']
    tests.append(dict(path=path.relative_to(root).as_posix(), **counters))
assert len(tests) == 3 and sorted(int(t['total']) for t in tests) == [396, 397, 398]
packages = sorted((directory / 'packages').glob('*.nupkg'))
assert len(packages) == 1
with zipfile.ZipFile(packages[0]) as package:
    assert package.testzip() is None
    names = package.namelist()
    for tfm in ['netstandard2.1', 'net10.0', 'net11.0']:
        assert f'lib/{tfm}/Tedd.Voxtree.dll' in names
    nuspec = ET.fromstring(package.read('Tedd.Voxtree.nuspec'))
    assert nuspec.find('.//{*}releaseNotes').text == (
        'Maintenance release revalidating the existing implementation across supported targets. '
        'Runtime behavior, public APIs, and serialized formats are unchanged.')
files = [p for p in directory.iterdir() if p.is_file()]
files += list((directory / 'packages').iterdir())
files += list((root / 'final-release-results').glob('*.trx'))
files += [Path(__file__).resolve(), Path(__file__).with_name('Test-FinalRelease.ps1')]
archive = output / 'release-verification.zip'
audit = output / 'release-verification.json'
assert not archive.exists() and not audit.exists()
manifest = []
with zipfile.ZipFile(archive, 'x', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as target:
    for path in sorted(files):
        data = path.read_bytes()
        name = path.relative_to(root).as_posix() if path.is_relative_to(root) else 'drivers/' + path.name
        target.writestr(name, data)
        manifest.append(dict(path=name, bytes=len(data), sha256=hashlib.sha256(data).hexdigest()))
    target.writestr('manifest.json', json.dumps(manifest, indent=2))
with zipfile.ZipFile(archive) as target:
    assert target.testzip() is None
    assert len(set(target.namelist())) == len(target.namelist())
    for item in manifest:
        data = target.read(item['path'])
        assert len(data) == item['bytes'] and hashlib.sha256(data).hexdigest() == item['sha256']
result = dict(passed=True, tests=tests, totalPassed=1191, totalFailed=0,
              buildWarnings=18, buildErrors=0, warningScope='Unchanged archived benchmark fields',
              packageTargets=['netstandard2.1', 'net10.0', 'net11.0'], completion=completion,
              localPackageVersion='2.0.19 base version; deploy workflow overrides published version',
              archiveBytes=archive.stat().st_size, archivePaths=len(manifest),
              archiveSha256=hashlib.sha256(archive.read_bytes()).hexdigest(),
              newRuntimeOptimization=False, fullPublicApiTenfoldQualified=False)
audit.write_bytes((json.dumps(result, indent=2) + '\n').encode())
print(json.dumps(result))
