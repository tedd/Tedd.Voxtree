"""Split P15's large reader without changing its tree algorithm or getter hints."""
import argparse
from pathlib import Path
import shutil

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
task = args.task_root.resolve()
if task != Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve():
    raise SystemExit('Unexpected task root')
fork = task / 'reader-split-source'
if fork.exists():
    raise SystemExit('Reader fork exists; inspect original operation before recovery')
shutil.copytree(task / 'p15/source', fork)
for name, typ in [('OctreeCodec.cs', 'uint'), ('GenericOctreeCodec.cs', 'TStorage')]:
    path = fork / name
    source = path.read_text()
    marker = 'out int lodLevel)\n    {'
    if source.count(marker) != 1:
        raise RuntimeError(f'{name}: reader signature changed')
    signature_end = source.index(marker) + len(marker)
    body_start = signature_end - 1
    signature_start = source.rfind('    internal static bool TryGetUnchecked(', 0, signature_end)
    depth, end = 1, body_start + 1
    while depth:
        if source[end] == '{': depth += 1
        if source[end] == '}': depth -= 1
        end += 1
    body = source[body_start + 1:end - 1]
    tree_marker = '        if (levels == 0 || data.Length < HeaderSize + MinimumNodeSize + 1)'
    if body.count(tree_marker) != 1:
        raise RuntimeError(f'{name}: tree boundary changed')
    prefix, tree = body.split(tree_marker, 1)
    initial = '        value = default;\n        lodLevel = 0;\n'
    if prefix.count(initial) != 1:
        raise RuntimeError(f'{name}: output initialization changed')
    prefix = prefix.replace(initial, '')
    for kind in ['Uniform', 'Dense']:
        anchor = f'        if (storageKind == StorageKind.{kind})\n        {{\n'
        if prefix.count(anchor) != 1:
            raise RuntimeError(f'{name}: fast branch changed')
        prefix = prefix.replace(anchor, anchor + initial.replace('        ', '            '))
    signature = source[signature_start:body_start]
    replacement = ('    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.AggressiveInlining)]\n'
        + signature + '{' + prefix + '''        return TryGetTreeUnchecked(data, levels, x, y, z, out value, out lodLevel);
    }

    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.NoInlining)]
    private static bool TryGetTreeUnchecked(ReadOnlySpan<byte> data, int levels,
        int x, int y, int z, out ''' + typ + ''' value, out int lodLevel)
    {
''' + initial + ('        var sideLength = 1 << levels;\n' if 'sideLength' in tree else '') + tree_marker + tree + '}')
    path.write_text(source[:signature_start] + replacement + source[end:], encoding='utf-8')
print(fork)
