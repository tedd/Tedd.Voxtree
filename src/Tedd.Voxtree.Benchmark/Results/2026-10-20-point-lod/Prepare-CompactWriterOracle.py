"""Retain the wide differential oracle and add independent R bytes/capacities."""
from pathlib import Path
import hashlib,json
root=Path(__file__).resolve().parent
source=root/'PackedWriterOracle.cs.txt';out=root/'CompactWriterOracle.cs.txt'
if out.exists():raise SystemExit('Preserve existing compact writer oracle')
text=source.read_text(encoding='utf-8-sig')
def change(old,new):
    global text
    if text.count(old)!=1:raise ValueError(f'Writer anchor changed: {old[:80]}')
    text=text.replace(old,new)
text=text.replace('using System.Diagnostics;','using System.Diagnostics;\nusing System.Runtime.InteropServices;\nusing System.Buffers.Binary;')
text=text.replace('control="selected Snapshot.Voxtree bundle source",wire="byte-for-byte including capacity-failure mutations"','control="published release Snapshot.Voxtree source plus independent dense-to-R oracle",wire="canonical R bytes or exact release fallback, including capacity-failure mutations"')
text=text.replace('After.DenseVoxel<T>.Convert(values,morton,level,After.DenseVoxelLayout.Linear,After.DenseVoxelLayout.Morton);','Before.DenseVoxel<T>.Convert(values,morton,level,Before.DenseVoxelLayout.Linear,Before.DenseVoxelLayout.Morton);')
text=text.replace('After.DenseVoxel.Convert(values,morton,level,After.DenseVoxelLayout.Linear,After.DenseVoxelLayout.Morton);','Before.DenseVoxel.Convert(values,morton,level,Before.DenseVoxelLayout.Linear,Before.DenseVoxelLayout.Morton);')
change('int[] Sizes(int required,int maximum)=>new[]{0,1,2,3,required-1,required,required+1,maximum}.Where(n=>n>=0).Distinct().ToArray();', '''int[] Sizes(int required,int old,int maximum)=>new[]{0,1,2,3,old-1,old,old+1,required-1,required,required+1,maximum}.Where(n=>n>=0).Distinct().ToArray();
byte[] Expected(uint[] values,int level,int width,int header,byte[] old,int maximum)
{
    if(level<3||level>6||(old[1]&3)!=0||values.Max()>8191)return old;
    int side=1<<level;var lods=new byte[values.Length];
    void Fill(int x,int y,int z,int l){
        int n=1<<l;uint v=values[(x*side+y)*side+z];bool same=true;
        for(int a=x;a<x+n&&same;a++)for(int b=y;b<y+n&&same;b++)for(int c=z;c<z+n;c++)if(values[(a*side+b)*side+c]!=v){same=false;break;}
        if(same){for(int a=x;a<x+n;a++)for(int b=y;b<y+n;b++)Array.Fill(lods,(byte)l,(a*side+b)*side+z,n);return;}
        int h=n/2;for(int c=0;c<8;c++)Fill(x+((c>>2)&1)*h,y+((c>>1)&1)*h,z+(c&1)*h,l-1);
    }
    Fill(0,0,0,level);int states=values.Select((v,i)=>(v,lods[i])).Distinct().Count();
    long model=header+2L+values.Length+states*width*2L,required=header+2L*values.Length;
    if(states>256||model>maximum||4*model>5L*old.Length||required>maximum||2*required>5L*old.Length)return old;
    var result=new byte[(int)required];result[0]=0x52;result[1]=(byte)(0xc3|(level<<2));if(header==3)result[2]=(byte)(width==2?1:2);
    for(int i=0;i<values.Length;i++)BinaryPrimitives.WriteUInt16LittleEndian(result.AsSpan(header+2*i),(ushort)(values[i]|((uint)lods[i]<<13)));
    return result;
}
void ExpectedCapacity(byte[] expected,int header,byte[] control,ref bool ok,ref int written)
{
    if(expected[0]!=0x52)return;
    if(control.Length>=expected.Length){Array.Fill(control,(byte)0xa5);expected.CopyTo(control,0);ok=true;written=expected.Length;}
    else{if(ok)Array.Fill(control,(byte)0xa5,0,header);ok=false;written=0;}
}''')
change('    byte[] expected=b.Data.ToArray();Same(expected,a.Data.ToArray(),"generic owned bytes");', '''    byte[] old=b.Data.ToArray();int width=System.Runtime.CompilerServices.Unsafe.SizeOf<T>();
    uint[]? raw=width==2?MemoryMarshal.Cast<T,ushort>(values).ToArray().Select(v=>(uint)v).ToArray():width==4?MemoryMarshal.Cast<T,uint>(values).ToArray():null;
    byte[] expected=raw is null?old:Expected(raw,level,width,3,old,Before.Octree<T>.GetMaximumSize(level));Same(expected,a.Data.ToArray(),"generic owned bytes");''')
change('    int required=Before.Octree<T>.GetRequiredSize(values,level);','    int required=expected.Length;Require(Before.Octree<T>.GetRequiredSize(values,level)==old.Length,"generic release size");')
change('    foreach(int size in Sizes(required,After.Octree<T>.GetMaximumSize(level)))','    foreach(int size in Sizes(required,old.Length,After.Octree<T>.GetMaximumSize(level)))')
change('        Require(lb==rb&&lw==rw,"generic TryBuild outcome");','        ExpectedCapacity(expected,3,left,ref lb,ref lw);\n        Require(lb==rb&&lw==rw,"generic TryBuild outcome");')
change('    byte[] expected=b.Data.ToArray();Same(expected,a.Data.ToArray(),"legacy owned bytes");','    byte[] old=b.Data.ToArray();byte[] expected=Expected(values,level,4,2,old,Before.Octree.GetMaximumSize(level));Same(expected,a.Data.ToArray(),"legacy owned bytes");')
change('    int required=Before.Octree.GetRequiredSize(values,level);','    int required=expected.Length;Require(Before.Octree.GetRequiredSize(values,level)==old.Length,"legacy release size");')
change('    foreach(int size in Sizes(required,After.Octree.GetMaximumSize(level)))','    foreach(int size in Sizes(required,old.Length,After.Octree.GetMaximumSize(level)))')
change('        Require(lb==rb&&lw==rw,"legacy TryBuild outcome");','        ExpectedCapacity(expected,2,left,ref lb,ref lw);\n        Require(lb==rb&&lw==rw,"legacy TryBuild outcome");')
out.write_text(text,encoding='utf-8')
print(json.dumps({'sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),'outputSha256':hashlib.sha256(out.read_bytes()).hexdigest()}))
