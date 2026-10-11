# Model Library

A standalone Godot application for reviewing the project's recorded 3D assets. The viewer reads
`game/assets/README.md`'s contract and never changes assets or their records. It loads GLB/glTF
files directly at runtime, so new models don't need an editor import.

## Open it

The Mac application is **Model Library.app**. Double-click it, then right-click its Dock icon and
choose **Options → Keep in Dock**. The local build is in `build/Model Library.app`; the installed
copy is in `~/Applications/Model Library.app`.

From the project root:

```sh
godot --path game/preview/model_viewer
```

Rebuild the local Mac app with the installed Godot 4.7 runtime:

```sh
python3 game/preview/model_viewer/build_macos.py
```

To build directly into the user's Applications folder:

```sh
python3 game/preview/model_viewer/build_macos.py --output "$HOME/Applications/Model Library.app"
```

The app includes its runtime; using it doesn't require a separate Godot installation. The build
uses the installed official editor binary as the local runtime, plus an ad-hoc Mac signature.
It is a local application, not a notarized distribution build. Models stay in the repository;
the bundled default library location and saved preferences point there. If the project moves,
use **Open library…** and select its `game/assets` folder.

## Review a model

- **Folders** preserves the on-disk asset hierarchy. **All models** gives a flat list with newest
  added, oldest added, A–Z, Z–A, folder, and recently updated sorting. Search matches names, ids,
  categories and paths; the status menu filters the asset review state.
- Clicking a model loads it and centers the camera around its actual geometry. **Refresh** or
  Command-R discovers new records and reloads the selection. It also invalidates cached model
  data, so replacing a model is visible even when its timestamp and file size are unchanged.
- Left-drag pans; right-drag or Option-left-drag orbits. Middle-drag also pans. Mouse wheel and
  pinch zoom; two-finger pan moves the camera. **Frame**, F or double-click recenters the view.
- **View** includes front, back, left, right, top and bottom presets, orthographic projection,
  a slow turntable, and the ground grid toggle.
- **Materials**, **Clay**, **Albedo**, **Normals** and **Wireframe** expose different aspects of
  surface quality and geometry. Studio, Bright and Contrast lighting help inspect silhouettes
  and surface response. Normals are shown in camera space; wireframe shows triangulated edges.
- **Details** collapses the inspector. It shows dimensions in metres, geometry counts, material
  names and texture resolutions, file size, review status, dates, provenance and notes. Finder
  and record buttons open the source locations for closer inspection.
- Animation controls appear for embedded or recorded clips. Choose a clip to play it, pause,
  drag the timeline to inspect a pose, or choose **Still** to restore the rest pose. Space toggles
  playback. External clips use matching skeleton bone names; incompatible clips are reported.
- **Capture…** saves a PNG of the viewing area without the application controls.

Added dates use the model file's creation date on macOS (file modification date elsewhere).
Updated dates use the model's modification time. These are filesystem dates, not Git history.
Dates display in the Mac's current local timezone. File copies can change creation dates.

Folders without a matching `<folder-name>.json` record remain folders, not listed models. This
keeps source packs and animation-only files from becoming duplicate asset entries. Invalid
records are listed under **Issues**; the rest of the library remains available.

## Implementation

- `catalog.gd` scans folders, validates records, and collects dates. It doesn't load model data.
- `stage.gd` parses selected files on a worker thread, builds their scene on the main thread,
  measures geometry, and handles rendering, camera control and animation. Its two-entry cache
  bounds memory use. Static views stop rendering between changes; animation renders at 60 fps.
- `viewer.gd` owns the browser, inspector, filters, refresh, capture and preferences. Preferences
  are stored in `~/Library/Application Support/Model Library/preferences.cfg`.
- `build_macos.py` bundles the runtime and viewer, creates the Dock icon, and signs the app.

The viewer is its own small Godot project under `game/preview/`, independent of the battle's
scripts, globals, input settings and shaders. Rendering is deliberately neutral; it shows the
model's imported materials rather than the game's toon treatment. Frame and dimensions use the
rest-pose bounds, even when a character is animated. Legacy `fit_to_height` models are resized and
grounded according to the asset contract; other models keep their authored scale.

Godot runtime loading follows the [GLTFDocument API](https://docs.godotengine.org/en/4.7/classes/class_gltfdocument.html).

## Verification — 2026-10-10

All 13 registered assets loaded, with five inspection modes and six camera presets exercised.
All eight recorded animation files loaded with matching skeleton tracks. Temporary fixtures
verified new-asset refresh, malformed-record isolation, retained selection, alphabetical sorting,
search, status filtering, cached selection and camera input handling. The native Mac app was
visually checked for character framing, list selection, animation playback, panning and zooming.
The installed resource pack started without script errors. Bryson tried the app and reported
that it works great.

The existing-library scan took about 34 ms. The automated loading and inspection pass took about
0.2 seconds per prop and 0.9–1.4 seconds per character, including construction of the wireframe
geometry; these are local test timings, not guarantees for larger future models.
