"""Keep version 13 immutable; add explicit short/vector-tail count guards."""
from pathlib import Path

here=Path(__file__).resolve().parent;out=here/'Scenarios-bulk14.cs.txt'
if out.exists():raise SystemExit('Version-14 fixture exists')
source=(here/'Scenarios-bulk.cs.txt').read_text()
anchor='if(args[0]=="--validate"){'
assert source.count(anchor)==1
source=source.replace(anchor,'foreach(var op in new[]{"count7","miss7","count17","miss17"}){registry.Register(new BulkUInt32Scenario("mixed-u16-air",op));registry.Register(new BulkUInt16Scenario("mixed-u16-air",op));}\n'+anchor)
assert source.count(',"13",')==2;source=source.replace(',"13",',',"14",')
parts=source.split('public sealed class BulkUInt16Scenario',1);assert len(parts)==2
head=parts[0];tail='public sealed class BulkUInt16Scenario'+parts[1]
for typ,text in [('uint',head),('ushort',tail)]:
    for mode,obj in [('Before','before'),('After','after')]:
        anchor=f'void {mode}Batch(int count){{switch(op){{';assert text.count(anchor)==1
        filter_type=mode+'.VoxelFilter'+('<ushort>' if typ=='ushort' else '')
        cases=''
        for op,end,wanted in [('count7',8,0),('miss7',8,65535),('count17',18,0),('miss17',18,65535)]:
            cases+=f'case "{op}":for(int i=0;i<count;i++){{sum=unchecked(sum+{obj}.CountMatches(new {mode}.VoxelBox(1,1,1,31,31,{end}),{filter_type}.EqualTo({wanted})));}}return;'
        text=text.replace(anchor,anchor+cases)
    anchor='"count"=>zeros,"miss"=>values.Count(v=>v==65535),';assert text.count(anchor)==1
    text=text.replace(anchor,anchor+'"count7"=>ExpectedClipped(8,0),"miss7"=>ExpectedClipped(8,65535),"count17"=>ExpectedClipped(18,0),"miss17"=>ExpectedClipped(18,65535),')
    anchor='    void Initialize()';assert text.count(anchor)==1
    helper='''    int ExpectedClipped(int endZ,uint wanted){int count=0;
        for(int x=1;x<31;x++)for(int y=1;y<31;y++)for(int z=1;z<endZ;z++)if((uint)values[(x*32+y)*32+z]==wanted)count++;
        return count;
    }
'''
    text=text.replace(anchor,helper+anchor)
    if typ=='uint':head=text
    else:tail=text
out.write_text(head+tail,encoding='utf-8')
