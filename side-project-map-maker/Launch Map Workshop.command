#!/bin/zsh
set -e
workshop_dir="${0:A:h}"
cd "$workshop_dir"
godot_bin="$(command -v godot || true)"
if [[ -z "$godot_bin" && -x /Applications/Godot.app/Contents/MacOS/Godot ]]; then
  godot_bin=/Applications/Godot.app/Contents/MacOS/Godot
fi
if [[ -z "$godot_bin" ]]; then
  print "Godot was not found. Install Godot or add it to PATH, then run this launcher again."
  read "?Press Return to close."
  exit 1
fi
if [[ ! -d "$workshop_dir/.godot/imported" ]]; then
  print "The workshop's copied models need to be imported before the first run."
  print "From this folder, run: godot --headless --path . --import"
  read "?Press Return to close."
  exit 1
fi
exec "$godot_bin" --path "$workshop_dir"
