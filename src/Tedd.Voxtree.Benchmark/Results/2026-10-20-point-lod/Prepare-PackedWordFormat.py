"""P24: distinct representation magic, legacy constants preserved."""
import argparse,hashlib,json,shutil
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
root=args.task_root.resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
before=root/'leaf-helper-inline-source';after=root/'packed-word-format-source'
assert not after.exists(), 'P24 exists; inspect before recovery'
shutil.copytree(before,after)
p=after/'PackedLeafEncoding.cs';s=p.read_text()
s=s.replace('// Isolated P15 prototype; not a production wire-format commitment.','// Packed value and exact leaf LOD words use their own representation magic.')
anchor='    private static readonly int Width = Unsafe.SizeOf<T>();';assert s.count(anchor)==1
s=s.replace(anchor,"    internal const byte Magic = 0x50; // 'P'; distinct from legacy/prototype 'O'.\n"+anchor)
assert s.count('data[0] != 0x4f')==1 and s.count('destination[0] = 0x4f;')==1
s=s.replace('data[0] != 0x4f','data[0] != Magic').replace('destination[0] = 0x4f;','destination[0] = Magic;')
s=s.replace('data[1] >> 6 != 3','data[1] >> 6 != Octree.PackedLeafFormatVersion')
s=s.replace('destination[1] = (byte)(0xc3 | (levels << 2));','destination[1] = (byte)((Octree.PackedLeafFormatVersion << 6) | 3 | (levels << 2));')
p.write_text(s)
for name,typ in [('OctreeCodec.cs','uint'),('GenericOctreeCodec.cs','TStorage')]:
 p=after/name;s=p.read_text()
 start=s.index('    internal static bool TryReadHeader(');end=s.index('    internal static bool IsWellFormed(',start)
 section=s[start:end]
 anchor='''        if (data.Length < HeaderSize + 1 || data[0] != Magic)
            return false;
''';assert section.count(anchor)==1
 section=section.replace(anchor,f'''        if (data.Length < HeaderSize + 1) return false;
        if (data[0] == PackedLeafEncoding<{typ}>.Magic)
        {{
            storageKind = StorageKind.PackedLeaf;
            return PackedLeafEncoding<{typ}>.TryReadHeader(data, HeaderSize, out levels);
        }}
        if (data[0] != Magic) return false;
''')
 old=('''        if (version != Octree.FormatVersion)
        {
            if (version != 3) return false;
            storageKind = StorageKind.PackedLeaf;
            return PackedLeafEncoding<uint>.TryReadHeader(data, HeaderSize, out levels);
        }''' if typ=='uint' else '''        if (((metadata & VersionMask) >> VersionShift) != Version || data[2] != GetSizeCode())
        {
            if (((metadata & VersionMask) >> VersionShift) != 3) return false;
            storageKind = StorageKind.PackedLeaf;
            return PackedLeafEncoding<TStorage>.TryReadHeader(data, HeaderSize, out levels);
        }''')
 assert section.count(old)==1
 new=('        if (version != Octree.FormatVersion) return false;' if typ=='uint' else '        if (((metadata & VersionMask) >> VersionShift) != Version || data[2] != GetSizeCode()) return false;')
 section=section.replace(old,new);p.write_text(s[:start]+section+s[end:])
for name,generic in [('Octree.cs',False),('Octree.Generic.cs',True)]:
 p=after/name;s=p.read_text()
 old='The generic serialized format version.' if generic else 'The current serialized format version.'
 assert s.count(old)==1
 s=s.replace(old,'The legacy serialized version used by tree, uniform and dense representations.')
 anchor='    public const int FormatVersion = '+('2;' if generic else '1;')
 assert s.count(anchor)==1
 s=s.replace(anchor,anchor+'''\n    /// <summary>The serialized version used by packed leaf words with magic byte 0x50.</summary>
    public const int PackedLeafFormatVersion = '''+('Octree.PackedLeafFormatVersion;' if generic else '3;'))
 p.write_text(s)
changed=[];manifest=[]
for p in sorted(after.glob('*.cs')):
 a=(before/p.name).read_bytes();b=p.read_bytes()
 norm=lambda v:v.decode('utf-8-sig').replace('\r\n','\n')
 if norm(a)!=norm(b):changed.append(p.name)
 manifest.append({'file':p.name,'before_sha256':hashlib.sha256(a).hexdigest(),'after_sha256':hashlib.sha256(b).hexdigest()})
assert set(changed)=={'GenericOctreeCodec.cs','Octree.Generic.cs','Octree.cs','OctreeCodec.cs','PackedLeafEncoding.cs'}
# Cold header/version edits leave the entire hot word-reader tail identical.
a=(before/'PackedLeafEncoding.cs').read_text();b=(after/'PackedLeafEncoding.cs').read_text()
assert a[a.index('    private static void WriteCube('):]==b[b.index('    private static void WriteCube('):]
(root/'p24-source-origin.json').write_text(json.dumps({'control':'complete P18','changed_files':changed,'hot_word_reader_tail_identical':True,'manifest':manifest},indent=2)+'\n')
print(json.dumps({'candidate':str(after),'changed_files':changed,'hot_word_reader_tail_identical':True}))
