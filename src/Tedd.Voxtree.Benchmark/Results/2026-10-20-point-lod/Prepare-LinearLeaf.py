"""P22: direct bottom-level summaries, starting from released source only."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
args = parser.parse_args()
root = args.task_root.resolve()
assert root == Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo = Path(__file__).resolve().parents[4]
control, fork = root / 'p22-release-source', root / 'linear-leaf-source'
assert not control.exists() and not fork.exists(), 'P22 source exists; inspect before recovery'
control.mkdir()
fork.mkdir()
revision = subprocess.check_output(['git', '-C', str(repo), 'rev-parse', 'f0772c8'], text=True).strip()
files = subprocess.check_output(['git', '-C', str(repo), 'ls-tree', '-r', '--name-only', revision,
                                 '--', 'src/Tedd.Voxtree'], text=True).splitlines()
manifest = []
for name in files:
    if not name.endswith('.cs'):
        continue
    data = subprocess.check_output(['git', '-C', str(repo), 'show', f'{revision}:{name}'])
    (control / Path(name).name).write_bytes(data)
    (fork / Path(name).name).write_bytes(data)
    manifest.append({'path': name, 'sha256': hashlib.sha256(data).hexdigest()})
for name, generic in [('OctreeCodec.cs', False), ('GenericOctreeCodec.cs', True)]:
    path = fork / name
    source = path.read_text()
    start = source.index('    private static bool BuildLinearSubtree(')
    end = source.index('    private static bool BuildMortonSubtree(', start)
    section = source[start:end]
    anchor = '        var subtreeStart = writer.Position;'
    assert section.count(anchor) == 1
    section = section.replace(anchor, '''        if (level == 1)
            return BuildLinearLeaf(source, baseIndex, rowStride, planeStride, ref writer, out result);

''' + anchor)
    source = source[:start] + section + source[end:]
    typ = 'TStorage' if generic else 'uint'
    equal = lambda n: f'v{n}.Equals(v0)' if generic else f'v{n} == v0'
    write = 'WriteValue' if generic else 'WriteVarUInt'
    helper = f'''    // Wire children are Z-first. A bottom node contains only value tokens.
    private static bool BuildLinearLeaf(ReadOnlySpan<{typ}> source, int start,
        int rowStride, int planeStride, ref OctreeWriter writer, out SubtreeResult result)
    {{
        var v0 = source[start];
        var v1 = source[start + 1];
        var v2 = source[start + rowStride];
        var v3 = source[start + rowStride + 1];
        var v4 = source[start + planeStride];
        var v5 = source[start + planeStride + 1];
        var v6 = source[start + planeStride + rowStride];
        var v7 = source[start + planeStride + rowStride + 1];
        if ({' && '.join(equal(i) for i in range(1, 8))})
        {{
            result = SubtreeResult.Uniform(v0);
            return true;
        }}
        var nodeOffset = writer.Position;
        if (!writer.WriteByte(255) || {' || '.join(f'!writer.{write}(v{i})' for i in range(8))})
        {{
            result = default;
            return false;
        }}
        result = SubtreeResult.Node(nodeOffset);
        return true;
    }}

'''
    anchor = '    private static bool BuildMortonSubtree('
    assert source.count(anchor) == 1
    source = source.replace(anchor, helper + anchor)
    path.write_text(source, encoding='utf-8')
(root / 'p22-source-origin.json').write_text(json.dumps({'control': revision, 'files': manifest}, indent=2) + '\n')
print(json.dumps({'control': str(control), 'candidate': str(fork), 'revision': revision}))
