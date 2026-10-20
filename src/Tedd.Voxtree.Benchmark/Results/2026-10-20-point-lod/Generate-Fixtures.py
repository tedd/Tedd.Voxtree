from pathlib import Path

header = r'''using System.Diagnostics;
using System.Runtime.CompilerServices;
using Tedd.DotNetLab.Contracts;
using Tedd.DotNetLab.Harness;
using Tedd.Voxtree;
using Before = Snapshot.Voxtree;

FixtureMode.Validation = args[0] == "--validate";
if (OperatingSystem.IsWindows()) Process.GetCurrentProcess().ProcessorAffinity = (nint)4;
if(args[0]=="--fuzz") {LegacyScenario.Fuzz();WideScenario.Fuzz();HugeScenario.Fuzz();return;}
var registry = new ScenarioRegistry();
foreach (var pattern in new[]{"full","coarse","long","sparse","uniform","dense"})
foreach (var op in new[]{"get","lod"}) registry.Register(new LegacyScenario(5,pattern,"owned",op));
foreach (var op in new[]{"get","lod"}) registry.Register(new LegacyScenario(5,"full","span",op));
registry.Register(new LegacyScenario(5,"long","span","lod"));
foreach (var op in new[]{"try","trylod","getlod","indexer"}) registry.Register(new LegacyScenario(5,"full","owned",op));
foreach (var op in new[]{"get","lod"}) registry.Register(new LegacyScenario(5,"full","sequential",op));
foreach (var pattern in new[]{"full","sparse"})
foreach (var op in new[]{"get","lod"}) registry.Register(new LegacyScenario(5,pattern,"compiled",op));
foreach (var pattern in new[]{"coarse","long"})
foreach (var op in new[]{"get","lod"}) registry.Register(new LegacyScenario(5,pattern,"compiled",op));
foreach (var pattern in new[]{"full","coarse","sparse"})
foreach (var op in new[]{"create","lifecycle"}) registry.Register(new LegacyScenario(5,pattern,"compiled",op));
foreach (var levels in new[]{3,6})
foreach (var op in new[]{"get","lod"}) registry.Register(new LegacyScenario(levels,"full","owned",op));
foreach (var pattern in new[]{"full","coarse","long"})
foreach (var op in new[]{"get","lod"}) registry.Register(new WideScenario(5,pattern,"owned",op));
foreach (var pattern in new[]{"full","long"})
foreach (var op in new[]{"get","lod"}) registry.Register(new HugeScenario(5,pattern,"owned",op));
foreach (var op in new[]{"get","lod"}) registry.Register(new WideScenario(5,"full","span",op));
if (args[0] == "--inventory") {
    var flags=System.Reflection.BindingFlags.Public|System.Reflection.BindingFlags.Instance|System.Reflection.BindingFlags.Static|System.Reflection.BindingFlags.DeclaredOnly;
    Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(typeof(Octree).Assembly.GetExportedTypes().Where(t=>t.Namespace=="Tedd.Voxtree").OrderBy(t=>t.FullName).Select(t=>new {type=t.FullName,methods=t.GetMethods(flags).Select(m=>m.ToString()),constructors=t.GetConstructors(flags).Select(c=>c.ToString())})));
    return;
}
if(args[0]=="--callers") {
    var types=new[]{typeof(LegacyScenario),typeof(WideScenario),typeof(HugeScenario)};
    var inventory=types.SelectMany(t=>t.GetMethods(System.Reflection.BindingFlags.NonPublic|System.Reflection.BindingFlags.Instance).Where(m=>m.Name.StartsWith("AfterBatch")).Select(m=>new {method=t.Name+"."+m.Name,sha256=Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(m.GetMethodBody()!.GetILAsByteArray()!))}));
    Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(inventory));return;
}
if (args[0] is "--validate" or "--code") {
    foreach (var d in registry.Describe()) {
        if(args.Length>1&&!d.Id.Contains(args[1]))continue;
        var s=(ISynchronousScenario)registry.Get(d.Id);
        foreach(var v in new[]{"baseline","candidate"}) {
            s.Prepare(new ScenarioContext(v,CancellationToken.None));
            s.Reset(new ResetContext(ResetLevel.LogicalState));
            s.ExecuteBatch(d.Id.EndsWith("-create")||d.Id.EndsWith("-lifecycle")?1:args[0]=="--code"?65536:2048);
            if(!s.Validate().Correct)throw new InvalidOperationException(d.Id+v);
            s.Cleanup();
        }
        Console.WriteLine(d.Id+" valid");
    }
    return;
}
var host=new HarnessHost(registry,args[1]);
if(args[0]=="--harness-owned"||Environment.GetEnvironmentVariable("DOTNET_EnableDiagnostics")=="0")await host.RunOwnedAsync();
else {
    Console.WriteLine(Wire.Serialize(host.Target));
    using var cancel=new CancellationTokenSource();
    _=Task.Run(async()=>{await Console.In.ReadLineAsync();cancel.Cancel();});
    await host.ListenAsync(cancel.Token);
}
public static class FixtureMode {public static bool Validation;}
'''

template = r'''
public sealed class CLASSScenario : ISynchronousScenario {
    private readonly int levels,side;
    private readonly string pattern,access,op;
    private readonly (int X,int Y,int Z)[] points=new (int,int,int)[1024];
    private readonly long[] prefix=new long[1025];
    private readonly VALUE[] values;
    private TREE tree=null!;
    private Before.TREE before=null!;
    LOOKUP_FIELDS
    private bool initialized,baseline,beforePrimed,afterPrimed;
    private int position;
    private long sum,completed;
    public CLASSScenario(int levels,string pattern,string access,string op) {
        this.levels=levels;side=1<<levels;this.pattern=pattern;this.access=access;this.op=op;
        values=new VALUE[side*side*side];
    }
    public ScenarioDescriptor Describe()=>new($"point-CLASS-L{levels}-{pattern}-{access}-{op}","2",
        Wire.Hash(new{levels,pattern,access,op,seed=20261022,points=1024,lifecycleReads=65536,affinity=4,primeMs=1000,consumer="unchecked-full-value-fold-plus-lod"}),
        ResetLevel.LogicalState,ThreadAffinity.Any,false,op=="create"?"One complete CreateLookup":op=="lifecycle"?"One CreateLookup plus 65536 public reads":"One complete public point or stored-LOD read",["baseline","candidate"]);
    private int ExpectedLod(int x,int y,int z) {
        if(pattern=="uniform")return levels;
        if(pattern is "coarse" or "long")return Math.Min(2,levels);
        if(pattern!="sparse")return 0;
        for(var lod=levels;lod>0;lod--) {
            var size=1<<lod;var a=x&-size;var b=y&-size;var c=z&-size;
            if(!(a==0&&b==0&&c==0)&&!(a+size==side&&b+size==side&&c+size==side))return lod;
        }
        return 0;
    }
    private void Initialize() {
        if(initialized)return;
        for(var x=0;x<side;x++)for(var y=0;y<side;y++)for(var z=0;z<side;z++) {
            var index=(x*side+y)*side+z;
            var code=(uint)((x*13+y*7+z)&31);
            var coarse=(uint)(((x>>2)*13+(y>>2)*7+(z>>2))&31);
            values[index]=pattern switch {
                "uniform"=>(VALUE)7,"sparse"=>(VALUE)(index==0?1u:index==values.Length-1?2u:0u),
                "coarse"=>(VALUE)coarse,"long"=>LONG_VALUE,
                "dense"=>(VALUE)unchecked((uint)index*2654435761u),_ =>(VALUE)code
            };
        }
        tree=new TREE(levels,values);before=new Before.TREE(levels,values);
        if(!tree.Data.Span.SequenceEqual(before.Data.Span))throw new Exception("Encoding parity");
        var expectedKind=pattern=="uniform"?1:pattern=="dense"?2:0;
        if((tree.Data.Span[1]&3)!=expectedKind)throw new Exception("Storage kind");
        LOOKUP_INIT
        var random=new Random(20261022);
        for(var i=0;i<points.Length;i++) {
            var index=access=="sequential"?i%values.Length:i==0?0:i==1?values.Length-1:random.Next(values.Length);
            var x=index/(side*side);var y=index/side%side;var z=index%side;points[i]=(x,y,z);
            var lod=op is "lod" or "trylod" or "getlod"?ExpectedLod(x,y,z):0;
            prefix[i+1]=unchecked(prefix[i]+FOLD_VALUES+((long)lod<<32));
        }
        initialized=true;
    }
    private bool Check() {
        foreach(var p in points) {
            var expected=values[(p.X*side+p.Y)*side+p.Z];var lod=ExpectedLod(p.X,p.Y,p.Z);
            if(tree.Get(p.X,p.Y,p.Z,out var a)!=expected||a!=lod||before.Get(p.X,p.Y,p.Z,out var b)!=expected||b!=lod)return false;
            var s=tree.AsSpan();var bs=before.AsSpan();
            if(s.Get(p.X,p.Y,p.Z,out a)!=expected||a!=lod||bs.Get(p.X,p.Y,p.Z,out b)!=expected||b!=lod)return false;
            LOOKUP_CHECK
        }
        return true;
    }
    public static void Fuzz() {
        var dense=new VALUE[64];
        for(var i=0;i<64;i++)dense[i]=(VALUE)(uint)((i*13+i/4)&31);
        var original=new TREE(2,dense).Data.ToArray();
        var random=new Random(20261022);
        for(var trial=0;trial<2048;trial++) {
            var length=trial<original.Length?trial:original.Length;
            var bytes=original.AsSpan(0,length).ToArray();
            if(bytes.Length>0)for(var mutation=0;mutation<1+trial%3;mutation++)bytes[random.Next(bytes.Length)]=(byte)random.Next(256);
            for(var child=0;child<8;child++) {
                var x=child>>2;var y=child>>1&1;var z=child&1;
                if(ProbeBefore(bytes,x,y,z)!=ProbeAfter(bytes,x,y,z))throw new Exception($"CLASS malformed differential trial {trial} child {child}");
            }
        }
        Console.WriteLine("CLASS: 16384 malformed path probes agree");
    }
    private static string ProbeBefore(byte[] bytes,int x,int y,int z) {
        try {var view=new Before.SPAN(bytes);var a=view.TryGet(x,y,z,out var value);var first=$"{a}:{value}";a=view.TryGet(x,y,z,out value,out var lod);return $"{first}:{a}:{value}:{lod}";}
        catch(Exception e){return e.GetType().FullName!;}
    }
    private static string ProbeAfter(byte[] bytes,int x,int y,int z) {
        try {var view=new SPAN(bytes);var a=view.TryGet(x,y,z,out var value);var first=$"{a}:{value}";a=view.TryGet(x,y,z,out value,out var lod);return $"{first}:{a}:{value}:{lod}";}
        catch(Exception e){return e.GetType().FullName!;}
    }
    public void Prepare(ScenarioContext context) {
        Initialize();baseline=context.Variant=="baseline";
        if(!Check())throw new Exception("Dense and aligned-leaf oracle");
        if(!FixtureMode.Validation&&(baseline?!beforePrimed:!afterPrimed)) {
            var clock=Stopwatch.StartNew();
            do {ExecuteBatch(op is "create" or "lifecycle"?1:8192);}while(clock.ElapsedMilliseconds<1000);
            if(baseline)beforePrimed=true;else afterPrimed=true;
        }
    }
    public void Reset(ResetContext context){position=0;sum=completed=0;}
    public long ExecuteBatch(int count) {
#if PRIMARY_BASELINE_CALLER
        AfterBatch(count);
#else
        if(baseline)BeforeBatch(count);else AfterBatch(count);
#endif
        completed+=count;return count;
    }
    BATCH_METHODS
    public ValidationResult Validate()=>new(sum==EXPECTED_SUM&&Check());
    public void Cleanup(){}
}
'''


def batch(name, before, tree, value_type, compiled):
    field = "before" if before else "tree"
    methods = []
    dispatch = f'''[MethodImpl(MethodImplOptions.NoInlining)] private void {name}(int count) {{
        if(access=="span"){{{name}Span(count);return;}}
        if(access=="compiled"){{{name}Compiled(count);return;}}
        {name}Owned(count);
    }}'''
    for kind in ("Owned", "Span", "Compiled"):
        if kind == "Compiled" and not compiled:
            methods.append(f"private void {name}Compiled(int count)=>throw new NotSupportedException();")
            continue
        target = "view" if kind == "Span" else ("beforeLookup" if before else "lookup") if kind == "Compiled" else field
        setup = f"var view={field}.AsSpan();" if kind == "Span" else ""
        if kind == "Compiled":
            setup += f'''if(op=="create"){{for(var i=0;i<count;i++){{{target}={field}.CreateLookup();sum+={target}.StorageBytes;}}return;}}
            if(op=="lifecycle"){{for(var i=0;i<count;i++){{{target}={field}.CreateLookup();for(var j=0;j<65536;j++){{var p=points[j&1023];sum=unchecked(sum+(long){target}.Get(p.X,p.Y,p.Z));}}}}return;}}'''
        calls = {"get": f"{target}.Get(p.X,p.Y,p.Z)", "lod": f"{target}.Get(p.X,p.Y,p.Z,out lod)",
                 "indexer": f"{target}[p.X,p.Y,p.Z]"}
        loops = []
        for op in ("get", "lod", "try", "trylod", "getlod", "indexer"):
            declaration = f"{value_type} value;int lod=0;"
            if op == "try":
                read = f"if(!{target}.TryGet(p.X,p.Y,p.Z,out value))throw new Exception();"
            elif op == "trylod":
                read = f"if(!{target}.TryGet(p.X,p.Y,p.Z,out value,out lod))throw new Exception();"
            elif op == "getlod":
                read = f"lod={target}.GetLod(p.X,p.Y,p.Z,out value);"
            else:
                read = f"value={calls[op]};"
            fold = "(long)((ulong)value^(ulong)(value>>64))" if value_type == "UInt128" else "(long)value"
            loops.append(f'''if(op=="{op}"){{for(var i=0;i<count;i++){{var p=points[position++&1023];{declaration}{read}sum=unchecked(sum+{fold}+((long)lod<<32));}}return;}}''')
        methods.append(f'''[MethodImpl(MethodImplOptions.NoInlining)] private void {name}{kind}(int count){{{setup}{''.join(loops)}throw new Exception();}}''')
    return dispatch + "\n" + "\n".join(methods)


source = header
for cls, typ, tree, compiled, shift in [("Legacy", "uint", "Octree", True, 27), ("Wide", "ulong", "Octree<ulong>", False, 55), ("Huge", "UInt128", "Octree<UInt128>", False, 100)]:
    fragment = template.replace("BATCH_METHODS", batch("BeforeBatch", True, tree, typ, compiled)+"\n"+batch("AfterBatch", False, tree, typ, compiled))
    fields = "private OctreeLookup lookup=null!;private Before.OctreeLookup beforeLookup=null!;private int beforeBytes,afterBytes;" if compiled else ""
    init = "lookup=tree.CreateLookup();beforeLookup=before.CreateLookup();beforeBytes=beforeLookup.StorageBytes;afterBytes=lookup.StorageBytes;" if compiled else ""
    check = "if(lookup.Get(p.X,p.Y,p.Z,out a)!=expected||a!=lod||beforeLookup.Get(p.X,p.Y,p.Z,out b)!=expected||b!=lod)return false;" if compiled else ""
    fold = "(long)((ulong)values[index]^(ulong)(values[index]>>64))" if typ == "UInt128" else "(long)values[index]"
    expected = "(op==\"create\"?completed*(baseline?beforeBytes:afterBytes):op==\"lifecycle\"?unchecked(completed*prefix[1024]*64):unchecked(completed/1024*prefix[1024]+prefix[(int)(completed%1024)]))" if compiled else "unchecked(completed/1024*prefix[1024]+prefix[(int)(completed%1024)])"
    for a, b in sorted({"CLASS": cls,"VALUE":typ,"TREE":tree,"SPAN":tree.replace("Octree", "OctreeSpan"),"LONG_VALUE":f"((VALUE)1<<{shift})+(VALUE)coarse","LOOKUP_FIELDS":fields,"LOOKUP_INIT":init,"LOOKUP_CHECK":check,"FOLD_VALUES":fold,"EXPECTED_SUM":expected}.items(), key=lambda item: -len(item[0])):
        fragment = fragment.replace(a, b.replace("VALUE", typ))
    source += fragment
source = "\n".join(line.rstrip() for line in source.splitlines()).rstrip() + "\n"
Path(__file__).with_name("Scenarios.cs.txt").write_text(source, encoding="utf-8")
