"""P23: measurement-only token lengths; ordinary writer remains unchanged."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
root=args.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path(__file__).resolve().parents[4]
control,fork=root/'p23-release-source',root/'sizing-writer-source'
assert not control.exists() and not fork.exists(), 'P23 source exists; inspect before recovery'
control.mkdir();fork.mkdir()
revision=subprocess.check_output(['git','-C',str(repo),'rev-parse','f0772c8'],text=True).strip()
files=subprocess.check_output(['git','-C',str(repo),'ls-tree','-r','--name-only',revision,'--','src/Tedd.Voxtree'],text=True).splitlines()
manifest=[]
for name in files:
    if not name.endswith('.cs'):continue
    data=subprocess.check_output(['git','-C',str(repo),'show',f'{revision}:{name}'])
    (control/Path(name).name).write_bytes(data);(fork/Path(name).name).write_bytes(data)
    manifest.append({'path':name,'sha256':hashlib.sha256(data).hexdigest()})
for name,generic in [('OctreeCodec.cs',False),('GenericOctreeCodec.cs',True)]:
    path=fork/name;text=path.read_text()
    anchor='''        internal bool WriteVarUInt(uint value)
        {
'''
    assert text.count(anchor)==1
    text=text.replace(anchor,anchor+'''#if NET10_0_OR_GREATER
            if (_measureOnly)
                return AdvanceMeasured(System.Numerics.BitOperations.Log2(value | 1u) / 7 + 1);
#endif
''')
    if generic:
        anchor='''        internal bool WriteValue(TStorage value)
        {
'''
        assert text.count(anchor)==1
        text=text.replace(anchor,anchor+'''#if NET10_0_OR_GREATER
            if (_measureOnly)
                return AdvanceMeasured(StorageInteger<TStorage>.VarIntLength(value));
#endif
''')
    anchor='        internal bool WriteVarUInt(uint value)'
    helper='''#if NET10_0_OR_GREATER
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private bool AdvanceMeasured(int length)
        {
            var available = _limit - Position;
            if (available < length)
            {
                // Match the original byte loop's position even on failure.
                Position += Math.Max(0, available);
                return false;
            }
            Position += length;
            return true;
        }
#endif

'''
    assert text.count(anchor)==1;text=text.replace(anchor,helper+anchor)
    path.write_text(text,encoding='utf-8')
path=fork/'StorageInteger.cs';text=path.read_text()
anchor='    [MethodImpl(MethodImplOptions.AggressiveInlining)]\n    internal static bool HasMoreThanSevenBits(T value)'
assert text.count(anchor)==1
helper='''#if NET10_0_OR_GREATER
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static int VarIntLength(T value)
    {
        int bits;
        if (Unsafe.SizeOf<T>() == 16)
        {
            var wide = Unsafe.As<T, VoxelUInt128>(ref value);
            bits = wide.High != 0
                ? 128 - System.Numerics.BitOperations.LeadingZeroCount(wide.High)
                : 64 - System.Numerics.BitOperations.LeadingZeroCount(wide.Low);
        }
        else
            bits = 64 - System.Numerics.BitOperations.LeadingZeroCount(ToUInt64(value));
        return Math.Max(1, (bits + 6) / 7);
    }
#endif

'''
path.write_text(text.replace(anchor,helper+anchor),encoding='utf-8')
(root/'p23-source-origin.json').write_text(json.dumps({'control':revision,'files':manifest},indent=2)+'\n')
print(json.dumps({'control':str(control),'candidate':str(fork),'revision':revision}))
