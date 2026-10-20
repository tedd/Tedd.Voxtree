"""Prepare P6 in the task-owned source fork; never edit production source."""
import argparse
import re
from pathlib import Path
import shutil
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('task_root', type=Path)
parser.add_argument('--name', default='dense-byte-source')
parser.add_argument('--fixture-name', default='Scenarios-byte.cs.txt')
parser.add_argument('--fixture-version', default='4')
args = parser.parse_args()
task = args.task_root.resolve()
if task.parent != Path('D:/Workspaces/AI').resolve():
    raise SystemExit('Expected a dedicated task workspace')
here = Path(__file__).resolve().parent
repo = here.parents[3]
if not re.fullmatch('[a-z][a-z0-9-]*', args.name) or not re.fullmatch(r'[A-Za-z][A-Za-z0-9.-]*\.cs\.txt', args.fixture_name):
    raise SystemExit('Invalid source/fixture label')
fork = task / args.name
if fork.exists():
    raise SystemExit('Fork exists; inspect prior operations before recovery')
fork.mkdir()
paths = subprocess.check_output(['git', '-C', str(repo), 'ls-tree', '-r', '--name-only', 'f0772c8', '--', 'src/Tedd.Voxtree'], text=True).splitlines()
for path in paths:
    if path.endswith('.cs'):
        content = subprocess.check_output(['git', '-C', str(repo), 'show', f'f0772c8:{path}'], text=True)
        (fork / Path(path).name).write_text(content, encoding='utf-8')
shutil.copyfile(here / 'DenseByteEncoding.cs.txt', fork / 'DenseByteEncoding.cs')


def edit(name, before, after):
    path = fork / name
    text = path.read_text(encoding='utf-8')
    if text.count(before) != 1:
        raise RuntimeError(f'{name}: expected one source anchor, got {text.count(before)}: {before[:80]}')
    path.write_text(text.replace(before, after, 1), encoding='utf-8')


edit('OctreeCodec.cs', '    Dense = 2\n', '    Dense = 2,\n    DenseByte = 3\n')
edit('OctreeCodec.cs', '''        if (plan.StorageKind == StorageKind.Uniform)''', '''        if (plan.StorageKind == StorageKind.DenseByte)
        {
            DenseByteEncoding.Write(source, levels, layout, encoded);
            return encoded;
        }

        if (plan.StorageKind == StorageKind.Uniform)''')
edit('OctreeCodec.cs', '''        var denseLength = GetDenseSize(source.Length);

        var writer = new OctreeWriter(Span<byte>.Empty''', '''        if (DenseByteEncoding.IsEligible(source, levels, layout))
            return BuildPlan.DenseByte(DenseByteEncoding.HeaderSize + source.Length);
        var denseLength = GetDenseSize(source.Length);

        var writer = new OctreeWriter(Span<byte>.Empty''')
edit('OctreeCodec.cs', '''        bytesWritten = 0;
        if (destination.Length < HeaderSize + 1)''', '''        bytesWritten = 0;
        if (DenseByteEncoding.IsEligible(source, levels, layout))
        {
            var required = DenseByteEncoding.HeaderSize + source.Length;
            if (destination.Length < required) return false;
            DenseByteEncoding.Write(source, levels, layout, destination);
            bytesWritten = required;
            return true;
        }
        if (destination.Length < HeaderSize + 1)''')
edit('OctreeCodec.cs', '''        if (version != Octree.FormatVersion)''', '''        if (version == DenseByteEncoding.Version)
        {
            storageKind = StorageKind.DenseByte;
            return DenseByteEncoding.TryReadHeader(data, out levels);
        }
        if (version != Octree.FormatVersion)''')
edit('OctreeCodec.cs', 'storageKind is StorageKind.Uniform or StorageKind.Dense)', 'storageKind is StorageKind.Uniform or StorageKind.Dense or StorageKind.DenseByte)')
edit('OctreeCodec.cs', '        var dense = data[HeaderSize..];', '        var dense = data[(storageKind == StorageKind.DenseByte ? DenseByteEncoding.HeaderSize : HeaderSize)..];')
edit('OctreeCodec.cs', '''        var sideLength = 1 << levels;

        if (storageKind == StorageKind.Uniform)''', '''        var sideLength = 1 << levels;

        if (storageKind == StorageKind.DenseByte)
        {
            value = data[DenseByteEncoding.HeaderSize + (x * sideLength + y) * sideLength + z];
            return true;
        }
        if (storageKind == StorageKind.Uniform)''')
edit('OctreeCodec.cs', '''        destination = destination[..count];
        if (storageKind == StorageKind.Uniform)''', '''        destination = destination[..count];
        if (storageKind == StorageKind.DenseByte)
        {
            DenseByteEncoding.CopyTo(data, levels, destination, layout);
            return true;
        }
        if (storageKind == StorageKind.Uniform)''')
edit('OctreeCodec.cs', '''        internal static BuildPlan Dense(int encodedLength) =>''', '''        internal static BuildPlan DenseByte(int encodedLength) =>
            new(encodedLength, StorageKind.DenseByte, default);

        internal static BuildPlan Dense(int encodedLength) =>''')
edit('OctreeLookup.cs', '''        if (kind == StorageKind.Dense)''', '''        if (kind == StorageKind.DenseByte)
        {
            _dense = DenseByteEncoding.ExpandForLookup(encoded, Levels);
            return;
        }
        if (kind == StorageKind.Dense)''')

filter_methods = '''
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal int CountBytes(ReadOnlySpan<byte> values)
    {
#if NET10_0_OR_GREATER
        if (_expected > byte.MaxValue) return _negate ? values.Length : 0;
        var mask = (byte)_mask;
        if (mask == 0) return _negate ? 0 : values.Length;
        return MaskedVoxelSearch<byte>.Count(values, mask, (byte)_expected, _negate);
#else
        var count = 0;
        foreach (var value in values) if (Matches(value)) count++;
        return count;
#endif
    }

    internal bool AnyBytes(ReadOnlySpan<byte> values)
    {
#if NET10_0_OR_GREATER
        if (_expected > byte.MaxValue) return _negate && !values.IsEmpty;
        var mask = (byte)_mask;
        if (mask == 0) return !_negate && !values.IsEmpty;
        return MaskedVoxelSearch<byte>.Any(values, mask, (byte)_expected, _negate);
#else
        foreach (var value in values) if (Matches(value)) return true;
        return false;
#endif
    }

'''
edit('VoxelFilter.cs', '    [MethodImpl(MethodImplOptions.AggressiveInlining)]\n    internal int CountIn(ReadOnlySpan<uint> values)', filter_methods + '    [MethodImpl(MethodImplOptions.AggressiveInlining)]\n    internal int CountIn(ReadOnlySpan<uint> values)')

query = (fork / 'OctreeQueries.cs').read_text(encoding='utf-8')
start = query.index('    private static int CountDense(')
end = query.index('    internal ref struct State', start)
byte_scans = query[start:end].replace('CountDense(', 'CountDenseBytes(').replace('AnyDense(', 'AnyDenseBytes(').replace('ReadOnlySpan<uint>', 'ReadOnlySpan<byte>').replace('filter.CountIn(', 'filter.CountBytes(').replace('filter.AnyIn(', 'filter.AnyBytes(')
byte_query = '''    private static void DenseBytes(ReadOnlySpan<byte> data, int side, ref State state)
    {
        var box = state.Box;
        var values = data[DenseByteEncoding.HeaderSize..];
        if (state.Kind == QueryKind.Count)
        {
            state.Count += CountDenseBytes(values, side, box, state.Filter);
            return;
        }
        if (state.Kind == QueryKind.Any)
        {
            if (AnyDenseBytes(values, side, box, state.Filter)) { state.Count = 1; state.Done = true; }
            return;
        }
        if (state.Kind == QueryKind.Copy && state.RingSide == 0 &&
            box.MinX == 0 && box.MinY == 0 && box.MinZ == 0 &&
            box.MaxX == side && box.MaxY == side && box.MaxZ == side &&
            state.CopyBounds.MinX == 0 && state.CopyBounds.MinY == 0 && state.CopyBounds.MinZ == 0 &&
            state.CopyBounds.MaxX == side && state.CopyBounds.MaxY == side && state.CopyBounds.MaxZ == side)
        {
            var levels = 0;
            for (var length = side; length > 1; length >>= 1) levels++;
            DenseByteEncoding.CopyTo(data, levels, state.Values[..box.Count], state.OutputLayout);
            return;
        }
        for (var x = box.MinX; x < box.MaxX && !state.Done; x++)
        for (var y = box.MinY; y < box.MaxY && !state.Done; y++)
        for (var z = box.MinZ; z < box.MaxZ && !state.Done; z++)
            state.Accept(new VoxelBox(x, y, z, x + 1, y + 1, z + 1), values[(x * side + y) * side + z]);
    }

'''
edit('OctreeQueries.cs', '''        if (kind == StorageKind.Dense)''', '''        if (kind == StorageKind.DenseByte)
        {
            DenseBytes(data, tree.SideLength, ref state);
            return;
        }
        if (kind == StorageKind.Dense)''')
edit('OctreeQueries.cs', '    internal ref struct State', byte_query + byte_scans + '    internal ref struct State')
print(f'Prepared isolated P6 source: {fork}')

# The candidate intentionally changes full-tree bytes; other fixture inputs
# retain byte parity. Independent value/LOD checks still run on both arms.
fixture = (here / 'Scenarios-precision.cs.txt').read_text(encoding='utf-8')
head, legacy_and_rest = fixture.split('public sealed class LegacyScenario', 1)
legacy, rest = legacy_and_rest.split('public sealed class WideScenario', 1)
legacy = legacy.replace('if(!tree.Data.Span.SequenceEqual(before.Data.Span))throw new Exception("Encoding parity");', 'if(!tree.Data.Span.SequenceEqual(before.Data.Span) && !((tree.Data.Span[1]>>6)==3 && (tree.Data.Span[1]&3)==3 && tree.Data.Length==values.Length+3))throw new Exception("Unchanged-format encoding parity");')
legacy = legacy.replace('if((tree.Data.Span[1]&3)!=expectedKind)throw new Exception("Storage kind");', 'if((tree.Data.Span[1]&3)!=expectedKind && !(pattern=="full" && (tree.Data.Span[1]&3)==3))throw new Exception("Storage kind");')
legacy = legacy.replace('new Octree(2,dense).Data.ToArray()', 'new Before.Octree(2,dense).Data.ToArray()')
fixture = head + 'public sealed class LegacyScenario' + legacy + 'public sealed class WideScenario' + rest
fixture = fixture.replace(',"3",', f',"{args.fixture_version}",')
(here / args.fixture_name).write_text(fixture, encoding='utf-8')
