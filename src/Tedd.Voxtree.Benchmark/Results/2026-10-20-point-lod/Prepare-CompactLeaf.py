"""Create P31 on complete P30; replace unpublished Q with checked R words."""
import argparse,hashlib,json,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('task_root',type=Path);a=p.parse_args()
root=a.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;before=root/'build-plan-reuse-source';after=root/'compact-leaf13-source'
read=lambda f:json.loads(f.read_text(encoding='utf-8-sig'))
assert read(root/'k2-audit.json')['state']=='supported'
assert read(root/'p30-disposition.json')['primaryPassed']
origin=read(root/'p30-source-origin.json');sha=lambda b:hashlib.sha256(b).hexdigest()
for item in origin['manifest']:assert sha((before/item['file']).read_bytes())==item['after_sha256'],item['file']
assert not after.exists();shutil.copytree(before,after)
for f in after.glob('*.cs'):
    if f.name=='PaletteLeafEncoding.cs':continue
    s=f.read_text(encoding='utf-8-sig')
    n=s.replace('PaletteLeafEncoding<','CompactLeafEncoding<').replace('PaletteLeafFormatVersion','CompactLeafFormatVersion')
    n=n.replace('packed leaf words with magic byte 0x50','13-bit value/3-bit LOD words with magic byte 0x52')
    n=n.replace('byte-indexed value/leaf-LOD palette representation','compact value/leaf-LOD word representation')
    if n!=s:f.write_text(n,encoding='utf-8')
(after/'PaletteLeafEncoding.cs').unlink()
for name in ['CompactLeafEncoding','CompactWordSearch']:shutil.copyfile(research/(name+'.cs.txt'),after/(name+'.cs'))

for name,generic in [('VoxelFilter.cs',False),('VoxelFilter.Generic.cs',True)]:
    f=after/name;s=f.read_text(encoding='utf-8-sig')
    marker='    internal int CountIn(ReadOnlySpan<'+('T' if generic else 'uint')+'> values)'
    # Insert before the existing CountIn inlining attribute rather than detaching it.
    start=s.rfind('    [MethodImpl(',0,s.index(marker)) if not generic else s.index(marker)
    if generic:
        extra='''#if NET10_0_OR_GREATER
    internal int CountCompactWords(ReadOnlySpan<ushort> words, int levels)
    {
        var mask = _mask; var expected = _expected;
        if (Unsafe.SizeOf<T>() == 2)
            return CompactWordSearch.Count(words, levels, Unsafe.As<T, ushort>(ref mask), Unsafe.As<T, ushort>(ref expected), _negate);
        if (Unsafe.SizeOf<T>() == 4)
            return CompactWordSearch.Count(words, levels, Unsafe.As<T, uint>(ref mask), Unsafe.As<T, uint>(ref expected), _negate);
        throw new InvalidOperationException("Unsupported compact logical width.");
    }
#endif

'''
    else:
        extra='''#if NET10_0_OR_GREATER
    internal int CountCompactWords(ReadOnlySpan<ushort> words, int levels) =>
        CompactWordSearch.Count(words, levels, _mask, _expected, _negate);
#endif

'''
    s=s[:start]+extra+s[start:];f.write_text(s,encoding='utf-8')

for name,generic in [('OctreeQueries.cs',False),('GenericOctreeQueries.cs',True)]:
    f=after/name;s=f.read_text(encoding='utf-8-sig')
    start=s.index('    private static void Packed');end=s.index('    private static void Dense',start)
    part=s[start:end];anchor='        var box = state.Box;';assert part.count(anchor)==1
    header='GenericOctreeCodec<TStorage>.HeaderSize' if generic else 'OctreeCodec.HeaderSize'
    extra=f'''        var box = state.Box;
#if NET10_0_OR_GREATER
        if (state.Kind == QueryKind.Count && BitConverter.IsLittleEndian)
        {{
            var words = MemoryMarshal.Cast<byte, ushort>(data[{header}..]);
            state.Count += CountCompact(words, 1 << levels, box, state.Filter, levels);
            return;
        }}
#endif'''
    part=part.replace(anchor,extra)
    filter_type='VoxelFilter<T>' if generic else 'VoxelFilter'
    helper=f'''#if NET10_0_OR_GREATER
    private static int CountCompact(ReadOnlySpan<ushort> words, int side, VoxelBox box, {filter_type} filter, int levels)
    {{
        var width = box.MaxZ - box.MinZ;
        var count = 0;
        if (width == side)
        {{
            if (box.MinY == 0 && box.MaxY == side)
                return filter.CountCompactWords(words.Slice(box.MinX * side * side, box.Count), levels);
            var length = (box.MaxY - box.MinY) * side;
            for (var x = box.MinX; x < box.MaxX; x++)
                count += filter.CountCompactWords(words.Slice((x * side + box.MinY) * side, length), levels);
        }}
        else
        {{
            for (var x = box.MinX; x < box.MaxX; x++)
            for (var y = box.MinY; y < box.MaxY; y++)
                count += filter.CountCompactWords(words.Slice((x * side + y) * side + box.MinZ, width), levels);
        }}
        return count;
    }}
#endif

'''
    s=s[:start]+part+helper+s[end:];f.write_text(s,encoding='utf-8')

# New fixture versions describe the new representation; read/checksum bodies stay.
fixtures=[]
for old,new,version in [('Scenarios-byte-palette.cs.txt','Scenarios-compact-leaf.cs.txt','15'),('Scenarios-bulk14.cs.txt','Scenarios-compact-bulk.cs.txt','14')]:
    original=(research/old).read_text(encoding='utf-8-sig');target=research/new;assert not target.exists()
    updated=original.replace('"'+version+'"','"16"').replace('byte-palette-v1','compact-word13-v1')
    assert updated!=original;target.write_text(updated,encoding='utf-8')
    fixtures.append({'file':new,'parent':old,'before_sha256':sha(original.encode()),'after_sha256':sha(updated.encode())})
norm=lambda b:b.decode('utf-8-sig').replace('\r\n','\n').rstrip('\n')+'\n'
files=sorted({f.name for f in before.glob('*.cs')}|{f.name for f in after.glob('*.cs')});manifest=[]
for name in files:
    x=before/name;y=after/name;xb=x.read_bytes() if x.exists() else None;yb=y.read_bytes() if y.exists() else None
    manifest.append({'file':name,'before_sha256':sha(xb) if xb is not None else None,'after_sha256':sha(yb) if yb is not None else None,'normalized_changed':xb is None or yb is None or norm(xb)!=norm(yb)})
value={'parent':'complete P30','format':'R0x52/v3/kind3; header+N little-endian UInt16 low13 value/high3 LOD','published_fallback':'exact O/v1/v2; reject unpublished P/Q','manifest':manifest,'fixtures':fixtures,'performance_measured':False}
(root/'p31-source-origin.json').write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps({'source':str(after),'changed_files':[r['file'] for r in manifest if r['normalized_changed']],'fixtures':fixtures}))
