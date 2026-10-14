#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check_dir="$(mktemp -d "${TMPDIR:-/tmp}/strategy-game-check.XXXXXX")"
trap 'rm -rf "$check_dir"' EXIT

if grep -rq --include='*.import' '^compress/mode=0$' "$project_root/game/assets"; then printf '%s\n' 'FAIL: asset textures must use video-memory compression (compress/mode=2)' >&2; exit 1; fi

linter_path="$(command -v gdlint || true)"
if [[ -z "$linter_path" && -x "${PIPX_BIN_DIR:-$HOME/.local/bin}/gdlint" ]]; then
    linter_path="${PIPX_BIN_DIR:-$HOME/.local/bin}/gdlint"
fi
if [[ -n "$linter_path" ]]; then
    if ! (cd "$project_root" && "$linter_path" game tools) >"$check_dir/lint.log" 2>&1; then
        cat "$check_dir/lint.log" >&2
        exit 1
    fi
    printf '%s\n' 'GDScript lint: passed'
else
    printf '%s\n' 'GDScript lint: skipped (install gdtoolkit 4.x with pipx)'
fi

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
run_check 'Scenery fog: visibility and material opt-in' -s tests/test_scenery_fog.gd
