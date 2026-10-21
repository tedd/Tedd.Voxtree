"""Prepare the prospective R census, retaining the complete semantic scanner."""
from pathlib import Path
import hashlib
import json

root = Path(__file__).resolve().parent
source = root / 'PackedCorpus.cs.txt'
destination = root / 'CompactCorpus.cs.txt'
if destination.exists():
    raise SystemExit('Preserve existing compact corpus fixture')
text = source.read_text(encoding='utf-8-sig')
def replace(old, new):
    global text
    if text.count(old) != 1:
        raise ValueError(f'Changed corpus anchor: {old[:80]}')
    text = text.replace(old, new)

text = text.replace('PALETTE_LEAF_CENSUS', 'COMPACT_LEAF_CENSUS')
text = text.replace('forcecraft-census-palette-j1/palette-states.json', 'k2-audit.json')
text = text.replace('"eligible"', '"selected"').replace('"selectedProjection"', '"projected_bytes"')
text = text.replace('after.Span[0]==0x51', 'after.Span[0]==0x52')
text = text.replace('Palette', 'Compact').replace('palette', 'compact').replace('rejects Q', 'rejects R')
replace('            uint expected = values[i];', '''            uint expected = values[i];
            CheckWord(after.Data,2,i,expected,lod);
            CheckWord(after16.Data,3,i,expected,lod16);
            CheckWord(after32.Data,3,i,expected,lod32);''')
replace('        int maximum = small.Max();', '''        int maximum = small.Max();
        Require(after.EncodedLength<=Candidate.Octree.GetMaximumSize(5),"UInt32 maximum");
        Require(after16.EncodedLength<=Candidate.Octree<ushort>.GetMaximumSize(5),"UInt16 maximum");
        Require(after32.EncodedLength<=Candidate.Octree<uint>.GetMaximumSize(5),"Generic UInt32 maximum");''')
replace('    static bool Packed(ReadOnlyMemory<byte> data)', '''    static void CheckWord(ReadOnlyMemory<byte> data,int header,int index,uint expected,int lod)
    {
        if(data.Span[0]!=0x52)return;
        Require(expected<=8191 && lod<=6,"Compact representable raw state");
        ushort word=System.Buffers.Binary.BinaryPrimitives.ReadUInt16LittleEndian(data.Span.Slice(header+index*2,2));
        Require(word==(ushort)(expected|((uint)lod<<13)),"Independent dense-to-word byte oracle");
    }
    static bool Packed(ReadOnlyMemory<byte> data)''')
replace('        if(compact)Require(after.Span[0]==0x52,"Compact magic");', '''        if(compact){
            Require(after.Span[0]==0x52,"Compact magic");
            Require(after.Length*2L<=before.Length*5L,"Selected encoded growth bound");
        }''')
destination.write_text(text, encoding='utf-8')
print(json.dumps({'source':str(source),'sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),
                  'output':str(destination),'outputSha256':hashlib.sha256(destination.read_bytes()).hexdigest()}))
