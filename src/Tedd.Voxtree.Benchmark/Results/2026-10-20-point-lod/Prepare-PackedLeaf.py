"""Prepare isolated P15 from f0772c8; reject changed source anchors."""
import argparse
from pathlib import Path
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
here = Path(__file__).resolve().parent
repo = here.parents[3]
fork = task / 'packed-leaf-source'
if fork.exists():
    raise SystemExit('Fork exists; inspect prior work before recovery')
fork.mkdir()
for path in subprocess.check_output(['git', '-C', str(repo), 'ls-tree', '-r', '--name-only',
                                     'f0772c8', '--', 'src/Tedd.Voxtree'], text=True).splitlines():
    if path.endswith('.cs'):
        (fork / Path(path).name).write_text(subprocess.check_output(
            ['git', '-C', str(repo), 'show', f'f0772c8:{path}'], text=True), encoding='utf-8')
(fork / 'PackedLeafEncoding.cs').write_text((here / 'PackedLeafEncoding.cs.txt').read_text(), encoding='utf-8')

def edit(name, before, after):
    path = fork / name
    text = path.read_text()
    if text.count(before) != 1:
        raise RuntimeError(f'{name}: expected one source anchor: {before}')
    path.write_text(text.replace(before, after), encoding='utf-8')

edit('OctreeCodec.cs', '    Dense = 2\n', '    Dense = 2,\n    PackedLeaf = 3\n')
for name, storage in [('OctreeCodec.cs', 'uint'), ('GenericOctreeCodec.cs', 'TStorage')]:
    helper = f'PackedLeafEncoding<{storage}>'
    anchor = '        if (plan.StorageKind == StorageKind.Uniform)'
    edit(name, anchor, f'''        if (plan.StorageKind == StorageKind.PackedLeaf)
        {{
            {helper}.Write(source, levels, layout, encoded, HeaderSize);
            return encoded;
        }}
{anchor}''')
    if storage == 'uint':
        before = '''        return writer.Position < denseLength
            ? BuildPlan.Tree(writer.Position)
            : BuildPlan.Dense(denseLength);'''
    else:
        before = '        return writer.Position < denseLength ? BuildPlan.Tree(writer.Position) : BuildPlan.Dense(denseLength);'
    edit(name, before, f'''        if (writer.Position >= denseLength) return BuildPlan.Dense(denseLength);
        return {helper}.Select(source, levels, writer.Position, denseLength)
            ? BuildPlan.PackedLeaf(denseLength) : BuildPlan.Tree(writer.Position);''')
    anchor = '        if (!treeCompleted || writer.Position >= denseLength)'
    edit(name, anchor, f'''        if (treeCompleted && !root.IsUniform && writer.Position < denseLength &&
            {helper}.Select(source, levels, writer.Position, denseLength))
        {{
            if (destination.Length < denseLength) return false;
            {helper}.Write(source, levels, layout, destination, HeaderSize);
            bytesWritten = denseLength;
            return true;
        }}
{anchor}''')
    if storage == 'uint':
        anchor = '        if (version != Octree.FormatVersion)'
    else:
        anchor = '        if (((metadata & VersionMask) >> VersionShift) != Version || data[2] != GetSizeCode())'
    condition = 'version == 3' if storage == 'uint' else '((metadata & VersionMask) >> VersionShift) == 3'
    edit(name, anchor, f'''        if ({condition})
        {{
            storageKind = StorageKind.PackedLeaf;
            return {helper}.TryReadHeader(data, HeaderSize, out levels);
        }}
{anchor}''')
    anchor = '        if (storageKind is StorageKind.Uniform or StorageKind.Dense)'
    edit(name, anchor, f'''        if (storageKind == StorageKind.PackedLeaf)
            return {helper}.IsWellFormed(data, HeaderSize, levels);
{anchor}''')
    anchor = '        var dense = data[HeaderSize..];'
    edit(name, anchor, f'''        if (storageKind == StorageKind.PackedLeaf) return {helper}.IsEmpty(data, HeaderSize);
{anchor}''')
    anchor = '        lodLevel = 0;\n        var sideLength = 1 << levels;'
    edit(name, anchor, f'''        lodLevel = 0;
        if (storageKind == StorageKind.PackedLeaf)
            return {helper}.TryGet(data, HeaderSize, levels, x, y, z, out value, out lodLevel);
        var sideLength = 1 << levels;''')
    anchor = '        destination = destination[..count];'
    edit(name, anchor, f'''        destination = destination[..count];
        if (storageKind == StorageKind.PackedLeaf)
        {{
            {helper}.CopyTo(data, HeaderSize, levels, destination, layout);
            return true;
        }}''')
    if storage == 'uint':
        anchor = '        internal static BuildPlan Dense(int encodedLength) =>'
    else:
        anchor = '        internal static BuildPlan Dense(int encodedLength) => new(encodedLength, StorageKind.Dense, default);'
    edit(name, anchor, f'''        internal static BuildPlan PackedLeaf(int encodedLength) => new(encodedLength, StorageKind.PackedLeaf, default);
{anchor}''')

for name, generic in [('OctreeQueries.cs', False), ('GenericOctreeQueries.cs', True)]:
    anchor = '        if (kind == StorageKind.Dense)'
    call = 'Packed<TStorage>' if generic else 'Packed'
    edit(name, anchor, f'''        if (kind == StorageKind.PackedLeaf)
        {{
            {call}(data, tree.Levels, ref state);
            return;
        }}
{anchor}''')
    storage = 'TStorage' if generic else 'uint'
    header = f'GenericOctreeCodec<{storage}>.HeaderSize' if generic else 'OctreeCodec.HeaderSize'
    constraint = '\n        where TStorage : unmanaged, IEquatable<TStorage>' if generic else ''
    to_value = 'ToValue(value)' if generic else 'value'
    declaration = 'Packed<TStorage>' if generic else 'Packed'
    path = fork / name
    text = path.read_text()
    marker = '    private static void Dense'
    index = text.index(marker)
    text = text[:index] + f'''    private static void {declaration}(ReadOnlySpan<byte> data, int levels, ref State state){constraint}
    {{
        var box = state.Box;
        for (var x = box.MinX; x < box.MaxX && !state.Done; x++)
        for (var y = box.MinY; y < box.MaxY && !state.Done; y++)
        for (var z = box.MinZ; z < box.MaxZ && !state.Done; z++)
        {{
            if (!PackedLeafEncoding<{storage}>.TryGet(data, {header}, levels, x, y, z, out var value, out _))
                throw new FormatException("Malformed packed leaf.");
            state.Accept(new VoxelBox(x, y, z, x + 1, y + 1, z + 1), {to_value});
        }}
    }}

''' + text[index:]
    path.write_text(text, encoding='utf-8')

edit('OctreeLookup.cs', '        if (kind == StorageKind.Dense)', '''        if (kind == StorageKind.PackedLeaf)
        {
            _dense = ownedEncoding.IsEmpty ? encoded.ToArray() : ownedEncoding;
            _uniform = uint.MaxValue;
            return;
        }
        if (kind == StorageKind.Dense)''')
edit('OctreeLookup.cs', '            var index = ((x << Levels) + y) * SideLength + z;', '''            if (_uniform != 0)
            {
                if (PackedLeafEncoding<uint>.TryGet(_dense.Span, OctreeCodec.HeaderSize, Levels, x, y, z, out var value, out lodLevel)) return value;
                return OctreeThrowHelper.ThrowMalformed();
            }
            var index = ((x << Levels) + y) * SideLength + z;''')
subprocess.run([sys.executable, str(here / 'Refine-PackedLeaf-Dispatch.py'), str(task)], check=True)
print(fork)
