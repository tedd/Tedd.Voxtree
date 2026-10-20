"""Prepare the explicitly larger direct-state representation independently."""
import argparse
import re
from pathlib import Path
import shutil
parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
parser.add_argument('--name', default='direct-state-source')
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
if not re.fullmatch('[a-z][a-z0-9-]*', args.name):
    raise SystemExit('Invalid source label')
fork = task / args.name
if fork.exists():
    raise SystemExit('Fork exists; inspect previous operation before recovery')
shutil.copytree(task / 'leaf-byte-source', fork)
here = Path(__file__).resolve().parent
shutil.copyfile(here / 'DirectStateLookup.cs.txt', fork / 'OctreeLookup.DirectState.cs')
path = fork / 'OctreeLookup.cs'
source = path.read_text()
edits = [
    ('        if (TryCompilePacked(body, root, Levels, nodeCount, out var palette, out var grid, out var prefixWords))',
     '''        if (TryCompileDirectState(body, root, Levels, nodeCount, out var direct))
        {
            _nodes = direct;
            _uniform = uint.MaxValue;
            return;
        }
        if (TryCompilePacked(body, root, Levels, nodeCount, out var palette, out var grid, out var prefixWords))'''),
    ('(_uniform != 0 ? _dense!.Length : 0)', '(_uniform != 0 && _uniform != uint.MaxValue ? _dense!.Length : 0)'),
    ('        if (_uniform != 0) return GetPacked',
     '        if (_uniform == uint.MaxValue) return GetDirectState(x, y, z, nodes, out lodLevel);\n        if (_uniform != 0) return GetPacked'),
]
for before, after in edits:
    if source.count(before) != 1:
        raise RuntimeError('Source anchor mismatch: ' + before)
    source = source.replace(before, after)
path.write_text(source, encoding='utf-8')
print(fork)
