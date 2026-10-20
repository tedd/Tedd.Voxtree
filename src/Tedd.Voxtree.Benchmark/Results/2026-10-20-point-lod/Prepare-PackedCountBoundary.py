"""P21 preserves P20 executable bodies and changes only vector-helper attributes."""
import argparse,shutil
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
root=args.task_root.resolve()
if root!=Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():raise SystemExit('Unexpected task root')
fork=root/'packed-count-boundary-source'
if fork.exists():raise SystemExit('P21 source exists; inspect previous work')
shutil.copytree(root/'packed-count-vector-source',fork)
for name,generic in [('OctreeQueries.cs',False),('GenericOctreeQueries.cs',True)]:
    p=fork/name;text=p.read_text()
    anchor='    private static int CountPackedVector'+('<TStorage>' if generic else '')+'('
    assert text.count(anchor)==1
    text=text.replace(anchor,'    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.NoInlining)]\n'+anchor)
    p.write_text(text,encoding='utf-8')
print(fork)
