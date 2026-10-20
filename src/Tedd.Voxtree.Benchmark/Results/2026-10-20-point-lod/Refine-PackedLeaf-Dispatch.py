"""Keep legacy uniform/dense dispatch order in the unbuilt P15 prototype."""
import argparse
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
if args.task_root.resolve() != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
fork = args.task_root / 'packed-leaf-source'
if (args.task_root / 'p15').exists():
    raise SystemExit('P15 build exists; do not mutate bound sources')

for name, typ in [('OctreeCodec.cs', 'uint'), ('GenericOctreeCodec.cs', 'TStorage')]:
    path = fork / name
    source = path.read_text()
    helper = f'PackedLeafEncoding<{typ}>'
    def edit(before, after):
        global source
        if source.count(before) != 1:
            raise RuntimeError(f'{name}: dispatch source anchor changed: {before}')
        source = source.replace(before, after)
    version = 'version' if typ == 'uint' else '((metadata & VersionMask) >> VersionShift)'
    original = 'version != Octree.FormatVersion' if typ == 'uint' else '((metadata & VersionMask) >> VersionShift) != Version || data[2] != GetSizeCode()'
    edit(f'''        if ({version} == 3)
        {{
            storageKind = StorageKind.PackedLeaf;
            return {helper}.TryReadHeader(data, HeaderSize, out levels);
        }}
        if ({original})
            return false;''', f'''        if ({original})
        {{
            if ({version} != 3) return false;
            storageKind = StorageKind.PackedLeaf;
            return {helper}.TryReadHeader(data, HeaderSize, out levels);
        }}''')
    packed = f'''        if (storageKind == StorageKind.PackedLeaf)
            return {helper}.IsWellFormed(data, HeaderSize, levels);
'''
    normal = '''        if (storageKind is StorageKind.Uniform or StorageKind.Dense)
            return true;
'''
    edit(packed + normal, normal + packed)
    packed = f'''        if (storageKind == StorageKind.PackedLeaf)
            return {helper}.TryGet(data, HeaderSize, levels, x, y, z, out value, out lodLevel);
'''
    edit(packed, '')
    if typ == 'uint':
        anchor = '''            value = BinaryPrimitives.ReadUInt32LittleEndian(data.Slice(byteOffset, sizeof(uint)));
            return true;
        }
'''
    else:
        anchor = '''            return TryReadFixedValue(data, HeaderSize + (flatIndex * ValueSize), out value);
        }
'''
    edit(anchor, anchor + packed)
    path.write_text(source, encoding='utf-8')
