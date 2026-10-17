"""Validate and summarize every retained observation; no outlier exclusions."""
import json
import pathlib
import statistics

evidence = pathlib.Path(__file__).parent / 'evidence'
summaries = {}
for epoch, pairs in [('exploration', 5), ('exploration-fullopts', 5), ('confirmation-fullopts', 3)]:
    cases = {}
    identities = []
    for pair in range(pairs):
        for arm in ['baseline', 'candidate']:
            lines = (evidence / f'{epoch}-{pair}-{arm}.jsonl').read_text().splitlines()
            records = [json.loads(line) for line in lines]
            assert len(records) == 61, (epoch, pair, arm, len(records))
            identities.append(dict(pair=pair, arm=arm, **records[0]))
            for row in records[1:]:
                key = (row['levels'], row['kind'], row['access'])
                cases.setdefault(key, dict(baseline=[], candidate=[]))[arm].append(row)
    summary = []
    for key, arms in sorted(cases.items()):
        entry = dict(levels=key[0], kind=key[1], access=key[2])
        checksums = {r['checksum'] for rows in arms.values() for r in rows}
        assert len(checksums) == 1
        for arm, rows in arms.items():
            assert len(rows) == pairs * 5
            assert all(r['allocatedBytes'] == 0 for r in rows)
            times = [r['nanoseconds'] for r in rows]
            entry[arm] = dict(observations=len(times), median_ns=statistics.median(times),
                              minimum_ns=min(times), maximum_ns=max(times), allocated_bytes=0)
        entry['checksum'] = checksums.pop()
        entry['reduction_percent'] = 100 * (1 - entry['candidate']['median_ns'] / entry['baseline']['median_ns'])
        summary.append(entry)
    summaries[epoch] = dict(cases=summary, process_identities=identities,
        interpretation='Descriptive pooled batch medians; correlated observations; no confidence or independence claim.')
(evidence / 'summary.json').write_text(json.dumps(summaries, indent=2) + '\n')
print('| Levels | Workload | Access | Baseline µs | Candidate µs | Reduction |')
print('| --- | --- | --- | ---: | ---: | ---: |')
for row in summaries['confirmation-fullopts']['cases']:
    print(f"| {row['levels']} | {row['kind']} | {row['access']} | "
          f"{row['baseline']['median_ns']/1000:.2f} | {row['candidate']['median_ns']/1000:.2f} | {row['reduction_percent']:.1f}% |")
