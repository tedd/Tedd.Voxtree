"""P16 changes reader visibility only, preserving the frozen P15 source."""
import argparse
from pathlib import Path
import shutil

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
source = task / 'p15/source'
fork = task / 'lod-inline-source'
if fork.exists():
    raise SystemExit('P16 fork exists; inspect retained work before recovery')
shutil.copytree(source, fork)
for name, result, count in [('Octree.cs', 'uint', 1), ('OctreeSpan.cs', 'uint', 1), ('Octree.Generic.cs', 'T', 2)]:
    path = fork / name
    text = path.read_text()
    anchor = f'    public {result} Get(int x, int y, int z, out int lodLevel)'
    if text.count(anchor) != count:
        raise RuntimeError(f'{name}: expected {count} LOD overloads')
    text = text.replace(anchor,
        '    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.AggressiveInlining)]\n' + anchor)
    path.write_text(text, encoding='utf-8')
print(fork)
