"""Keep small legacy encodings and prepare P6b without changing frozen P6."""
import argparse
from pathlib import Path
import subprocess
import sys
parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
here = Path(__file__).resolve().parent
subprocess.run([sys.executable, str(here / 'Prepare-DenseByte.py'), str(args.task_root), '--name', 'dense-byte-b-source',
                '--fixture-name', 'Scenarios-byte-b.cs.txt', '--fixture-version', '10'], check=True)
fork = args.task_root / 'dense-byte-b-source'
path = fork / 'DenseByteEncoding.cs'
source = path.read_text()
anchor = 'if (levels == 0 ||'
if source.count(anchor) != 1:
    raise RuntimeError('Eligibility source anchor changed')
path.write_text(source.replace(anchor, 'if (levels < 3 ||'), encoding='utf-8')
path = fork / 'Octree.cs'
source = path.read_text()
anchor = 'public const int FormatVersion = 1;'
if source.count(anchor) != 1:
    raise RuntimeError('Version constant anchor changed')
source = source.replace(anchor, '''public const int FormatVersion = 1;
    /// <summary>The newest supported UInt32 encoding version; individual payloads may use an older version.</summary>
    public const int LatestFormatVersion = 3;''')
path.write_text(source, encoding='utf-8')
