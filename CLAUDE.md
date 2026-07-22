# FBK Checker — Standing Notes & Common Requests

Notes from the owner so they don't get forgotten between sessions. Read this
first and follow it on every task in this repo.

## Standing rules (always do these)

- **Bump the fruit version badge on EVERY push.** Use a *different* fruit each
  time and increment `build`. This lets me confirm the live page isn't cached.
  - Update BOTH places in `index.html`:
    1. The static badge span (`id="fruitBadge"`) text near the top of `<body>`.
    2. The `const VERSION={fruit,name,build}` marker in the script
       (search for `VERSION MARKER`).
  - History so I can tell what's live:
    | Build | Fruit | Note |
    |-------|-------|------|
    | 1 | 🍎 APPLE | knockdown corrections |
    | 2 | 🍌 BANANA | RCFL flow-line knockdown |
    | 3 | 🍇 GRAPE | RCFL knockdown only at points with their own curb code |
    | 4 | 🍊 ORANGE | COGO insert keeps proper FBK format (code + moved B/E) |
    | 5 | 🍓 STRAWBERRY | editable inspector: any field edit reflects to the FBK |
    | 6 | 🍒 CHERRY | inserted pt shows formatted line in review; per-line "render as NEZ" checkbox |
    | 7 | 🥝 KIWI | drag-and-drop vertex rows to set draw order in the line editor |
    | 8 | 🍑 PEACH | canvas vertex order # moved below node so it doesn't overlap the pt # |
    | 9 | 🍍 PINEAPPLE | line-code review: hover a knocked-down H/V offset to see the curb code + REF that produced it |
    | 10 | 🥭 MANGO | line-code review: rolled back the hover; added a toggle button to show curb codes (before knockdown) vs baked offsets |
    | 11 | 🍐 PEAR | moved the knockdown codes/offsets toggle into the Review/edit FBK code window (off the inspector panel) |
    | 12 | 🍉 WATERMELON | Add Point (COGO): "Pick on canvas" with basic CAD object snap (endpoint, apparent intersection of 2 lines, midpoint, nearest) |
    | 13 | 🥥 COCONUT | COGO snap now includes curb offset lines; intersection snap prompts which elevation to use (line A / line B / average / custom) |
    | 14 | 🍋 LEMON | Import CSV (PNEZD): comma-delimited point#, N, E, Z, description → NEZ points; standalone COGO/CSV points now always export |
    | 15 | 🍎 APPLE | Export CSV (↓ Export CSV): all points → comma-delimited PNEZD file, round-trips with Import CSV |
    | 16 | 🍇 GRAPE | MAP background: brighter aerial (white backing + brightness lift, α0.9) and higher resolution (4096px, 2× DPR, auto-downsize retry) |
    | 17 | 🍊 ORANGE | MAP now uses the ArcGIS JS API — a tiled MapView behind the canvas, synced to the 2D view (fast/progressive tiles); image export kept as fallback |
    | 18 | 🍓 STRAWBERRY | fix "no map": image now ALWAYS loads immediately; ArcGIS only takes over once its imagery layer genuinely loads (no more dead-loading trap) |
    | 19 | 🍒 CHERRY | ArcGIS MapView built in the county's custom projection (Ramsey Lambert WKT) so tiles actually render — was blank because it defaulted to Web Mercator |
    | 20 | 🥝 KIWI | ArcGIS SDK disabled (county server has no CORS); MAP now a tiled 3×3 plain-<img> mosaic — sharper + streams in progressively; Esri single-image fallback |
    | 21 | 🍑 PEACH | box (marquee) multi-select in SEL: drag to select many points, Shift-drag adds, bulk Delete/Restore, Del key + Esc-clear |
  - Suggested next fruits to rotate through: 🍇 GRAPE, 🍊 ORANGE, 🍓 STRAWBERRY,
    🍒 CHERRY, 🥝 KIWI, 🍑 PEACH, 🍍 PINEAPPLE, 🥭 MANGO, 🍐 PEAR, 🍉 WATERMELON.

## Knockdown behavior (⚙ button → `applyKnockdown()`)

- **RBCB** (rod on back of curb) → uses the **Back-of-Curb DB** (`CURB_BOC`).
  - A point with its own curb code gets that code's std cross-section (overrides REF).
  - A point with no code derives the reveal from the nearest **REF** point's Z
    difference. **REF is a back-of-curb-only workflow.**
- **RCFL** (rod on flow line) → gets the std **Flow-Line DB** (`CURB_FL`)
  cross-section (full reveal), but **only at points that carry their OWN curb
  code** in the description. A flow-line point with no code is left untouched —
  it does NOT inherit the last-seen code or a default. **Do NOT use REF for RCFL.**

## Insert point by COGO (`insertCogoPoint()`) — keep FBK format valid

- An inserted point must carry the **figure code** (e.g. `RCFL1`), never a
  placeholder like `COGO inserted`. CAD needs the code or the linework breaks.
- Insert at **start** (pos 0): new point gets `<code> B`; the `B` is MOVED off
  the old first point (it drops to just `<code>`).
- Insert at **end**: if the old last point had `E`, move it to the new point
  (`<code> E`); otherwise the new point is just `<code>`.
- Inserted points have `srcLine = -1` and export as fresh `NEZ` records placed
  in the right file position (not appended to a non-existent source line).

## MAP background — tiled plain-`<img>` mosaic (`fetchMapTiles`/`drawMapBackground`)

- **Why not the ArcGIS SDK:** an ArcGIS `ImageryLayer`/`MapView` loads via `fetch`/XHR
  which needs **CORS**, and `maps.co.ramsey.mn.us` sends none → blank. The service SR
  is also a custom **Ramsey County Lambert Conformal Conic** (US ft, custom datum, no
  wkid) the client can't reproject. So `USE_ARCGIS=false`; the SDK code (`initArcGIS`/
  `syncArcGIS`, `RAMSEY_WKT`, `#agmap`) is left in but dormant. Flip `USE_ARCGIS` only
  if the county server ever adds CORS.
- **Ramsey (default):** a **3×3 grid** of `/export` requests (plain `<img>`, no CORS),
  each ~near-screen resolution, fired in parallel and drawn as each arrives — so it's
  ~3× sharper than one capped export and streams in progressively (fixes dark/low-res/
  slow). Survey coords are passed as the bbox directly (native county SR). Tiles are
  `[{img,ext,ok}]` in `mapTiles`; `drawMapBackground` paints a white backing then the
  bright tiles (α `mapAlpha`, brightness/contrast lift), overlapping 0.5px to hide seams.
- **Esri fallback:** if every county tile errors, `mapSource='esri'` fetches one
  World_Imagery image (Web Mercator via `surveyToLL`/`llToMerc` calibrated transform).
- **Refresh:** `scheduleMapRefresh` (350ms debounce) refetches on viewport change; keyed
  by `viewKey` to skip duplicates. Hidden in 3D and when MAP is off.
- **Untested here:** the sandbox blocks `maps.co.ramsey.mn.us`, so live verification needed.

## Import CSV / PNEZD (`importCSV`, ↥ Import CSV button)

- Comma-delimited coordinate import: **point number, Northing, Easting, Elevation
  (Z), Description** (PNEZD). Rows become `srcLine=-1` NEZ/control points; figure
  codes in the description drive linework like any other coded point.
- A **header row** is auto-detected (non-numeric N/E in row 1) and skipped. The
  **description may contain commas** (fields 5+ are re-joined). Blank/duplicate
  point numbers are auto-renumbered. Points are **appended** to whatever is loaded
  (import several files, or layer onto an FBK).
- Export safety net (`exportFBK` step 3b): every non-deleted `srcLine<0` point not
  already written in a figure block is emitted as a fresh `NEZ` at the end — so
  CSV-imported and simple Add-Point (COGO) points are never dropped, even with no
  FBK loaded (RAW empty).
- **Export CSV** (`exportCSV`, ↓ Export CSV button): writes every non-deleted point
  back out as a `Point,Northing,Easting,Elevation,Description` file (3-dp coords,
  header row, descriptions CSV-quoted when they contain commas/quotes). Round-trips
  with `importCSV`.

## Add Point (COGO) canvas pick + CAD snap (`startCogoPick`/`snapPoint`)

- The **Add Point (COGO)** dialog has a **📍 Pick on canvas (snap)** button. It
  hides the dialog, lets you click the drawing, and fills N/E/Z from the click.
- Basic CAD object snap (`snapPoint`, 2D only) in priority order: **endpoint**
  (any point/vertex), **apparent intersection** of two lines (lines are extended
  until they cross — the headline request), **midpoint**, then **nearest** on a
  segment. Z is interpolated along the segment (W2S is affine, so the screen-space
  parameter equals the world parameter); apparent-intersection Z is the average of
  the two lines' Z at the crossing.
- A live osnap marker is drawn under the cursor (▢ endpoint, ✕ intersection,
  △ midpoint, ⋈ nearest). No snap in range → free pick (N/E only, Z left for the
  user). **Esc** cancels and reopens the dialog. Both the figure linework **and
  the curb cross-section offset lane lines** are snapped (`collectOffsetSegments`
  rebuilds the offsets as world segments using the same math as `drawOffsets`).
- **Intersection elevation prompt** (`openZPick`): an apparent intersection of two
  lines can have two different Z values, so picking an intersection sets N/E and
  then opens a chooser — line A's Z, line B's Z, the average, or a custom value.
  Esc/Cancel returns to the Add Point dialog.

## Box (marquee) multi-select (`selSet`, `inspectMulti`, `multiDelete`)

- In **SEL** mode, dragging on empty canvas draws a marquee (reuses `#zwbox`); on
  release, every non-deleted point whose `W2S` screen position is inside the box is
  added to `selSet`. **Shift/Ctrl-drag** adds to the existing set instead of replacing.
- A short drag (<5px) is treated as a **click** → figure pick / deselect (so clicking
  a line still selects the figure). `sel` (single) and `selSet` (multi) are mutually
  exclusive — selecting one point clears `selSet`.
- Selected points highlight gold (`drawPt` uses `hot=i===sel||selSet.has(i)`).
  `inspectMulti()` shows the count with **Delete / Restore / Clear**; `multiDelete()`
  bulk-sets `.deleted` (archived as Deleted on export). **Del/Backspace** deletes the
  set, **Esc** clears it (both guarded against typing in inputs). Undo/redo clears it.

## Figure / line code review (`inspectFig`)

- Each vertex row shows its **current** formatted FBK line via `pointFbkLine()`
  (reflects edits; inserted points with `srcLine = -1` render as an `NEZ`
  record instead of a blank line). After a COGO insert the panel refreshes
  automatically so the new point's line shows.
- **Render line as NEZ** checkbox (`figNEZ[figId]`) → on export, every vertex
  of that line is emitted as an `NEZ` coordinate record (originals archived as
  `Deleted`). Use it so the linework is independent of which setup each point
  was shot from. The FBK code editor (`applyRawLine`) now also accepts `NEZ`
  lines, not just `F1/F2 VA`.

## Project layout

- Single-file app: `index.html` (HTML + CSS + JS inline).
- Curb template databases live both inline in `index.html` (`CURB_BOC`,
  `CURB_FL`, `CURB_KD`) and as text files in `data/`.

## Workflow

- Develop on branch `claude/ecstatic-mendel-4ngsu9`; owner also wants pushes
  reflected on `main`. Keep the two in sync.
- Verify inline script parses before pushing (e.g. extract `<script>` and
  `new Function(...)` it with node).
