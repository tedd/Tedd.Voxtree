"""Add bounded stderr detail only inside the existing failure catch."""
import argparse,difflib,hashlib,json
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('task_root',type=Path);args=parser.parse_args()
task=args.task_root.resolve();assert task==Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
root=task/'coldlog-controller-source';path=root/'src/Tedd.DotNetLab.Application/ConfirmationService.cs'
before=path.read_text();assert before== (root/'ConfirmationService.original.txt').read_text()
anchor='                joined=code!="process_quiescence_unknown";'
assert before.count(anchor)==1
addition='''                try
                {
                    string detail=e.ToString();
                    Console.Error.WriteLine("DOTNETLAB_CONFIRMATION_FAILURE "+JsonSerializer.Serialize(new
                    {
                        operation_id=operation.Id,plan_id=plan.Id,execution_id=id,failure_code=code,
                        exception_type=e.GetType().FullName,hresult=e.HResult,
                        detail=detail.Length<=32768?detail:detail[..32768],detail_truncated=detail.Length>32768,
                        recorded_utc=DateTimeOffset.UtcNow
                    }));
                }
                catch(Exception loggingError) when(loggingError is not OutOfMemoryException) { }
'''
after=before.replace(anchor,addition+anchor);assert after.replace(addition,'')==before
path.write_text(after,encoding='utf-8')
patch=''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),
    fromfile='a/src/Tedd.DotNetLab.Application/ConfirmationService.cs',tofile='b/src/Tedd.DotNetLab.Application/ConfirmationService.cs'))
(root/'cold-failure-log.diff').write_text(patch)
(root/'patch-review.json').write_text(json.dumps({'one_changed_source_file':True,
    'outside_added_catch_logging_identical':True,'diff_sha256':hashlib.sha256(patch.encode()).hexdigest(),
    'bounded_detail_characters':32768,'no_background_observer':True},indent=2)+'\n')
print('Pinned controller failure catch patched; successful-path source unchanged')
