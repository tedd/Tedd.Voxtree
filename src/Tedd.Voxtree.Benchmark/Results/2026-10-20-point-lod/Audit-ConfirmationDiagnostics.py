"""Inspect original closed evidence; do not restart a failed confirmation."""
import argparse,hashlib,json,re,subprocess
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
root=args.task_root.resolve()
assert root==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
output=root/'p18normal-controller-log-audit.json'
assert not output.exists(), 'Keep original diagnostic audit'
log=root/'p18-screen/p18normal-controller.log'
data=log.read_bytes();text=data.decode('utf-8-sig')
matches=[n for n,line in enumerate(text.splitlines(),1) if re.search(r'(?i)exception|\b(error|failed)\b',line)]
terminal=json.loads((root/'p18-screen/p18normal-point-ForceUInt32-L5-mixed-u16-air-span-get-terminal.json').read_text(encoding='utf-8-sig'))
assert terminal['state']=='failed' and terminal['error_code']=='confirmation_failed'
repo=Path('D:/SourceCode/Tedd.AIdotNET');name='src/Tedd.DotNetLab.Application/ConfirmationService.cs'
source=(repo/name).read_bytes();normalized=lambda b:b.decode('utf-8-sig').replace('\r\n','\n')
frozen=subprocess.check_output(['git','-C',str(repo),'show','9c23369:'+name])
assert normalized(source)==normalized(frozen)
s=normalized(source)
assert s.index('string directory=await StageBuildAsync')<s.index('Catalog.Put(sessionId+"-launch"')
assert 'e is LabException error?error.Code:e is OperationCanceledException?"cancelled":"confirmation_failed"' in s
value={'original_operation_id':terminal['id'],'terminal':terminal['state'],'failure_code':terminal['error_code'],
       'controller_log_bytes':len(data),'controller_log_sha256':hashlib.sha256(data).hexdigest(),
       'exception_error_failed_line_numbers':matches,'search_availability':'requires_review' if matches else 'no_details_found_by_text_search',
       'inspected_source_revision':'9c23369','source_raw_sha256':hashlib.sha256(source).hexdigest(),
       'source_matches_revision_after_newlines':True,'launch_record_follows_completed_staging':True,
       'interpretation':'No retained detailed exception; launch establishes staging returned. Generic handler and finally cleanup do not localize the historic fault. No retry, replacement, new timing sample or inference of successful completion.'}
output.write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps(value))
