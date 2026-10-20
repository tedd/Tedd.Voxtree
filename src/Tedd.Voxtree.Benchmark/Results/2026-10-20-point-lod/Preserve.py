"""Export completed, task-local DotNetLab evidence before workspace cleanup."""
import argparse
import base64
import csv
import hashlib
import json
import sqlite3
import zipfile
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("task_root", type=Path)
parser.add_argument("output", type=Path)
parser.add_argument("--label", default="")
args = parser.parse_args()
if args.label and not args.label.replace('-', '').isalnum():
    raise SystemExit('Archive label must be alphanumeric with optional hyphens')
suffix = '-' + args.label if args.label else ''
root = args.task_root.resolve()
if root.parent != Path("D:/Workspaces/AI").resolve():
    raise SystemExit("Expected a dedicated task directory under D:/Workspaces/AI")
args.output.mkdir(parents=True, exist_ok=True)

def unwrap(value):
    return json.loads(value["json"]) if isinstance(value, dict) and "json" in value else value

rows = []
for path in sorted(root.glob("**/*comparison.json")) + sorted(root.glob("**/*objective_vector.json")):
    if "artifacts" in path.relative_to(root).parts or "driver-source" in path.parts:
        continue
    value = unwrap(json.loads(path.read_text(encoding="utf-8-sig")))
    if not isinstance(value, dict) or "effects_without_run_ids" not in value:
        continue
    for effect in value["effects_without_run_ids"]:
        ratio = effect.get("effect")
        interval = effect.get("difference_interval") or {}
        latency = effect["metric"] == "scenario.ns_per_operation"
        rows.append({
            "evidence": str(path.relative_to(root)).replace("\\", "/"),
            "scope_validity": "unchanged_namespace_control" if path.parent.name == "p0-quiet" else "namespace_screening_only" if path.name.endswith("comparison.json") else "identical_caller_fresh_confirmation",
            "regime": "cpu_diagnostic" if path.parent.name.endswith("-diagnostic") else "fresh_normal" if path.name.endswith("objective_vector.json") else "descriptive_paired",
            "execution_id": value.get("execution_id"), "plan_id": value.get("plan_id"),
            "metric": effect["metric"], "candidate_over_baseline": ratio,
            "speedup": 1 / ratio if latency and ratio else None,
            "speedup_lower": 1 / interval["upper"] if latency and interval else None,
            "speedup_upper": 1 / interval["lower"] if latency and interval else None,
            "interval_coverage": interval.get("coverage"),
            "classification": effect.get("effect_class"), "quality": effect.get("quality"),
            "independent_blocks": effect.get("independent_blocks"),
            "promotion_eligible": value.get("promotion_eligible"),
            "reason_codes": ";".join(effect.get("reason_codes", [])),
        })
if rows:
    with (args.output / f"measurements{suffix}.csv").open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)

catalogs = sorted(root.glob("*/catalog.sqlite"))
catalog_directories = {p.parent.name for p in catalogs}
source_directories = {"baseline", "rig", "g2", "g3", "q1", "q2", "q3", "q4", "normal-baseline", "normal-candidate", "steady-baseline", "steady-candidate"}
source_directories.update(p.parent.name for p in root.glob("*/Rig.csproj"))
source_directories.update(p.name for p in root.iterdir() if p.is_dir() and (p.name.endswith("-baseline") or p.name.endswith("-source")))
source_directories.update(p.name for p in root.iterdir() if p.is_dir() and p.name.startswith(('forcecraft-scanner', 'dense-byte-validation', 'packed-lookup-validation')))
manifest = []
archive_path = args.output / f"evidence{suffix}.zip"
with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
    def add(name, data):
        archive.writestr(name, data)
        manifest.append({"path": name, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()})

    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(root)
        parts = relative.parts
        if path.name.startswith("catalog.sqlite") or path.suffix == ".lock":
            continue
        if any(p in {"obj", "bin", "temp", "incoming"} for p in parts[1:-1]):
            continue
        include = len(parts) == 1 and path.suffix in {".json", ".jsonl", ".txt", ".log", ".ps1", ".diff", ".asm"}
        if parts[0] in catalog_directories and not any(p in {"temp", "incoming"} for p in parts[1:-1]):
            include = True
        if parts[0] in source_directories and not any(p in {"obj", "bin"} for p in parts[1:-1]):
            include = path.suffix in {".cs", ".csproj", ".txt", ".json"}
        if parts[0] == "bundles":
            include = path.suffix in {".dll", ".json"}
        if parts[0].endswith("-results"):
            include = path.suffix in {".trx", ".json", ".xml"}
        if parts[0].startswith('forcecraft-census'):
            include = path.suffix in {'.csv', '.json', '.u16le'}
        if include:
            add(relative.as_posix(), path.read_bytes())

    for catalog in catalogs:
        # URI mode=ro forbids database mutation. Export every table and its schema;
        # preserve raw JSON strings and binary columns without interpreting them.
        with sqlite3.connect(catalog.as_uri() + "?mode=ro", uri=True) as connection:
            tables = connection.execute("SELECT name,sql FROM sqlite_master WHERE type='table' ORDER BY name").fetchall()
            exported = []
            for name, schema in tables:
                quoted = '"' + name.replace('"', '""') + '"'
                cursor = connection.execute("SELECT * FROM " + quoted)
                columns = [column[0] for column in cursor.description]
                records = []
                for row in cursor:
                    records.append([{"base64": base64.b64encode(v).decode()} if isinstance(v, bytes) else v for v in row])
                exported.append({"name": name, "schema": schema, "columns": columns, "rows": records})
        add(catalog.parent.name + "/catalog-export.json", json.dumps(exported, ensure_ascii=False).encode())
    archive.writestr("manifest.json", json.dumps(manifest, indent=2).encode())

digest = hashlib.sha256(archive_path.read_bytes()).hexdigest()
(args.output / f"evidence{suffix}.sha256").write_text(digest + "  " + archive_path.name + "\n", encoding="utf-8")
print(json.dumps({"archive_bytes": archive_path.stat().st_size, "files": len(manifest), "catalogs": len(catalogs), "metric_rows": len(rows), "sha256": digest}))
