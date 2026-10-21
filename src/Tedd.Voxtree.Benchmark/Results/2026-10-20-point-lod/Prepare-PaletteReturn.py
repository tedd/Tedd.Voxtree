"""Fork complete P27 with a direct throwing palette read; keep Try paths exact."""
import argparse,hashlib,json,re,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
before=root/'byte-palette-source';after=root/'palette-return-source'
origin=json.loads((root/'p27-source-origin.json').read_text(encoding='utf-8-sig'))
sha=lambda b:hashlib.sha256(b).hexdigest()
for item in origin['manifest']:
    f=before/item['file']
    if item['after_sha256'] is None:assert not f.exists()
    else:assert sha(f.read_bytes())==item['after_sha256'],item['file']
assert not after.exists();shutil.copytree(before,after)

f=after/'PaletteLeafEncoding.cs';s=f.read_text(encoding='utf-8-sig')
marker='    [MethodImpl(MethodImplOptions.AggressiveInlining)]\n    internal static bool TryGet('
assert s.count(marker)==1
extra='''    // All-one has an invalid LOD for every supported depth, including when
    // every raw value bit is set. Bounds failures never become a table address.
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static ulong ReadStateOrInvalid(ReadOnlySpan<byte> data, int header, int levels,
        int x, int y, int z)
    {
        var index = ((x << levels) + y) * (1 << levels) + z;
        var count = OctreeCodec.GetVoxelCount(levels);
        if ((uint)index >= (uint)count) return ulong.MaxValue;
        var offset = header + 2 + index;
        if ((uint)offset >= (uint)data.Length) return ulong.MaxValue;
        var code = data[offset];
        var entry = header + 2 + count + code * EntryWidth;
        if ((uint)entry > (uint)data.Length || data.Length - entry < EntryWidth) return ulong.MaxValue;
        return ReadEntry(data.Slice(entry, EntryWidth));
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static T GetValue(ReadOnlySpan<byte> data, int header, int levels, int x, int y, int z)
    {
        if (Width is not (2 or 4)) return GenericOctreeThrowHelper<T>.ThrowMalformed();
        var word = ReadStateOrInvalid(data, header, levels, x, y, z);
        if (Lod(word) > (uint)levels) return GenericOctreeThrowHelper<T>.ThrowMalformed();
        return Value((uint)word);
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static T GetValue(ReadOnlySpan<byte> data, int header, int levels,
        int x, int y, int z, out int lod)
    {
        lod = 0;
        if (Width is not (2 or 4)) return GenericOctreeThrowHelper<T>.ThrowMalformed();
        var word = ReadStateOrInvalid(data, header, levels, x, y, z);
        var stored = Lod(word);
        if (stored > (uint)levels) return GenericOctreeThrowHelper<T>.ThrowMalformed();
        lod = (int)stored;
        return Value((uint)word);
    }

'''
s=s.replace(marker,extra+marker);f.write_text(s,encoding='utf-8')

f=after/'OctreeCodec.cs';s=f.read_text(encoding='utf-8-sig')
marker='    internal static bool TryGetUnchecked(\n'
assert s.count(marker)==2
extra='''    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static uint GetUnchecked(ReadOnlySpan<byte> data, int levels, StorageKind storageKind,
        int x, int y, int z)
    {
        if (storageKind == StorageKind.PackedLeaf)
            return PaletteLeafEncoding<uint>.GetValue(data, HeaderSize, levels, x, y, z);
        if (!TryGetUnchecked(data, levels, storageKind, x, y, z, out var value))
            return OctreeThrowHelper.ThrowMalformed();
        return value;
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static uint GetUnchecked(ReadOnlySpan<byte> data, int levels, StorageKind storageKind,
        int x, int y, int z, out int lod)
    {
        if (storageKind == StorageKind.PackedLeaf)
            return PaletteLeafEncoding<uint>.GetValue(data, HeaderSize, levels, x, y, z, out lod);
        if (!TryGetUnchecked(data, levels, storageKind, x, y, z, out var value, out lod))
            return OctreeThrowHelper.ThrowMalformed();
        return value;
    }

'''
s=s.replace(marker,extra+marker,1);f.write_text(s,encoding='utf-8')

f=after/'VoxelType.cs';s=f.read_text(encoding='utf-8-sig')
marker='    internal static bool TryGet(ReadOnlySpan<byte> data, int levels, StorageKind storageKind,'
assert s.count(marker)==1
extra=''
for lod in [False,True]:
    suffix=', out int lod' if lod else '';output=', out lod' if lod else ''
    extra+=f'''    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static T GetUnchecked(ReadOnlySpan<byte> data, int levels, StorageKind storageKind,
        int x, int y, int z{suffix})
    {{
        if (storageKind == StorageKind.PackedLeaf)
        {{
            if (Unsafe.SizeOf<T>() == 2)
            {{
                var storage = PaletteLeafEncoding<ushort>.GetValue(data, GenericOctreeCodec<ushort>.HeaderSize,
                    levels, x, y, z{output});
                return Unsafe.As<ushort, T>(ref storage);
            }}
            if (Unsafe.SizeOf<T>() == 4)
            {{
                var storage = PaletteLeafEncoding<uint>.GetValue(data, GenericOctreeCodec<uint>.HeaderSize,
                    levels, x, y, z{output});
                return Unsafe.As<uint, T>(ref storage);
            }}
        }}
        if (!TryGetUnchecked(data, levels, storageKind, x, y, z, out var value{output}))
            return GenericOctreeThrowHelper<T>.ThrowMalformed();
        return value;
    }}

'''
s=s.replace(marker,extra+marker);f.write_text(s,encoding='utf-8')

counts={}
for name,codec,helper,expected in [('Octree.cs','OctreeCodec','OctreeThrowHelper',1),
                                   ('OctreeSpan.cs','OctreeCodec','OctreeThrowHelper',2),
                                   ('Octree.Generic.cs','VoxelCodec<T>','GenericOctreeThrowHelper<T>',3)]:
    f=after/name;s=f.read_text(encoding='utf-8-sig')
    pattern=re.compile(r'        if \(!'+re.escape(codec)+r'\.TryGetUnchecked\((.*?)out var value(, out lodLevel)?\)\)\s*(?:\{\s*)?return '+re.escape(helper)+r'\.ThrowMalformed\(\);(?:\s*\})?\s*return value;',re.S)
    def replace(m):
        args=m[1].rstrip().rstrip(',').rstrip();tail=m[2] or ''
        return f'        return {codec}.GetUnchecked({args}{tail});'
    s,n=pattern.subn(replace,s);assert n==expected,(name,n);counts[name]=n;f.write_text(s,encoding='utf-8')

norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
manifest=[]
for f in sorted(before.glob('*.cs')):
    x=f.read_bytes();y=(after/f.name).read_bytes();manifest.append({'file':f.name,'before_sha256':sha(x),'after_sha256':sha(y),'normalized_changed':norm(x)!=norm(y)})
changed=[x['file'] for x in manifest if x['normalized_changed']]
assert set(changed)=={'PaletteLeafEncoding.cs','OctreeCodec.cs','VoxelType.cs','Octree.cs','OctreeSpan.cs','Octree.Generic.cs'},changed
# Existing boolean/out readers are byte-normalized identical, not merely similar.
for name,start in [('OctreeCodec.cs','    internal static bool TryGetUnchecked('),('VoxelType.cs','    internal static bool TryGet(ReadOnlySpan<byte>'),('PaletteLeafEncoding.cs','    internal static bool TryGet(')]:
    x=(before/name).read_text(encoding='utf-8-sig');y=(after/name).read_text(encoding='utf-8-sig')
    assert x[x.index(start):]==y[y.index(start):],name
(root/'p29-source-origin.json').write_text(json.dumps({'parent':'complete P27','changed_files':changed,'getter_sites':counts,'manifest':manifest,'performance_measured':False},indent=2)+'\n')
print(json.dumps({'source':str(after),'changed_files':changed,'getter_sites':counts}))
