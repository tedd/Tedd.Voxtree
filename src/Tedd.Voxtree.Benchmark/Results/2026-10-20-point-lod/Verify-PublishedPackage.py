"""Verify the downloaded public NuGet artifact, without executing its code."""
import hashlib
import json
import sys
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

package = Path(sys.argv[1]).resolve()
version = sys.argv[2]
output = Path(sys.argv[3]).resolve()
assert package.parent == Path('D:/Workspaces/AI/voxtree-point-lod-20261020/published').resolve()
assert not output.exists(), 'Preserve the original verification record'
with zipfile.ZipFile(package) as archive:
    assert archive.testzip() is None
    names = archive.namelist()
    assert len(names) == len(set(names))
    metadata = ET.fromstring(archive.read('Tedd.Voxtree.nuspec'))
    value = lambda name: metadata.find('.//{*}' + name).text
    assert value('id') == 'Tedd.Voxtree' and value('version') == version
    assert value('releaseNotes') == (
        'Maintenance release revalidating the existing implementation across supported targets. '
        'Runtime behavior, public APIs, and serialized formats are unchanged.')
    assemblies = []
    for tfm in ['netstandard2.1', 'net10.0', 'net11.0']:
        name = f'lib/{tfm}/Tedd.Voxtree.dll'
        data = archive.read(name)
        assemblies.append(dict(path=name, bytes=len(data), sha256=hashlib.sha256(data).hexdigest()))
result = dict(passed=True, id='Tedd.Voxtree', version=version,
              packageUrl=f'https://api.nuget.org/v3-flatcontainer/tedd.voxtree/{version}/tedd.voxtree.{version}.nupkg',
              packageSha256=hashlib.sha256(package.read_bytes()).hexdigest(),
              packageBytes=package.stat().st_size, assemblies=assemblies,
              releaseNotes=value('releaseNotes'), crcAndUniqueEntriesPassed=True,
              packageExecuted=False)
output.write_bytes((json.dumps(result, indent=2) + '\n').encode())
print(json.dumps(result))
