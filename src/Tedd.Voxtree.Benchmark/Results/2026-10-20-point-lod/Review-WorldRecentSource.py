"""Prove the bounded source delta and retain current consumer context."""
import difflib,hashlib,json,re,subprocess,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve();assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path(__file__).resolve().parents[4];out=root/'p34-source-review.json';assert not out.exists()
old=subprocess.check_output(['git','-C',str(repo),'show','f0772c8:src/Tedd.Voxtree/WorldEntity.cs']).decode().replace('\r\n','\n')
current=(root/'world-recent-source/WorldEntity.cs').read_text();reverted=current
reverted=reverted.replace('    private int _lastRecentIndex = -1;\n','')
pattern=r'        if \(\(uint\)_lastRecentIndex < \(uint\)_recentCount\)\n        \{.*?\n        \}\n\n'
reverted,n=re.subn(pattern,'',reverted,flags=re.S);assert n==2
reverted=re.sub(r'^\s*_lastRecentIndex = (?:recentIndex|index|-1);\n','',reverted,flags=re.M)
assert reverted==old,'Non-hint source change'
diff=''.join(difflib.unified_diff(old.splitlines(True),current.splitlines(True),fromfile='f0772c8/WorldEntity.cs',tofile='P34/WorldEntity.cs'))
(root/'p34-world-normalized-source.diff').write_text(diff)
consumer=Path('D:/SourceCode/Tedd.Forcecraft10/src/Tedd.Forcecraft.Common/Models/Lod/LodTopologyIndex.cs')
c=consumer.read_text();member=c[c.index('    public bool TryGetOwner('):c.index('    /// <summary>Desired exact owners')]
declaration=next(line.strip() for line in c.splitlines() if 'WorldEntity<byte> _tree' in line)
value={'sourceEquivalentAfterRemovingHint':True,'exactDelta':'One hint field, two checked full-address hit paths, two successful lookup updates, Set/AddRecent updates and Remove/Clear invalidations; all other source text exactly published after newline normalization.','normalizedDiffSha256':hashlib.sha256(diff.encode()).hexdigest(),'consumerPath':str(consumer),'consumerSha256':hashlib.sha256(consumer.read_bytes()).hexdigest(),'consumerDeclaration':declaration,'consumerTryGetOwner':member,'consumerLimitations':'Current source uses byte values, one channel, side1 and an application lock. The fixture uses UInt32/UInt16 and two channels, levels0..7, and public TryGetLod searches without that application lock. It is a synthetic contrast, not an end-to-end or observed-frequency replay. Real-world immutable region corpus is not consumed in P34 because the affected map is tested independently of voxel compression.','nativeAuditCorrection':'Initial prerequisite audit assumed linear success fallthrough; actual Equals-true edges may be outlined. Original audit source retained; corrected control-flow trace uses the same native capture, without producer rerun.','registry':['A03 repeated invariant calculation','A09 exact common case','M22 clustered keys/access','C02 dependency chain','C18 emitted call visibility','C19 branch transitions','R03 PGO/history']}
out.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps({'sourceEquivalentAfterRemovingHint':True,'consumerDeclaration':declaration,'consumerSha256':value['consumerSha256']}))
