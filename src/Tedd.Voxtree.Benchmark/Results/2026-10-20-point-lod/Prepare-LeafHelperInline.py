"""P18 targets two remaining native call sites, preserving the P17 source."""
import argparse
from pathlib import Path
import shutil

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
fork = task / 'leaf-helper-inline-source'
if fork.exists():
    raise SystemExit('Helper fork exists; inspect retained work before recovery')
shutil.copytree(task / 'p17/source', fork)
path = fork / 'PackedLeafEncoding.cs'
source = path.read_text()
for anchor in ['    private static T Value(uint value)', '    private static uint ReadWord(ReadOnlySpan<byte> value)']:
    if source.count(anchor) != 1:
        raise RuntimeError('Leaf helper source anchor changed')
    source = source.replace(anchor, '    [MethodImpl(MethodImplOptions.AggressiveInlining)]\n' + anchor)
path.write_text(source, encoding='utf-8')
print(fork)
