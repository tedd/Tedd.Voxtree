"""Extend synthetic controls with compiled dense/uniform complete lifecycles."""
from pathlib import Path
import subprocess
import sys
here = Path(__file__).resolve().parent
destination = here / 'Scenarios-array.cs.txt'
subprocess.run([sys.executable, str(here / 'Generate-Fixtures.py'), '--prime-ms', '3000', '--version', '7', '--output', str(destination)], check=True)
source = destination.read_text()
anchor = 'if (args[0] == "--inventory")'
if source.count(anchor) != 1:
    raise RuntimeError('Registry anchor changed')
source = source.replace(anchor, '''foreach(var pattern in new[]{"uniform","dense"})
foreach(var op in new[]{"get","lod","create","lifecycle"})registry.Register(new LegacyScenario(5,pattern,"compiled",op));
''' + anchor)
destination.write_text(source, encoding='utf-8')
print('Generated 59 independent-oracle scenarios, including the frozen 16-case array-storage family.')
