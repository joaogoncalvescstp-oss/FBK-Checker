# FBK Canvas — Claude Code Handoff

You're picking up an in-progress survey tool. This file is the full context. Read it, then continue development. The working file is **`FBK-Canvas-Edit.html`** (attach it alongside this prompt).

## What it is
A single-file, no-backend HTML/JS tool for **Saint Paul Public Works** that loads an AutoCAD/Civil 3D **FBK field book**, reduces the raw observations to coordinates, draws the field-to-finish **linework on a canvas (2D + 3D orbit)**, lets the user **edit codes / delete shots / move points / reorder figures / hand-edit raw FBK**, and **exports a surgically-edited FBK**. It's a sibling to the existing **FieldEdit-Pro** tool and follows the same house style.

Hosting target: **GitHub Pages**, government-managed Windows machine. Keep it one self-contained file.

## Non-negotiable conventions (match the existing codebase)
- **Single file.** All HTML/CSS/JS inline. No build step, no npm, no external libs, no CDN.
- **No browser storage.** No `localStorage`/`sessionStorage` (breaks in some sandboxes). State lives in JS.
- **Saint Paul brand + dark theme.** Navy `#071D49`, gold `#F1B434`. Dark canvas. Monospace for data.
- **Never silently corrupt raw measurements.** This is the prime directive (see Export below).
- Concise, structured code. The author has dyslexia — keep responses brief and direct, don't comment on phrasing.

## FBK domain knowledge (the important part — reverse-engineered from real data)
The file is **descriptor-coded field-to-finish**, NOT explicit `FIG` records. Linework comes from the point descriptions.

Record types seen:
- `NEZ <pt> <N> <E> <Z> "<desc>"` — coordinate/control points (header block = published control, e.g. CP13–CP66).
- `STN <pt> <HI> "<desc>"` — instrument setup (occupied point + instrument height).
- `Used last station setup` — resume previous STN/orientation.
- `BS <pt> <circle>` — backsight (point + horizontal circle reading, DMS-packed).
- `PRISM <h>` — current rod/prism height; applies to following shots until changed.
- `F1 VA <pt> <HA> <SD> <ZA> "<desc>"` — face-1 angle/distance shot. `F2` = face 2.
- `Deleted <time> <date>` — marks the preceding observation as deleted (excluded from processing). The file already uses this; reuse the convention.

**Angle format:** packed DMS `DDD.MMSSss` (e.g. `169.47402` = 169°47'40.2"). Helpers `dms2deg`/`deg2dms` already exist.

**Coordinate reduction:** orientation per setup = grid azimuth STN→BS (from control coords) minus the backsight circle. Then `az = ori + HA`, `HD = SD·sin(ZA)`, `VD = SD·cos(ZA)`, `N = Ns + HD·cosaz`, `E = Es + HD·sinaz`, `Z = Zs + VD + HI − prism`. F2 shots are normalized (`ZA→360−ZA`, `HA→HA+180`).

**Field-to-finish linework rules (critical):**
- A code is **only a line if it carries a `B`** (begin). Codes with no B (RMONO, RSTP, BCAN spot shots) stay **points**.
- `E` = end (open figure), `CLS`/`CL` = close (connect back to start).
- `BC … EC` = **begin curve … end curve**; the span renders as a circular **arc** (fit through first/mid/last). `PC`/`PT` treated as aliases.
- A modifier applies to the **figure code it follows** on that point. Points can carry **multiple codes** (e.g. `RWLK2 RMONO B` = continue RWLK2 **and** begin RMONO) → vertex on multiple figures.
- **Number suffixes are separate figures**: RWLK1, RWLK2, RWLK3 are three parallel lines, NOT one. Do **not** strip digits.
- `H…` / `V…` tokens (e.g. `H-0.67 V0.5`) are **stepped-reveal curb values** — ignore for connectivity.

## Current architecture (functions in the file)
- `parse(text)` → fills `RAW[]` (original lines), `PTS[]` (control + reduced shots; each shot stores `srcLine, stn, hi, ori, ha, sd, za, prism, sN/sE/sZ` station coords, `desc, code, face, deleted, edited, rawOverride?`).
- `parseDesc(desc)` → `{code:{begin,end,close,bc,ec}}`. `buildLinework()` → `CODES{}`. `figures()` → runs honoring B/E/CLS, applies `figOrder{}` overrides, assigns stable `id = code + '@' + beginSrcLine`.
- `sampleArc()` / `strokeFigure(f, proj, color)` → polyline + arc rendering, projection-agnostic.
- Rendering: `draw()` → `draw2D()` (plan, `W2S`/`S2W`) or `draw3D()` (orthographic orbit `P3()`, elevation-colored points, vert-exag slider, axis gizmo). `drawSelFig()` highlights selected figure with numbered vertices.
- Navigation: pan, wheel-zoom, zoom-window, **3D orbit**, **two-finger pinch/pan** (pointer-events `pointers` Map + `pinch`), zoom buttons, **Fit**, **Go-to-point** dialog.
- Editing: `inspect()` (point: edit descriptor, delete/restore, move; shows multi-figure membership), `inspectFig()` (figure: ▲▼ reorder, **Reverse**, Reset order, **Review/edit FBK**). `reduce(p)` re-reduces from edited HA/SD. `applyRawLine(p, raw)` parses a hand-edited line and sets `rawOverride`.
- **FBK code editor modal** (`openFbk`/`syncHL`/`applyFbk`): highlighted editable textarea of the figure's lines (`hlLine()` tokenizer).
- `exportFBK()` — surgical write-back into a copy of `RAW`:
  - Edited descriptors/HA/SD rewritten in place (`finalLine(p)`, honors `rawOverride`).
  - Deletions → insert `Deleted <stamp>` after the line.
  - **Reorders:** if within one setup → permute the VA lines among their slots (coords unchanged). If the new order **crosses a STN boundary** → emit the vertices as an ordered **`NEZ` block** (coordinates, full descriptor preserved) and mark the originals `Deleted`. Shared multi-figure points are flagged in the log.

## Verify before shipping
- No browser/IDE to render in CI; **syntax-check the script** by extracting it and running `node --check`.
- Manual test: open in a browser, load `P-1517_EARL_TOPO_S7_north_FIXED-EDITED.fbk` (sample FBK; ~5,500 lines, 60+ setups, control CP13–CP66). Expected: ~hundreds of points, dozens of figures, curb arcs on RCFL/RWLK/RAMP returns.

## Known limitations / backlog (good next tasks)
1. **MAG-occupied setups** (STN 500/502/503) aren't drawn — their station coords aren't in the NEZ header, so `ctrl[stn.id]` is undefined and those shots are skipped. Derive station coords from the sideshots that set them (the QC report did this) and feed `sN/sE/sZ`.
2. **Round-trip of NEZ-converted figures**: this parser reads `NEZ` as control only, so reordered-cross-setup figures re-import as points, not lines. Civil 3D rebuilds them fine. Optionally build figures from coded `NEZ` descriptions too.
3. **Shared-point reorder** shifts the point in *both* figures. "also on" badges warn, but a true fix = explicit figure-vertex lists independent of shot order (emit `FIG`/`BEG`/`CONT` records).
4. **Insert / append vertex** to a figure (currently can only edit/reorder/delete existing).
5. **Curve fit** uses first/mid/last of the BC…EC span — exact for 3-pt returns, approximate for long spans. Consider least-squares arc.
6. **F2 round-trip** when edited via the non-raw path writes normalized HA/ZA. The FBK code editor avoids this via `rawOverride`; the descriptor-only path is fine. Watch if adding new HA/SD editors.
7. **Layer/code panel** to toggle figure codes on/off (isolate curb work), and **select-by-code**.
8. **Undo** (edit log is the only audit trail today; reload reverts).

## House style reference
Tokens: `--navy #071D49`, `--gold #F1B434`, `--bg #0a0f1c`, `--panel #0f1626`, `--rule #22304d`, `--pass #35c184`, `--fail #ff5d52`, `--pt #7fb3ff`, `--ctrl #ffd24a`. Monospace everywhere for data. Keep the left tool rail, right inspector, edit log, and bottom HUD layout.

---
**First task suggestion:** confirm the file loads and renders the sample FBK, run `node --check` on the script, then pick a backlog item. Ask before large refactors — the single-file constraint and the FBK conventions above are load-bearing.
