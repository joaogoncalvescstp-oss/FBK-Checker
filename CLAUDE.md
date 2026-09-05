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
    | 22 | 🍍 PINEAPPLE | fix MAP blank/no imagery: county ImageServer request used the wrong REST op (`/export`, a MapServer-only name) instead of `/exportImage` — every tile 404'd silently; added USGS NAIP as a 3rd fallback (county → Esri → NAIP) |
    | 23 | 🥭 MANGO | fix MAP tiles misaligning relative to each other on zoom: grid cells requested a fixed *square* pixel size against a non-square bbox, and `adjustAspectRatio` (default true) was silently expanding each cell's bbox server-side to compensate — by a different amount per cell, so they drifted apart; forced `adjustAspectRatio=false` on all 3 map sources |
    | 24 | 🍇 GRAPE | BC..EC linework now fits a true best-fit constant-radius arc (least-squares circle fit through all the shots) instead of a wiggly cubic spline — matches how a real curve is staked; falls back to the old spline only when the points are near-collinear and don't fit a circle |
    | 25 | 🍊 ORANGE | fix build-24 arc fit silently returning a wildly wrong giant circle on real survey coords: county/state-plane N/E run in the 100,000s-1,000,000s of feet, and squaring raw values that large loses precision (catastrophic cancellation) in the least-squares normal equations — `circleFitLS` now recenters on the points' local centroid before fitting, then shifts the solved center back to world coords |
    | 26 | 🍓 STRAWBERRY | fix build-25 arc: it drew each point PROJECTED onto the single least-squares circle, so real (noisy) shots that weren't perfectly concyclic drifted slightly off their true position — now every consecutive pair gets its own circle of (as close as possible to) the fitted design radius solved to pass through BOTH real points exactly, so the drawn curve always hits every shot on the nose |
    | 27 | 🍒 CHERRY | the green curb offset **lane lines** now curve through a BC..EC run too, instead of chording straight across it — `drawOffsets` detects the run on the base line and runs the *same* `sampleCurve` best-fit-through-every-point machinery on that lane's own offset points, so it independently best-fits (and passes through) its own points, tracking the base curve's curvature in parallel |
    | 28 | 🥝 KIWI | fix `offsetAt` corners: it offset each vertex using the AVERAGED prev→next secant direction, which pinches a sharp corner in short instead of extending it — a 1.0 offset at a 90° corner (e.g. a rectangle) landed only 1.0 from the true corner instead of the correct 1.4142 (√2) miter distance. `offsetAt` now offsets each adjacent segment individually and intersects the two offset lines at interior vertices — the standard mitered/extended corner (CAD `OFFSETGAPTYPE=0`) |
    | 29 | 🍑 PEACH | BC..EC now understands **PCC** (point of compound curve) and **PRC** (point of reverse curve) — either splits the run into independently-fit sub-arcs, so a real compound/reverse curve no longer gets crammed into one meaningless average-radius circle; and the curb offset lane lines through a curve now derive their radius explicitly as that base segment's own fitted radius ± the lane's offset distance (not an independent re-fit of the offset points) |
    | 30 | 🍐 PEAR | Zoom window (⊕ WIN / `Z`) now works in the 3D orbit view, not just 2D — picking it no longer force-switches you back to plan view; drag a box on the 3D canvas and it zooms to fit exactly like 2D does, via a screen-space affine fit of `orbit.s/ox/oy` (there's no world-space inverse for the oblique orbit projection, unlike 2D's `S2W`) |
    | 31 | 🍉 WATERMELON | inspector now shows a shot's **Rod HT** (prism height) and lets you correct it — HA/SD/ZA stay the exact same observation, only Z is recomputed (`reduce()`); export brackets the corrected shot with `PRISM <new>` / `PRISM <original>` lines so it never touches any other point still relying on the original height on that setup — verified with a full parse→edit→export→re-parse round trip |
    | 32 | 🥥 COCONUT | **Insert point on line** (⊕ Click line to insert point) now gets the same CAD apparent-intersection snap as COGO canvas-pick — click near where the line crosses another line (or a curb offset lane) and it snaps to that crossing, then asks which elevation to use, since the two lines can sit at different Z. `openZPick` generalized (caller-supplied callback) so both flows share one elevation-chooser |
    | 33 | 🍋 LEMON | added a **Snap to line crossings** checkbox (`insertSnapOn`, on by default) next to the insert-on-line button — unticking it skips the build-32 crossing-snap pass entirely, so a click always lands at the plain along-the-line position with no elevation prompt, for when you're inserting near a crossing you don't actually want to snap to |
  - Suggested next fruits to rotate through: 🍇 GRAPE, 🍊 ORANGE, 🍓 STRAWBERRY,
    🍒 CHERRY, 🥝 KIWI, 🍑 PEACH, 🍐 PEAR, 🍉 WATERMELON, 🥥 COCONUT, 🍋 LEMON.

## Knockdown behavior (⚙ button → `applyKnockdown()`)

- **RBCB** (rod on back of curb) → uses the **Back-of-Curb DB** (`CURB_BOC`).
  - A point with its own curb code gets that code's std cross-section (overrides REF).
  - A point with no code derives the reveal from the nearest **REF** point's Z
    difference. **REF is a back-of-curb-only workflow.**
- **RCFL** (rod on flow line) → gets the std **Flow-Line DB** (`CURB_FL`)
  cross-section (full reveal), but **only at points that carry their OWN curb
  code** in the description. A flow-line point with no code is left untouched —
  it does NOT inherit the last-seen code or a default. **Do NOT use REF for RCFL.**

## BC..EC curve linework (`sampleCurve`/`sampleArcFit`, build 24-29)

- A **BC..EC** span (`PC`/`PT` are aliases) renders as a **constant-radius
  arc that passes exactly through every shot** — not an arbitrary wiggly
  spline, and not a curve that only approximates the shots. `circleFitLS`
  does a least-squares (Kåsa) circle fit through every shot's N/E in the span
  to get the one **design radius** for the whole run (matches how a real
  curve is staked in the field). Then `sampleArcFit` walks the span pair by
  pair: for each consecutive real shot P→Q, `circleThroughChordR` solves the
  *specific* circle of (as close as possible to) that design radius that
  passes through **both** P and Q exactly, picking whichever of the two
  solutions sits on the same side as the overall fit (so direction stays
  consistent run to run, out-of-order/CW/CCW included), then arcs the shorter
  way around from P to Q. Elevation is linear between each real P.Z/Q.Z, so
  every shot's Z is hit exactly too.
  - **Build 26 fix:** build 24/25 sampled points straight off the single
    least-squares circle (`c.E+c.r*cos(angle)`), which only lies exactly on a
    real shot when that shot happens to sit exactly on the fitted circle —
    real (noisy) shots don't, so the drawn curve quietly drifted off the
    actual point positions. Solving a per-segment circle through the real
    P/Q pair (this section) fixes that: the curve now passes through every
    point, always, not just approximately.
  - If a chord is longer than the fitted diameter (a sparse/outlier shot),
    `circleThroughChordR` widens just enough for that one segment (semicircle
    limit) rather than failing — verified this still lands exactly on both
    endpoints.
  - If the points are effectively collinear (no meaningful circle fits, or the
    fitted radius is unrealistically huge), `circleFitLS` returns `null` and
    `sampleCurve` **falls back to the old spline** (which also interpolates
    every point exactly) rather than drawing garbage.
  - `circleFitLS` recenters points on their local centroid before fitting,
    then shifts the solved center back to world coords — real N/E are
    county/state-plane coords (100,000s-1,000,000s of ft), and fitting
    directly on raw values that large loses too much double-precision
    (catastrophic cancellation) in the normal-equations determinant. Always
    test this code with realistic large coordinates, not small ones near the
    origin — small coords hide that class of bug.
  - A 2-point BC..EC span (no interior shots) has no unique circle — stays a
    straight line, same as before.
  - **Build 27:** the curb cross-section offset **lane lines** in `drawOffsets`
    now curve through a BC..EC run too (previously always chorded straight
    vertex-to-vertex regardless of the base line — a curb offset line looked
    faceted next to the now-curved base line it was standing off). For each
    lane, `drawOffsets` still computes each vertex's offset point via
    `offsetAt` (see build 28 below), but when the base line's vertex range
    for that stretch is a BC..EC run, it now calls the *same* `sampleCurve`
    used for the base line on that lane's own run of offset points — an
    independent least-squares circle fit through the offset points
    themselves, guaranteed to pass through every one of them exactly (same
    guarantee as the base curve), and it naturally tracks the base curve's
    center/radius since the offset points are geometrically a parallel copy
    of it. Falls back to the old straight vertex-to-vertex connector if any
    point in that lane's run is missing (a gap from `SO`/an uncoded point).
    `collectOffsetSegments` (used for the OSNAP endpoint/intersection engine)
    is intentionally left as straight vertex-to-vertex chords — same
    approximation the main figure's own snap segments (`collectSegments`)
    already use for a curved base line, so this isn't a regression, just
    consistent with the existing snap tradeoff.
  - **Build 28 fix — mitered/extended corners (`offsetAt`):** at an interior
    vertex, `offsetAt` used to offset perpendicular to the AVERAGED
    prev→next secant direction — at a sharp corner (e.g. a rectangle/RECT
    turn, or any real curb corner) that pinches the corner in short instead
    of extending it: a 1.0 ft offset on a 90° corner landed only 1.0 ft from
    the true corner, when the correct mitered/extended distance (what every
    CAD OFFSET command draws by default — `OFFSETGAPTYPE=0`) is `1.0·√2 ≈
    1.4142` ft. `offsetAt` now offsets the incoming and outgoing segments
    individually (each parallel to its own segment, at distance `h`) and
    intersects those two offset lines (`lineIntersect`) to get the corner —
    verified this reproduces the exact √2 ratio on a 90° corner, leaves a
    straight run untouched (no false miter when there's no turn — parallel
    offset lines fall back to the plain perpendicular), and stays finite
    (no crash/NaN) even on a near-180° reversal. First/last vertex (no
    opposite neighbor) still gets a plain single-segment perpendicular, same
    as before. This feeds every offset consumer — the dashed cross-section
    ribs, the build-27 curving lane lines, and (unchanged) the straight
    `collectOffsetSegments` snap chords all sit on the corrected corners now.
  - **Build 29 — PCC (compound curve) / PRC (reverse curve), and offsets tied
    to the base radius:**
    - A single `circleFitLS` over an ENTIRE BC..EC run assumes it's all one
      constant-radius arc. Real roadway geometry often isn't: a **compound
      curve** changes radius (same turn direction) at a **PCC**, and a
      **reverse curve** flips turn direction at a **PRC** — either way, one
      least-squares circle over both pieces produces a meaningless average
      (verified: a true 300ft-radius arc joined to a true 150ft-radius arc
      fit, as one span, to a nonsense ~237ft circle that matches neither).
    - Put **`PCC`** or **`PRC`** on the point where the curve's radius or
      direction changes — same token style as `BC`/`EC`/`OC`. It does not
      end the run (no new `B`/`E`, still one figure) — `parseDesc` just sets
      a flag (`map[cur].pcc`/`.prc`) that rides the vertex through `figures()`
      into `f.verts[].pcc/.prc`, same plumbing as `bc`/`ec`.
    - `breakIndices`/`splitAtBreaks` cut a BC..EC span into sub-spans at every
      interior `PCC`/`PRC` (the marker point is shared as both the last point
      of one sub-span and the first of the next, so there's no gap). Both
      `strokeFigure` (the base line) and `drawOffsets` (the offset lane
      lines) run `sampleCurve`/the curved-offset logic **per sub-span**
      instead of over the whole run, so each piece gets its own independent
      circle fit — verified this recovers the true 300ft/150ft radii (a
      compound curve) and two true ~200ft arcs of opposite curvature (a
      reverse curve/S-curve) respectively, in both cases still passing
      through every real shot exactly, with no code needed to special-case
      "compound" vs "reverse" — an independent least-squares fit per
      sub-span naturally finds whichever radius and turn direction the real
      points describe.
    - **Offset radius now explicitly tied to the base curve, not
      independently re-fit:** build 27 fit a separate least-squares circle to
      the lane's OWN offset points, which tracked the base curve closely
      but only approximately (~0.2 ft off on a real test case) since it
      didn't know the base radius at all. `curvedOffsetPts` (replacing that
      approach) instead reuses `arcSegmentsForSpan` on the BASE points to get
      each segment's own already-solved `{center,R,sweep}`, then computes
      that lane's target radius as `R ± h` — outward (`+h`) when the base
      segment sweeps CCW, inward (`-h`) when CW (`dirSign = sweep>=0?1:-1`),
      matching which side "right of travel" (the `offsetAt`/CAD offset
      convention) falls on for a circle. `circleThroughChordR` then solves
      the *specific* circle at that exact target radius through the two real
      offset points — verified every segment's solved radius matches
      `R±h` to float precision (e.g. base R=250, h=8.5 → offset segment R is
      exactly 258.5, every segment, every time), while still passing through
      every real offset point exactly, same as before. PCC/PRC splits apply
      here too (`curvedOffsetPts` calls `breakIndices` on the base sub-span
      first) — verified end-to-end through a compound curve's offset run.

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
- **Ramsey (default):** a **3×3 grid** of `/exportImage` requests (plain `<img>`, no CORS),
  each ~near-screen resolution, fired in parallel and drawn as each arrives — so it's
  ~3× sharper than one capped export and streams in progressively (fixes dark/low-res/
  slow). Survey coords are passed as the bbox directly (native county SR). Tiles are
  `[{img,ext,ok}]` in `mapTiles`; `drawMapBackground` paints a white backing then the
  bright tiles (α `mapAlpha`, brightness/contrast lift), overlapping 0.5px to hide seams.
  - **Build 22 fix:** this was `/export` (the MapServer operation name) against an
    **ImageServer**, whose REST op is `exportImage` — every county tile 404'd silently,
    so the map was always blank and immediately fell through to Esri. Fixed to
    `/exportImage`.
  - **Build 23 fix:** each grid cell requested a fixed *square* `size` even though its
    bbox (1/3 of the viewport) is almost never square — `adjustAspectRatio` defaults to
    **true**, so the server silently expanded each cell's bbox to match the square pixel
    size, by a different amount per cell (depends how far that cell's aspect ratio is
    from 1:1), making adjacent tiles drift apart as you zoomed. All 3 map sources
    (`ramsey`/`esri`/`naip`) now send `adjustAspectRatio=false` so the server always
    honors the exact bbox we compute — the one `rect()` in `drawMapBackground` also
    uses to place the tile, so the two now agree.
- **Esri fallback:** if every county tile errors, `mapSource='esri'` fetches one
  World_Imagery image (Web Mercator via `surveyToLL`/`llToMerc` calibrated transform).
- **NAIP fallback (build 22):** if the Esri tile also errors, `mapSource='naip'` tries
  one USGS NAIP image from `imagery.nationalmap.gov/.../USGSNAIPPlus/ImageServer/exportImage`
  (same Web Mercator transform/URL shape as Esri, just a different host+op) before giving
  up and setting `mapErr`. Chain is county → Esri → NAIP → error banner.
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
- **Build 32 — `openZPick` generalized:** it used to hardcode writing the chosen
  Z into the COGO dialog's `#simplCogoZ` field. It now takes `openZPick(snap,
  onDone)` — `onDone(z)` gets the chosen Z (or `null` on cancel) and the CALLER
  decides what to do with it. The COGO call site's callback reproduces the old
  behavior exactly (fills `#simplCogoZ`, re-shows the dialog, hud message).
  This is what let **Insert point on line** (below) share the same chooser
  without touching the COGO flow at all — only that one call site changed to
  pass a callback; `applyZPick`/`closeZPick` themselves are now just plumbing
  (`zpickCtx.onDone(z)` / `onDone(null)`).
- **Insert point on line snap (`pickSegmentForInsert`, build 32):** the
  separate, simpler **⊕ Click line to insert point** tool (`insertPt` /
  `insertPointOnLine` — distinct from the COGO dialog above; it drops a plain
  `NEZ` point at a clicked spot along one figure's own segments, chosen by
  nearest screen distance) previously had no CAD snap at all — a click only
  ever projected onto the figure's own line. It now also checks, for whichever
  of the figure's own segments is nearest the click, whether that segment
  crosses ANY other line (another figure, or a curb offset lane, via
  `collectSegments()` + `lineLineX` — the same primitives `snapPoint` already
  uses) within `TOL_X=14`px of the click; an in-range crossing wins over the
  plain along-the-line landing. On a crossing, `openZPick` prompts for the
  elevation (line A / line B / average / custom) exactly like COGO's
  intersection snap, and only then calls `insertPointOnLine(...,t,z)` — a new
  optional 5th arg that overrides the plain `p1.Z+(p2.Z-p1.Z)*t` interpolation.
  N/E still come from `t` along the figure's own segment (equivalent to the
  crossing point, verified: intersecting two synthetic lines crossing at a
  known world point recovered that exact E/N, and each line's own Z at the
  crossing to float precision). 2D only (guarded by `!is3D`, matching
  `snapPoint`), same as the insert tool itself (its toolbar button doesn't
  render in 3D).
- **Build 33 — `insertSnapOn` checkbox:** the crossing-snap above always won
  over the plain along-the-line landing whenever a crossing was in range,
  with no way to opt out — inserting near a crossing you didn't actually
  want to snap to always triggered the elevation prompt. A **Snap to line
  crossings** checkbox next to the insert-mode button (checked by default)
  gates the whole intersection-detection pass in `pickSegmentForInsert`
  (`if(!is3D&&insertSnapOn){...}`); unticked, a click always lands at the
  plain along-the-line position, same as before build 32. Purely a global
  UI toggle (`insertSnapOn`), not per-figure — persists across figures/tool
  switches, resets only on a fresh page load.

## Zoom window in 3D (`setMode`, `endInteract`, build 30)

- The **Zoom window** tool (⊕ WIN toolbar button / `Z` key, `mode='zoom'`) already
  worked in 2D (drag a box, `S2W` inverts the two corners to world coords, fit
  `view.s`/`view.x`/`view.y` to them). It did **nothing** in 3D — worse, clicking
  it while orbiting silently forced you back to 2D, because `setMode` treated
  "which view" (`is3D`) and "which tool" (`mode`) as the same switch: every tool
  except `'orbit'` set `is3D=false`.
- Fix: `setMode` now only forces `is3D=false` for tools OTHER than `'zoom'` —
  `if(m==='orbit')is3D=true;else if(m!=='zoom')is3D=false;`. Picking Zoom while
  orbiting leaves you in 3D with `mode='zoom'`; every other tool (`sel`/`move`/
  `pan`/`inv`) still forces 2D exactly as before — this is the one deliberately
  new reachable state (`is3D && mode==='zoom'`), not a general "any tool works in
  any view" change.
- `pointerdown`'s `is3D` branch checks `mode==='zoom'` first and starts the same
  `zw` marquee box used in 2D instead of starting an orbit-drag.
- **The actual zoom math is different in 3D**, because there's no inverse of the
  oblique orbit projection (`P3`) back to world coordinates the way `S2W` inverts
  the 2D affine view — so `endInteract` computes the new `orbit.s/ox/oy` directly
  in **screen space**: `f=min(w/dx,h/dy)` (fit the tighter axis), then
  `orbit.ox=-(bx-w/2-orbit.ox)*f` and the same for `oy` (`bx,by` = the drawn
  box's screen-space center). This comes directly from solving `P3`'s own affine
  form (`sx=x1*orbit.s+w/2+orbit.ox`) for the `ox` that puts the box center
  exactly at the viewport center after scaling `orbit.s` by `f` — verified
  numerically (a standalone reimplementation of `P3`): the box center maps to
  exactly `(w/2,h/2)` post-zoom and the box's half-size scaled by `f` exactly
  matches the viewport's half-size on the binding axis. (First draft of this
  formula had a copy-paste bug — an extra `w/2 -` term carried over from the
  2D `view.x` formula, which has a genuinely different shape — that put the
  box center at `(w,h)` instead of `(w/2,h/2)`; caught by that same numeric
  check, so always verify a projection-math change like this against the
  actual forward projection, not just "the code runs without throwing.")
- Cursor and the 3D hint text (`#orbHint`) now key off `mode==='zoom'` before
  `is3D`, so the cursor shows `zoom-in` and the hint reads "drag a box to
  zoom…" instead of the orbit-drag hint while the tool is active in 3D.

## Rod height (prism) — view + correct (`origPrism`, build 31)

- A shot's rod/prism height (`p.prism`) was always parsed (from the FBK's
  standalone `PRISM <value>` line, which applies to every subsequent shot on
  that setup until the next `PRISM` line) and used to compute `Z = station.Z +
  hi + vertical_component - prism`, but it was never shown or editable — if a
  crew logged the wrong rod height for one shot, there was no way to fix it
  in the app.
- The inspector now shows a **Rod HT** field for shot points (next to the
  `From STN … (HI …)` line). Editing it and hitting Apply sets `p.prism` and
  calls `reduce(p)` — the exact same recompute used for an angle/distance
  edit — which leaves `p.ha/p.sd/p.za` (the actual total-station observation)
  untouched and only recomputes `Z`. If N/E/Z or HA/SD/ZA are edited in the
  *same* Apply, the new rod height is applied first, so `setShotFromNEZ`/the
  angle branch both pick it up automatically — no special-case interaction
  needed, verified physically: increasing the rod height by 0.5 ft lowers Z
  by exactly 0.5 ft, nothing else on the shot changes.
- **Export is the tricky part**, because `PRISM` is not a per-shot field — one
  line sets the height for every subsequent shot on the setup, so you can't
  just rewrite it in place without silently changing every OTHER unedited
  shot that relied on the original value. `exportFBK` instead brackets only
  the corrected shot: a `PRISM <new height>` line immediately before it (in
  `nezBefore[p.srcLine]`, the same "insert extra lines before line L" hook
  the NEZ-reordering logic already uses) and a `PRISM <original height>` line
  immediately after (`nezBefore[p.srcLine+1]`) restoring it for whatever
  follows. `p.origPrism` (captured once at parse time, never mutated) is what
  the restore line and the "is this shot edited" check (`p.prism!==
  p.origPrism`) both key off.
- Verified with a full round trip: parsed a synthetic setup (`PRISM 5.000`
  then three shots), edited the middle shot's rod height to `5.500`,
  generated the bracketed export text, then re-parsed THAT text with the
  unmodified original parser — the edited shot's Z came back exactly
  corrected, and both neighboring shots (before and after, same setup) came
  back with their Z completely unchanged, proving the bracket never leaks
  into any other point's data.

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
