"""Audit original P36 normal sessions and apply only the frozen interval rules."""
import argparse
import hashlib
import json
import statistics
from datetime import datetime
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('task_root', type=Path)
a = p.parse_args()
task = a.task_root.resolve()
assert task == Path('D:/Workspaces/AI/voxtree-point-lod-20261020').resolve()
root = task / 'p36-normal-screen'
output = task / 'p36-normal-family-audit.json'
assert not output.exists(), 'Audit already exists; preserve the original'
read = lambda f: json.loads(f.read_text(encoding='utf-8-sig'))
unwrap = lambda v: json.loads(v['json']) if 'json' in v else v
dt = datetime.fromisoformat
plans = read(root / 'plans.json')
expected = [f'normal-world-{w}-{op}-{pattern}' for op in ['get', 'lod', 'chunk']
            for pattern in ['cycle12', 'repeated'] for w in ['UInt32', 'UInt16']]
assert [i['scenario'] for i in plans] == expected
complete = (root / 'run-driver-completed.json').exists()
assert complete or (root / 'driver-failure.log').exists(), 'Original family remains active'
if complete:
    done = read(root / 'run-driver-completed.json')
    assert done['cases'] == 12 and done['maximumSessions'] == 288 and done['driverExitedNormally']
inputs = read(root / 'inputs.json')
bundle_hashes = {}
for arm, bundle in zip(['baseline', 'candidate'], inputs['bundles']):
    bundle_hashes[arm] = {}
    for f in bundle['files']:
        assert hashlib.sha256(Path(f['path']).read_bytes()).hexdigest() == f['sha256']
        bundle_hashes[arm][f['name']] = f['sha256']
frozen = read(root / 'frozen-dependencies.json')
for name, digest in frozen.items():
    assert hashlib.sha256((Path(__file__).parent / name).read_bytes()).hexdigest() == digest.lower()
ids, identities, controllers = set(), set(), set()
last_freeze = max(dt(i['plan']['frozen_at']) for i in plans)
first_start = None
previous_exit = None
rows = []
stopped = False
for item in plans:
    name, plan = item['scenario'], item['plan']
    e = plan['experiment']
    primary = name.endswith('-cycle12')
    assert item['primary'] == primary
    assert e['blocks'] == 12 and int(e['operations_per_run']) == 16777216 and e['warmup_batches'] == 1
    assert e['seed'] == '20261116' and e['scenario_version'] == '22'
    assert e['analysis']['family_size'] == 24 and e['analysis']['alpha_family'] == 0.05
    assert e['analysis']['useful_improvement_ratio'] == (1 / 1.10 if primary else 0.95)
    assert e['maximum_duration_seconds'] == 600 and e['profile'] == 'quiet-validation'
    assert e['fresh_normal_build'] and e['confirmatory'] and e['independent_blocks']
    policy = e['guardrail_policies'][0]
    assert e['guardrail_metrics'] == ['scenario.thread_allocation_bytes_per_operation']
    assert policy['scale'] == 'absolute_difference' and not policy['descriptive_only']
    assert policy['equivalence_lower'] == -0.01 and policy['equivalence_upper'] == 0.01
    path = lambda suffix: root / (name + suffix + '.json')
    if not path('-terminal').exists():
        assert not complete
        rows.append(dict(scenario=name, state='unexecuted_or_unresolved_after_failure', sessions=0))
        stopped = True
        continue
    assert not stopped, 'Unexpected postfailure continuation'
    op = read(path('-terminal'))
    accepted = read(path('-operation'))
    assert op['id'] == accepted['id'] and op['target_id'] == plan['id']
    execution = unwrap(read(path('-execution')))
    assert execution['id'] == op['result_id'] and execution['plan_id'] == plan['id']
    assert execution['plan_hash'] == plan['content_hash'] and execution['operation_id'] == op['id']
    sessions = [unwrap(s) for s in read(path('-sessions'))]
    assert [s['id'] for s in sessions] == execution['session_ids']
    shutdown = read(path('-controller-shutdown'))
    assert shutdown['joined'] and shutdown['exitCode'] == 0
    controller = read(path('-controller'))
    key = (shutdown['pid'], shutdown['startTicks'])
    assert key == (controller['pid'], controller['startTicks']) and key not in controllers
    controllers.add(key)
    assert controller['entrySha256'].lower() == 'a270c5a6b2661ede3343b1d31e32d2d68c1ec9b783af02c3d31fc7e101e883f1'
    grant = read(path('-grant'))
    assert grant['maximum_operations'] == 24 and grant['target_id'] == plan['id']
    request = read(path('-request'))
    assert request == dict(action='start_confirmation', plan_id=plan['id'], grant_id=grant['id'], idempotency_key='P36-first-' + name)
    obs = {'baseline': [], 'candidate': []}
    blocks, allocs = {}, set()
    for s in sessions:
        t, m, r, arm = s['target'], s['measurement'], s['runtime'], s['variant']
        identity = (t['process_id'], t['start_time_utc_ticks'])
        assert identity not in identities and s['id'] not in ids
        identities.add(identity)
        ids.add(s['id'])
        assert t['runtime_version'] == '10.0.13' and t['architecture'] == 'X64'
        assert r['entry_assembly_hash'] == bundle_hashes[arm]['WorldNormal.dll']
        assert r['assembly_hashes'] == {k: v for k, v in bundle_hashes[arm].items() if k.endswith('.dll')}
        assert r['runtime_configuration_hash'] == bundle_hashes[arm]['WorldNormal.runtimeconfig.json']
        assert r['owned_process'] and not r['debugger_attached'] and not r['native_profiler_present']
        assert r['diagnostics_enabled'] == '0' and r['profiling_enabled'] == '0'
        assert not r['startup_hooks'] and not r['additional_dependencies']
        assert s['plan_id'] == plan['id'] and s['build_id'] == plan[arm + '_build_id']
        assert s['execution_id'] == execution['id'] and s['exit_code'] == 0
        assert s['compilation_regime'] == 'normal-build/fresh-process'
        start = dt(s['started_at'])
        first_start = min(first_start, start) if first_start else start
        exited = dt(s['exited_at'])
        assert exited >= start >= last_freeze
        assert previous_exit is None or start >= previous_exit, 'Fresh process lifetimes overlap'
        previous_exit = exited
        assert m['correct'] and m['quiescent'] and m['failure'] is None
        assert int(m['completed_operations']) == 16777216 and m['scenario_version'] == '22'
        assert m['input_hash'] == e['input_hash'] and m['execution_id'] == execution['id']
        assert m['run_id'] == s['id'] and m['start_thread_id'] == m['end_thread_id']
        assert abs(m['nanoseconds_per_operation'] - m['elapsed_nanoseconds'] / 16777216) < 1e-9
        obs[arm].append(m['nanoseconds_per_operation'])
        allocs.add((int(m['thread_allocation_bytes']), int(m['process_allocation_bytes'])))
        blocks.setdefault(s['block_ordinal'], []).append((s['arm_ordinal'], arm))
    row = dict(scenario=name, primary=primary, state=op['state'], plan_id=plan['id'],
               operation_id=op['id'], execution_id=execution['id'], sessions=len(sessions),
               observed_thread_process_allocation_pairs=sorted(allocs))
    if op['state'] == 'completed':
        assert len(sessions) == 24 and set(blocks) == set(range(12))
        assert all(sorted(arm for _, arm in v) == ['baseline', 'candidate'] and
                   sorted(ordinal for ordinal, _ in v) == [0, 1] for v in blocks.values())
        vector = unwrap(read(path('-objective_vector')))
        decision = read(path('-decision'))
        assert vector['execution_id'] == execution['id'] and vector['plan_id'] == plan['id']
        time = next(x for x in vector['effects_without_run_ids'] if x['metric'] == 'scenario.ns_per_operation')
        allocation = next(x for x in vector['effects_without_run_ids'] if x['metric'] == policy['metric'])
        assert time['family_size'] == allocation['family_size'] == 24
        assert time['independent_blocks'] == allocation['independent_blocks'] == 12
        interval = time.get('difference_interval')
        usable = time['availability'] == 'available' and time['quality'] == 'usable' and interval is not None
        futile = bool(primary and usable and interval['lower'] > 1 / 1.10)
        harmful = bool(not primary and usable and interval['lower'] > 1.05)
        row.update(time=time, allocation=allocation,
                   median_ns={k: statistics.median(v) for k, v in obs.items()},
                   descriptive_speedup=1 / time['effect'] if time.get('effect') else None,
                   speedup_interval=dict(lower=1 / interval['upper'], upper=1 / interval['lower'], coverage=interval['coverage']) if interval else None,
                   primary_futility=futile, guarded_harm=harmful,
                   tool_promotion_eligible=decision['promotion_eligible'], tool_reason_codes=decision['reason_codes'])
        assert 'DOTNETLAB_CONFIRMATION_FAILURE' not in (root / (name + '-controller.log')).read_text(encoding='utf-8-sig')
    else:
        stopped = True
        row.update(failure=execution.get('failure'), error_code=op['error_code'])
    rows.append(row)
if complete:
    assert len(ids) == len(identities) == 288 and len(controllers) == 12
    assert all(r['state'] == 'completed' for r in rows)
counterevidence = complete and any(r.get('primary_futility') or r.get('guarded_harm') for r in rows)
native_summary = read(task / 'native-summary-phase28-normal.json')
native = {}
expected_callers = {f'World{w}:After{op}(int):this (Tier1)' for w in ['UInt32', 'UInt16']
                    for op in ['Get', 'Lod', 'Chunk', 'Topology']}
for arm, label, listing in zip(['baseline', 'candidate'], ['p36n0', 'p36n1'], native_summary['listings']):
    stem = 'p36-normal-' + label + '-native'
    assert listing['file'] == stem + '.asm'
    assert hashlib.sha256((task / listing['file']).read_bytes()).hexdigest() == listing['sha256']
    identity = read(task / (stem + '-identity.json'))
    shutdown = read(task / (stem + '-shutdown.json'))
    assert identity['hash'].lower() == bundle_hashes[arm]['WorldNormal.dll']
    assert identity['regime'] == 'external-owned-JIT-diagnostic-not-quiet' and identity['scenario'] == 'cycle12'
    assert identity['pid'] == shutdown['pid'] and shutdown['exited'] and shutdown['exitCode'] == 0
    assert len([s for s in (task / (stem + '-output.log')).read_text(encoding='utf-8-sig').splitlines() if s.endswith(' valid')]) == 8
    callers = [m for m in listing['methods'] if m['method'] in expected_callers]
    assert len(callers) == 8 and {m['method'] for m in callers} == expected_callers
    assert all(m['listing_availability'] == 'complete' for m in callers)
    native[arm] = {}
    for m in callers:
        clear_sites = sum('ClearWithoutReferences' in c or 'ClearWithReferences' in c for c in m['call_sites'])
        assert (clear_sites > 0) if arm == 'baseline' else (clear_sites == 0)
        native[arm][m['method']] = dict(native_bytes=m['native_bytes'], fixed_rsp_subtractions=m['rsp_subtractions'], static_clear_call_sites=clear_sites)
audit = dict(epoch='p36-normal-first-family-v22', control='f0772c8', candidate='P36 ordered incremental maintenance only',
             complete=complete, planned_cases=12, planned_sessions=288,
             completed_cases=sum(r['state'] == 'completed' for r in rows), distinct_process_start_identities=len(identities),
             joined_controllers=len(controllers), all_plans_frozen_before_first_session=bool(first_start and last_freeze <= first_start),
             primary_futility_count=sum(r.get('primary_futility', False) for r in rows),
             guarded_harm_count=sum(r.get('guarded_harm', False) for r in rows),
             disposition='not_supported' if counterevidence else 'inconclusive', source_adoption=False,
             cases=rows, separate_exact_module_native_callers=native,
             rule='Only prospective usable/available difference intervals classify futility or guarded harm; no point-estimate rejection, allocation waiver, pooling or expansion.',
             limits='First family cannot authorize adoption. Residual paired independence is assumed; default hash seeds, heap/JIT placement and environmental drift remain. Full affected API, construction, mutation, storage, allocation and real-consumer confirmation plus original10x qualification remain open.')
output.write_text(json.dumps(audit, indent=2) + '\n')
print(json.dumps({k: v for k, v in audit.items() if k not in ['cases', 'limits', 'rule', 'separate_exact_module_native_callers']}))
