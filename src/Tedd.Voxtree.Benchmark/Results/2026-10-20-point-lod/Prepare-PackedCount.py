"""P19 isolates Count mode specialization from the complete P18 source."""
import argparse
from pathlib import Path
import shutil

parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
task=args.task_root.resolve()
if task!=Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():raise SystemExit('Unexpected task root')
here=Path(__file__).resolve().parent;fork=task/'packed-count-source';fixture=here/'PackedCountTests.cs.txt'
if fork.exists() or fixture.exists():raise SystemExit('P19 source/test identity exists; inspect retained work')
shutil.copytree(task/'leaf-helper-inline-source',fork)
for file,generic in [('OctreeQueries.cs',False),('GenericOctreeQueries.cs',True)]:
    path=fork/file;source=path.read_text()
    signature=('    private static void Packed<TStorage>(ReadOnlySpan<byte> data, int levels, ref State state)\n'
               '        where TStorage : unmanaged, IEquatable<TStorage>\n' if generic else
               '    private static void Packed(ReadOnlySpan<byte> data, int levels, ref State state)\n')
    anchor=signature+'    {\n'
    assert source.count(anchor)==1
    dispatch=('        if (state.Kind == QueryKind.Count)\n        {\n'
              f'            state.Count += CountPacked{"<TStorage>" if generic else ""}(data, levels, state.Box, state.Filter);\n'
              '            return;\n        }\n')
    source=source.replace(anchor,anchor+dispatch)
    dense='    private static void Dense'+('<TStorage>' if generic else '')+'('
    assert source.count(dense)==1
    helper=('    private static int CountPacked'+('<TStorage>' if generic else '')+
            '(ReadOnlySpan<byte> data, int levels, VoxelBox box, '+('VoxelFilter<T>' if generic else 'VoxelFilter')+' filter)\n'+
            ('        where TStorage : unmanaged, IEquatable<TStorage>\n' if generic else '')+
            '    {\n        var count = 0;\n'
            '        for (var x = box.MinX; x < box.MaxX; x++)\n'
            '        for (var y = box.MinY; y < box.MaxY; y++)\n'
            '        for (var z = box.MinZ; z < box.MaxZ; z++)\n        {\n'
            f'            if (!PackedLeafEncoding<{"TStorage" if generic else "uint"}>.TryGet(data, '+
            ('GenericOctreeCodec<TStorage>' if generic else 'OctreeCodec')+'.HeaderSize, levels, x, y, z, out var value, out _))\n'
            '                throw new FormatException("Malformed packed leaf.");\n'
            f'            if (filter.Matches({"ToValue(value)" if generic else "value"})) count++;\n'
            '        }\n        return count;\n    }\n\n')
    source=source.replace(dense,helper+dense)
    path.write_text(source,encoding='utf-8')
fixture.write_text((here/'PackedLeafTests.cs.txt').read_text()+'\n'+(here/'PackedCountCases.cs.txt').read_text(),encoding='utf-8')
print(fork)
