#!/usr/bin/env python3
"""Normalize paired BenchmarkDotNet reports to comparable nanosecond statistics."""

from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path


HEADER = re.compile(
    r"^DeferredCapacityBenchmarks\.(?P<method>\w+): .*"
    r"\[Case=\"?(?P<case>[^,\"]+)\"?, Pattern=(?P<pattern>\w+)\]$"
)
MEAN = re.compile(r"^Mean = (?P<value>[\d,.]+) (?P<unit>ns|us|μs|µs|ms), .* N = (?P<n>\d+),")
RANGE = re.compile(
    r"^Min = (?P<min>[\d,.]+) (?P<min_unit>ns|us|μs|µs|ms), .*"
    r"Median = (?P<median>[\d,.]+) (?P<median_unit>ns|us|μs|µs|ms), .*"
    r"Max = (?P<max>[\d,.]+) (?P<max_unit>ns|us|μs|µs|ms)$"
)
SCALE = {"ns": 1.0, "us": 1_000.0, "μs": 1_000.0, "µs": 1_000.0, "ms": 1_000_000.0}


def number(value: str, unit: str) -> float:
    return float(value.replace(",", "")) * SCALE[unit]


def read_run(directory: Path) -> dict[tuple[str, str, str], dict[str, object]]:
    logs = list(directory.glob("*.log"))
    if len(logs) != 1:
        raise ValueError(f"expected one log in {directory}, found {len(logs)}")
    lines = logs[0].read_text(encoding="utf-8-sig", errors="replace").splitlines()
    results: dict[tuple[str, str, str], dict[str, object]] = {}
    current: tuple[str, str, str] | None = None
    partial: dict[str, object] = {}
    for line in lines:
        header = HEADER.match(line)
        if header:
            current = (header["method"], header["case"], header["pattern"])
            partial = {}
            continue
        if current is None:
            continue
        mean = MEAN.match(line)
        if mean:
            partial["mean_ns"] = number(mean["value"], mean["unit"])
            partial["n"] = int(mean["n"])
            continue
        spread = RANGE.match(line)
        if spread:
            partial["min_ns"] = number(spread["min"], spread["min_unit"])
            partial["median_ns"] = number(spread["median"], spread["median_unit"])
            partial["max_ns"] = number(spread["max"], spread["max_unit"])
            results[current] = partial
            current = None

    csv_files = list((directory / "results").glob("*-report.csv"))
    if len(csv_files) != 1:
        raise ValueError(f"expected one report CSV in {directory / 'results'}, found {len(csv_files)}")
    with csv_files[0].open(encoding="utf-8-sig", newline="") as source:
        for row in csv.DictReader(source):
            key = (row["Method"], row["Case"], row["Pattern"])
            if key in results:
                results[key]["allocated"] = row["Allocated"]
    return results


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    baseline = read_run(args.baseline)
    candidate = read_run(args.candidate)
    if baseline.keys() != candidate.keys():
        raise ValueError("baseline and candidate benchmark sets differ")

    fields = [
        "Method", "Case", "Pattern",
        "BaselineMeanNs", "BaselineMedianNs", "BaselineMinNs", "BaselineMaxNs", "BaselineN", "BaselineAllocated",
        "FinalMeanNs", "FinalMedianNs", "FinalMinNs", "FinalMaxNs", "FinalN", "FinalAllocated", "MedianDeltaPct",
    ]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8", newline="") as destination:
        writer = csv.DictWriter(destination, fieldnames=fields)
        writer.writeheader()
        for key in sorted(baseline):
            before = baseline[key]
            after = candidate[key]
            delta = (float(after["median_ns"]) / float(before["median_ns"]) - 1.0) * 100.0
            writer.writerow({
                "Method": key[0], "Case": key[1], "Pattern": key[2],
                "BaselineMeanNs": before["mean_ns"], "BaselineMedianNs": before["median_ns"],
                "BaselineMinNs": before["min_ns"], "BaselineMaxNs": before["max_ns"],
                "BaselineN": before["n"], "BaselineAllocated": before.get("allocated", ""),
                "FinalMeanNs": after["mean_ns"], "FinalMedianNs": after["median_ns"],
                "FinalMinNs": after["min_ns"], "FinalMaxNs": after["max_ns"],
                "FinalN": after["n"], "FinalAllocated": after.get("allocated", ""),
                "MedianDeltaPct": round(delta, 3),
            })


if __name__ == "__main__":
    main()
