"""Copy the frozen byte-grid prototype and change only its private word storage."""
import argparse
from pathlib import Path
import shutil
parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
fork = task / 'packed-words-source'
if fork.exists():
    raise SystemExit('Fork exists; inspect the prior operation before recovery')
shutil.copytree(task / 'packed-lookup-source', fork)
here = Path(__file__).resolve().parent
shutil.copyfile(here / 'PackedLookupWords.cs.txt', fork / 'OctreeLookup.Packed.cs')
path = fork / 'OctreeLookup.cs'
source = path.read_text()
edits = [
    ('TryCompilePacked(body, root, Levels, nodeCount, out var palette, out var payload)',
     'TryCompilePacked(body, root, Levels, nodeCount, out var palette)'),
    ('            _dense = payload;\n', ''),
    ('_nodes.Length * sizeof(uint) + (_uniform == uint.MaxValue ? _dense.Length : 0) :',
     '_nodes.Length * sizeof(uint) :'),
]
for before, after in edits:
    if source.count(before) != 1:
        raise RuntimeError('Source anchor mismatch: ' + before)
    source = source.replace(before, after)
path.write_text(source, encoding='utf-8')
print(fork)
