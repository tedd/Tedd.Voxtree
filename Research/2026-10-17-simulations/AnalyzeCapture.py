"""Analyze a retained task-local capture through one owned stdio controller."""
import json
import pathlib
import subprocess
import sys
import time

root = pathlib.Path(sys.argv[1]).resolve()
if not str(root).lower().startswith('d:\\workspaces\\ai\\'):
    raise ValueError('Use a designated task workspace')
runtime, host = sys.argv[2:4]
capture = json.loads((root / 'capture.jsonl').read_text().splitlines()[-1])['result_id']
with (root / 'analysis-controller.stderr').open('w') as errors, (root / 'analysis-protocol.jsonl').open('x') as log:
    process = subprocess.Popen([runtime, host, 'serve', str(root / 'catalog')],
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                               stderr=errors, text=True, encoding='utf-8')
    sequence = 0

    def rpc(method, params):
        global sequence
        sequence += 1
        request = dict(jsonrpc='2.0', id=sequence, method=method, params=params)
        log.write(json.dumps(dict(request=request)) + '\n')
        log.flush()
        process.stdin.write(json.dumps(request) + '\n')
        process.stdin.flush()
        while True:
            line = process.stdout.readline()
            if not line:
                raise RuntimeError('Controller exited before reply')
            reply = json.loads(line)
            log.write(json.dumps(dict(response=reply)) + '\n')
            log.flush()
            if reply.get('id') == sequence:
                if 'error' in reply:
                    raise RuntimeError(reply['error'])
                return reply['result']

    def call(name, request):
        reply = rpc('tools/call', dict(name=name, arguments=dict(request=request)))
        envelope = reply.get('structuredContent')
        if envelope is None:
            envelope = json.loads(reply['content'][0]['text'])
        if envelope['status'] != 'ok':
            raise RuntimeError(envelope)
        return envelope['data']

    try:
        rpc('initialize', dict(protocolVersion='2024-11-05', capabilities={},
                               clientInfo=dict(name='voxtree-capture-analysis', version='1')))
        process.stdin.write(json.dumps(dict(jsonrpc='2.0', method='notifications/initialized')) + '\n')
        process.stdin.flush()
        advertised = rpc('tools/list', {})
        (root / 'analysis-tool-schemas.json').write_text(json.dumps(advertised, indent=2))
        hypothesis = call('lab.experiment', dict(action='create_hypothesis',
            mechanism='Repeated immutable depth/layout validation in checked voxel indexers.',
            prediction='Reuse constructor validation and combine coordinate bounds checks while preserving exact simulations.',
            evidence_ids=[capture]))
        (root / 'hypothesis.json').write_text(json.dumps(hypothesis, indent=2))
        operation = call('lab.run', dict(action='analyze_stacks', capture_id=capture,
            idempotency_key='voxtree-simulation-stack-analysis-20261017-1'))
        (root / 'analysis-operation.json').write_text(json.dumps(operation, indent=2))
        deadline = time.monotonic() + 90
        while operation['state'] not in ('completed', 'failed', 'cancelled', 'canceled'):
            if time.monotonic() > deadline:
                raise TimeoutError(operation)
            time.sleep(0.5)
            operation = call('lab.run', dict(action='status', operation_id=operation['id']))
        (root / 'analysis-operation.json').write_text(json.dumps(operation, indent=2))
        if operation['state'] != 'completed':
            raise RuntimeError(operation)
        report = call('lab.query', dict(view='hotspots', result_id=operation['result_id'], ranking='self', limit=15))
        (root / 'hotspots.json').write_text(json.dumps(report, indent=2))
        record = call('lab.inspect', dict(action='record', id=operation['result_id']))
        (root / 'stack-record.json').write_text(json.dumps(record, indent=2))
        print(json.dumps(dict(operation=operation, hotspots=report)))
    finally:
        process.stdin.close()
        process.wait(timeout=50)
