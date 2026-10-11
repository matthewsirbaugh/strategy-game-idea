#!/usr/bin/env python3
"""Five fresh processes and five warm restarts, using the same Godot probe."""
import argparse
import json
import pathlib
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("output", type=pathlib.Path)
parser.add_argument("--headless", action="store_true")
args = parser.parse_args()
args.output = args.output.resolve()
project = pathlib.Path(__file__).resolve().parents[1]
args.output.mkdir(parents=True, exist_ok=True)
command = ["godot", "--path", str(project / "game"), "--resolution", "1280x800", "--position", "60,60"]
if args.headless:
    command.append("--headless")
samples = []
for run in range(6):
    scenario = f"fresh-{run + 1}" if run < 5 else "restarts"
    log = args.output / f"{scenario}.log"
    invocation = command + ["--log-file", str(log), "-s", "../tools/profile_startup.gd"]
    if run == 5:
        invocation += ["--", "--restarts"]
    result = subprocess.run(invocation, cwd=project, text=True, capture_output=True, timeout=180)
    log.write_text(result.stdout + result.stderr)
    if result.returncode or any(line.startswith(("SCRIPT ERROR:", "ERROR:", "FAIL:")) for line in log.read_text().splitlines()):
        raise SystemExit(f"Benchmark failed; inspect {log}")
    for line in result.stdout.splitlines():
        if line.startswith("STARTUP_SAMPLE "):
            sample = json.loads(line.removeprefix("STARTUP_SAMPLE "))
            samples.append(sample)
            print(json.dumps(sample), flush=True)
    (args.output / "samples.json").write_text(json.dumps(samples, indent=2) + "\n")
