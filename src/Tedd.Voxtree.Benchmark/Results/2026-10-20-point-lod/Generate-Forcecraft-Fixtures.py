"""Generate reproducible point/LOD fixtures from the fixed, verified terrain strata."""
import argparse
import ast
import base64
import gzip
import hashlib
import json
from pathlib import Path
import zipfile

parser = argparse.ArgumentParser()
parser.add_argument('census', type=Path)
parser.add_argument('--compiled', action='store_true')
args = parser.parse_args()
here = Path(__file__).resolve().parent
report = json.loads((args.census / 'census.json').read_text())
samples = report['samples']
tree = ast.parse((here / 'Generate-Fixtures.py').read_text())
constants = {n.targets[0].id: ast.literal_eval(n.value) for n in tree.body
             if isinstance(n, ast.Assign) and isinstance(n.targets[0], ast.Name)
             and n.targets[0].id in {'header', 'template'}}
batch_node = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'batch')
scope = {}
exec(compile(ast.Module(body=[batch_node], type_ignores=[]), '<batch generator>', 'exec'), scope)
batch = scope['batch']

header = constants['header']
start = header.index('foreach (var pattern in new[]{')
end = header.index('if (args[0] == "--inventory")')
registration = 'foreach(var pattern in new[]{' + ','.join(json.dumps(k) for k in sorted(samples)) + '})\n'
registration += 'foreach(var access in new[]{"owned","span"})\nforeach(var op in new[]{"get","lod"}) {registry.Register(new ForceUInt32Scenario(5,pattern,access,op));registry.Register(new ForceUInt16Scenario(5,pattern,access,op));}\n'
if args.compiled:
    registration += 'foreach(var pattern in new[]{' + ','.join(json.dumps(k) for k in sorted(samples)) + '})foreach(var op in new[]{"get","lod","create","lifecycle"})registry.Register(new ForceUInt32Scenario(5,pattern,"compiled",op));\n'
header = header[:start] + registration + header[end:]
header = header.replace('LegacyScenario.Fuzz();WideScenario.Fuzz();HugeScenario.Fuzz();', 'ForceUInt32Scenario.Fuzz();ForceUInt16Scenario.Fuzz();')
header = header.replace('typeof(LegacyScenario),typeof(WideScenario),typeof(HugeScenario)', 'typeof(ForceUInt32Scenario),typeof(ForceUInt16Scenario)')
source = header
for cls, typ, api in [('ForceUInt32', 'uint', 'Octree'), ('ForceUInt16', 'ushort', 'Octree<ushort>')]:
    compiled = args.compiled and typ == 'uint'
    fragment = constants['template']
    # The owned source is widened for legacy UInt32, never truncated for UInt16.
    fragment = fragment.replace('private readonly VALUE[] values;', 'private readonly VALUE[] values;private readonly byte[] expectedLods;')
    fragment = fragment.replace('values=new VALUE[side*side*side];', 'var raw=ForcecraftCorpus.Load(pattern);values=raw.Select(v=>(VALUE)v).ToArray();expectedLods=ForcecraftCorpus.Lods(raw);')
    start = fragment.index('    private int ExpectedLod(')
    end = fragment.index('    private void Initialize()', start)
    fragment = fragment[:start] + '    private int ExpectedLod(int x,int y,int z)=>expectedLods[(x*side+y)*side+z];\n' + fragment[end:]
    start = fragment.index('        for(var x=0;x<side;x++)')
    end = fragment.index('        tree=new TREE', start)
    fragment = fragment[:start] + fragment[end:]
    fragment = fragment.replace('var expectedKind=pattern=="uniform"?1:pattern=="dense"?2:0;', 'var expectedKind=pattern.StartsWith("uniform-")?1:0;')
    fragment = fragment.replace('        LOOKUP_INIT', ('''        lookup=tree.CreateLookup();beforeLookup=before.CreateLookup();beforeBytes=beforeLookup.StorageBytes;afterBytes=lookup.StorageBytes;
''' if compiled else '') + '''        // Check every voxel once, independently of sampled timed coordinates.
        for(var index=0;index<values.Length;index++) {
            var x=index/(side*side);var y=index/side%side;var z=index%side;
            if(tree.Get(x,y,z,out var a)!=values[index]||a!=expectedLods[index]||before.Get(x,y,z,out var b)!=values[index]||b!=expectedLods[index])throw new Exception("Full terrain value/LOD oracle");
        }''')
    if compiled:
        fragment = fragment.replace('throw new Exception("Full terrain value/LOD oracle");', 'throw new Exception("Full terrain value/LOD oracle");if(lookup.Get(x,y,z,out a)!=values[index]||a!=expectedLods[index]||beforeLookup.Get(x,y,z,out b)!=values[index]||b!=expectedLods[index])throw new Exception("Full terrain compiled oracle");')
    fragment = fragment.replace('seed=20261022,points=1024', 'voxelSha256=ForcecraftCorpus.Hash(pattern),seed=20261022,points=1024')
    version = '6' if args.compiled else '5'
    fragment = fragment.replace('"2",', f'"{version}",').replace('primeMs=1000', 'primeMs=3000').replace('clock.ElapsedMilliseconds<1000', 'clock.ElapsedMilliseconds<3000')
    fragment = fragment.replace('BATCH_METHODS', batch('BeforeBatch', True, api, typ, compiled) + '\n' + batch('AfterBatch', False, api, typ, compiled))
    fields = 'private OctreeLookup lookup=null!;private Before.OctreeLookup beforeLookup=null!;private int beforeBytes,afterBytes;' if compiled else ''
    expected = '(op=="create"?completed*(baseline?beforeBytes:afterBytes):op=="lifecycle"?unchecked(completed*prefix[1024]*64):unchecked(completed/1024*prefix[1024]+prefix[(int)(completed%1024)]))' if compiled else 'unchecked(completed/1024*prefix[1024]+prefix[(int)(completed%1024)])'
    for a, b in sorted({'CLASS': cls, 'VALUE': typ, 'TREE': api, 'SPAN': api.replace('Octree', 'OctreeSpan'), 'LOOKUP_FIELDS': fields, 'LOOKUP_CHECK': '', 'FOLD_VALUES': '(long)values[index]', 'EXPECTED_SUM': expected}.items(), key=lambda kv: -len(kv[0])):
        fragment = fragment.replace(a, b)
    source += fragment

encoded, hashes = [], []
with zipfile.ZipFile(here / 'forcecraft-corpus.zip', 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
    for name, sample in sorted(samples.items()):
        raw = (args.census / 'samples' / sample['sampleName']).read_bytes()
        if len(raw) != 65536 or hashlib.sha256(raw).hexdigest().upper() != sample['hash']:
            raise RuntimeError('Sample identity mismatch: ' + name)
        archive.writestr(sample['sampleName'], raw)
        encoded.append(json.dumps(name) + '=>' + json.dumps(base64.b64encode(gzip.compress(raw, mtime=0)).decode()))
        hashes.append(json.dumps(name) + '=>' + json.dumps(sample['hash']))
    archive.write(args.census / 'chunks.csv', 'chunks.csv')
    archive.write(args.census / 'census.json', 'census.json')
source += '''
public static class ForcecraftCorpus {
    public static string Hash(string name)=>name switch {HASHES,_=>throw new ArgumentException(name)};
    public static ushort[] Load(string name) {
        var text=name switch {ENCODED,_=>throw new ArgumentException(name)};
        using var input=new MemoryStream(Convert.FromBase64String(text));
        using var gzip=new System.IO.Compression.GZipStream(input,System.IO.Compression.CompressionMode.Decompress);
        var bytes=new byte[65536];gzip.ReadExactly(bytes);if(gzip.ReadByte()!=-1)throw new Exception("Sample size");
        if(Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(bytes))!=Hash(name))throw new Exception("Sample hash");
        var values=new ushort[32768];for(var i=0;i<values.Length;i++)values[i]=System.Buffers.Binary.BinaryPrimitives.ReadUInt16LittleEndian(bytes.AsSpan(i*2));return values;
    }
    public static byte[] Lods(ushort[] values) {
        var lods=new byte[values.Length];
        void Visit(int x,int y,int z,int level) {
            var width=1<<level;var first=values[(x*32+y)*32+z];var uniform=true;
            for(var a=x;a<x+width&&uniform;a++)for(var b=y;b<y+width&&uniform;b++)for(var c=z;c<z+width;c++)if(values[(a*32+b)*32+c]!=first){uniform=false;break;}
            if(uniform){for(var a=x;a<x+width;a++)for(var b=y;b<y+width;b++)Array.Fill(lods,(byte)level,(a*32+b)*32+z,width);return;}
            if(level==0)throw new Exception("LOD oracle");var half=width/2;
            for(var a=0;a<2;a++)for(var b=0;b<2;b++)for(var c=0;c<2;c++)Visit(x+a*half,y+b*half,z+c*half,level-1);
        }
        Visit(0,0,0,5);return lods;
    }
}
'''.replace('HASHES', ','.join(hashes)).replace('ENCODED', ','.join(encoded))
source = '\n'.join(line.rstrip() for line in source.splitlines()).rstrip() + '\n'
(here / ('Scenarios-forcecraft-p7.cs.txt' if args.compiled else 'Scenarios-forcecraft.cs.txt')).write_text(source, encoding='utf-8')
(here / 'FORCECRAFT-CENSUS.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(f'Generated {48 if args.compiled else 32} terrain scenarios, four hash-bound strata.')
