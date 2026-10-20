"""P20 reuses validated vector predicates without changing wire or ownership."""
import argparse
from pathlib import Path
import shutil

parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
task=args.task_root.resolve()
if task!=Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():raise SystemExit('Unexpected task root')
here=Path(__file__).resolve().parent;fork=task/'packed-count-vector-source';fixture=here/'PackedCountVectorTests.cs.txt'
if fork.exists() or fixture.exists():raise SystemExit('P20 identity exists; inspect retained work')
shutil.copytree(task/'packed-count-source',fork)
for file,generic in [('OctreeQueries.cs',False),('GenericOctreeQueries.cs',True)]:
    path=fork/file;source=path.read_text()
    anchor=('    private static int CountPacked'+('<TStorage>' if generic else '')+
       '(ReadOnlySpan<byte> data, int levels, VoxelBox box, '+('VoxelFilter<T>' if generic else 'VoxelFilter')+' filter)\n'+
       ('        where TStorage : unmanaged, IEquatable<TStorage>\n' if generic else '')+'    {\n')
    assert source.count(anchor)==1
    fast=('#if NET10_0_OR_GREATER\n'
      '        if (BitConverter.IsLittleEndian && System.Runtime.Intrinsics.Vector128.IsHardwareAccelerated &&\n'
      '            ((box.MinY == 0 && box.MaxY == (1 << levels) && box.MinZ == 0 && box.MaxZ == (1 << levels)) || box.MaxZ - box.MinZ >= 16))\n'
      f'            return CountPackedVector{"<TStorage>" if generic else ""}(data, levels, box, filter);\n#endif\n')
    source=source.replace(anchor,anchor+fast)
    dense='    private static void Dense'+('<TStorage>' if generic else '')+'('
    assert source.count(dense)==1
    source=source.replace(dense,(here/('PackedCountVectorGeneric.cs.txt' if generic else 'PackedCountVectorLegacy.cs.txt')).read_text()+'\n'+dense)
    path.write_text(source,encoding='utf-8')
for file,snippet in [('VoxelFilter.cs','PackedCountVectorFilter.cs.txt'),('VoxelFilter.Generic.cs','PackedCountVectorFilterGeneric.cs.txt')]:
    path=fork/file;source=path.read_text();anchor='    public bool Matches('
    start=source.index(anchor);end=source.index('\n',start)
    source=source[:end+1]+'\n'+(here/snippet).read_text()+source[end+1:]
    path.write_text(source,encoding='utf-8')
fixture.write_text((here/'PackedCountTests.cs.txt').read_text()+'\n'+(here/'PackedCountVectorCases.cs.txt').read_text(),encoding='utf-8')
print(fork)
