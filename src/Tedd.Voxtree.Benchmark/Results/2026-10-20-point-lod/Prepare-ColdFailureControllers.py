"""Copy pinned tool source only; original repository and installations stay read-only."""
import argparse,hashlib,json,subprocess,zipfile
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
task=args.task_root.resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
repo=Path('D:/SourceCode/Tedd.AIdotNET');root=task/'coldlog-controller-source';archive=task/'coldlog-source-9c23369.zip'
assert not root.exists() and not archive.exists(), 'L1 source exists; inspect before recovery'
revision=subprocess.check_output(['git','-C',str(repo),'rev-parse','9c23369'],text=True).strip()
subprocess.run(['git','-C',str(repo),'archive','--format=zip','--output='+str(archive),revision,'--',
                'src','schemas','Directory.Build.props','Directory.Packages.props','NuGet.Config','global.json'],check=True)
root.mkdir()
with zipfile.ZipFile(archive) as z:
    for item in z.infolist():
        path=(root/item.filename).resolve()
        assert path.is_relative_to(root) and ((item.external_attr>>16)&0o170000)!=0o120000
        if item.is_dir():path.mkdir(parents=True,exist_ok=True)
        else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(z.read(item))
original_global=(root/'global.json').read_bytes()
(root/'global-original.json').write_bytes(original_global)
(root/'global.json').write_text(json.dumps({'sdk':{'version':'10.0.402','rollForward':'disable','allowPrerelease':False}},indent=2)+'\n')
source=root/'src/Tedd.DotNetLab.Application/ConfirmationService.cs'
(root/'ConfirmationService.original.txt').write_bytes(source.read_bytes())
value={'revision':revision,'original_repository_head':subprocess.check_output(['git','-C',str(repo),'rev-parse','HEAD'],text=True).strip(),
       'archive_sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'sdk_override':'10.0.402',
       'original_source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
       'scope':'Task-local source copy, no Git checkout/worktree or shared installation changes'}
(root/'origin.json').write_text(json.dumps(value,indent=2)+'\n');print(json.dumps(value))
