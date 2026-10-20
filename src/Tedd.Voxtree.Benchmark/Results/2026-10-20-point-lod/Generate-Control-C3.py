"""Generate explicit sixteen-read operation units without changing inner callers."""
from pathlib import Path
import subprocess
import sys

here = Path(__file__).resolve().parent
output = here / 'Scenarios-c3.cs.txt'
if output.exists():
    raise SystemExit('C3 fixture exists; do not overwrite a frozen epoch')
subprocess.run([sys.executable, str(here / 'Generate-Fixtures.py'), '--prime-ms', '5000',
                '--version', '11', '--output', str(output)], check=True)
source = output.read_text()
anchor = 'public long ExecuteBatch(int count) {'
if source.count(anchor) != 3 or source.count('completed+=count;return count;') != 3:
    raise RuntimeError('Control wrapper source changed')
source = source.replace(anchor, anchor + '\n        int logicalCount=count; count=checked(count*16);')
source = source.replace('completed+=count;return count;', 'completed+=count;return logicalCount;')
source = source.replace('primeMs=5000,consumer=', 'primeMs=5000,readsPerOperation=16,consumer=')
source = source.replace('"One complete public point or stored-LOD read"',
                        '"Sixteen complete public point or stored-LOD reads"')
if source.count('readsPerOperation=16') != 3:
    raise RuntimeError('Operation-unit identity missing')
output.write_text(source, encoding='utf-8')
