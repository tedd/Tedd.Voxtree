"""Isolate the P25 writer algorithm; packed wire bytes and readers stay unchanged."""
import argparse,hashlib,json,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
before=root/'packed-word-format-source';after=root/'packed-bottom-up-source'
origin=json.loads((root/'p24-source-origin.json').read_text())
for item in origin['manifest']:
    assert hashlib.sha256((before/item['file']).read_bytes()).hexdigest()==item['after_sha256'],item['file']
assert not after.exists();shutil.copytree(before,after)
f=after/'PackedLeafEncoding.cs';s=f.read_text(encoding='utf-8-sig')
s=s.replace('WriteCube(source, levels, layout, destination[header..], 0, 0, 0, levels);','WriteBottomUp(source, levels, layout, destination[header..]);')
start=s.index('    private static void WriteCube(');end=s.index('    private static bool Uniform(',start)
replacement='''    private static void WriteBottomUp(ReadOnlySpan<T> source, int levels, DenseVoxelLayout layout,
        Span<byte> body)
    {
        var side = 1 << levels;
        for (var x = 0; x < side; x++)
        for (var y = 0; y < side; y++)
        for (var z = 0; z < side; z++)
        {
            var index = (x * side + y) * side + z;
            WriteWord(body.Slice(index * Width, Width), Raw(source[DenseVoxel.Index(x, y, z, side, layout)]));
        }

        for (var level = 1; level <= levels; level++)
        {
            var size = 1 << level;
            var half = size >> 1;
            for (var x = 0; x < side; x += size)
            for (var y = 0; y < side; y += size)
            for (var z = 0; z < side; z += size)
            {
                var offset = ((x * side + y) * side + z) * Width;
                var word = ReadWord(body.Slice(offset, Width));
                if ((word >> Bits) != (uint)(level - 1)) continue;
                var equal = true;
                for (var child = 1; child < 8; child++)
                {
                    var cx = x + ((child >> 2) & 1) * half;
                    var cy = y + ((child >> 1) & 1) * half;
                    var cz = z + (child & 1) * half;
                    var childOffset = ((cx * side + cy) * side + cz) * Width;
                    if (ReadWord(body.Slice(childOffset, Width)) != word) { equal = false; break; }
                }
                if (equal) WriteWord(body.Slice(offset, Width), (word & Mask) | ((uint)level << Bits));
            }
        }
        FillMarked(body, side, 0, 0, 0, levels);
    }

    private static void FillMarked(Span<byte> body, int side, int x, int y, int z, int level)
    {
        var word = ReadWord(body.Slice(((x * side + y) * side + z) * Width, Width));
        var size = 1 << level;
        if ((word >> Bits) == (uint)level)
        {
            for (var xx = x; xx < x + size; xx++)
            for (var yy = y; yy < y + size; yy++)
            {
                var row = body.Slice(((xx * side + yy) * side + z) * Width, size * Width);
                if (BitConverter.IsLittleEndian)
                {
                    if (Width == 2) MemoryMarshal.Cast<byte, ushort>(row).Fill((ushort)word);
                    else MemoryMarshal.Cast<byte, uint>(row).Fill(word);
                }
                else for (var zz = 0; zz < size; zz++) WriteWord(row.Slice(zz * Width, Width), word);
            }
            return;
        }
        var half = size >> 1;
        for (var child = 0; child < 8; child++)
            FillMarked(body, side, x + ((child >> 2) & 1) * half,
                y + ((child >> 1) & 1) * half, z + (child & 1) * half, level - 1);
    }

'''
s=s[:start]+replacement+s[end:];f.write_text(s,encoding='utf-8')
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n')
changed=[x.name for x in after.glob('*.cs') if norm(x.read_bytes())!=norm((before/x.name).read_bytes())]
assert changed==['PackedLeafEncoding.cs']
old=(before/f.name).read_text(encoding='utf-8-sig')
assert old[old.index('    private static uint Raw('):]==s[s.index('    private static uint Raw('):]
(root/'p25-source-origin.json').write_text(json.dumps({'parent':'complete P24','changed_files':changed,
    'reader_tail_identical':True,'before_sha256':hashlib.sha256((before/f.name).read_bytes()).hexdigest(),
    'after_sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'extra_arrays':0},indent=2)+'\n')
print('P25 writer-only source generated; no performance inference')
