"""Compare every original catalog table to its frozen export, using mode=ro."""
import argparse,base64,hashlib,json,sqlite3,zipfile
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
task=args.task_root.resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
research=Path(__file__).resolve().parent;output=research/'original-p18-catalog-unchanged.json'
assert not output.exists(), 'Keep original catalog comparison'
archive=research/'evidence-phase7.zip'
archive_hash=hashlib.sha256(archive.read_bytes()).hexdigest()
assert archive_hash==(research/'evidence-phase7.sha256').read_text().split()[0]
with zipfile.ZipFile(archive) as z:
    manifest={v['path']:v for v in json.loads(z.read('manifest.json'))}
    item=manifest['p18-screen/catalog-export.json'];frozen=z.read(item['blob'])
    assert hashlib.sha256(frozen).hexdigest()==item['sha256']
actual=[]
with sqlite3.connect((task/'p18-screen/catalog.sqlite').as_uri()+'?mode=ro',uri=True) as connection:
    tables=connection.execute("SELECT name,sql FROM sqlite_master WHERE type='table' ORDER BY name").fetchall()
    for name,schema in tables:
        quoted='"'+name.replace('"','""')+'"'
        cursor=connection.execute('SELECT * FROM '+quoted)
        columns=[c[0] for c in cursor.description]
        rows=[[{'base64':base64.b64encode(v).decode()} if isinstance(v,bytes) else v for v in row] for row in cursor]
        actual.append({'name':name,'schema':schema,'columns':columns,'rows':rows})
assert actual==json.loads(frozen)
value={'archive_sha256':archive_hash,'frozen_export_sha256':item['sha256'],
       'tables':len(actual),'rows':sum(len(t['rows']) for t in actual),
       'all_tables_schemas_columns_rows_identical':True,'access':'SQLite URI mode=ro; no controller/recovery/writer opened on original catalog',
       'scope':'Original P18 catalog logical contents unchanged against phase-seven frozen export; not a claim about filesystem timestamps'}
output.write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps(value))
