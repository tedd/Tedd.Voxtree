"""Keep complete terrain oracles while allowing the alternative P15 encoding."""
from pathlib import Path

here = Path(__file__).resolve().parent
output = here / 'Scenarios-packed-leaf.cs.txt'
if output.exists():
    raise SystemExit('P15 fixture exists; preserve frozen identity')
source = (here / 'Scenarios-forcecraft-p7.cs.txt').read_text()
for before, after in [
    ('","6",', '","12",'),
    ('primeMs=3000,consumer=', 'primeMs=3000,formatExperiment="inline-leaf-lod-v1",consumer='),
    ('if(!tree.Data.Span.SequenceEqual(before.Data.Span))',
     'if(!tree.Data.Span.SequenceEqual(before.Data.Span) && (tree.Data.Span[1]>>6)!=3)'),
    ('if((tree.Data.Span[1]&3)!=expectedKind)',
     'if((tree.Data.Span[1]&3)!=expectedKind && !((tree.Data.Span[1]>>6)==3 && (tree.Data.Span[1]&3)==3))'),
]:
    if source.count(before) != 2:
        raise RuntimeError(f'Expected two terrain fixture anchors: {before}')
    source = source.replace(before, after)
output.write_text(source, encoding='utf-8')
