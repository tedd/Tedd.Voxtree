"""Prepare P7 independently of earlier unadopted candidates."""
import argparse
from pathlib import Path
import shutil
import subprocess
parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
here = Path(__file__).resolve().parent
repo = here.parents[3]
fork = task / 'packed-lookup-source'
if fork.exists():
    raise SystemExit('Fork exists; inspect the prior operation before recovery')
fork.mkdir()
paths = subprocess.check_output(['git', '-C', str(repo), 'ls-tree', '-r', '--name-only', 'f0772c8', '--', 'src/Tedd.Voxtree'], text=True).splitlines()
for path in paths:
    if path.endswith('.cs'):
        content = subprocess.check_output(['git', '-C', str(repo), 'show', f'f0772c8:{path}'], text=True)
        (fork / Path(path).name).write_text(content, encoding='utf-8')
shutil.copyfile(here / 'PackedLookup.cs.txt', fork / 'OctreeLookup.Packed.cs')
path = fork / 'OctreeLookup.cs'
source = path.read_text()
edits = [
    ('public sealed class OctreeLookup', 'public sealed partial class OctreeLookup'),
    ('        _nodes = new uint[checked(nodeCount * NodeWords)];', '''        if (TryCompilePacked(body, root, Levels, nodeCount, out var palette, out var payload))
        {
            _nodes = palette;
            _dense = payload;
            _uniform = uint.MaxValue;
            return;
        }
        _nodes = new uint[checked(nodeCount * NodeWords)];'''),
    ('_nodes.Length * sizeof(uint) :', '_nodes.Length * sizeof(uint) + (_uniform == uint.MaxValue ? _dense.Length : 0) :'),
    ('        var offset = 0;', '        if (_uniform == uint.MaxValue) return GetPacked(x, y, z, nodes, out lodLevel);\n        var offset = 0;'),
]
for before, after in edits:
    if source.count(before) != 1:
        raise RuntimeError('Source anchor mismatch: ' + before)
    source = source.replace(before, after)
path.write_text(source, encoding='utf-8')
print(fork)
