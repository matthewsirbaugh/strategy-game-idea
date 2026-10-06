#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check_dir="$(mktemp -d "${TMPDIR:-/tmp}/strategy-game-check.XXXXXX")"
trap 'rm -rf "$check_dir"' EXIT

run_check() {
    local label="$1"
    shift
    if ! godot --headless --path "$project_root/game" --log-file "$check_dir/engine.log" "$@" >"$check_dir/output.log" 2>&1; then
        cat "$check_dir/output.log" >&2
        exit 1
    fi
    # Godot can log a script error and still exit successfully.
    if grep -Eq '^(SCRIPT ERROR:|ERROR:|FAIL:)' "$check_dir/output.log"; then
        cat "$check_dir/output.log" >&2
        exit 1
    fi
    printf '%s: passed\n' "$label"
}

run_check 'Import and script registration' --import
run_check 'Battle rules' -s tests/test_rules.gd
run_check 'Hacking and context math' -s tests/test_hacking.gd
run_check 'Random playthroughs' -s tests/test_playthrough.gd
run_check 'Battle flow: into the AI' -s tests/test_battle_flow.gd
