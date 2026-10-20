"""Prepare exact-array storage as an isolated refinement or a joint-state grid."""
import argparse
from pathlib import Path
import shutil
import subprocess
parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
parser.add_argument('--joint', action='store_true')
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
here = Path(__file__).resolve().parent
repo = here.parents[3]
fork = task / ('leaf-byte-source' if args.joint else 'array-storage-source')
if fork.exists():
    raise SystemExit('Fork exists; inspect the prior operation before recovery')
if args.joint:
    shutil.copytree(task / 'leaf-state-source', fork)
else:
    fork.mkdir()
    paths = subprocess.check_output(['git', '-C', str(repo), 'ls-tree', '-r', '--name-only', 'f0772c8', '--', 'src/Tedd.Voxtree'], text=True).splitlines()
    for path in paths:
        if path.endswith('.cs'):
            (fork / Path(path).name).write_text(subprocess.check_output(['git', '-C', str(repo), 'show', f'f0772c8:{path}'], text=True), encoding='utf-8')

def edit(path, before, after):
    text = path.read_text()
    if text.count(before) != 1:
        raise RuntimeError(f'{path.name}: source anchor mismatch: {before}')
    path.write_text(text.replace(before, after), encoding='utf-8')

main = fork / 'OctreeLookup.cs'
for before, after in [
    ('private readonly ReadOnlyMemory<byte> _dense;', 'private readonly byte[]? _dense;'),
    ('ReadOnlyMemory<byte> ownedEncoding)', 'byte[]? ownedEncoding)'),
    ('_dense = ownedEncoding.IsEmpty ? encoded.ToArray() : ownedEncoding;', '_dense = ownedEncoding ?? encoded.ToArray();'),
    ('!_dense.IsEmpty ? _dense.Length', '_dense is not null ? _dense.Length'),
    ('if (_dense.IsEmpty)', 'if (_dense is null)'),
    ('_dense.Span.Slice(', '_dense.AsSpan().Slice('),
]:
    edit(main, before, after)
if args.joint:
    for before, after in [
        ('out var palette, out var prefixWords)', 'out var palette, out var grid, out var prefixWords)'),
        ('            _nodes = palette;', '            _nodes = palette;\n            _dense = grid;'),
        ('_nodes.Length * sizeof(uint) :', '_nodes.Length * sizeof(uint) + (_uniform != 0 ? _dense!.Length : 0) :'),
    ]:
        edit(main, before, after)
    helper = fork / 'OctreeLookup.Packed.cs'
    for before, after in [
        ('// contain four byte-sized state indices, independent of native byte order.', '// use a separate byte array of exact state indices.'),
        ('out uint[] result, out uint prefixWords)', 'out uint[] result, out byte[] grid, out uint prefixWords)'),
        ('        result = Array.Empty<uint>();', '        result = Array.Empty<uint>();\n        grid = Array.Empty<byte>();'),
        ('count + 16L > nodeCount * 36L', 'count + 32L > nodeCount * 36L'),
        ('count + used * 8L > nodeCount * 36L', 'count + used * 8L + 16 > nodeCount * 36L'),
        ('result = new uint[checked(used * 2 + count / 4)];', 'result = new uint[used * 2];\n        grid = new byte[count];'),
        ('states[..used], (int)prefixWords, result);', 'states[..used], grid);'),
        ('ReadOnlySpan<ulong> states, int prefix, uint[] result)', 'ReadOnlySpan<ulong> states, byte[] grid)'),
        ('levels, states, prefix, result);', 'levels, states, grid);'),
        ('                        FillStateBytes(result, prefix, (xx << (levels * 2)) + (yy << levels) + c, half, (uint)index);', '''                    {
                        int start = (xx << (levels * 2)) + (yy << levels) + c;
                        if (half == 1) grid[start] = (byte)index;
                        else grid.AsSpan(start, half).Fill((byte)index);
                    }'''),
        ('int state = (int)((data[(int)_uniform + (index >> 2)] >> ((index & 3) << 3)) & 255) * 2;', 'int state = _dense![index] * 2;'),
    ]:
        edit(helper, before, after)
    text = helper.read_text()
    start = text.index('    private static void FillStateBytes(')
    end = text.index('    private uint GetPacked(', start)
    helper.write_text(text[:start] + text[end:], encoding='utf-8')
print(fork)
