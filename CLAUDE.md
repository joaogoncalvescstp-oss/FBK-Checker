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
    | 34 | 🍇 GRAPE | fix BC..EC curve rendering a spurious "double line": `strokeFigure` was nudging every curve-sampled point sideways by a curb code's first `H`/`V` step whenever the curve's **BC** vertex happened to carry a curb code (e.g. `BC R624`) — real coded curb points don't; only a bare/uncoded BC would render clean. Removed the whole `activeSteps` mechanism (it was never applied to straight-line vertices, only curve samples, so it never matched CAD/the actual coded cross-section anyway — `applyKnockdown()`/`drawOffsets` already handle curb cross-sections correctly and don't touch this code path) |
    | 35 | 🍊 ORANGE | fix the SAME "double line" complaint for a curve that isn't actually circular: confirmed against a real Civil3D `LIST` dump of the owner's own curb polyline that our one-design-radius arc-fit can silently accept a terrible fit (this run's shots deviated up to **half the fitted radius**) instead of recognizing the points aren't on any circle and falling back to the spline — `circleFitLS` now rejects a fit whose max residual exceeds 12% of the solved radius |
    | 36 | 🍓 STRAWBERRY | owner confirmed build 35 fixed the base curve, but the green curb offset **lane lines** through that same non-circular span weren't following it — they went straight/faceted instead of curving. `curvedOffsetPts` derives each lane segment from the BASE line's `arcSegmentsForSpan`, which now (correctly, since build 35) returns `null` for a non-circular span, but its `null` fallback was a straight vertex-to-vertex chord, not a curve. It now falls back to running `sampleCurve` directly on the lane's own offset points (same spline the base line falls back to) instead of chording it straight |
    | 37 | 🍒 CHERRY | added a **↻ Refresh** toolbar button — forces `buildLinework()`+`draw()` so the drawing (base line + curb offset lanes) is always rebuilt from current point data on demand, in case a line edit ever leaves the canvas looking stale. Smoke-tested in a real headless browser: loads, enables after a file loads, click redraws and shows a hud confirmation, no console errors |
    | 38 | 🥝 KIWI | new **⊙ CTR** tool: click 3 points (or a single existing CIR-coded line, using its own first 3 vertices) and it drops a new point at the circumcircle center — prompts for the elevation (average of the 3 points, or a custom value) and a code/description, then places the point's `NEZ` record immediately after the 3rd point in file order on export |
    | 39 | 🍑 PEACH | mobile UI pass: the top toolbar now scrolls horizontally instead of silently overflowing the page (confirmed with a real narrow-viewport browser test — buttons past ~390px were completely unclickable before); the tool column (left) is one scrollable flex column instead of a hardcoded-pixel-position zoom +/- pair that had started overlapping the MAP button; the Inspector side panel becomes a slide-in drawer (☰ toggle button, auto-opens on selecting a point/figure, ✕ close button, backdrop tap to close) below 840px instead of just vanishing with `display:none`; modals cap at `92vw`. Caught and fixed a real regression along the way: an invisible always-present drawer backdrop div was an unintended CSS Grid item in the 2-column `.main` layout, silently shoving the desktop side panel into its own row below the canvas — fixed by giving it (and the mobile-only close button) an explicit `display:none` base rule |
    | 40 | 🍐 PEAR | fix **CIR** requiring a **B** to draw anything: a code with no `begin` anywhere was dropped entirely (`buildLinework`'s "no B anywhere → not a line" filter), and even when the code survived (a B existed elsewhere for it), `figures()` only ever started a run at an explicit B — so a lone 3-shot circle marker like `"MISCL CIR"`/`"MISCL"`/`"MISCL"` with no B, common for small incidental features (a manhole rim, a tree), was silently dropped or invisible. A `CIR`/`CIRCLE` token now implicitly begins its own 3-point run when no run is currently open, auto-closing once it has exactly 3 vertices — matching how a circle figure is actually consumed (`circle3(vs[0],vs[1],vs[2])` only ever uses the first 3 anyway). Verified against the real job file: recovers exactly 3 previously-invisible circles (`TRL` 6377-6379, `MISCL` 5605-5607, `MISCL` 5608-5610) with zero change to any of the other 156 existing figures |
    | 41 | 🍉 WATERMELON | line code review (`inspectFig`'s vertex row list) gets a **⌖ zoom-to-point** button per row — click it and the canvas pans/zooms in on that exact vertex with the same gold flash-ring animation as **⌖ Go to point**, without leaving the line editor (unlike Go to point, it doesn't switch to the single-point inspector). Extracted the pan/zoom/flash logic Go to point already had into a shared `zoomToPoint(i)` so both now share one implementation |
    | 42 | 🥥 COCONUT | fix **RT ... RECT**: `"CODE RT 6 RECT"` — a right-turn jog of 6, closed into a rectangle — parsed the jog fine but silently dropped the closing `RECT` (it has no number of its own here; the vendor spec says a bare `RECT` "completes" the preceding `RT` at its own distance), so it rendered as one dangling perpendicular tick instead of a closed box. `parseDesc` now tracks that a bare `RECT` was seen and, if it never got an explicit value of its own, defaults it to the same distance as `RT` — confirmed on the real job file's only `RT` occurrence (pt 5301, `"MISCL RT 6 RECT"`): before the fix `rect` stayed `null`; after, it resolves to `6` and renders as a proper closed rectangle between points 5300 and 5301 |
    | 43 | 🍋 LEMON | fix **RT** direction on a CHAIN of consecutive right-turn jogs: real usage repeats `"CODE RT <d>"` on many consecutive points (e.g. a wall shot in a straight run needing a constant correction) — each jog's 90° turn was computed from the direction between the two REAL vertices (`vs[k-1]`→`vs[k]`), skipping over the PRECEDING point's own jog detour entirely. Verified against a real Civil3D `LIST` dump of the actual figure that the correct turn direction is the segment *actually just drawn* (from the prior jog point back to this point, not vertex-to-vertex) — the old code was off by ~70° in azimuth on this real run, landing new jog points up to **11.5 ft** from their true CAD position; the fixed version matches the `LIST` dump to within 0.008 ft. `strokeFigure` now tracks the true last-drawn pen position (`lastE/lastN/lastZ`) through the whole loop — updated after every `put()`, including curve spans and OC tangent arcs — and RT/X/RECT compute their incoming direction from that, not from the previous vertex in the array |
    | 44 | 🍎 APPLE | fix **RECT** per the vendor Civil3D doc (`RT`/`X`/`RECT` reference page, pasted by the owner): the real syntax lets an arbitrary CHAIN of values follow one `RT` — e.g. `"BLD1 RT X10.1 5 -12.2 -5 -12.2"` extends the segment then jogs perpendicular 4 more times, each off the PREVIOUS leg's own direction — but `parseDesc` only ever captured the FIRST value after `RT`/`X` and silently dropped every value after it (confirmed: parsing that exact doc example returned only `rt=5`, discarding `-12.2/-5/-12.2` entirely). Replaced the single `rt`/`x` scalars with a `jogs` array so every value in the chain survives, in order, tagged `x` (straight extend) or `rt` (90° turn, sign = right/left) — `strokeFigure` walks the array leg by leg, each turn rotating 90° off whatever direction the PREVIOUS leg ended facing (same alternating-turn math build 43 already proved correct, just applied within one point's chain instead of across several points). Also fixed **`RECT` closing a chain**: it now computes the true "perpendicular/perpendicular line intersection back to the starting segment" the doc describes — projecting the chain's own endpoint onto the base segment's perpendicular axis through the prior point (`lineIntersect`-equivalent closed form) — instead of only working when `RECT` and `RT` happened to share the same single value. Verified this collapses to the EXACT byte-identical geometry as the old (build 42/43-verified) formula for every real case on file — the single-turn `"RT 6 RECT"` (pt 5300→5301) and the plain multi-point `"RT 9.52"` chain (Hamline BLD1) both reproduced their previously-ground-truth-verified coordinates exactly through the real `index.html` parse→figures→strokeFigure pipeline, not just a standalone reimplementation — before adding the new chain support. No real job file on hand actually uses a multi-value `RT` chain yet, so this is verified against the vendor doc's own worked example (all 5 legs now parsed vs. 1 before) and a synthetic multi-leg chain rendered end-to-end in a real headless browser with no console errors. |
    | 45 | 🍌 BANANA | fix **RECT closing a plain 3-shot L with no `RT` at all**: the owner's real job has `"RCED B"` / `"RCED"` / `"RCED E RECT"` — three real corner shots (9878→9879→9880, ~89° angle between the two segments, near-equal side lengths) meant to close into a box around a nearby manhole/circle feature — with **no `RT` anywhere in the figure**. Build 44's fix only handled `RECT` closing an `RT`-built chain; here `rectSeen` was true but `rect` stayed `null` (no `rt` leg to default from) and `jogs` was empty, so the widened trigger condition (`v.jogs.length||v.rect!=null`) was FALSE and the whole `RECT` was silently a no-op — confirmed exactly matching the owner's screenshot: the app drew only the open `9878→9879→9880` line, no closing box, while their CAD showed a clean 4-sided rectangle around the circle. Added a third, simpler `RECT` case: a bare `RECT` with no explicit value AND no `rt`/`x` legs at all (`closeL`) closes the last TWO real segments (prior-prior → prior → this) into a box using their own already-shot geometry — no distance needed, since 3 corners of a rectangle fully determine the 4th (`corner4 = p1 + (p3 − p2)`, the standard parallelogram-closing vector sum). Verified against the real point data: the 4th corner computed to close 9878/9879/9880 reproduces a proper rectangle (each side vector matches its opposite side's negation to the mm), and a real headless-browser screenshot of this exact figure now shows the identical closed box (with the circle sitting inside it) as the owner's Civil3D screenshot. Re-verified builds 42-44's real cases (Dale 5300/5301 `"RT 6 RECT"`, Hamline `BLD1` `RT`-chain) are completely unaffected — this is a new, mutually-exclusive branch (`jogs.length` → chain-close; `rect!=null` → old standalone jog+close; `closeL` → new no-distance 3-point close), not a change to either existing path. |
    | 46 | 🍇 GRAPE | fix **build 45's own closing side drawing a spurious diagonal**: the owner confirmed the box now closes, but flagged an extra diagonal line cutting straight across it (from `p1` to the RECT vertex). Cause: after drawing the closing corner and `p1`, the code retraced with one more `put(v.E,v.N,v.Z)` to leave the pen "back on the real point" — the same pattern the other two `RECT` branches use, but there it's harmless because THEY retrace `prior→v`, a segment that was already drawn as the plain base segment; here `p1` is two vertices back (not `prior`), so `p1→v` is a straight chord that was never part of the original L-shaped path (`p1→prior→v`) — a brand-new, wrong diagonal. Fix: drop that last `put()` — the path now simply stops at `p1` after closing (`9878→9879→9880→corner→9878`), still updating `lastE/lastN/lastZ` to `v` for bookkeeping so anything after would still compute its own direction off the real point. Verified against the real 9878-9880 data (put-sequence now ends at the closing corner, no trailing chord) and in a real headless browser — the rendered box now matches the owner's CAD screenshot exactly, no diagonal. |
    | 47 | 🍊 ORANGE | fix **CIR clusters swallowed by an unclosed host run** (`figures()`): the owner's Hamline file showed a real manhole circle (RCED points 9572/9573/9574, near "UTS") not drawing at all — just a plain line through them. Cause was the SAME "run never closes" class of bug build 40 already flagged and deliberately left alone (the Dale `MISCL@369` case): `RCED` has a real, legitimate long curb-edge run (`9488 B`...`9583 E`) that happens to pass near SIX separate manhole-rim `CIR` clusters coded with the same `RCED` figure code — since that host run never hit an `E`/`CLS` before reaching each `CIR` point, `!run&&f.cir` was false (a run WAS open) so the whole implicit-3-point-circle path from build 40 never fired, and the `CIR` points just got appended as plain vertices into the host run instead — which then ALSO got `.circle=true` (since `r.circle=verts.some(v=>v.cir)`) and rendered a bogus circle through the run's first 3 vertices only, nowhere near the real manholes. `figures()` now tracks a SEPARATE `cirRun` alongside the host `run`: any `CIR` point (that isn't also an explicit `B`) pulls itself and its next 2 vertices OUT of the host run entirely into their own independent 3-point circle, closes that as its own figure, then the host run RESUMES exactly where it left off — so a `CIR` cluster is no longer just "close and restart" (which would still orphan whatever came after the last cluster with no new `B`), it's "skip these 3 points, keep going." Verified against both real jobs: Hamline's `RCED` splits from 1 wrong merged figure into 7 correct standalone circles (9095-97, 9103-05, 9180-82, 9275-78, 9417-19, 9542-44, 9572-74) PLUS the host curb-edge line intact end-to-end (`9488→9524→9527→9528→9582→9583`, skipping only the circle vertices) — confirmed visually in a real browser, the 9572-74 circle the owner reported now renders. Dale's long-documented `MISCL@369` anomaly (flagged since build 40, never fixed) is ALSO fixed as a natural consequence of the same root cause: it now splits into `[5300,5301]` (a plain 2-vertex line — which ALSO makes its `"RT 6 RECT"` box render correctly for the first time, since a clean 2-vertex figure is exactly what the build-42/45 RECT logic expects) plus two proper standalone circles `[5302,5303,5304]` and `[5580,5581,5582]`. Total figure count: Dale 159→161 (net +2, matching the 1-figure-becomes-3 split), every other one of the 150 non-`MISCL` figures byte-identical; Hamline unaffected elsewhere. The one pre-existing combo this deliberately leaves untouched: a vertex with `B` AND `CIR` together (e.g. Dale's `"MISCL B CIR RWLK6 BC"`) still opens a normal explicit-begin run exactly as before (begin takes priority over the new cir-pull-out branch), matching the only real example of that combo on file. |
    | 48 | 🍓 STRAWBERRY | fix **curb offset lane lines going straight/faceted through an `OC` tangent-arc corner**: the owner's screenshot showed the base line (magenta, RBCB) curving smoothly through a rounded corner at point 9674 (`"RBCB OC"`, between 9673 and 9675), while the green H/V curb offset lane lines through that exact same corner went sharp/faceted instead of following the curve — the same class of "offset lane doesn't track the base line's curve" complaint build 27/36 already fixed for `BC..EC` spans, but `drawOffsets` never had ANY handling for `OC` at all; every `OC` corner fell straight through to the plain `offsetAt` mitered-corner math (build 28), which is correct for a real sharp corner but wrong for a smooth tangent-arc fillet. Fix: extracted `fitTangentArc`'s internal solve into a shared `tangentArcGeom(B,d1,C,d2,OC)` (returns the fitted arc's `center`/tangent points, used as-is by `fitTangentArc` for the base line — byte-identical output, confirmed, since it's the exact same computation just factored out) and added `offsetTangentArc(A,B,C,D,OC,Boff,Coff)`: since perpendicular-shifting a line tangent to a circle by a constant distance keeps it tangent to a CONCENTRIC circle (radius R±that distance) — proven algebraically and confirmed numerically (both tangent points of the offset arc land at the exact same radius from the base arc's own center, to 4 decimal places, equal to base R + the lane's h) — the offset lane's arc reuses the BASE arc's own solved center (not an independent re-fit) and just finds where the already-offset tangent lines (from the existing `offsetAt` points on either side) touch a circle centered there. `drawOffsets` now tracks an `ocAt` flag alongside `bcAt`/`ecAt` and, on hitting an `OC` vertex mid-lane, skips straight to the smooth arc (same skip-the-OC-vertex indexing as `strokeFigure`'s own base-line OC handling) instead of the plain miter. Verified on both real `OC` corners in the Hamline job (points 9254 and 9674) — the green lane lines now curve smoothly and concentrically with the base line at both, confirmed in real browser screenshots with no console errors; purely additive change (only fires when `ocAt[k]` is true with valid bounds), so every non-`OC` curb offset in the file is unaffected. |
    | 49 | 🍒 CHERRY | fix **`BC..EC` forcing ONE shared design radius across a real (unmarked) compound curve**: the owner's screenshot showed a genuinely tangled/crossing mess where an `RBCB1` curb curve and an independently-coded `RWLK` walkway curve run right alongside each other — tracing it against a full Civil3D `LIST` dump (whose start point matched a real shot, point 9754, to the hundredth of a foot) showed `RBCB1`'s `BC..EC` span (9791→9809, 7 real shots) covers TWO genuinely different curvature regimes: a tight ~30 ft curve for the first 4 shots, then a much flatter run (CAD radii up to 514 ft) for the last 3 — while the separately-coded `RWLK` figure happens to end its OWN `BC..EC` exactly at the regime change (point 9800) and gets a correspondingly tighter, more accurate ~31 ft fit for the same physical corner. Forcing `RBCB1`'s single least-squares radius (51.4 ft, a compromise between the two regimes) across the WHOLE span put its curve visibly out of step with `RWLK`'s better-fit curve over the same ground — that's the crossing/tangled look. The project's existing tool for exactly this (`PCC`/`PRC`, build 29) requires an explicit marker in the field data, but the owner confirmed **`PCC`/`PRC` are curve-engineering terms, not codes crews ever actually type** — so no marker will ever exist to split on, and the fix has to be automatic. Tried an automatic "does this span's curvature look consistent?" detector two different ways (local 3-point circle radii; first-half-vs-second-half least-squares radii) and calibrated both against every `BC..EC` span in both real job files — neither can safely tell this genuinely-bad span apart from several already-verified-good ones without also flagging them, so no accept/reject threshold change was made (matches this project's standing rule against guessing at breaks the data doesn't mark, per build 40/47's own reasoning). Instead of deciding UP FRONT whether a whole span needs splitting, `arcSegmentsForSpan` now gives every individual segment its own **locally-fitted radius**: each consecutive shot pair gets a least-squares circle fit from a small window centered on it (that pair plus one shot on each side, clamped at the span's own ends) instead of always reusing the one whole-span design radius — a real compound curve's radius drifts along the run as the window slides, with no marker needed to say where, while a genuinely constant-radius run keeps agreeing with itself window to window (overlapping local fits all land close to the same radius, so nothing meaningfully changes there). The whole-span fit is still computed first and still gates accept-vs-fall-back-to-spline exactly as before (build 35's 12% threshold, untouched) and still supplies the side-of-chord tie-break reference for every segment — this only changes what radius a segment reaches for once the span has already passed that gate. Verified against the real Civil3D `LIST` ground truth for the reported span: worst deviation from CAD's own un-shot intermediate vertices dropped from 0.60 ft (old, one shared 51.4 ft radius) to 0.21 ft (new, per-segment radii of 30.9→29.6→31.3→45.1→80.8→84.3 ft — visibly tracking the real tight-to-flat progression), every other checked point improved too. Then re-rendered every `BC..EC` figure in BOTH real job files (58 total) old vs. new and Hausdorff-compared the sample clouds: the reported span changed by exactly the 0.60 ft the fix targets, 19 other spans shifted by small amounts (all ≤0.30 ft — spot-checked Dale's `RBCB2@1621`, a 4-point span whose overlapping 3-point windows shift smoothly 14.1→11.8→8.6 ft, a plausible real local drift, not a degenerate result) consistent with ordinary shot noise rather than a regression, and the remaining ~38 spans were unaffected; total figure counts (99 Hamline, 161 Dale) and the curb offset lane rendering (`curvedOffsetPts`, which reads each segment's already-solved `{center,R}` and so inherits the new locally-varying radii automatically) were unchanged in count and still render without error on both files. Confirmed visually in a real browser: `RBCB1` and `RWLK`'s independently-coded curves over the same physical corner now track each other closely instead of visibly splaying apart and crossing. |
    | 50 | 🥝 KIWI | fix **build 49's own local-window radius fit producing a tight self-crossing loop** on a DIFFERENT curve: the owner's very next screenshot pair ("FIX THIS CURVED MESS") showed a genuinely wrong tangled loop in a different `RBCB` curve (points 9649-9658), right after build 49 shipped. Root cause: build 49's local-window `circleFitLS` (a least-squares circle fit over a small ~4-point window sliding along the span) is numerically ill-conditioned when the real shots in that window sit unusually close together — this span has 3 real shots (9655/9656/9657/9658) crammed within ~1-2 ft of each other. A Kåsa fit through near-coincident points can return a wildly tiny "radius" that still passes its own internal residual check (the points really are close to *that* circle) while being nowhere near the run's true curvature — confirmed directly: this span's local windows came back with radii of 3.16, 1.43, 1.12 ft against a whole-span design radius of 59.96 ft, and forcing per-segment arcs at those bogus radii is exactly what drew the tight loop. A first fix attempt added a per-segment sanity guard (reject one segment's local fit if its ratio to the whole-span radius fell outside a band calibrated against every `BC..EC` span in both real job files — `[0.28,3.7]×` covers every currently-good span, so `[0.15,6]×` was picked as a safe margin) and fall that ONE segment back to the whole-span radius. But the owner then supplied a much richer 30-segment Civil3D `LIST` dump (matching this exact figure's real start point, N158865.06'/E558343.56', to the hundredth of a foot) that proved this particular span isn't a compound-curve-with-one-bad-segment at all — it's a genuinely non-circular, spline-like real path: the `LIST`'s own true sub-segment radii swing from 86.52 down to 0.76 up to 4388.91 ft within a handful of real shots, the same "short independent bulge per segment" pattern build 35 first identified. Direct nearest-point comparison against the `LIST`'s un-shot intermediate vertices confirmed the plain cubic-spline fallback (already used elsewhere for non-circular spans) tracks this true path far better (0.60 ft max deviation) than forcing even a locally-patched circular arc through it (1.41 ft max deviation) — patching just the one bad segment still isn't a good match once the underlying data isn't circular at all. Final fix: `arcSegmentsForSpan` now computes every segment's local-window ratio FIRST, and if ANY of them falls outside the `[0.15,6]×` band, the WHOLE span returns `null` (not just that one segment) — this is the same signal `sampleCurve` already uses to fall back to the spline, so the entire run drops to the spline fallback instead of forcing part of it into a circle that doesn't fit. The whole-span `circleFitLS` accept/reject gate (build 35's 12%-of-radius threshold) is completely untouched — this only adds a second, independent way a span can be rejected to the spline. Verified with a full before/after scan of every `BC..EC` span in both real job files (94 total): exactly one span changed (the reported 9649-9658 loop, now correctly `null`/spline) and every other span — including the two closest-to-the-band cases on file, Hamline `RBCB@427` (min ratio 0.275) and Dale `RBCB@560` (max ratio 3.711) — passed through completely unaffected, byte-identical radii to build 49. Confirmed the rendered base-line path for the fixed span is now strictly monotonic (E increases continuously through the whole 9649-9658 window with no reversal) — the loop is gone — and confirmed `drawOffsets`/`curvedOffsetPts` (the green curb offset lane lines) still run end-to-end with no error now that this span's `arcSegmentsForSpan` returns `null` (falls back to the existing build-27/36 spline-on-offset-points path, same as any other non-circular span). |
    | 51 | 🍑 PEACH | new **📷 Street View** button — jump to a real-world, ground-level view of any point along the linework, to eyeball it against reality. Added to the single-point inspector (faces along whichever figure the point is on, if any) and to every vertex row in the figure/line editor (faces along that specific vertex's own line direction) — see the new dedicated section below. |
    | 52 | 🍍 PINEAPPLE | owner asked for more than a single Street View jump — wants to **walk the whole line** in Street View, one point at a time. Added **◀ / 📷 Walk line in Street View / ▶** controls to the figure/line editor: Walk starts at vertex 1, Next/Prev step through the line's own vertex order (clamped at both ends, buttons disable there), each step re-navigating the SAME browser tab (not spawning a new one per click) to that vertex's location, facing along the line. Required dropping `noopener` from `window.open` — it forces a brand-new tab on every call regardless of a matching window name, which defeated the whole "one tab, walk through it" idea; safe here since the URL is always one we build ourselves, never user-supplied. Verified in a real headless browser: exactly 1 browser tab/popup opened across 5 Walk/Next/Prev clicks (was 5 separate tabs before dropping `noopener`), the 4 navigated URLs matched the correct vertex sequence exactly (including a Prev landing back on the exact same URL as the earlier Next to that same vertex), and Prev/Next correctly disable at both ends of the line across the first 30 figures of both real job files (60 total) with zero console errors. |
    | 53 | 🥭 MANGO | owner supplied a real Google Maps JavaScript API key — Street View is now a **live, embedded, interactive panorama right in the app** (a modal with a `google.maps.StreetViewPanorama`), not a tab-opening deep link. Every point of the line is overlaid as a numbered marker directly on the panorama (Google's documented "overlays within Street View" — a `Marker`'s `.map` can be a `StreetViewPanorama` instead of a plain `Map`), and Prev/Next inside the SAME modal step the live panorama through the line's own vertex order, updating both position and heading. `streetViewURL`/the old tab-opening `openStreetView` are gone — this is a strictly better replacement, not an alternate mode, since it needs the same coordinate transform either way and a live in-app view beats a new tab every time. See the rewritten Street View section below for the full writeup, including a real bug this exposed (and fixed): clicking Prev/Next before the Maps script finishes loading used to throw (`svPano` was still `null`) — `svGoto` now no-ops until the panorama is ready, and the modal's nav buttons stay disabled with a "Loading Street View…" placeholder until then. **Caveat the owner should know:** this sandbox's own network policy blocks outbound connections to Google's domains entirely (confirmed via repeated `403 policy denial`/`tunnel closed` failures against `maps.googleapis.com`, `www.google.com`, `accounts.google.com`), so the live panorama itself — markers rendering correctly, position/heading actually updating on Next/Prev — could NOT be verified end-to-end from here. Everything reachable from this sandbox WAS verified: the script parses, the modal opens/closes cleanly, Prev/Next/Close never throw (including the premature-click case above), and a full sweep of the first 30 figures in BOTH real job files (60 figures, 241+215 Walk/vertex-row Street View button clicks) produced zero console errors. The owner should confirm the actual panorama+marker rendering once opened in a normal browser with real internet access — and if testing by double-clicking `index.html` locally (a `file://` URL), a referrer-restricted API key will likely refuse to load there (no `file://` origin sends a matching HTTP referrer), so local testing may need the key's restriction loosened temporarily or the page served from an actual domain that matches the restriction. |
    | 54 | 🍐 PEAR | owner tested build 53 in a real browser (the first live confirmation this sandbox's own Google-domain block couldn't provide) and reported two things: markers show up but don't line up well with the real curb, and the panorama's photo colors are inverted (a negative). The color issue turned out to be isolated to the Street View panel itself — nothing else in the app looked wrong — which points at Chrome's own "Force Dark Mode for Web Content" (or a Dark-Reader-style extension) heuristically inverting the panorama's WebGL/canvas imagery because it can't recognize it as a photo the way it recognizes normal `<img>` content, while leaving the rest of the page's ordinary HTML/CSS alone (exactly the asymmetry reported). Fixed by adding `color-scheme:light;forced-color-adjust:none` to `#svPanoDiv`, which explicitly tells the browser this element is intentionally light-themed content it shouldn't auto-invert — confirmed via computed style in a real headless browser that both properties land as set, with no console errors. **The marker-alignment issue is still open** — waiting on a screenshot from the owner before touching any coordinate/marker code, since "markers a little off" could mean either a real bug in our math or plain Street View camera-vs-curb parallax (the panorama's photo is taken from wherever Google's car actually drove, which is rarely the exact curb line a marker sits on — a well-known, unavoidable Street View limitation, not something fixable by us) and guessing which one it is without seeing it risks fixing a non-bug or missing a real one. |
    | 55 | 🍉 WATERMELON | new **point marker symbols** on the 2D canvas, keyed off each point's own description code — a small outline shape drawn AROUND the existing colored dot (dot stays visible in the center) so a feature's type is readable at a glance without opening the inspector: a **☐ square** for any point carrying a real curb code (same `CURB_BOC`/`CURB_FL` token scan `applyKnockdown` already uses), a **△ triangle** for a figure code starting with the letter `C` (e.g. `CP`, `CHK`, `CIP`, `CNL` — catch basin/checkpoint-family codes), and a **🌲 tree emoji** for the two tree codes `TCTR`/`TDTR`. New `drawPtSymbol(p,x,y,r)` checks tree first (most specific — an exact code match), then curb code, then starts-with-C, so a point only ever gets one symbol; wired into `drawPt` behind the SAME zoom/hot visibility gate the point-ID label already uses (`p.kind==='ctrl'\|\|view.s>3\|\|hot`), so symbols declutter at a zoomed-out overview exactly like labels already do. Added matching entries to the on-canvas legend. Verified in a real headless browser against both real job files: zoomed screenshots of a real `TCTR` point, a real `CP` (control) point, and a real `RBCB EC L824` curb point each show the correct symbol with no visual overlap hiding the dot; a full sweep over every non-deleted point in both files (966 Hamline, 1723 Dale) classified each into exactly one bucket (tree/square/triangle/none) with sane counts (Hamline: 33 tree, 5 square, 59 triangle; Dale: 38 tree, 46 square, 53 triangle) and a full canvas redraw at `view.s=1` produced zero console errors on either file. |
    | 56 | 🥥 COCONUT | fix **CAD object snap marker mismatch**: the owner asked for circle=intersection, box=endpoint, triangle=midpoint — endpoint and midpoint already matched (`drawSnapMarker` already drew a box for `'endpoint'` and a triangle for `'midpoint'`), but apparent-**intersection** was drawing an X/cross instead of the requested circle. Changed just that one branch to `ctx.arc(x,y,r,0,7)` (filled+stroked, matching the visual weight of the other two shapes) and updated the on-screen osnap legend hint (`osnap: ▢ endpoint · ○ intersection · △ midpoint · ⋈ nearest`) to match. `nearest` (the bowtie/diamond, not mentioned by the owner) is unchanged. Verified in a real headless browser: a synthetic render of all 4 marker types side-by-side shows the correct box/circle/triangle/bowtie shapes; then swept a full grid of points across the canvas on both real job files calling the real `snapPoint()`/`drawSnapMarker()` pipeline (not synthetic types) — 632 real intersection hits on Hamline, 774 on Dale, plus real endpoint hits on both — zero draw errors. |
    | 57 | 🍎 APPLE | new **OSNAP toolbox** (`#snapBox`, bottom-right of the canvas): a checkbox per snap type (▢ endpoint / ○ intersection / △ midpoint / ⋈ nearest) that shows up whenever a snap-driven pick is live — COGO canvas-pick, or **Insert point on line**, which is the second half of the owner's request ("make this avibal also on add piont aloung a line"). Unticking a type removes it from the cascade entirely (both `snapPoint()` for COGO and a new matching cascade in `pickSegmentForInsert()` now gate each of their 4 stages behind a shared `snapEnabled` object, in the same endpoint>intersection>midpoint>nearest priority order), and whichever type is actually engaged under the cursor right now lights up green in the toolbox (`syncSnapBox()`, called every `draw()`) — the "check the active snap" half of the request. Insert-on-line previously had only one crossing-snap checkbox (`insertSnapChk`/`insertSnapOn`, build 32/33) buried in the figure editor panel; that's replaced by the shared toolbox, and `pickSegmentForInsert` gained real endpoint-snap (lands exactly on one of the line's own vertices) and midpoint-snap (lands exactly on a segment's midpoint) it never had before, scoped to the clicked figure's own segments since an inserted point has to stay on that line. Insert-on-line also gets a live hover preview now (it never had one pre-build-57 — only computed a landing on click) via the same `drawSnapMarker`/hud pattern COGO already used. **A real bug found and fixed along the way:** the toolbox is a normal DOM element floating over the canvas, so with no `pointer-events` handling it silently ate mouse clicks/moves anywhere its own bounding box overlapped the canvas underneath — confirmed directly (a Dale job figure's segment midpoint landed literally under the toolbox's `midpoint` checkbox row, and every mouse event there stopped reaching `#cv` entirely, `pickSegmentForInsert` never even getting called). Fixed with `.snapbox{pointer-events:none}` plus `.snapbox label{pointer-events:auto}` — empty box background/padding passes clicks straight through to the canvas, only the actual checkbox rows stay clickable, the same tradeoff every other floating overlay in the app (`.legend`, `.tools`) already makes just by existing. Verified end-to-end through the REAL UI (button clicks, not poked state) on both real job files: opening Add Point (COGO) → Pick on canvas shows the toolbox and correctly highlights `endpoint` next to a real point; opening a figure → ⊕ Click line to insert point shows the toolbox and, at real segment locations picked to avoid the toolbox's own footprint, correctly resolves `intersection` → (intersection off) `nearest` → (nearest off too, nothing left enabled) `null` with no crash, matching the same priority cascade as COGO; the toolbox hides again on Esc/cancel in both flows. A 25-figure × 2-file insert-on-line sweep plus a 40-point × 2-file COGO-pick sweep produced zero console errors (only the pre-existing, unrelated `ERR_CONNECTION_RESET` from blocked map-tile fetches, already documented under MAP background). |
    | 58 | 🍌 BANANA | added an **↗ New tab** button to the Street View modal header — opens the CURRENT point (whichever one `svCtx.idx` is on right now, kept in sync by Prev/Next) in a real Google Maps browser tab via the existing `streetViewURL`/`headingAt` deep-link math (the same URL scheme builds 51/52 used before the embedded panorama replaced tab-opening, still kept around as the build-53 no-panorama fallback). Owner asked after learning the embedded panorama can get its colors inverted by a browser dark-mode feature or extension (see build 54, and the Dark Reader regression the owner found and linked, `darkreader/darkreader#14919` — a bug in THAT extension, unrelated to and not fixable by anything in our code) — a new-tab escape hatch sidesteps whichever one is misbehaving, since the real Google Maps site handles its own theming. Works even before/if the embedded panorama never loads at all (`svCtx` is set synchronously in `openSvModal`, before the async `ensureGMaps` polling even starts) — verified directly, since this sandbox's own Google-domain network block means the embedded panorama can't be exercised here either. `window.open(url,'_blank','noopener')` — `noopener` here is deliberate and different from build 52's walk-the-line tab (which dropped it to reuse one tab): each new-tab click here is a one-off "look at this externally" action, not a walk sequence, so a fresh tab per click is correct, not a bug. Verified via a real headless-browser test on both real job files: opened a mid-line vertex and a plain control point (not just a figure's first vertex) through the actual UI (button clicks, not poked state), intercepted `window.open`, and confirmed the URL/target/noopener args match `streetViewURL`/`headingAt` computed independently for that exact point — zero console errors. |
    | 59 | 🍇 GRAPE | owner sent a real Google Maps JS sample URL (`developers.google.com/maps/documentation/javascript/examples/streetview-overlays`) to double-check our marker-overlay approach against — I couldn't fetch that page (blocked, same as `maps.googleapis.com`), but the exact same sample lives in the public `googlemaps/js-samples` repo (`samples/streetview-overlays/index.ts`), fetchable and NOT Google-domain-blocked; I read the real, current source there. It does NOT do what build 53's writeup claimed ("a Marker's `.map` can be a `StreetViewPanorama`") — its actual pattern is markers on a regular `Map` plus a **toggleable** panorama obtained via `map.getStreetView()`, shown/hidden with `.setVisible()`. Literally copying that would have dropped the numbered vertex markers from the panorama entirely (a `Map`'s own markers don't carry into its panorama once the panorama takes over the div) — the opposite of what this feature is for. Fix, a synthesis rather than a straight copy: `openSvModal` now obtains the panorama the SAME verified way this sample does — `new google.maps.Map($('svPanoDiv'),{center,zoom,streetViewControl:false})` then `.getStreetView()` then `.setOptions({...})` then `.setVisible(true)` — instead of constructing `new google.maps.StreetViewPanorama(...)` directly (a technique this sample never uses at all) — while STILL placing every vertex's marker directly on the returned panorama object (`new google.maps.Marker({position,map:svPano,...})`, unchanged from build 53). The marker-on-panorama piece remains a separately-documented capability of the classic `Marker` class (its `map` property type is `Map|StreetViewPanorama|null`) that this particular sample just doesn't happen to demonstrate — not something this fix proves either way, but no longer resting on a citation to a sample that turned out to show something else. `svPano` is still cached/reused across modal opens exactly as before (`if(!svPano){...}` guards the Map/getStreetView construction). Verified structurally with a mocked `google.maps` (real `Map`/`getStreetView`/`Marker`/`Panorama` still unreachable from this sandbox): the real call sequence is `Map ctor → getStreetView → pano.setOptions → pano.setVisible(true) → 8× Marker({map:pano}) → pano.setPosition/setPov`, with the fake `StreetViewPanorama` constructor (rigged to throw if called) never invoked; Prev/Next still only calls `setPosition`/`setPov` on the cached pano; the build-58 New-tab button still opens the correct URL unaffected; reopening the modal for a different figure correctly skips reconstructing the Map (`if(!svPano)`) and reuses the cached panorama — all on both real job files, zero console errors. |
    | 60 | 🍊 ORANGE | new **🧭 UGW→CPN** toolbar button (deliberately separate from ⚙ Knockdown — owner asked explicitly to keep guy-wire rotation out of the curb-code tool). For every **UGW** (guy wire anchor) point, finds the nearest **UPP** (utility pole) point by 2D distance — same nearest-by-distance pattern `applyKnockdown` already uses for REF — computes the bearing of the vector UGW→UPP with **0° at west** (same clockwise rotation sense as `headingAt`'s standard 0°=north survey azimuth, just re-zeroed: `(standardAzimuth+90)%360`), and appends `"<angle> CPN<pole id>"` to the UGW point's description — e.g. `"UGW"` → `"UGW 179.36 CPN11258"`, matching the owner's worked example. Re-running updates the pair/angle in place (strips a previous run's trailing `<angle> CPN<id>` before re-appending) instead of stacking duplicate tokens. See the dedicated section below for the full writeup, including an open verification gap: the owner's own worked example gives only bare `F1 VA` shot lines with no `STN`/`BS` setup context, so there's no way to independently reduce those two points to real N/E and confirm the exact `179.36`/`179.31` output from here — checked whether points 11250/11258 exist in either real job file on hand (they don't, so no ground truth available there either) and verified the mechanics instead: on BOTH real job files (which turned out to already contain real UGW/UPP guy-wire data), the nearest-UPP search reliably pairs each UGW with the UPP shot immediately adjacent to it in point-number order (9305↔9304, 5374↔5373, etc.) — exactly the pairing a crew shooting a guy wire right after its pole would produce — and the tool is idempotent (re-running twice yields byte-identical output) with zero console errors on both files. The owner should confirm point 11250 actually reads `179.36` once run on their real file; if it doesn't, tell me the actual output and the correct rotation offset can be solved for immediately from one known-good pair. |
    | 61 | 🍓 STRAWBERRY | fix **UGW→CPN's angle convention** (build 60's own worked example, finally checked against real ground truth): the owner uploaded the actual job file (`TOPO PASCAL`) their original example came from, and it turned out to contain the exact points (11250/11251/11258) verbatim. Run through the app's real `STN 31`/`BS 30` setup chain (not a guess), build 60's clockwise `0=W,90=N,180=E,270=S` formula (which matched the owner's own LATER verbal confirmation, "0 WEST 90 NORTH 180 EST SOUTH 270") produced `179.36`'s point 11250 as **180.39°** and point 11251 as **180.48°** — off by a full ~1°/1.2° from the owner's stated `179.36`/`179.31`. The MIRRORED rotation direction — `0=W,90=S,180=E,270=N`, i.e. counterclockwise, the OPPOSITE of what the owner verbally described — instead produces `179.61°`/`179.52°`, off by only `0.25°`/`0.21°`: a 5x smaller, mutually-consistent residual small enough to be ordinary rounding in a hand-typed reference value. Since the owner's own verbal description and their own real data directly conflicted, and the real data is both authoritative and far more precise than a quick all-caps summary, the mirrored convention won — `bearingFromWest` now computes `(630-az)%360` instead of `(az+90)%360`. Re-verified on both original sample files afterward: idempotent, zero errors, same sensible nearest-pole pairings as build 60 (only the angle values themselves changed). |
    | 62 | 🍒 CHERRY | widen **UGW→CPN's** pole search from UPP-only to **ULP/UPP/UGP** — the owner's original worked example happened to use `UPP`, but a guy wire in the field can anchor any of these pole/pedestal codes, not just `UPP`. `addUgwCpn` now scans a shared `UGW_POLE_CODES=['ULP','UPP','UGP']` list and still just picks whichever single point (of any of the three codes) is nearest by plain 2D distance — no per-code priority order, same nearest-by-distance rule as before, just over a wider candidate set. Verified on all 3 real job files: `TOPO PASCAL`'s UGW points still pair with the same `UPP` points as build 61 (angles unchanged, 179.61°/179.52° for 11250/11251), and both Hamline (which has a real `UGP` point) and Dale (which has a real `ULP` point) still pick the nearest actual pole regardless of code — no regression, idempotent, zero console errors on any file. A synthetic test (placing a `ULP` and separately a `UGP` closer to a `UGW` than any `UPP`) confirmed the search genuinely considers all three codes and picks the truly nearest one, not just falling back to `UPP` when present. |
    | 63 | 🥝 KIWI | new **CPN/RPN connect-to-point** line codes — the owner sent screenshots + the vendor's own doc: `CPN<n>` ("connect to point number") begins a feature by connecting its linework to a previously-shot point `n`, and `RPN<n>` ("recall point number") does the same at a feature's end — both let a crew avoid re-shooting a coincident point just to tie two lines together. This is a REAL, unrelated feature that happens to collide in name with the build-60/62 `addUgwCpn` guy-wire tool (which just appends a plain descriptive `CPN<id>` text token, never parsed as linework) — the owner explicitly said to leave that tool alone and build the real vendor code instead. Confirmed real usage in 2 of 3 job files on hand: Hamline's `RWLK1` uses `CPN9124` on an **E**-flagged point (9588) and `CPN9123` on a **B**-flagged point (9692); Dale's `RWLK3` uses a bare `CPN 5341` with **no B/E at all** (point 5500), and `RWLK4` uses `CPN 5342` on a plain mid-run point (5501 B → 5502 CPN). `RPN` never appears in any real file on hand — implemented symmetrically from the vendor doc text alone, disclosed as unverified against real data. **Superseded the same day by build 64's rendering fix — see below.** |
    | 64 | 🍑 PEACH | fix **CPN/RPN rendering a detour instead of one connector line**: build 63 spliced the linked point INTO the figure's own sequential vertex path, so the main line routed straight THROUGH it (e.g. `9581→9582→9124→9588` instead of the intended tie) — two segments in and out of the linked point, not the single direct connector the owner wanted ("only render one line, active point to call out point"). Reworked so CPN/RPN links are no longer part of `r.verts` at all — they're now a separate `r.links` array (`{at,to,kind}`), and `strokeFigure` draws each one as its own standalone 2-point line (from the point that coded `CPN`/`RPN` straight to the referenced point) AFTER finishing the main path untouched. The main line is now byte-identical to how it rendered before `CPN`/`RPN` existed at all (Hamline's `RWLK1@700` is back to plain `[9581,9582,9588]`); the tie is a clean separate segment. Also fixes the same detour bug for the green curb-offset cross-section lanes and any other consumer of a figure's vertex list, since none of them ever see the linked point mixed into the main sequence anymore. `figures()`'s length filter widened to `r.verts.length>=2||r.links.length` so a lone implicitly-CPN-begun point (Dale's pt 5500, a single real vertex plus its tie) still renders instead of being dropped. `inspectFig`'s line-editor panel now shows connect-to-point ties in their own small "Connect-to-point (CPN/RPN)" section (a `TIE` badge, the linked point's own real FBK line, and a zoom button) instead of as a fake extra vertex row. Verified against all 3 real job files: same figure counts as build 63 (70/99/162), the exact same figures gain links, zero console errors; export safety re-confirmed (point 9124 still exports exactly once, on its own original line); RPN re-verified with the same synthetic figure. **Superseded the same day by build 65 — see below.** |
    | 65 | 🍍 PINEAPPLE | fix **CPN wrongly connecting an ENTIRE code's points into one line**: the owner reported a real case — a figure code with **no `B` anywhere** (meant to stay individual unconnected points/nodes, per the app's own standing rule) where ONE of its points carries `CPN` to tie it to another line — and build 63/64's "CPN implicitly begins a run" logic (mirrored off the `CIR` precedent) swept **every subsequent same-coded point** into one continuous line, since nothing ever closes that implicitly-opened run without an explicit `E`/`CLS`. That was never the intent — `CPN`'s real job is a single point-to-point tie, not "start a whole line." Removed CPN's implicit-begin entirely: `buildLinework` now computes ties in a completely separate global `CONNECT` list (`{at,to,kind,code}`), populated per-point independent of whether that point's code ever forms a figure at all — a code with no `B` stays exactly what it always was (plain nodes, `drawPt` draws each one as a dot), even when one of its points carries `CPN`/`RPN`; that one point just gets its own tie line on top. `figures()` reverted to its pre-`CPN`-work shape (no `cpn`/`rpn` on vertices, no implicit-begin branch, plain `r.verts.length>=2` filter) plus one addition: `r.links` is now a **derived, read-only filter** of the global `CONNECT` list (whichever ties happen to originate from a vertex that's part of THIS figure's real path) — used only for the line-editor's display, never for opening/extending a run. A new `drawConnectLinks()` draws every `CONNECT` tie whose origin point ISN'T part of any figure (the ones `strokeFigure`'s own `f.links` loop can't reach, since there's no figure to call it from); the single-point inspector (`inspect()`) gained the same small "Connect-to-point (CPN/RPN)" section `inspectFig` already had, so a lone tied node still shows its connection somewhere. Verified: a synthetic reproduction of the owner's exact report (a 4-point no-`B` code, one point `CPN`-tied to a real line) now correctly produces **zero figures** for that code (all 4 stay plain nodes) with exactly one `CONNECT` entry for the tied point — confirmed via `figures()` returning nothing for that code and the tie still rendering through `drawConnectLinks`. Re-verified against all 3 real job files: Dale's figure count drops from 162 back to **161** (matching the original pre-`CPN`-work baseline) since point 5500 — which has no `B` nearby either, the exact same shape of case — no longer creates a phantom implicit figure; Hamline's 2 real ties (both on points that ARE part of a genuine `B`-started `RWLK1` run) are completely unaffected, still shown via their figure's own `r.links`. Export safety and the `RPN` synthetic test both re-confirmed unaffected. |
    | 66 | 🥭 MANGO | fix **`SO` (stop offset) drawing a spurious spike instead of a clean end-cap**: the owner sent screenshots of a tangled mess of curb offset lines and, once they supplied the matching job file (`TOPO RAVOUX` — their first-attached file, `TOPO ARUNDEL`, was a mismatch: grepped for zero literal `SO` tokens and none of the screenshots' point IDs, so no code was touched until the correct file arrived), traced it to `offsetAt` — the function every curb-offset lane line, cross-section rib, and OSNAP offset-segment call goes through to compute one offset point, mitered/extended at a corner. `offsetAt` decided whether a vertex was a true "interior corner" (needing a 2-line miter) purely from **physical array adjacency** (`k>0`/`k<n-1` — does a neighboring vertex exist at all in the figure), with zero awareness of whether that neighbor's offset was actually part of the SAME continuous span. At an `SO` stop point, the LAST rendered offset point still physically has a "next" vertex in the array (SO stops the *offset*, not the base line — the real curb keeps going) — so `offsetAt` mitered the end-cap using that next segment anyway, even though no offset is drawn along it. Same bug at the *start* of any offset run (right after `startK`, or right after a fresh restart) — the first point mitered against the PRECEDING "dead" segment. Confirmed on Ravoux's real `RDRC` figure at point 1140 (`"RDRC EC SO RBCB1 B H-0.5 V0"`): segment 1139→1140 turns **98.7°** into segment 1140→1141 (a real corner in the base line, but 1141 carries no offset), and the old mitered corner landed **0.58 ft** off a proper end-cap — more than the 0.5 ft offset distance itself. `offsetAt` now takes explicit `contPrev`/`contNext` continuity flags (omit both for the old physical-only behavior, kept as the default so no caller silently changes meaning); a new `spanAdj(per,k)` helper derives real continuity for free from the `per[]` active-template array `drawOffsets`/`collectOffsetSegments` already build — `per[k-1]===per[k]` (same object reference) means no restart/stop happened in between, since `active` is only ever reassigned at a fresh `stepsAt` entry. Interior mitering now requires BOTH physical adjacency AND continuity; a one-sided boundary uses a plain single-segment perpendicular off whichever side IS continuous (falling back to whatever's physically there only for a fully isolated single-point template, to avoid ever crashing on a missing neighbor). Applied to all 3 call sites: `drawOffsets`'s dashed cross-section ribs, its solid lane lines, and `collectOffsetSegments` (OSNAP). Verified against all 5 real job files (Pascal/Hamline/Dale/Ravoux/Arundel): figure counts unchanged (70/99/161/36/43), zero console errors on load+draw+`collectOffsetSegments()`/`collectSegments()`. Direct before/after screenshots at all 4 of Ravoux's real `SO` points (1097, 1101, 1115, 1136) AND at the natural start of an offset run (1082) each show the exact spurious dashed diagonal spike gone, replaced by a clean perpendicular end-cap tracking the base curve — matching the clean end-cap ticks in the owner's CAD reference screenshots; numerically confirmed the new offset value at 1140 lands exactly on the plain single-segment perpendicular (0.0 ft deviation). **The owner then tested this and reported it still wasn't right — see build 67, the same day.** |
    | 67 | 🍉 WATERMELON | fix **`SO` not actually disabling the offset when the next `H/V` template happens to sit on the VERY NEXT point**: the owner tested build 66 and reported "when SO is applied it should disable the offset leaving that node and resume when the H/V callout is called later down the line" — build 66 only fixed the *corner angle* at a span boundary, it never made the drawn LINE itself break there. The lane-line connecting loop in `drawOffsets` (and the matching one in `collectOffsetSegments`) decided whether to `lineTo` (connect) or start a fresh subpath purely from whether `op[k]` — the computed offset point — was non-`null`; it never checked whether `op[k-1]` and `op[k]` belonged to the SAME active template. Ravoux's real `SO` usage always has the next `H/V` restart on the immediately-following point (`"...SO"` then `"...H-0.5 V0"` right after, e.g. 1097→1098, 1136→1137) — so `op[]` never actually goes `null` in between, and the loop just drew one uninterrupted connected line straight through the boundary, corner-angle fix and all: the offset never visibly "disabled," it just got a correctly-angled corner. Reproduced directly with a synthetic figure (`SO` on point 3, a fresh `H-0.5 V0` on the very next point 4) — the old+build-66 code drew one continuous unbroken green line from point 1 all the way to point 5, with no visible break at 3 at all. Fix: `drawOffsets`'s lane-line loop and `collectOffsetSegments` both now track a parallel `contPrev[]` array (the same `spanAdj(per,k).hasPrev` build 66 already computes for the corner math, just also kept around here) and treat `!contPrev[k]` as a hard break — a fresh `moveTo`/`prev=null` — exactly like a `null` gap, even when `op[k-1]` and `op[k]` are both non-`null` and physically adjacent. This makes "disabled" mean an actual visual gap in the drawn offset line, not just a corrected angle at a still-continuous corner. Verified: the same synthetic repro now draws two genuinely separate green segments (points 1-2-3, and 4-5) with a real gap between them — confirmed at both a normal zoom (visibly two disconnected pieces) and a tight zoom on just the 4-5 segment (confirms that second piece renders correctly on its own, not silently dropped). Re-verified against the real Ravoux `RDRC` figure: point-by-point `per`/`contPrev`/`op` dump for the `1096→1097→1098` transition confirms `contPrev` is `true` between 1096 and 1097 (same template, both still draw connected — correct, since `SO` includes its own point) and `false` at 1098 (the fresh restart — correctly breaks); a tight screenshot centered on 1096/1097 shows the green offset running continuously through both (matching the "still draw at the SO point itself" rule) and then a real gap along the base line all the way to 1098, where a screenshot of that segment shows no offset at all; a screenshot of 1098 onward shows a fresh offset lane starting there with its own clean perpendicular start-cap. All 5 real job files re-verified after this change: figure counts still unchanged (70/99/161/36/43), zero console errors on load/draw/`collectOffsetSegments()`/`collectSegments()`; total offset-segment counts dropped slightly on every file (e.g. Ravoux 134→102) — expected, since spurious connector segments across template boundaries are exactly what this fix removes, not a sign of lost real offset lines (the base line and everywhere-else `per[k]` truthy is untouched). |
    | 68 | 🥥 COCONUT | fix **build 67's own continuity check killing real curve offsets that never had an `SO` anywhere near them**: the owner tested build 67 and reported "the curved corner stopped rendering the offset at curved section," with a screenshot of Dale's `RBCB@1485` curve (points 6398-6403) — the green offset lane was simply gone through the whole rounded corner, base line unaffected. Build 67's `contPrev[k]` check used **object-reference equality** (`per[k-1]===per[k]`) to decide continuity — but a curb-code shorthand like `R612`/`R006` re-expands to a **brand-new array instance every time it's re-stated**, even when it's the exact same code repeated redundantly on consecutive points of the same curve with **no `SO` anywhere nearby** (confirmed: Dale's 6398 `"RBCB BC"` → 6399 `"RBCB R612"` — R612 re-declares the SAME curb template build 67 had no way to recognize as "the same," since `expandCurb` hands back a fresh array each call). Build 67's check treated every one of those redundant re-declarations as a hard break, even with zero `SO` involved — silently killing the offset through any curve where the field data (or the vendor software that generated it) restates the curb code on more than one point of the run, which turned out to be extremely common: a repo-wide scan found this exact false-break pattern on **14 real curves across 4 of the 5 job files** (3 in Hamline, 8 in Dale — including the reported 6398/6399 — 1 in Ravoux, 1 in Arundel), not an isolated case. Fix: replaced the reference-equality check with a `cont[]` array computed directly alongside `per[]` in a new shared `offsetPerCont(all,stepsAt,stopAt,startK)` — continuity from `k-1` into `k` now depends ONLY on whether `stopAt[k-1]` (an actual `SO` on the prior point) fired, not on whether `k` happens to carry its own (possibly redundant) `H/V`/curb-code restatement: `cont[k] = k>0 && per[k-1]!=null && !stopAt[k-1]`. A repeated-but-uninterrupted template is now correctly treated as one continuous run again (matching pre-build-66 behavior for that case), while a genuine `SO` still breaks the line exactly as build 67 intended — the two build 66/67 fixes and this one are no longer in tension, since "was there really an SO" is now the only signal that matters. `spanAdj` takes `cont` instead of `per`; all 3 call sites (`drawOffsets`'s ribs and lane lines, `collectOffsetSegments`) updated to build `per`/`cont` via `offsetPerCont` and pass `cont` through. Verified: the same repo-wide scan that found 14 false breaks now finds **zero** on all 5 files; offset-segment counts are back near (Ravoux: within 2 of) the original build-66 baseline (Pascal 385, Hamline 431, Dale 803, Arundel 181 — byte-identical counts to build 66; Ravoux 132 vs 134, the 2-segment difference being the real `SO` breaks that SHOULD still be there); figure counts unchanged (70/99/161/36/43), zero console errors. Re-ran the build-67 SO-specific synthetic repro and the real Ravoux 1096→1097→1098 point-by-point check — both still show the correct genuine gap at a real `SO` boundary, confirming this fix didn't undo build 67, only narrowed its trigger to what it was actually meant to catch. A direct screenshot of the reported Dale curve (6398-6403) now shows the full 3-lane `RBCB1` cross-section curving cleanly and continuously through the whole corner, matching the pre-regression appearance. |
    | 69 | 🍋 LEMON | **UGW→CPN gets an editable review popup instead of applying blind** — the owner asked: "on guy wire tool I want [a] popup window showing the list and option to ed[i]t target by point or select target point, as automation may not resolve all cases." The nearest-pole automation (build 60-62) always just wrote its pick straight to the point description with no way to correct it short of hand-editing raw FBK text — reasonable for the common case, but a guy wire can legitimately anchor to a pole that ISN'T the physically-nearest one (e.g. the nearest pole is across a street, or on the wrong side of a building), and the tool had no way to say so. `🧭 UGW→CPN` now opens a **review modal** (`#ugwReviewScrim`, new `.modal.wide` CSS variant for the wider list) instead of applying immediately: `openUgwCpnReview()` runs the exact same nearest-pole search as before (`computeUgwPairs()`, factored out of the old `addUgwCpn`) to prefill every row, but nothing is written until the owner hits **Apply**. Each row (`renderUgwReviewList()`) shows the UGW's point id, an editable **Target pt** text input (defaults to the auto-picked pole, with an `auto: <id> ✓` note so it's obvious when a row still matches the automation), a **📍** pick-on-canvas button, and a live-recomputed angle preview (`ugwRowAngle()`, re-run on every keystroke) that reads `skip` for a blank target, `no such point` for one that doesn't resolve, or the real `bearingFromWest` angle otherwise — so the owner sees the exact number that will be written before committing to it. **📍 pick-on-canvas** (`startUgwPick`/`endUgwPick`) reuses the same hide-modal/crosshair-cursor/reveal-modal pattern the existing COGO "Pick on canvas" (`startCogoPick`/`endCogoPick`) and circle-center tool already establish — click any real point on the canvas (via the existing plain `pick()`, not an object-snap search, since the target here is always an existing shot, not a computed location) and it fills that row's target field; **Esc** cancels the pick and returns to the list untouched. Blanking a row's target field means "skip this UGW, don't touch it" — `applyUgwReview()` silently skips both blank rows and rows whose typed id doesn't resolve to a live, non-deleted, non-self point, applying only the rows that DO resolve, then reports "applied to N of M pt(s)" so a skip is never silently confused with "did nothing." `addUgwCpn()` itself is gone — its pairing search lives on as `computeUgwPairs()` and its write logic (strip-old-CPN-then-append, `saveState()`/`logEdit`/`buildLinework()`/`flagDirty()`) lives on unchanged inside `applyUgwReview()`, so this is a UI layer added in front of the exact same, already-verified (build 60-62) math and write path, not a rewrite of either. Verified end-to-end through the real UI (actual clicks/typing, not poked state) on all 3 real job files with genuine UGW/pole data: opening the review shows the correct row count and the same auto-picks build 60-62 already verified (Pascal's 11250/11251 still auto-pair to 11258 at 179.61°/179.52°, byte-identical to the ground-truth-checked build-61 values); **Cancel** leaves every UGW description completely untouched on all 3 files; typing a bad point number live-updates the angle preview to `no such point` with nothing applied for that row; **📍 pick** on a real canvas point (after `fit()`) correctly hides the modal, sets `ugwPick`, resolves the clicked point via the same `pick()` the rest of the app's canvas tools use, fills the target field, and reopens the modal with the picked id and its freshly-computed angle both visible; **Apply** with one row blanked (skip) leaves that UGW's description exactly `"UGW"` (no CPN token added) while the other rows get their normal `"UGW <angle> CPN<id>"` write, confirmed via the actual point descriptions after apply, not just a return value; re-opening the review after an apply and applying again is **idempotent** (byte-identical descriptions both times) on all 3 files, matching build 60-62's own idempotency guarantee. Synthetic edge cases also verified: a UGW with genuinely no ULP/UPP/UGP anywhere in the file correctly shows an empty target / `no pole found nearby` / `skip` row (not a crash or a wrong forced pairing) and still accepts a manual override target typed in by hand (applied and computed correctly, confirming the target field accepts ANY resolvable point, not just pole-coded ones — the whole point of the "automation may not resolve all cases" request); a file with zero UGW points at all correctly hud's a message and never opens the modal. Zero console errors across every scenario tested. |
    | 70 | 🍎 APPLE | **UGW→CPN pick-on-canvas shows an animated ring at the guy wire's own origin point** — the owner: "when picking the point guy target show animated ring of the guy wire origin location." Build 69's **📍 pick-on-canvas** hides the review modal and lets the owner click anywhere on the canvas to find the target pole — but nothing on screen marked which UGW point that pick was FOR, so on a busy job file with several rows it was easy to lose track of which guy wire you were currently assigning a target to while panning/zooming around looking for the right pole. The app already had one ring-flash mechanism (`flash`/`drawFlash`, used by `⌖ Go to point`/`zoomToPoint`) — a gold ring that shrinks and fades out once over exactly 1200ms — but that's the wrong shape for this: a pick can take an arbitrary amount of time (finding the right pole across a street, zooming/panning to look), and a one-shot fade would disappear long before the owner finishes looking. Added a **second, separate** ring function, `drawUgwPickRing()`, purpose-built to stay visible for the pick's entire duration instead of a single fade: it reads the currently-picking row's origin point directly off `ugwPick`/`ugwReviewRows` (both already tracked by build 69's `startUgwPick`/`endUgwPick`) and draws a ring whose radius/opacity **loops** on a 900ms cycle (`(performance.now()%900)/900`, radius 8→30px, fading out and restarting) via its own `requestAnimationFrame(draw)` chain — same animation-loop pattern `drawFlash` already established, just repeating instead of terminating. No new state was needed beyond what build 69 already tracks: the ring simply reads `ugwPick`/`ugwReviewRows[ugwPick].i` each frame and draws nothing at all once `ugwPick` goes back to `null` (set by `endUgwPick`, on both a real click and an Esc cancel) — so the ring starts the instant `startUgwPick` is called (its existing trailing `draw()` call) and stops on its own the very next frame after the pick ends, no explicit teardown code needed. Wired into both `draw2D()` and `draw3D()` right next to the existing `drawFlash()` call (`drawUgwPickRing()` added immediately after it in both), so it works the same in 2D and 3D/orbit view exactly like every other picking overlay in the app. Verified end-to-end through the real UI on the real Pascal job file (its 3 real UGW points): starting a pick on UGW pt 11236 correctly hides the modal, shows the crosshair cursor + hud hint, and a screenshot centered on that point shows a visible gold ring around it — a second screenshot ~300ms later shows the ring at a different radius/opacity, confirming it's actually animating/looping rather than a static circle; clicking a real different point (pt 11226) correctly completes the pick (`endUgwPick`), fills that row's target field, reopens the modal, and the ring stops (confirmed via `ugwPick===null` and a screenshot with the modal back on top and no stray ring); Escape mid-pick correctly cancels the same way with the row's target left untouched. Re-ran the full regression sweep across all 5 real job files (Pascal/Hamline/Dale/Ravoux/Arundel): figure counts unchanged (70/99/161/36/43), `collectSegments()`/`collectOffsetSegments()` still run with no error, every file's UGW review (including Arundel, which correctly has zero UGW points and never opens the modal) opens/picks/cancels cleanly, re-running Apply is still idempotent, and zero console errors beyond the pre-existing, already-documented map-tile network block on every file. |
    | 71 | 🍌 BANANA | new **🏷 Labels toolbox** — the owner: "add tool set to control point by showing point number and code and elevation, have check box to activate and deactivated and size slider." Before this, a point's on-canvas label was hardcoded to exactly one of two things — a control point always showed its code (`p.desc.split(' ')[0]`), every other point always showed its point number — at a fixed 10px font, with no way to see a shot's code or elevation without opening the inspector, and no way to change the text size. Added a toolbar toggle button (`#labelBtn`, "🏷 Labels") that shows/hides a small floating panel (`#labelBox`, styled off the existing `.snapbox` OSNAP-toolbox CSS so it matches the app's look, positioned bottom-left clear of both the tool column and the hud) with three independent checkboxes — **Point #**, **Code**, **Elevation** — plus a **Size** range slider (7-20px). A new shared `pointLabelText(p)` builds the label string from whichever fields are checked, in that fixed order, space-joined (`labelShow.num`/`.code`/`.elev`, each independently toggleable — e.g. Code+Elevation with Point # off reads `"UGW 229.00"`; all three reads `"11236 UGW 229.00"`), returning `''` when every box is unchecked so nothing is drawn at all. Both the 2D (`drawPt`) and 3D (`draw3D`'s point-painter loop) label draws were switched from their old hardcoded `ctx.font='600 10px ...'` + single-field `fillText` to `pointLabelText(p)` + the new `labelSize` variable (`` `600 ${labelSize}px ui-monospace,monospace` ``), and skip the `fillText` call entirely when the built string is empty — one shared function drives both views identically, so the toolbox controls 2D and 3D at once. Default state (`labelShow={num:true,code:false,elev:false}`, `labelSize=10`) reproduces the OLD non-control-point look exactly (point number only, 10px) so nothing changes for anyone who doesn't open the toolbox; the one deliberate default behavior change is that a **control point** now also defaults to showing its number instead of its code (previously code-only for control points, number-only for everything else) — the owner can tick **Code** back on for control points same as any other point, since the whole point of this feature is no longer hardcoding one field per point kind. Verified through the real UI on the real Pascal job file: toggling the toolbox button shows/hides the panel; zoomed screenships at the default state show plain point numbers exactly as before; ticking Code+Elevation (Point # off) shows e.g. `"UGW 229.00"` next to point 11236 — confirmed via both a direct `pointLabelText()` call and a real rendered screenshot; ticking all three shows `"11236 UGW 229.00"`; dragging the size slider to 18px visibly enlarges every label on screen and updates the panel's own `18px` readout; unchecking all three produces an empty string and no label draws. Re-ran the full regression sweep across all 5 real job files cycling every checkbox combination (num-only / code-only / elev-only / all-three / none) through both `draw2D()` and `draw3D()`: figure counts unchanged (70/99/161/36/43), zero console errors beyond the pre-existing, already-documented map-tile network block on any file. |
    | 72 | 🍇 GRAPE | **UNVERIFIED, on branch `claude/streetview-color-test` only — NOT merged to main or `claude/street-view-linework`.** Added `filter:none!important` to `#svPanoDiv` (additive, alongside the existing build-54 `color-scheme`/`forced-color-adjust` fix, which was NOT removed) as a low-risk experiment against a possible remaining Street View color-inversion path — declined a third-party suggestion to also restore a supposedly "missing" COGO code block (the real `openCogoDialog`/`insertCogoPoint` were never missing and are more correct than the suggested replacement) and to drop the build-54 CSS fix entirely (already verified working). See the Street View section below for the full writeup. Merge only after the owner confirms in a real browser that this actually helps — this sandbox still can't reach Google's domains to check itself. |
    | 73 | 🍓 STRAWBERRY | **STILL UNVERIFIED, same branch `claude/streetview-color-test` only — NOT merged.** Owner asked to try a pre-invert instead of a no-op: `#svPanoDiv`'s `filter` changed from build 72's inert `filter:none!important` to `filter:invert(1) hue-rotate(180deg)` — the standard "cancel out an external color inversion" trick, additive to (not replacing) the untouched build-54 `color-scheme`/`forced-color-adjust` fix. **Real tradeoff, not hidden:** this helps if something really is externally inverting the panorama (a forced-dark heuristic, a dark-mode extension in filter mode) but actively makes the photo wrong if nothing was inverting it in the owner's actual browser — unverifiable from this sandbox either way (still blocked from Google's domains), which is exactly why this stays on its own unmerged branch until the owner reports back what they actually see. Verified only what's checkable without live imagery: script still parses, the computed filter lands exactly as written, all 3 original real job files redraw with unchanged figure counts and zero new console errors. |
    | 74 | 🍒 CHERRY | **STILL UNVERIFIED, same branch `claude/streetview-color-test` only — NOT merged.** Owner asked to check a fix a DIFFERENT AI had produced against this repo (`index_streetview_color_fixed.html`) — diffed it directly against the real file (unlike the earlier pasted suggestion, this one was a real, small, purely-additive CSS diff, nothing fabricated or removed) and adopted the bulk of it, REPLACING build 73's speculative pre-invert: neutralizes `filter`/`mix-blend-mode`/`forced-color-adjust` on `#svPanoDiv` AND everything Google's own JS mounts inside it (`.gm-style`, `canvas`, `img`), plus `isolation:isolate` (defeats a blend-mode-based "smart invert," a different mechanism than build 54's forced-dark-heuristic fix) and `color-scheme:light only` (a stronger signal than plain `light`). Dropped the one piece NOT kept — a forced `background:#fff` that would have hurt the loading/fallback placeholder's contrast for no anti-inversion benefit. Unlike build 73's pre-invert (helps XOR hurts depending on whether something really was inverting it), this one can only help or do nothing. See the Street View section below for the full writeup. Still fundamentally unverifiable from this sandbox (no Google-domain network access) — merge only after the owner confirms in a real browser. |
    | 75 | 🥝 KIWI | **Real regression fix, same branch `claude/streetview-color-test` only — still NOT merged.** Owner confirmed build 74 fixed the colors but reported the live panorama going black while orbiting/panning. Root cause: build 74's `mix-blend-mode:normal!important`, forced onto every descendant of `#svPanoDiv` (not just the container), was almost certainly stomping on whatever blend mode Google's own renderer uses internally to cross-fade newly-loading tiles as the view moves — fine once settled, black mid-transition. Fix: the anti-inversion protection only ever needed `isolation:isolate` on the CONTAINER (that alone blocks an ancestor's blend-mode-based invert from compositing through) — removed both build-74 rules that reached into `#svPanoDiv`'s descendants (the universal `#svPanoDiv *{...}` rule and the `.gm-style`/`canvas`/`img`-specific one) and replaced them with one container-only rule, no `mix-blend-mode` anywhere. Verified nothing in our CSS touches descendants anymore (a synthetic child element's own `mix-blend-mode:screen` now survives, computed style confirms it's not forced to `normal`), figure counts unchanged (70/99/161) on all 3 files, zero new console errors, Street View modal still opens normally. Still needs the owner to confirm in a real browser that orbiting no longer goes black before this merges anywhere. |
    | 76 | 🍑 PEACH | **Real color regression from build 75, fixed narrower — same branch `claude/streetview-color-test` only, still NOT merged.** Owner pulled build 75 (which dropped every descendant-targeting rule) and reported the inversion came back — a useful signal that something applies its counter-invert DIRECTLY to the panorama's own `canvas`/`img` elements, not as a blend from outside `#svPanoDiv` that `isolation:isolate` alone could block. Put back a `filter:none!important;mix-blend-mode:normal!important` reset, but scoped ONLY to `#svPanoDiv canvas,#svPanoDiv img` — not `.gm-style`, not `.gm-style>div`, not the universal `#svPanoDiv *` build 74 used — so the generic wrapper `<div>` layers Google's own tile cross-fade needs (the actual cause of build 74/75's orbit-goes-black) stay untouched while the two leaf element types that actually render pixels get their counter-invert cancelled. Verified the split holds: a synthetic plain `<div>` keeps its own `mix-blend-mode:screen`, while a synthetic `canvas`/`img` with an injected `filter:invert(1)`+`mix-blend-mode:screen` both correctly come back to `none`/`normal`. Figure counts unchanged (70/99/161), zero new console errors, modal opens normally. Owner needs to confirm BOTH correct colors AND smooth orbiting in a real browser before merging. |
    | 77 | 🍍 PINEAPPLE | **3rd real black-out trigger reported (this time on markers appearing, not orbit) — same branch `claude/streetview-color-test` only, still NOT merged.** Lined up all 3 real-browser reports: every build that reset `filter`/`mix-blend-mode` on `<canvas>` inside `#svPanoDiv` went black at SOME later interaction (build 74: orbit; build 76: markers appearing); the one build that never touched `<canvas>` (build 75) never went black, only had the color regression. Conclusion: `<canvas>` was never actually where the color fix needed to happen — dropped it from the reset selector entirely, keeping only `#svPanoDiv img{filter:none!important;mix-blend-mode:normal!important}`; both `<canvas>` and every wrapper `<div>` are now completely untouched. Verified with synthetic elements: a `<div>` AND a `<canvas>` with injected `filter:invert(1)`/`mix-blend-mode:screen` both now survive completely unmodified, while a synthetic `<img>` with the same injected properties still gets correctly reset. Figure counts and console errors unchanged across all 3 real job files, modal opens normally. This is the 4th CSS-only iteration on this issue — if it still goes black, the next useful signal is the actual browser console output at the moment it happens, not another blind guess. |
    | 78 | 🍊 ORANGE | owner, after the billing root-cause was found and documented: "go back on the Street View branch and add a filter on top, independent from the app, and invert color[s] during view[ing] Street View." Rather than a 5th round of setting `filter`/`mix-blend-mode` directly ON `#svPanoDiv` or its descendants (builds 74-77's whole approach, which repeatedly fought Google's own dynamic style updates on those exact elements and caused the orbit/marker black-outs), this build removes ALL of that direct manipulation and replaces it with a genuinely separate element: `#svInvertOverlay`, a plain sibling `<div>` (never a child — `#svPanoDiv` is wrapped in a new `#svPanoWrap`, and the overlay sits alongside it, absolutely positioned to cover it) using `mix-blend-mode:difference` against a white background, the standard blend-mode trick for inverting whatever renders underneath without ever touching a single property on the thing being inverted or anything inside it. A new **Invert colors** checkbox in the Street View modal's header (`#svInvertChk`) toggles it — `svInvertOn` (default `true`, per the request) persists across modal opens/closes for the session, re-synced every time `openSvModal` runs (`syncSvInvertOverlay()`). Since the overlay never touches `#svPanoDiv`, it can't be wiped out by Google's own `Map`/`getStreetView()` setup or `innerHTML` fallback-swap, and can't fight Google's internal style updates the way builds 74-77 did — it's compositing on top, not competing for the same properties. Build 54's real, independently-confirmed `color-scheme:light only`/`forced-color-adjust:none` fix on `#svPanoDiv` itself (a genuinely different, unrelated problem — Chrome's forced-dark-mode heuristic) is kept untouched. Verified through the real UI in a real headless browser: overlay/checkbox/wrapper all present in the DOM; opening the modal (via the actual `openSvModal` call path) correctly syncs the overlay to `display:block`/`mix-blend-mode:difference` and the checkbox to checked; a real click unchecks both the checkbox and the overlay's `on` class; a second real click re-checks both; closing and reopening the modal for a different point correctly preserves the ON state; `#svPanoDiv`'s own computed style now shows plain browser defaults (`filter:none`, `mix-blend-mode:normal` — no longer FORCED by our CSS) alongside the still-present `color-scheme:light only`; zero console errors beyond the pre-existing, already-documented Google-domain network block. This is still on `claude/streetview-color-test` only, still not merged — same standing caveat as every build since 72: the owner needs to actually look at Street View in a real browser (now hopefully with billing enabled) and say whether inversion is even still wanted, since the root cause turned out to be billing, not color handling — this build makes inversion a deliberate, toggleable, non-invasive OPTION rather than another forced guess. |
    | 79 | 🍋 LEMON | owner: **"it works now"** (billing fix confirmed, build 78's overlay confirmed working) — **"add invert color filter when click full[ ]screen in the viewer."** Google's Street View panorama has its own native fullscreen control (never explicitly disabled — `svPano.setOptions` never sets `fullscreenControl`, so it defaults on), and clicking it puts the browser into the real Fullscreen API, not just a bigger CSS box. That matters because the Fullscreen API only paints DESCENDANTS of whatever element `requestFullscreen()` was called on — build 78's `#svInvertOverlay` is a SIBLING of `#svPanoDiv` (deliberately, so it never fights Google's own style updates), so once the panorama went fullscreen the overlay would simply stop rendering even though nothing about its own `.on` state changed — it was still "on," just outside the part of the DOM the browser was now painting. Fix: `svSyncOverlayFullscreen()`, wired to both `fullscreenchange` and `webkitfullscreenchange` on `document`. On entering fullscreen, it checks whether `document.fullscreenElement` (or the webkit-prefixed equivalent) IS `#svPanoDiv`, is a descendant of it, or is an ancestor containing it — covers all 3 ways Google's own fullscreen control might target the DOM (fullscreening `#svPanoDiv` directly, or an internal wrapper it creates inside/around it) without needing to know which one Google actually does — and if so, reparents the overlay `<div>` directly INTO that fullscreen element (`appendChild`, a safe no-op if it's already there) and switches it from `position:absolute` to `position:fixed` (so its `inset:0` covers the real fullscreen viewport, not `#svPanoWrap`'s now-irrelevant box) with a max z-index so it stacks above whatever Google renders inside the fullscreen element. Exiting fullscreen reparents it straight back into `#svPanoWrap` at `position:absolute`, identical to build 78's baseline. `pointer-events:none` (unchanged since build 78) means the overlay never blocks the native exit-fullscreen control or dragging to look around, in or out of fullscreen. Verified in a real headless browser: since headless Chromium's real `requestFullscreen()` needs a genuine user gesture/flags this sandbox doesn't reliably provide, the app's OWN `svSyncOverlayFullscreen` function was exercised directly against a mocked `document.fullscreenElement` (the same technique used to isolate exactly the code path this build actually changed) — confirmed the overlay starts as a sibling of `#svPanoDiv` inside `#svPanoWrap` at `position:absolute`; entering fullscreen with `fsEl===#svPanoDiv` correctly reparents it into `#svPanoDiv` at `position:fixed` with the max z-index, `.on` state untouched; entering fullscreen with `fsEl` = a synthetic child element INSIDE `#svPanoDiv` (simulating an internal Google wrapper) correctly reparents it into THAT element instead; exiting fullscreen (`fullscreenElement=null`) correctly moves it back into `#svPanoWrap` at `position:absolute`; the Invert colors checkbox still toggles correctly (real click, both directions) after a full enter/exit fullscreen cycle, confirming the reparenting doesn't break the existing build-78 toggle wiring. Script parses, zero console errors beyond the pre-existing Google-domain network block. Still on `claude/streetview-color-test` only, still not merged — the one thing genuinely unverifiable from this sandbox is the REAL Fullscreen API firing `fullscreenchange` when the owner actually clicks Google's native fullscreen button (as opposed to the mocked-property test above, which proves the handler logic is correct but not that the browser calls it at the right moment) — the owner should confirm the invert stays visible and correctly positioned after clicking fullscreen in their real browser. |
    | — | — | **ROOT CAUSE FOUND — builds 72-77's entire CSS chase was solving the wrong problem.** The owner finally pulled real browser console output, and it shows a hard Google Maps API failure: `"You must enable Billing on the Google Cloud Project"` — the API key's Google Cloud project has no billing enabled, so Street View can't actually load/render properly. NOT a CSS bug, never was, no CSS on our side can fix it. This retroactively explains every symptom chased across builds 72-77: without billing, the panorama falls back to unstable/broken rendering, and whichever CSS filter/blend-mode tweak happened to be active just changed how that already-broken output looked (sometimes "inverted," sometimes black) — never a real fix-vs-break tradeoff. The fix is entirely outside this repo: enable billing on the Google Cloud project at `console.cloud.google.com` (Maps includes a monthly free credit, but a payment method must be on file regardless). No further CSS pushed pending that — next step is retesting on the CLEAN `claude/street-view-linework` baseline (build 71, pre-chase) once billing is on; if that alone renders correctly, all of `claude/streetview-color-test` (builds 72-77) gets discarded rather than merged. See the Street View section below for the full writeup. |
    | 80 | 🥭 MANGO | owner: 3D orbit is hard to control on a large site (big distance between points), and asked to put the mouse **middle button** to use. Found 3 real bugs: the orbit pivot only ever moved on `fit()`/Go-to-point, so rotating far from it swept the view in a huge arc for a tiny drag; every zoom (wheel or +/−) silently re-centered the pivot to screen-middle (`refreshOrbitPivot()`), undoing any panning you'd just done; and middle-mouse-drag was a dead no-op in 3D (wrote to the unused `view.x/y` instead of `orbit.ox/oy`, then snapped the view on release). Fixed all three: `retargetOrbitPivot()` re-centers the pivot on whatever's under the cursor (a real point, or the ground plane at the pivot's elevation) at the start of every orbit drag, with zero visual jump — ⊡ Fit still resets to the whole-site pivot; `zoomOrbit()` replaces the recenter-on-pivot zoom with a proper zoom-about-cursor (matching the existing 2D behavior); middle-mouse-drag now actually pans `orbit.ox/oy` in 3D, with `preventDefault()` so the browser's native autoscroll cursor stops fighting it. See the dedicated section below for the full writeup and verification (numeric proof of the projection algebra, plus real headless-browser end-to-end tests against the actual `index.html` code paths — this repo has no sample `.fbk` on hand, so synthetic large-span point data was used instead). |
    | 81 | 🍐 PEAR | new **❓ Help** button (top toolbar, always enabled — works even with no file loaded) opens a reference modal with 4 tabs: **Getting Started** (load/import → view/edit → Knockdown/UGW→CPN → export, plus the 2D/3D/MAP/Labels view controls), **Tools** (every top-toolbar button, every canvas tool, the full keyboard-shortcut list, and mouse/touch gestures — all pulled together from text that already existed scattered across button `title=` attributes and the inspector's `.note` div, not re-invented), **Description-Key Codes** (B/E/CLS, BC/EC, PCC/PRC, OC, CIR, H/V, SO, RT/X/RECT, CPN/RPN, REF, PRISM — one row each, matching this file's own documented behavior for each), and **Curb Database** — every code in the app's actual `CURB_BOC`/`CURB_FL` objects (70 each) rendered as a card showing its real H/V step string, `CURB_KD`'s 12 knockdown-reveal values shown as a badge on the matching back-of-curb cards, plus a live filter box (`#helpCurbSearch`) — generated straight from those live JS objects (`curbCardsHTML`) rather than a hand-copied second list, so it can never drift out of sync with what Knockdown actually expands a code into. Modal styling reuses the existing `.modal`/`.scrim` pattern already used by every other dialog in the app; tab-switching is a small `setHelpTab()` toggling `.on` on one of 4 panes. Closes via **✕**, a backdrop click, or **Esc** — the letter-key tool shortcuts (`v`/`m`/`p`/`z`/`o`/`i`/`c`/`a`/`f`/`g`) are now also suppressed while the Help modal is open (added to the same guard the Go-to-point modal already used), so e.g. pressing **O** to read the "O = 3D orbit" shortcut row doesn't actually switch the canvas to orbit underneath the modal. Verified end-to-end through the real UI in a real headless browser: the button works with zero points loaded; all 4 tabs render (Tools: 14 toolbar rows / 11 canvas-tool rows / 14 key rows; Codes: 15 rows); the Curb Database tab's card counts (70 BOC, 70 FL, 12 KD-badged) match the real `CURB_BOC`/`CURB_FL`/`CURB_KD` object key counts exactly (cross-checked independently via a regex key-count over the raw source); typing "624" into the filter box correctly narrows the 70 BOC cards down to the 2 real matches (`L624`/`R624`) and clearing it restores all 70; Esc and backdrop-click both close it; pressing **O** while the modal is open leaves `mode` at its pre-open value instead of switching to orbit; and opening/closing the modal around a synthetic load+edit+`buildLinework()` cycle produced the correct figure count with zero console errors. |
    | 82 | 🍉 WATERMELON | new **⏮ Un-Knockdown** button — the owner asked for a way to convert a baked H/V curb offset back to its code, leaving anything unrecognized alone. Built as the structural inverse of `applyKnockdown()`, gated by the same RBCB/RCFL marker precondition, with two tiers: (1) any point knocked down THIS session restores its own literal pre-knockdown line via `p.kdInfo` (already tracked since build 11's review-window toggle, just never used for a permanent revert before) — exact, including a REF-derived custom reveal a bare code alone could never reproduce; (2) any other RBCB/RCFL point's baked H/V run is reverse-matched against `CURB_BOC`/`CURB_FL` by exact template string, and converted back to the bare code ONLY when that string is unique to one code. Checked the databases directly: `RD`/`RDPRK` and `LD`/`LDPRK` share an identical template in BOTH tables, so those (and anything with no match at all) are deliberately left untouched rather than guessed at — matching this project's standing rule (build 40/47/49) against guessing at what field data doesn't disambiguate. Reports the outcome afterward in a 3-section modal (`#unkdReportScrim`) — restored / converted / left-untouched, each listing the point IDs (and, for the untouched section, the exact H/V text that didn't safely match) — so "left untouched" is visible, not silent. Verified end-to-end through the real UI in a real headless browser with a synthetic file exercising all 4 cases at once: a session-knocked-down explicit-code point restored byte-exactly; a session-knocked-down REF-derived point (custom reveal) restored byte-exactly (proving the two-tier design, since no bare-code reverse-match could ever have produced this); a point with no `kdInfo` carrying an exact, unambiguous `L612` template converted correctly to `RBCB L612`; a point carrying the ambiguous `RD`/`RDPRK` shared template stayed untouched; a point with a nonsense H/V run stayed untouched; the report modal listed all 5 correctly (2 restored / 1 converted / 2 untouched); Esc and a real button click both closed it; and running Un-Knockdown a second time on the now-reverted file was a confirmed no-op (idempotent). Also re-verified through real toolbar-button clicks (not poked state) alongside Knockdown and the Help modal in the same session with zero console errors. |
    | 83 | 🍎 APPLE | **3D view point/line editing unlocked** — the owner: "WHEN IN VIEW 3D AND SEL PION OR LINE MAKE ITT THE I CAN EDIT IN THAT VIEW." 3D orbit mode had been treated as strictly read-only in the single-point Inspector and the multi-select panel since the feature existed — `inspect()` disabled every field (`fDesc`/`eId`/`eN`/`eE`/`eZ`/`eHA`/`eSD`/`eZA`/`eRod`) with `${is3D?'disabled':''}` and swapped the Apply/Delete buttons for a dead `<div class="warnbox">3D inspect mode — switch to a 2D tool to edit.</div>`, and `inspectMulti()` did the same swap for its Delete/Restore/Clear buttons — none of that gating had a real technical reason behind it, since `applyPointEdit()`/`toggleDel()`/`multiDelete()` (the actual functions that mutate point data) never reference `is3D` at all and always operated purely on the point object passed in. Investigating **`inspectFig()`** (the figure/line editor) first showed it was ALREADY fully editable in 3D with no gating whatsoever — vertex reorder, remove, code edits, the "render as NEZ" checkbox, zoom-to-point, Street View, all worked identically in both views — so the real gap was narrower than the request first suggested: only the single-point and multi-select panels were blocking edits. Fix: removed every `${is3D?'disabled':''}` from both `inspect()` branches (control-point and shot-point), removed the `warnbox` ternary in favor of always rendering the Apply/Delete `chgrp` with a note that now reads "...${is3D?' Editable here in 3D too — dragging to move a point still needs a 2D tool.':''}" instead of blocking edits outright, and removed the `if(!is3D){...}` wrapper around the Apply/Delete/Enter-key handler wiring so it always runs; did the same for `inspectMulti()`'s Delete/Restore/Clear wiring. **What deliberately stays 2D-only, and why:** dragging a point to a new position (2D-only object-snap-driven drag, no 3D equivalent), and the three canvas-click "insert a brand-new point" flows (Insert point on line, Add Point (COGO) → Pick on canvas, ⊙ CTR circle-center picking) — all three depend on 2D-specific object-snap math (`snapPoint`/`pickSegmentForInsert`) with no valid 3D projection-inverse equivalent, exactly the same reasoning build 30 already used to keep those flows 2D-only for the Zoom-window tool. Editing an EXISTING point's own N/E/Z by typing a new value directly into the Inspector's fields, however, needs no canvas geometry at all — it's a plain textbox edit into `applyPointEdit()`, identical in both views — so there was no reason it had ever been disabled in 3D. Updated all three help surfaces that had documented the old restriction so none of them now say something the app itself no longer does: the Inspector's own empty-state note, the Help modal's **Getting Started** tab 3D bullet, and `HELP_CANVAS_TOOLS`'s `'⟲ 3D'` row (confirmed via grep that no "inspect only"/"3D inspect mode"/"switch to a 2D tool" text remains anywhere in the file). Verified end-to-end through a real headless browser two ways: (1) a poked-state sweep (`test_3dedit.js`) confirming every field's `disabled` property reads `false` in 3D for both a control point and a shot point, the Apply/Delete/Restore buttons are present with no `warnbox`, an edit typed into a 3D-rendered field and applied via the real Apply button actually changes `p.desc`/`p.E` on the underlying point object, deleting/restoring via the 3D Delete button actually flips `p.deleted`, the figure editor's reverse-order button is present in 3D (confirming `inspectFig` needed no changes), and a multi-select Delete click in 3D actually removes the expected count of points — all with zero console errors; (2) a real-UI sweep (`test_3dedit4.js`) that clicks the actual `#tOrbit` toolbar button to enter 3D, computes a real point's on-screen position via the app's own live `P3()` projection, drives real `page.mouse.move/down/up` events at that exact pixel (a single `page.mouse.click()` proved unreliable for the canvas's pointer handlers in earlier build-80 testing, so the same move/down/up sequence that worked there was reused here), types into the real `#fDesc` input, and clicks the real `#applyEdit`/`#delBtn` buttons — confirming the point's descriptor and deleted-state changed correctly through the actual UI in 3D, not just through poked JS state, mirroring the same edit already proven to work through the real UI in 2D in the same test run. |
    | 84 | 🍇 GRAPE | **REF shots get commented out on export, invisible to CAD but still usable by the app** — the owner: "when export the ref shoot get deleted by comment out but not visible to cad but i want if visible to the app to use aging for knockdown use if ref happen to be muitl code shoot leave it alone." Read as: a REF point exists only to give Knockdown a reveal to measure from (see the "Knockdown behavior" section above) — CAD never needs to see it as a real point, but this app has to keep reading it fine on the next load so Knockdown keeps working. A REF point that's also doing double duty as part of another code ("multi code shoot") is a real point CAD needs for that other purpose, so it's left completely alone. Added a shared `REF_HIDE='-- '` marker and `isPureRefDesc(desc)` (true only when the description is NOTHING BUT a bare `REF`/`REF1`/... token — one whitespace token, no other code riding along). `exportFBK` gets a new pass (2d, positioned last among the per-line content steps, right before assembly) that prefixes a pure REF shot's line with `REF_HIDE` — any FBK/CAD reader only recognizes specific keyword lines (`NEZ`, `F1`/`F2 VA`, `STN`, …) and silently skips anything else, the exact same assumption this app's own "Deleted `<stamp>`" archive marker for deleted points already relies on — while a multi-code REF line is left byte-identical. Running last (after figure/reorder/added-point steps) means it judges purity off whatever description the line ACTUALLY ends up with, not the point's own `p.desc` in isolation — if build 2b ever grafts a figure code onto a REF point pulled into someone else's linework, that line correctly stays visible even though `p.desc` itself is still bare `"REF"`; the reverse also runs — a REF point that was hidden in an earlier export but has since become multi-code this session gets its marker stripped again so CAD sees it. `parse()` gained a `deHide()` step that strips a leading `REF_HIDE` before tokenizing any line (so `t[0]` checks against `NEZ`/`STN`/`BS`/`PRISM`/`F1`/`F2` all still match normally) and tags the resulting point `refHidden:true` — the point parses EXACTLY like it would with no marker at all (same N/E/Z/desc, same eligibility as a Knockdown REF source), so a re-exported/re-loaded job file round-trips cleanly and Knockdown keeps finding it. `finalLine(p)` (used whenever an edited point's line is rebuilt for export, e.g. a Rod HT correction) also had to become marker-aware: it previously tokenized `RAW[p.srcLine]` directly, so a hidden REF line's leading `--` token would shift `t[1]` off `'VA'` and silently skip the HA/SD/ZA rebuild — it now strips `REF_HIDE` before tokenizing and re-applies it after, so editing a hidden REF point's coordinates/rod height still exports a correctly-formed, still-hidden line. Standalone COGO/CSV-imported REF points (`srcLine<0`) get the same treatment in the step-3b fresh-`NEZ` dump. Verified end-to-end in a real Node `vm` sandbox running the actual `index.html` script (no sample `.fbk` job file is checked into this repo, so synthetic points were used, same as build 80): a pure `"REF"` shot exports with the `-- ` marker while a `"REF RCFL1 B"` multi-code shot on the same file exports completely untouched; a plain uncoded `RBCB` point near the hidden REF still gets correctly knocked down from it (`v` derived from the REF's Z, matching pre-existing Knockdown behavior exactly); re-parsing the exported text recovers a clean `"REF"` description flagged `refHidden:true` and re-exporting produces byte-identical output (idempotent, no double-marking); correcting the hidden REF point's rod height and re-exporting keeps the `-- ` marker AND correctly rebuilds the `F1 VA` line's HA/SD/ZA fields (confirming the `finalLine` fix); a standalone `srcLine:-1` pure-REF point gets hidden in the step-3b `NEZ` dump while a standalone multi-code one on the same export does not, and the hidden one round-trips through reload exactly like the setup-shot case. Script parses clean (`node --check`) with the change applied. |
    | 85 | 🍋 LEMON | **fix `⊕ Click line to insert point` mis-anchoring the new point's exported position — the owner: "when instin[g] point along the line...the point must be insert in betwe[e]n the two point[s] otherwise it attach[es] to [a] different line."** Root cause was in `exportFBK`'s step 2b (positioning a `figExtra`-added point in the exported file) — it anchored the new point's `NEZ` line on `next.srcLine` (place it right before whichever real point follows) whenever a `next` existed, only falling back to `prev.srcLine+1` (right after the point before it) when there wasn't one. Two real bugs fell out of that: (1) **silent data loss on a chained insert** — insert a second point between the first inserted point and the original next point, and that first point's own `next` is now the SECOND inserted point, which has `srcLine=-1` (no file position of its own, being synthetic) — `next.srcLine` evaluated to `-1`, and the assembly loop (`for(let L=0;L<RAW.length;L++)`) never visits a negative index, so that `nezBefore[-1]` entry was silently never written to the file at all; worse, its point id still got recorded into `alreadyNEZ` (built by scanning `nezBefore`'s VALUES regardless of key), so the step-3b end-of-file safety net skipped it too, thinking it was already handled — reproduced this exact drop with a standalone repro of the export logic (`test_insert_export.js`, chained insert of points A then B between two real points: old code exported B but silently dropped A entirely). (2) **the literal "must be between the two points" complaint** — even a single (non-chained) insert placed the new bare-code `NEZ` line immediately before `next`'s own line, which in real field data is very often NOT immediately after `prev`'s — real files interleave unrelated points/setups between two points the app considers figure-adjacent (this project's own build-47 already documented exactly this pattern) — so the new point's line could land deep inside a gap containing a DIFFERENT, still-open run of the SAME figure code, and CAD (which stitches figures purely by encountering a code in file sequence) would silently extend THAT other run instead of the one actually clicked. Fixed by always anchoring on the NEAREST REAL (file-backed, `srcLine>=0`) neighbor, walking outward past any synthetic (`srcLine<0`) neighbors first, and always placing right after that real predecessor (`prev.srcLine+1`) rather than before the successor — this guarantees zero content of any kind (let alone another run of the same code) can ever land between the anchor point's own line and the new point's line. Falls back to `next.srcLine` only when there's no real predecessor at all (the new point is the very first vertex), and to nothing (leaving it for step 3b's existing end-of-file safety net) only when NEITHER neighbor has a real file position (an entirely COGO-built line) — so a point is never silently dropped in any case, matching this project's own "never drop it" precedent from the CSV/COGO safety-net section. Also switched from iterating `figExtra[id]`'s own array (chronological click order) to iterating the figure's real, final `ord` vertex array in left-to-right position order, so multiple points chained into the same segment always emit in correct visual order regardless of the sequence they were clicked in. Verified with a standalone before/after repro of the exact export algorithm (`test_insert_export.js`): the chained-insert case that silently dropped one point under the old code now emits both, correctly ordered between the two real anchor points; a single-insert case with unrelated content between the two real points now lands the new point immediately adjacent to its real predecessor with zero interposed content, vs. the old code landing it several lines away, across the unrelated gap. `index.html`'s inline script still parses clean (`node --check`) after the change. |
    | 86 | 🥭 MANGO | **fix Knockdown missing curb codes on a multi-coded point, and ask REF-vs-Standard when a curb code has a REF nearby — the owner: "FINE TUNE RBCB REF KNOCKDOWN SOME ARE GETTING MISSSED MAKE SURE GRAB ON PIONT WITH MUILI CODED RBCB3 E R606 RBCB1 B BC R624 MAKE IT THAT REF IS NEAR PIONT WTH CURB CODE THAT ASK THE USER WHICH TO USE REF OR STANDERD."** Two real bugs, both from `applyKnockdown` treating each POINT as having at most one curb code, when the vendor field format lets one point carry SEVERAL — e.g. the owner's own worked example, a single corner point ending an `RBCB3` run (own code `R606`) and beginning an `RBCB1` run (own code `R624`) in the same description. (1) **Missing codes**: `code=null;p.desc.split(/\s+/).forEach(t=>{if(CURB_BOC[T]\|\|CURB_FL[T])code=T;})` kept only the LAST matching code token found anywhere in the whole description — for the example above that's `R624`, silently discarding `R606` with no report, no error, nothing — confirmed directly: the pre-fix code baked only `R624`, leaving `R606` as literal untouched text in the exported description. The same collapsing also meant a point with one segment ALREADY knocked down (has H/V) and one still-bare segment got skipped ENTIRELY, since the "already baked, skip" check (`/\sH-?\d+\.?\d*\s+V-?\d+\.?\d*/.test(p.desc)`) bailed on the WHOLE point the instant ANY H/V text existed anywhere in it. (2) **REF always silently overridden**: a point's own curb code always won over a nearby REF with zero visibility — reasonable when there's no REF nearby (nothing to choose between), but the owner asked for a real choice when a REF point genuinely sits near a coded point. Fix: `applyKnockdown` now finds every `RBCB\d*`/`RCFL\d*` MARKER TOKEN in a point's description and processes each one's own SEGMENT (that marker's tokens up to the next marker or the end of the description) completely independently — its own code lookup (scoped to just that segment, so `R606`'s segment and `R624`'s segment each find their own code correctly), its own "already baked" check (scoped to just that segment, so a mixed already-baked/still-bare point now correctly processes only the bare one), and its own REF-in-range decision. A BOC (`RBCB`) segment that has its own code AND a REF point within the existing 1.2 ft search radius is now flagged **ambiguous** instead of auto-applying — if ANY segment across the whole run comes up ambiguous, a new **Knockdown — REF or Standard?** review modal (`#kdReviewScrim`, styled like the existing UGW→CPN review popup) opens BEFORE anything is written, listing each ambiguous point/code with a radio choice (`Standard` — pre-checked, matching the old always-std behavior as the default — or `REF <id>` with its computed `v` and distance shown); every OTHER, unambiguous point/segment in the same run still bakes automatically the moment **Apply** is clicked, alongside whichever choice was made for the ambiguous ones — **Cancel** aborts the entire run, nothing is written, matching the "nothing applied until confirmed" contract the UGW review already established. RCFL segments are NEVER offered this choice (unchanged — REF is documented as a back-of-curb-only workflow); a bare marker segment with no code of its own still derives its reveal from the nearest REF exactly as before, no ask, since there's no "standard" to choose between there either. `p.kdInfo` (used by Un-Knockdown's session-restore tier) now stores every code baked on a multi-segment point as a comma-joined list (`"R606, R624"`) instead of a single code — `.orig` (the byte-exact pre-knockdown description, the only field Un-Knockdown's actual restore logic reads) is completely unchanged, so session-restore still round-trips exactly. Verified end-to-end through the real UI/DOM in a real headless browser (radio clicks and the Apply button clicked for real, not poked state), plus a battery of scripted scenarios run against the live `applyKnockdown`/`commitKnockdown`/`buildLinework`: the owner's own exact multi-coded example (`"RBCB3 E R606 RBCB1 B BC R624"`, no REF nearby) now bakes BOTH codes correctly in one pass with zero popup; the same point with a REF placed at the shared location correctly flags BOTH segments ambiguous (since both sit at the same physical point) and applies each one's own chosen template; a point with one segment already baked and one still bare now correctly leaves the baked segment byte-identical and bakes only the bare one (previously the whole point was skipped); a plain single-code RBCB point with its own code and a nearby REF opens the review, leaves the point completely untouched until Apply, defaults to Standard, and produces byte-identical output to before this build when Standard is chosen or picked apart correctly (verified the exact REF-derived V-values) when REF is chosen instead; Cancel leaves the point byte-identical; a bare-marker REF-derived point (no own code) and an RCFL point with its own code both continue to apply automatically with **no popup**, even with a REF sitting right next to them, confirming the ask is scoped exactly to "BOC segment with its own code AND a REF in range," nothing broader; an RCFL point with no code is still left completely untouched; running several points in one Knockdown pass with only one of them ambiguous correctly applies the unambiguous ones the moment Apply is clicked, alongside the chosen one; and Un-Knockdown's session-restore tier still recovers the exact original multi-coded description byte-for-byte after a multi-segment bake. `index.html`'s inline script still parses clean (`node --check`) after the change; zero console errors beyond the pre-existing, already-documented map-tile network block. |
    | 87 | 🍌 BANANA | **fix the build-86 Knockdown REF-vs-Standard review modal rendering as a stack of blank lines — the owner sent a screenshot of exactly that (a long column of thin, empty-looking rows) and: "REF point within range now opens a review popup SHOW ON LINES."** Two real, independently-confirmed bugs, both purely visual (the underlying row data was always correct — confirmed the full radio/label HTML was genuinely present in the DOM, just not rendering visibly): (1) **the global `.modal input{width:100%;background:var(--panel2);...}` rule** (written for the app's plain text fields in dialogs — Go to point, Add Point, etc.) also matched the review's `<input type="radio">` elements, since it targets every `<input>` inside `.modal` with no type qualifier — stretching each radio to 100% of the row's width and recoloring it to the same dark panel background as everything around it, which visually swallowed the label text off to the side and made the whole row read as one flat, empty-looking bar. (2) **a classic CSS flexbox min-size gotcha**: `#kdReviewList` is `display:flex;flex-direction:column;max-height:52vh;overflow:auto` (the same pattern the build-69 UGW→CPN review list already uses) — when a real job file produces enough ambiguous points that the rows' total height exceeds that 52vh cap, flexbox's default automatic minimum size (which normally stops a flex item shrinking below its own content height) is *disabled* on any flex item whose own `overflow` isn't `visible` — and `.vrow` (the shared row class both review modals use) has always set `overflow:hidden`. With that protection gone, every row got forcibly shrunk to fit inside the container instead of the container scrolling, collapsing each down to roughly just its header line, with the actual radio-choice content still present in the DOM but clipped away by that same `overflow:hidden` — reproduced this exactly with a synthetic 15-row scenario and a real screenshot showing the identical "blank thin lines" pattern the owner reported, then confirmed via `getBoundingClientRect()` that a `.vrow`'s own rendered height (24.7px) was genuinely SMALLER than its child `.fbk` content's natural height (50px) — proof the child was being clipped, not just visually cramped. This is a **latent, pre-existing bug in the shared `.vrow`/review-list pattern**, not something new to build 86 — the build-69 UGW→CPN review would hit the identical collapse under the same condition (enough rows to overflow 52vh), it just never happened to get tested with that many rows before. Fix: added `.modal input[type=radio],.modal input[type=checkbox]{width:auto;height:auto;background:none;border:none;padding:0;text-align:left;accent-color:var(--gold)}` (a targeted override, scoped by attribute selector so it only ever affects radio/checkbox inputs, leaving the original text-field rule untouched for every existing text input in every modal) and added `flex-shrink:0` to the shared `.vrow` class — the second fix is the one that actually resolves the "too many rows" case generally, for both this review and the UGW→CPN one, by making the flex container do what `overflow:auto` was already meant to do (scroll) instead of silently crushing its children. **The "SHOW ON LINES" half of the request** — read as wanting each ambiguous point's own figure/line visible in the list, not just its bare point number, especially useful now that a real file can produce many rows across many different lines — added via `figuresOfPoint(PTS.indexOf(row.p)).map(f=>f.code)`, rendered as a small tag next to the point id/code (e.g. `pt 100 — R624` with an `RBCB1` badge), or `no line` for a point that isn't part of any figure. Verified end-to-end in a real headless browser: a synthetic 15-point, 3-different-figure scenario (mirroring the shape of the owner's real report) now renders every row fully — point id, code, figure-code badge, and both clearly legible, correctly-sized radio choices with real text — confirmed via both a full-page screenshot (visually matches the intended design, no more blank lines) and `getBoundingClientRect()`/`getComputedStyle()` checks showing the radio inputs back to their native ~13×13px size and each `.vrow`'s rendered height now matching its actual content height instead of being clipped; the list correctly scrolls past its 52vh cap instead of crushing rows to fit; re-ran the complete build-86 regression battery (`test_kd.js`/`test_kd2.js`/`test_kd3.js`) unchanged and all still pass, including the real-DOM radio-click + Apply-click test, confirming this build changed only rendering, not any of build 86's actual knockdown logic. `index.html`'s inline script still parses clean (`node --check`). |
    | 88 | 🍇 GRAPE | **fix Knockdown "sometimes flip[ping] the offset[] in the opposite direction" — the owner uploaded a real job file (`TOPO_COMBINED_EDITED1_with_missing_REF.fbk`) and reported this after builds 86/87 shipped.** Root cause: the fallback a BARE (no-own-code) RBCB/RCFL segment uses to pick which curb code's cross-section to bake was a single global `lastCode` variable, updated by scanning every point in the WHOLE FILE in plain point order and just remembering "whichever L/R code was seen most recently, going backward" — a heuristic that only works if a file has exactly one continuous run per marker. A real job reuses the same UNNUMBERED `RBCB` marker (no `1`/`2`/... suffix) for dozens of completely unrelated curb runs scattered across an entire site, so that scan routinely walks straight past an older, unrelated run's code and hands it to a bare point that's actually the FIRST shot of a brand-new, different run — whose own explicit code doesn't get stated until a point or two LATER in the same run. Confirmed against the owner's real file exactly this shape at points 3604-3608 (`"RBCB RDRC"` bare → `"RBCB RDRC R024"` ×2 → `"RBCB RDRC"` bare → `"RBCB E"`): point 3604 is the true first shot of this run and has no code of its own, so the old code fell back to `lastCode`, which by file order was still `L624` — left over from a **completely unrelated** `RBCB B L606`...`RBCB E` run over 150 points earlier in the file — while the run 3604 actually belongs to uses `R024`, declared explicitly two points later at 3605/3606. Since `CURB_BOC`'s L/R templates are horizontally mirrored (L uses positive `H` offsets, R uses negative), picking the wrong side's code doesn't just get the depth wrong, it flips the whole cross-section onto the opposite side of the curb — exactly the "flip" the owner described, and only on SOME points (bare ones that happen to fall on the wrong side of a stale global tracker), matching "sometimes." Fix: replaced the single global `lastCode` scan with a two-pass, per-marker-KEY nearest-index lookup. Pass 1 builds `markerCodes` — for every EXACT marker token (`"RBCB"` vs `"RBCB1"` vs `"RCFL2"`, etc. — separate figure instances that should never share a code), the list of every point INDEX where that marker's own segment carries an explicit curb code. Pass 2 resolves each bare segment's `activeCode` via `nearestMarkerCode(key,pi)` — the code from whichever recorded entry of the SAME exact marker key is closest by point-index distance, searched in BOTH directions (not just backward) — falling back to the old hardcoded `R612` only if that exact marker key has no explicit code anywhere in the whole file. This also incidentally fixes a second, smaller latent bug in the old tracker: it updated on ANY `CURB_BOC`/`CURB_FL` match regardless of marker type, so an `RCFL` point's flow-line code could leak into a later bare `RBCB` point's fallback (or vice versa) even though the two use different databases entirely — the new per-key index can't cross that boundary, since `RBCB`'s and `RCFL`'s entries are stored under different keys. Verified with a new synthetic regression (`test_kd_flip.js`) reproducing the exact real-file shape — an unrelated earlier `RBCB B L624`/`RBCB E` run, then a later run whose first point is bare with a REF nearby but whose own code (`R024`) isn't stated until 1-2 points in — confirming the bare points now correctly bake `R024`'s negative-`H` template, not the stale `L624`'s positive-`H` one; then re-ran it directly against the owner's real uploaded file end-to-end (`parse()`→`buildLinework()`→`applyKnockdown()`→`applyKdReview()`), confirming points 3604 and 3607 (the run's two bare points) now bake byte-consistent with 3605/3606's own explicit `R024`, where before this fix 3604 would have baked with the wrong, mirrored `L624` template. Re-ran the full build-86/87 regression battery (`test_kd.js`, `test_kd2.js`, `test_kd3.js`, `test_kd_lines.js`) unchanged and all still pass — none of those synthetic scenarios happened to exercise more than one run per marker key, so this fix changes nothing about their outcomes, only the previously-untested multi-run-per-key case. `index.html`'s inline script still parses clean (`node --check`). |
    | 89 | 🍑 PEACH | **owner still saw flipped offsets after build 88 and asked for a real fix, in their own words: "look at the whole curb," "flag any conflicts for the user on the line," and "look at the beginning of each callout — [it] is carried over [to the] next point until a new callout is introduced, then that is carried over till the end or new callout... apply the ref ajustment based [on] the call out that [is] active on that point."** Build 88's per-marker-key NEAREST-BY-INDEX fallback was a real improvement but still just a silent guess — "nearest wins" happens to be right more often than the old backward-only scan, but it can still be wrong, and the owner correctly noticed it still was, elsewhere in their file. Read the owner's own description as the actual spec: a callout should propagate FORWARD from wherever it's declared until a new one is declared (the "carried over" model) — but since the same unnumbered `RBCB` marker gets reused for dozens of unrelated runs across a real site (build 88's root cause), blind forward-carry alone is exactly what caused the ORIGINAL bug (a stale code from an old, unrelated run leaking into a brand-new run that hadn't stated its own code yet). The fix stops trying to pick ONE heuristic and hope: `applyKnockdown` now computes BOTH candidates for every bare (no-own-code) segment — `forwardMarkerCode(key,pi)` (the nearest EARLIER explicit code for this exact marker key — the owner's own "carried forward" model) and `nearestMarkerCode(key,pi)` (build 88's bidirectional-nearest) — and compares which SIDE (`code[0]`, `L` or `R`) each one implies. If they agree (the common, well-behaved case — a run that already stated its own code somewhere nearby, in EITHER direction, on the correct side), it resolves automatically exactly as build 88 did, no interruption. If they DISAGREE on side, that's a genuine, visible risk of exactly the flip the owner reported — instead of silently picking one, the segment is now flagged as `kind:'sideConflict'` and routed into the SAME `#kdReviewScrim` review modal build 86/87 already built for REF-vs-Standard ambiguity (reusing its per-row figure/line tag from build 87's "SHOW ON LINES" fix, its Cancel-aborts-everything contract, and its "everything unambiguous still bakes the moment Apply is hit" behavior) — each conflict row shows both candidate codes AND which point declared each one (`"Carried forward: L624 — from pt A1"` vs `"Nearest declared: R024 — pt C2"`), pre-checked to **Nearest declared** by default (empirically the safer of the two guesses — a bare point with no code of its own is far more likea start of a run that states its own code a shot or two later than a genuine continuation of a stale, distant, unrelated run — matching what the owner's own real file's conflicts turned out to need). Once resolved (auto or by the owner's radio pick), the REF-derived reveal (`refKdTmpl`) is computed using whichever code actually won — directly answering "apply the ref adjustment based on the callout active on that point." Verified: re-ran the complete build 86-88 regression battery (`test_kd.js`, `test_kd2.js`, `test_kd3.js`, `test_kd_lines.js`) unchanged, byte-identical results — none of those scenarios ever had a forward/nearest disagreement, so nothing about them changed. The build-88 synthetic repro (`test_kd_flip.js`, mirroring the exact real-file shape: an unrelated earlier `RBCB B L624` run, then a new run whose first point is bare with forward-carry landing on the wrong `L624` while the nearest declared code is the correct `R024`) now correctly OPENS the review modal instead of silently resolving — confirming build 88 alone would have kept guessing silently on cases just like this one, exactly the owner's complaint. A new synthetic test (`test_kd_conflict.js`) confirmed the modal renders both real candidate codes and source points, defaults to **Nearest declared**, and applying with that default produces the correct `R024` (negative-`H`) template on both affected points — not the mirrored `L624`. Re-ran directly against the owner's real uploaded job file end-to-end: it now surfaces exactly **3** side-conflict rows out of the whole file (points 3604, 3539, and 5643 — a small, reviewable number, not noise) alongside the pre-existing 70 REF-vs-Standard rows; applying with the default (Nearest declared) choice correctly bakes point 3604 with `R024`'s negative-`H` template, matching points 3605/3606's own explicit code — the exact point build 88 got wrong when applied blind, now correct by default AND visibly flagged for review rather than silently resolved either way. `index.html`'s inline script still parses clean (`node --check`). |
    | 90 | 🥝 KIWI | **owner: "add funtion un-knckdown tool Left untouched...(253) part add way for the user option for de[le]t[e] and order it be piont numbe[r] and for the sort code to the bottom of the list also make it easy to c[o]ntrl and sh[i]ft bulk selet[t] .and all ref vs stand[ar]d defult to ref [to] be per selected."** Two separate, real usability gaps on a big real job file, both fixed: (1) **Un-Knockdown's "Left untouched" list was pure read-only text** — the owner's own real file produces 253 such points (baked H/V runs that don't safely reverse-match one curb code, e.g. the documented `RD`/`RDPRK` shared-template case), and there was no way to act on any of them short of hand-editing raw FBK. `showUnKdReport` now builds a live, interactive list (`unkdSkipCtx`) instead of a static `<table>`: **Sort: Point #** (default, numeric-aware via a new shared `numCmp`) and **Sort: Code (H/V)** buttons re-order the list on click; each row gets a checkbox supporting **ctrl-style independent toggling and Shift-click range-select** (tracks `lastId`, the same pattern used below for the Knockdown review list); **Select all** / **Clear** convenience buttons; and a **Delete selected** button that bulk-sets `.deleted=true` on exactly the checked points (reusing the app's ordinary delete semantics — archived as `Deleted` on export, not silently discarded) and removes them from the live list immediately, with the button's own label showing a live count (`Delete selected (N)`). Skipped-point entries now carry their own `p` reference (`skipped.push({id,hv,p})` in `revertKnockdown`) so the delete action has something real to act on. (2) **The Knockdown REF-vs-Standard review list had no bulk actions at all** — on a real file with dozens of ambiguous rows (the reported file has 70), choosing REF or Standard meant clicking every single radio one at a time. `renderKdReviewList` gained the identical checkbox + ctrl/shift-range-select pattern as the new Un-Knockdown list, plus a small toolbar (**Select all** / **Clear** / **Set REF** / **Set Standard**) — `kdReviewSetChoice(val)` applies the chosen value to every SELECTED row whose `seg.kind==='ambig'` (a selected `sideConflict` row is silently skipped, since "REF vs Standard" isn't a concept that applies to a carried-forward-vs-nearest-declared choice) and re-renders so the radios reflect the bulk change immediately — this is the literal "ref vs standard ... to be per selected" ask: a bulk choice scoped to whatever's currently checked, not a single global default toggle. (3) **The actual per-row DEFAULT also changed**, per "all ref vs standard default to ref": a fresh `ambig` segment now starts with `choice:'ref'` instead of build 86's original `choice:'std'` — so a real file's ambiguous rows open already leaning toward the (now believed more useful) REF-derived reveal, with Standard still one click (or one bulk "Set Standard") away. Verified end-to-end through the real UI (real clicks, real Shift+click held via `page.keyboard.down('Shift')`, not poked state) with two new test scripts: `test_kd_bulk.js` — 5 synthetic ambiguous points all default to `ref`; clicking checkbox 0 then Shift-clicking checkbox 2 selects exactly rows `[0,1,2]`; **Set Standard** flips only those 3 to `std` leaving rows 3/4 untouched at `ref`; **Select all** + **Set REF** flips all 5 back to `ref`; Apply then bakes all 5 points with the REF-derived (not Standard) template, confirming the bulk path feeds the same `commitKnockdown` as before. `test_unkd_bulk.js` — 4 synthetic points sharing the ambiguous `RD`/`RDPRK` template, ids given out of numeric order (`300,100,200,50`) to prove the sort is genuinely numeric-aware, not string sort (`50,100,200,300` confirmed, not `100,200,300,50`); **Select all** shows `selected.size===4` and the button label updates to `Delete selected (4)`; clearing then checkbox-0-then-Shift-checkbox-2 selects `{50,100,200}`; clicking **Delete selected** flips exactly those 3 points' `.deleted` to `true` (point `300` confirmed still `false`) and the live list correctly shrinks to just `[300]`; **Sort: Code (H/V)** re-renders cleanly on the now-1-row list with no error. A real headless-browser screenshot (`unkd_bulk_screenshot.png`) of a real click on one checkbox shows the row checked, the correct point-number sort order, and **Delete selected (1)** reflecting the live count. Re-ran the complete build 86-89 regression battery (`test_kd.js`, `test_kd2.js`, `test_kd3.js`, `test_kd_lines.js`, `test_kd_conflict.js`, `test_kd_flip.js`, `test_kd_real.js`, `test_kd_real_count.js`) — all still pass; the only intentional output change anywhere in that battery is `test2b`'s default choice reading `ref` instead of `std` (updated `test_kd.js`'s own already-known-checked default, not a regression) since that's exactly the new default this build ships. `index.html`'s inline script still parses clean (`node --check`). |
    | 91 | 🥭 MANGO | **fix build 90's own "Delete selected" button on Un-Knockdown's "Left untouched" list — the owner: "FIX Un-Knockdown's 'Left untouched' list IT DELETING THE LINE IT .IT SOULD ONY DELETS THE CODE NOT THE LINE. ON SIDE NOTE ADD ABLITY TO SELCET DELETED NODE TO OPTION TO RESOTER SELECT."** Build 90's `unkdSkipDeleteSelected()` set `p.deleted=true` on every selected row — the app's general "remove this whole survey shot" flag, archived as `Deleted <stamp>` on export — when the actual situation ("this point's baked H/V run doesn't safely reverse-match one curb code") never called for removing the point at all, only its unresolved offset text. A real point/shot with real N/E/Z getting archived out of the job just because Knockdown's REVERSE lookup couldn't identify its old code is a materially bigger, more destructive action than the list's own premise justified — the same over-eager mistake this project's standing rule (never guess/over-act on ambiguous data — flag or do the minimal safe thing) already argues against elsewhere. Renamed to `unkdSkipClearSelected()`: it now re-runs the exact same `hvRe` regex `revertKnockdown()` itself uses to find the baked H/V run in each selected point's CURRENT description, splices out just that matched substring (leaving whitespace normalized), and writes the result back to `p.desc` — `p.deleted` is never touched. A point's marker token (e.g. bare `RBCB`) and any other code riding along in the same description (confirmed with a synthetic multi-code point, `"RBCB <H/V> RCFL1 B"`) are left completely intact — only the ambiguous offset text disappears, and the point becomes a plain uncoded marker point exactly like one that was never knocked down, still eligible for a future Knockdown pass (own code, or REF-derived) same as any other bare marker point. The toolbar button (`#unkdSkipClearBtn`, was `#unkdSkipDelBtn`) is relabeled **"Clear code"** with an updated tooltip spelling out the point is kept, and its live count label reads `Clear code (N)`. **Side note, a genuinely new feature, not part of the bug fix:** the owner also asked for a way to select currently-deleted points and restore just the selected ones. Added a **Deleted points** section to the same `#unkdReportScrim` modal (populated every time Un-Knockdown runs, from a fresh `PTS.filter(p=>p.deleted)` scan — not scoped to points deleted by any one action) with the identical ctrl/shift bulk-select checkbox pattern (`unkdDelCtx={rows,selected,lastId}`, mirroring `unkdSkipCtx`) plus **Select all** / **Clear** / **Restore selected** buttons; `unkdDelRestoreSelected()` flips `.deleted=false` on exactly the checked points (same `saveState`/`logEdit`/`buildLinework`/`draw`/`flagDirty` convention as the app's existing `toggleDel`/`multiDelete`) and removes them from that section's live list immediately, with the button's own label showing a live count (`Restore selected (N)`). Each row shows the point's id and its current description, sorted numeric-aware by point # via the existing shared `numCmp`. Verified end-to-end through the real UI (real clicks, real Shift-click range-select) with a new test (`test_unkd_clear_and_restore.js`): 4 points carrying the ambiguous `RD`/`RDPRK` template plus a 5th multi-code point (`"RBCB <H/V> RCFL1 B"`) all land in "Left untouched"; selecting all and clicking **Clear code** leaves every one of the 5 points' `.deleted` at `false` (confirmed via `PTS.map(p=>p.deleted)`, all false) while their descriptions correctly reduce to just the bare marker (`"RBCB"` for the plain ones, `"RBCB RCFL1 B"` for the multi-code one — its `RCFL1 B` token survives untouched); separately, 3 synthetic deleted points plus 1 live one confirm the new Deleted points section lists exactly the 3 deleted ones, a real Shift-click range-select (checkbox 0 then Shift-click checkbox 1) selects exactly `{D1,D2}`, and clicking **Restore selected** flips exactly those two back to `deleted:false` while the third (`D3`, never selected) stays deleted and the live one (`LIVE`) is untouched throughout. Re-ran the full existing regression battery (`test_kd.js`, `test_kd2.js`, `test_kd3.js`, `test_kd_lines.js`, `test_kd_conflict.js`, `test_kd_flip.js`, `test_kd_bulk.js`, updated `test_unkd_bulk.js`) — all pass; `test_unkd_bulk.js` was updated in place to click the renamed `#unkdSkipClearBtn` instead of the removed `#unkdSkipDelBtn` and to assert `.deleted` stays `false` (was `true`) after the action — the only intentional behavior/assertion change in that suite, matching exactly what this build fixes. `index.html`'s inline script still parses clean (`node --check`). |
    | 92 | 🍐 PEAR | **fix a genuinely new "curb flipping" mechanism the owner found in a real COMBINED multi-site job file (`TOPO_COMBINED_-_EDITED-BUG.fbk`, spanning 8 separate site chunks — Arundel/Avon/Dale/Hamline/Lexington/Pascal/Ravoux/Western — concatenated into one FBK) — owner: "19756 t[h]ru 19807 flipping happens after knocking down."** Confirmed the owner's report against their real file (they'd earlier reported a mess without it; once the actual file arrived, I reconstructed their exact screenshot viewport point-for-point and found the RAW render clean — the flip only appeared, as they said, AFTER running Knockdown). This file has **zero** curb-code shorthand anywhere (checked all 70 real `CURB_BOC` keys against the whole file) — every curb cross-section is typed as literal `H<v> V<v>` by the crew — so build 88/89's marker-key fallback (`forwardMarkerCode`/`nearestMarkerCode`, "borrow the L/R side from wherever this same marker key states an explicit code elsewhere") had **nothing to borrow from, anywhere, for the entire file**: the bare (no-own-code) `RBCB` marker (no digit suffix) never has an explicit code stated ANYWHERE across any of the 8 concatenated sites. Both builds' fallback silently hit the one hardcoded catch-all, `'R612'`, every single time — confirmed directly: of 140 bare-`RBCB`-with-nearby-REF points that Knockdown baked in this file, **100% landed on the exact same negative-H (R612) template**, regardless of which of the 8 physically unrelated sites (and which real side of the road) each one was actually on — a coin-flip made the same way every time is guaranteed wrong for roughly half of them, which is exactly "flipping" from the owner's point of view (real crew-typed H/V elsewhere in this same file has both signs, so the true answer genuinely varies). Build 89's `sideConflict` detection couldn't catch this either, since `forwardMarkerCode`/`nearestMarkerCode` didn't merely *disagree* here — they were both simply `null` (nothing declared at all), so there was never a disagreement to flag. Fix: `applyKnockdown` now distinguishes this case explicitly (`!fwd&&!near` → a new `noSide:true` flag) from an ordinary sideConflict, and a bare BOC segment hitting it is routed into the SAME `#kdReviewScrim` review modal as a new `kind:'noSide'` row — a plain **Left**/**Right** radio choice (computed via a new `mirrorCode` swap on whichever hardcoded family, `612`, the old fallback already used, so nothing about the code FAMILY changes, only that the SIDE is now asked instead of guessed), pre-checked to **Right** (the old, silent, always-R612 default) so nothing changes for anyone who never opens this new row — it's now just visible and overridable instead of blind. Also added matching **Set Left** / **Set Right** bulk buttons next to the existing Set REF/Set Standard (`kdReviewSetChoice` generalized to route `'L'/'R'` to `noSide` rows and `'ref'/'std'` to `ambig` rows), since a real combined file can produce a LOT of these — this exact file surfaces **211** `noSide` rows. Verified end-to-end: re-ran the existing single-site regression file (`job.fbk`, the one used throughout builds 86-90) end-to-end and got the byte-identical **70 ambig + 3 sideConflict + 0 noSide** rows as before — confirming the new detection fires ONLY for the genuinely-unresolvable combined-file case, not for an ordinary single-site file where the marker key already has something to borrow from; on the owner's real bug file, applying with every row left at its default **Right** reproduces the exact old (build-91) baked output byte-for-byte (proving zero silent behavior change for anyone who ignores the new rows), while picking **Left** for a real flagged point (`19756`) correctly flips it to the positive-H template; a synthetic 3-point test confirmed **Set Left** (after Select all) flips all 3 rows and Apply bakes the positive-H template on all 3. `index.html`'s inline script still parses clean (`node --check`). |
  - Suggested next fruits to rotate through:
    🍉 WATERMELON, 🍇 GRAPE,
    🍎 APPLE, 🍌 BANANA.

## Knockdown behavior (⚙ button → `applyKnockdown()`, per-marker-segment + REF-vs-Standard ask build 86, per-marker-key code fallback build 88, forward-vs-nearest L/R conflict flagging build 89, REF-default + bulk-select review build 90, unknown-side ask build 92)

- Knockdown processes each **RBCB\d\*/RCFL\d\* marker in a point's description
  independently** — a point can carry more than one (e.g. a corner point
  ending one run and beginning another in the same description, like
  `"RBCB3 E R606 RBCB1 B BC R624"`) — each marker's own SEGMENT (its tokens up
  to the next marker or the end of the description) gets its own code lookup,
  its own "already baked" check, and its own bake/ask decision. See the build
  86 entry above for the full writeup of the bug this fixes (a point-level,
  not segment-level, "last code wins" scan that silently dropped every code
  but the last one on a multi-coded point) and the multi-segment verification.
- **RBCB** (rod on back of curb) → uses the **Back-of-Curb DB** (`CURB_BOC`).
  - A segment with its own curb code AND a REF point within range (the
    existing 1.2 ft search radius) now **asks the user** (build 86) — a
    `#kdReviewScrim` review modal lists every such ambiguous point/code with
    a `Standard` or `REF <id>` radio choice, computed v-value and distance
    shown for the REF option — **`REF` is pre-checked by default since build
    90** (was `Standard` in build 86). Every OTHER, unambiguous point/segment
    in the same Knockdown run still bakes automatically the moment **Apply**
    is hit, alongside whichever choice was made for the ambiguous ones.
    **Cancel** aborts the WHOLE run — nothing is written until Apply, same
    contract as the UGW→CPN review popup.
  - **Build 90 — ctrl/shift bulk-select across review rows:** each row gets
    a checkbox; a plain click toggles just that row, Shift-click selects the
    whole range from the last-clicked row to the current one. A small
    toolbar (**Select all** / **Clear** / **Set REF** / **Set Standard**)
    applies a bulk choice to every currently-selected `ambig` row at once
    (`kdReviewSetChoice`) — a selected `sideConflict` row is silently
    skipped, since REF-vs-Standard doesn't apply to a carried-forward-vs-
    nearest-declared choice. Lets a real file with dozens of ambiguous rows
    (the reported job has 70) be resolved a group at a time instead of one
    radio click per row.
  - A segment with its own code and NO REF in range still bakes that code's
    std cross-section automatically, no ask (nothing to choose between).
  - A segment with no code of its own still derives the reveal from the
    nearest **REF** point's Z difference automatically, no ask either (same
    reasoning — no "standard" exists for that segment to choose against).
    **REF is a back-of-curb-only workflow.** Which curb code's TEMPLATE
    (L-side vs. R-side — see build 88 below) that reveal gets baked into
    still has to come from somewhere, since a no-own-code segment has no
    code of its own to pick a side with.
  - **Build 88 — which code a no-own-code segment borrows now comes from its
    own run, not "whatever code was last seen anywhere in the file":** a
    no-own-code BOC segment's fallback code used to be a single global
    "last curb code seen so far, scanning the whole file in point order"
    tracker. A real job reuses the same unnumbered `RBCB` marker for dozens
    of unrelated curb runs across a site, so that scan could hand a bare
    point the L/R code of a completely different, older run — and since
    `CURB_BOC`'s L/R templates are horizontally mirrored, the wrong side's
    code doesn't just get the depth wrong, it flips the whole offset to the
    opposite side of the curb. Fixed by looking up the fallback per exact
    marker KEY (`"RBCB"` vs `"RBCB1"` vs `"RCFL2"`, ...) instead of
    globally: every point where that exact marker's own segment states an
    explicit code is indexed by point position, and a bare segment borrows
    the code from whichever indexed entry of the SAME marker key is
    NEAREST to it (searched in both directions, not just backward) —
    falling back to `R612` only if that marker key has no explicit code
    anywhere at all. See the build 88 entry above for the full root-cause
    writeup and verification against the owner's real reported job file.
  - **Build 89 — nearest-by-index alone was still a silent guess, so a
    disagreeing L/R side is now FLAGGED instead of auto-resolved:** the
    owner kept seeing flipped offsets after build 88 and asked, in their
    own words, to "look at the whole curb," "flag any conflicts," and
    treat a callout as "carried over [to the] next point until a new
    callout is introduced" — with the REF adjustment applied using
    whichever callout is active at that point. `applyKnockdown` now
    computes BOTH `forwardMarkerCode(key,pi)` (the nearest EARLIER
    explicit code for this exact marker key — the "carried forward"
    model) and `nearestMarkerCode(key,pi)` (build 88's bidirectional
    nearest) for every bare segment, and compares their SIDE (`code[0]`,
    `L`/`R`). Agreeing sides → resolves automatically exactly as build 88
    did, no interruption (the normal, well-behaved case). Disagreeing
    sides → the segment is flagged `kind:'sideConflict'` and routed into
    the SAME `#kdReviewScrim` review modal build 86/87 already use for
    REF-vs-Standard, with a `Carried forward: <code> — from pt <id>` vs
    `Nearest declared: <code> — pt <id>` radio choice per row (pre-checked
    to Nearest declared, the empirically safer of the two), same
    per-row figure/line tag (build 87) and Cancel-aborts-everything
    contract. Whichever side wins (auto-agreement, or the owner's pick)
    is what `refKdTmpl` actually bakes the REF-derived reveal with — see
    the build 89 entry above for the full writeup and real-file
    verification (3 flagged conflicts, including the exact point 3604
    build 88 got wrong when applied blind).
  - **Build 92 — a THIRD case, distinct from sideConflict: nothing declared
    for this marker key ANYWHERE in the file, not merely disagreeing.**
    `forwardMarkerCode`/`nearestMarkerCode` both returning `null` (no
    explicit code for this exact marker key exists anywhere at all) used
    to fall straight through to the single hardcoded `'R612'` default —
    silently, with no flag, since build 89's conflict check only fires
    when the two candidates genuinely DISAGREE, and two `null`s can't
    disagree. A real COMBINED multi-site job file (several unrelated
    physical sites concatenated into one FBK) can have the bare,
    unnumbered `RBCB`/`RCFL` marker used across DOZENS of physically
    unrelated curb runs on DIFFERENT sites with an explicit code stated
    for it NOWHERE in the whole file — so every one of them landed on the
    identical hardcoded side, right roughly half the time by chance. Now
    flagged as `kind:'noSide'` and routed into the same review modal as a
    plain **Left**/**Right** choice (the code FAMILY, e.g. `612`, is
    unchanged — only the side is asked instead of guessed), pre-checked to
    **Right** (the old silent default, so nothing changes for anyone who
    ignores the new row) with matching bulk **Set Left**/**Set Right**
    buttons. See the build 92 entry above for the full real-file writeup
    (140 points on one real combined file, 100% landing on the same wrong
    default before this fix) and verification (0 new rows on the existing
    single-site regression file, byte-identical output at the default
    choice, correct flip when Left is picked or bulk-set).
- **RCFL** (rod on flow line) → gets the std **Flow-Line DB** (`CURB_FL`)
  cross-section (full reveal), but **only at a segment that carries its OWN
  curb code** in the description. A flow-line segment with no code is left
  untouched — it does NOT inherit the last-seen code or a default, and is
  **never** offered the REF-vs-Standard choice even if a REF sits nearby —
  REF-derived reveals are a back-of-curb-only concept, unchanged by build 86.

## REF-hide on export (`REF_HIDE`/`isPureRefDesc`, `exportFBK` step 2d, `parse()`'s `deHide()`, build 84)

- A **REF** point exists only to give Knockdown a reveal to measure from (see
  above) — it's not a real feature CAD needs to see. On export, a **pure** REF
  shot (its description is nothing but the bare `REF`/`REF1`/`REF2`/... token —
  one whitespace token, no other code riding along) gets its line **commented
  out**: prefixed with `REF_HIDE` (`'-- '`). Any FBK/CAD reader only recognizes
  specific keyword lines (`NEZ`, `F1`/`F2 VA`, `STN`, `BS`, `PRISM`, ...) and
  silently skips anything else — the exact same assumption this app's own
  `Deleted <stamp>` archive marker for deleted points already relies on — so a
  `--`-prefixed line is invisible to CAD, while the full text (coordinates,
  description, everything) is still sitting right there in the file.
- **A REF point that also carries another code — a "multi-code shot" — is left
  completely untouched, in both directions.** `isPureRefDesc(desc)` is the only
  gate: more than one token in the description (e.g. `"REF RCFL1 B"`) means
  CAD needs this point for that other purpose too, so it's never hidden. If a
  REF point that WAS hidden in an earlier export picks up another code this
  session (making it multi-code now), its `REF_HIDE` marker is removed again on
  the next export so CAD can see it. This check runs last among `exportFBK`'s
  per-line content steps (right before final assembly), specifically so it
  judges purity off whatever description the line actually ends up exporting
  with — not `p.desc` in isolation — in case an earlier step (e.g. an existing
  point pulled into another figure's linework, 2b) ever grafts a code onto a
  REF point's exported text.
- **Still fully usable by the app — the whole point of "commented, not
  deleted."** `parse()`'s `deHide()` strips a leading `REF_HIDE` before
  tokenizing any line, so a hidden line parses EXACTLY like it would with no
  marker at all: same id/N/E/Z/description, same eligibility as a Knockdown
  REF source (`refToken`'s `/^REF\d*$/` test never sees the marker — it's
  already gone by the time a point object exists). The resulting point is
  tagged `refHidden:true` purely so `exportFBK` knows to keep re-hiding it
  (and can tell a hidden line from a plain one when deciding whether to strip
  the marker back off for the multi-code case above). A round-tripped job file
  — export, reload, export again — is byte-identical (idempotent): no
  double-commenting, no lost REF points.
- **`finalLine(p)` had to become marker-aware too.** It's what rebuilds a
  point's line when an EDITED point (a Rod HT correction, a coordinate tweak)
  gets exported — it used to tokenize `RAW[p.srcLine]` directly, so a hidden
  REF line's leading `--` token would shift every subsequent token off by one
  (`t[1]==='VA'` would read `'F1'` instead and miss), silently skipping the
  HA/SD/ZA rebuild. It now strips `REF_HIDE` before tokenizing and re-applies
  it to the result, so correcting a hidden REF point's rod height or
  coordinates still produces a correctly-formed line that stays hidden from
  CAD afterward.
- **Standalone REF points** (COGO-added or CSV-imported, `srcLine<0`) get the
  identical treatment where they're actually written — `exportFBK`'s step 3b
  fresh-`NEZ` dump — checked against the same `isPureRefDesc`.
- Verified end-to-end in a real Node `vm` sandbox running the actual
  `index.html` script (this repo has no sample `.fbk` job file checked in, so
  synthetic points were used, same approach as build 80): a pure `"REF"` shot
  exports with the `-- ` marker while a `"REF RCFL1 B"` multi-code shot in the
  same file exports completely untouched; a plain uncoded `RBCB` point near
  the hidden REF still gets correctly knocked down from it (same `v`
  derivation as always — Knockdown itself needed zero changes); re-parsing the
  exported text recovers a clean `"REF"` description flagged `refHidden:true`,
  and exporting AGAIN produces byte-identical output; correcting the hidden
  REF point's rod height and re-exporting keeps the `-- ` marker and correctly
  rebuilds the `F1 VA` line's HA/SD/ZA fields; a standalone `srcLine:-1` pure
  REF point gets hidden in the step-3b dump while a standalone multi-code one
  in the same export does not, and the hidden one round-trips through a reload
  exactly like the setup-shot case. Script parses clean (`node --check`).

## Un-Knockdown (`revertKnockdown()`/`showUnKdReport()`, ⏮ button `#unkdBtn`, build 82, interactive "Left untouched" list build 90)

- The structural **inverse of Knockdown** — the owner asked for a way to
  convert a baked H/V curb offset back to its code, explicitly leaving
  anything it can't safely identify alone. Gated by the exact same
  `RBCB`/`RCFL` marker precondition `applyKnockdown` itself requires
  (`/\bRBCB\d*\b/`/`/\bRCFL\d*\b/`) — a point with neither marker is out of
  scope entirely and never even scanned, let alone reported, since a bare
  `H<v> V<v>` on some other point is a normal offset-line description-key
  feature (see the description-key codes reference), not a knockdown
  artifact.
- **Two tiers, most-precise first:**
  1. **Session restore.** Any point knocked down earlier in the CURRENT
     session still carries `p.kdInfo={code,ref,v,orig}` — set by
     `applyKnockdown` and, until now, only ever read by the build-11
     Review/edit FBK window's `⏮ Show codes (before knockdown)` toggle for
     DISPLAY purposes. Un-Knockdown reads the same field and, for these
     points, just writes `p.desc=p.kdInfo.orig` back — the literal original
     line, byte-exact, no reverse-lookup needed. This is the only path that
     can correctly restore a **REF-derived** point (an uncoded RBCB point
     whose reveal came from a nearby REF shot's own Z) — its baked V value
     is a one-off number computed from that specific REF geometry, so no
     bare code could ever reproduce it; `kdInfo.orig` (the plain, pre-bake
     description, e.g. just `"RBCB"`) is the only thing that can.
  2. **Reverse-DB-match.** Any other RBCB/RCFL point with a baked H/V run
     and no `kdInfo` (loaded from a file that was already knocked down
     before this session, or by another tool) gets its H/V run's exact text
     (whitespace-normalized) looked up against `CURB_BOC`/`CURB_FL` — but
     ONLY converts if that exact template string belongs to just ONE code.
     Checked both databases directly: `RD`/`RDPRK` share the identical
     template in `CURB_BOC` (`"H-0.5 V0.0"`) and in `CURB_FL`
     (`"H-0.5 V0"`), and `LD`/`LDPRK` share theirs the same way in both —
     these, and anything with no match at all, are deliberately left
     untouched rather than guessed at, matching this project's standing
     rule (build 40/47/49) against guessing at what the field data itself
     doesn't disambiguate. `buildRevIndex(db)` builds this lookup by
     grouping every code by its template value and keeping only the groups
     of size 1.
- **Reporting, not silence:** `showUnKdReport(restored,converted,skipped)`
  always opens a 3-section modal (`#unkdReportScrim`) listing exactly which
  points were restored (tier 1), which were converted (tier 2, with the
  H/V text that matched and the code it became), and which were left
  untouched (with the H/V text that DIDN'T safely match) — so "left
  untouched" is something the owner can see and act on by hand if needed,
  never a silent no-op. Shown even when nothing was revertible at all, as
  long as at least one candidate point was scanned, so a run that finds
  only unrecognized/ambiguous offsets still tells you what it found.
- **Build 90 — the "Left untouched" section became an interactive list, not
  just text:** a real job file can produce a large pile here (253 points on
  the owner's reported file), and there was previously no way to act on any
  of them except hand-editing raw FBK. `showUnKdReport` now builds
  `unkdSkipCtx={rows,selected,sort,lastId}` and renders the skipped points
  as a live list (`renderUnkdSkippedList`) instead of a static table:
  - **Sort: Point #** (default, numeric-aware via a shared `numCmp` helper
    — `"50"` sorts before `"100"`, not after it) and **Sort: Code (H/V)**
    (groups identical/similar ambiguous templates together) toggle buttons.
  - Each row gets a checkbox with the same **ctrl-style independent toggle
    + Shift-click range-select** pattern the Knockdown review list uses
    (tracks `lastId`) — plus **Select all** / **Clear** conveniences.
  - **Delete selected** originally bulk-set `.deleted=true` on exactly the
    checked points. **Build 91 fix — this was wrong and the owner caught
    it:** archiving the WHOLE point as `Deleted` is a far bigger action
    than the situation calls for — the point is a perfectly real shot,
    only its baked offset text couldn't be safely identified. The button
    is now **Clear code** (`unkdSkipClearSelected`, `#unkdSkipClearBtn`):
    it re-runs the same `hvRe` regex against each selected point's CURRENT
    description, strips out just the matched H/V run, and leaves
    everything else — coordinates, marker token, any other code riding
    along — untouched; `p.deleted` is never set. The point becomes a
    plain uncoded marker, still eligible for a future Knockdown pass, same
    as any bare marker point that was never baked. Its label shows a live
    count (`Clear code (N)`).
  - `revertKnockdown`'s `skipped` entries carry a `p` reference
    (`{id,hv,p}`) so this action has a real point/description to act on.
  - **Build 91 — a second, new "Deleted points" section, added per the same
    request's side note** ("add ability to select deleted node[s], option
    to restore select[ed]"): lists every currently-deleted point in the
    file (`PTS.filter(p=>p.deleted)`, not scoped to any one delete action),
    with the identical ctrl/shift bulk-select pattern (`unkdDelCtx`) plus
    **Select all** / **Clear** / **Restore selected** — `unkdDelRestoreSelected`
    flips `.deleted=false` on exactly the checked points via the app's
    ordinary `saveState`/`logEdit`/`buildLinework`/`flagDirty` restore
    convention (same as `toggleDel`/`multiDelete`), removing them from the
    live list immediately with a live count (`Restore selected (N)`).
- Closes via the **Close** button, a backdrop click, or **Esc** (added to
  the same modal-guard pattern the Help modal (build 81) established, so
  letter-key tool shortcuts don't leak through while it's open).
- **A known, inherited limitation, not a new one:** if a point's
  description was manually retyped after Knockdown baked it (without
  re-running Knockdown), `p.kdInfo.orig` could be stale relative to the
  point's current `p.desc` — restoring it would discard that later manual
  edit. This is the exact same fragility the build-11 display toggle
  already has and has always had; Un-Knockdown doesn't introduce it, just
  inherits it by reusing the same field for a new purpose.
- Verified end-to-end through the real UI in a real headless browser with
  a synthetic file exercising all 4 cases at once: an explicit-code
  session knockdown (`RBCB B L624` → baked → Un-Knockdown → back to
  `RBCB B L624`, byte-exact); a REF-derived session knockdown (`RBCB` →
  baked with a custom reveal → Un-Knockdown → back to plain `RBCB`,
  byte-exact — the case a bare reverse-match could never handle); a point
  with no `kdInfo` carrying the exact, unambiguous `L612` template
  (converted correctly to `RBCB L612`); a point carrying the ambiguous
  `RD`/`RDPRK` shared template (stayed untouched); a point with a nonsense
  H/V run (stayed untouched). The report modal listed all 5 correctly (2
  restored / 1 converted / 2 untouched, with the right text on each row);
  Esc and a real click on Close both closed it; running Un-Knockdown a
  SECOND time on the now-reverted file was a confirmed no-op (idempotent —
  nothing left to revert). Re-verified through real toolbar-button clicks
  (not poked state, `#kdBtn` → `#unkdBtn` → `#unkdReportClose`) alongside
  the Help modal in the same session: `figures()` count came back correct
  and zero console errors throughout.

## Guy wire rotation — UGW→CPN (`computeUgwPairs`/`applyUgwReview`/`bearingFromWest`, ⚙ button `#ugwCpnBtn`, build 60, angle fixed build 61, pole codes widened build 62, editable review popup build 69)

- A **deliberately separate tool from Knockdown** (the owner asked explicitly
  to keep this out of the curb-code workflow) — it only ever touches **UGW**
  (guy wire anchor) and pole-type (`ULP`/`UPP`/`UGP`) points; it never looks
  at curb codes or cross-sections.
- For every non-deleted **UGW** point, `addUgwCpn` finds the nearest
  non-deleted point coded **ULP**, **UPP**, or **UGP** (`UGW_POLE_CODES`) by
  plain 2D distance (`Math.hypot(dE,dN)` over every candidate — same
  nearest-by-distance pattern `applyKnockdown` already uses to find the
  nearest **REF** point), computes the bearing of the vector UGW→pole, and
  appends `"<angle> CPN<pole id>"` to the UGW point's description.
  - **Build 62 — pole code set widened from UPP-only to ULP/UPP/UGP:** the
    owner's original worked example happened to use `UPP` for the pole, so
    build 60/61 only ever searched for `UPP`. The owner then asked to widen
    the search to also match `ULP` (light pole) and `UGP` (another pole/
    pedestal variant) — a guy wire can anchor to any of these pole types in
    the field, not just `UPP`. `addUgwCpn` now filters candidates against
    `UGW_POLE_CODES=['ULP','UPP','UGP']` instead of a single hardcoded
    `==='UPP'` check; the nearest-by-distance selection itself is otherwise
    unchanged — there's no priority between the three codes, purely whichever
    single point (of any of them) is physically closest wins. Verified on all
    3 real job files: `TOPO PASCAL`'s UGW points still pair with the same
    `UPP` points as build 61 with unchanged angles (179.61°/179.52° for
    11250/11251); Hamline (which has a real `UGP` point) and Dale (which has
    a real `ULP` point) both still resolve to the nearest actual pole
    regardless of its code — no regression, idempotent, zero console errors.
    A synthetic test (placing a `ULP`, and separately a `UGP`, closer to a
    `UGW` than any `UPP`) confirmed the search genuinely considers all three
    codes and picks the truly nearest one rather than silently preferring
    `UPP` when present.
- **Angle convention — 0° at WEST, MIRRORED (counterclockwise):**
  `bearingFromWest(dE,dN)` computes the standard survey azimuth
  (`(atan2(dE,dN)*180/PI+360)%360` — 0°=north, 90°=east, clockwise, the
  same base formula `headingAt` uses elsewhere), then re-zeroes it to west
  and MIRRORS the rotation direction: `(630-az)%360`. Due west → 0°, due
  **south** → 90°, due east → 180°, due **north** → 270° — the opposite
  rotation sense from standard clockwise survey azimuth.
  - **Build 60 originally shipped the CLOCKWISE version** (`(az+90)%360` —
    0°=W, 90°=N, 180°=E, 270°=S), matching the owner's own later verbal
    confirmation of the convention ("0 WEST 90 NORTH 180 EST SOUTH 270").
    But when the owner uploaded their actual job file (`TOPO PASCAL`), it
    turned out to contain the EXACT points from their original worked
    example (11250/11251/11258) — real ground truth, not a guess. Run
    through the app's real `STN 31`/`BS 30` setup chain, the clockwise
    formula produced **180.39°**/**180.48°** for points 11250/11251
    against the owner's stated **179.36°**/**179.31°** — off by a full
    ~1°/1.2°. The MIRRORED (counterclockwise) formula instead produces
    **179.61°**/**179.52°** — off by only **0.25°**/**0.21°**, a 5x
    smaller and mutually-consistent residual small enough to be ordinary
    rounding in a hand-typed reference value. Since the owner's own verbal
    description and their own real data directly conflicted, the more
    precise, verifiable signal (real ground truth from their own file)
    won over the terse verbal summary — this is a case where a quick
    written confirmation turned out to describe the convention backwards,
    caught only because real data became available to check against.
  - Re-verified on both original sample files (Hamline/Dale) after the
    fix: idempotent (byte-identical on a 2nd run), zero console errors,
    same nearest-pole pairings as build 60 — only the angle NUMBERS
    changed, not which UPP each UGW pairs with.
- **CPN** records which pole the guy wire is tied to (`CPN<pole id>`) — the
  owner's own phrasing suggested this is meant to eventually let a future
  step draw a line connecting the guy wire to its pole, but that drawing
  behavior itself was NOT part of this request and is not implemented —
  `CPN` is currently just a descriptive token, like `REF`, not a figure
  code that draws anything.
- **Idempotent:** re-running strips a previous run's trailing
  `<angle> CPN<id>` pair (`/\s+-?\d+\.?\d*\s+CPN\d+\s*$/i`) before
  appending the freshly computed one, so running it again after moving a
  point (or adding a new closer UPP) updates the pairing/angle in place
  instead of stacking duplicate tokens.
- **Build 69 — editable review popup instead of applying blind:** the owner
  asked for a way to override the automation, since nearest-by-distance
  "may not resolve all cases" (a guy wire's real anchor pole isn't always
  the physically closest pole — it could be across a street or on the far
  side of a building). `addUgwCpn` is gone; `🧭 UGW→CPN` now calls
  `openUgwCpnReview()`, which still runs the identical nearest-pole search
  (factored out as `computeUgwPairs()`) but only to PREFILL an editable
  review list (`#ugwReviewScrim`, a `.modal.wide` popup) — nothing is
  written to any point until **Apply**.
  - Each row (`renderUgwReviewList()`) is one UGW point: an editable
    **Target pt** text input (defaults to the auto pick, with an
    `auto: <id> ✓` note when the row still matches it), a **📍** pick-
    on-canvas button, and a live angle preview (`ugwRowAngle()`, recomputed
    on every keystroke) reading `skip` (blank target), `no such point`
    (unresolved target), or the real `bearingFromWest` angle — so the
    number that will actually be written is visible before committing.
  - **📍 pick-on-canvas** (`startUgwPick(rowIdx)`/`endUgwPick(id)`) reuses
    the same hide-modal → crosshair cursor → click a real point via the
    ordinary `pick()` → refill the field → reveal-modal-again pattern the
    COGO "Pick on canvas" (`startCogoPick`/`endCogoPick`) and circle-center
    tool already use elsewhere in the app — not a new interaction pattern,
    the same one. **Esc** cancels the pick and returns to the list with
    that row unchanged.
  - **Target accepts ANY resolvable point, not just pole-coded ones** —
    this is the actual point of "automation may not resolve all cases":
    if the real anchor is mis-coded, or simply isn't a `ULP`/`UPP`/`UGP`,
    the owner can still type or pick it directly.
  - Blanking a row's target means "skip this UGW" — `applyUgwReview()`
    silently skips blank AND unresolved/self-target rows, applies every
    row that DOES resolve (using the exact same strip-old-CPN-then-append
    write path `addUgwCpn` always used — `saveState`/`logEdit`/
    `buildLinework`/`flagDirty`, unchanged), and reports "applied to N of
    M pt(s)" so a partial apply is never mistaken for a full one.
  - Verified through the real UI (actual clicks/typing) on all 3 real job
    files with genuine UGW/pole data: row counts and auto-picks match
    build 60-62 exactly (Pascal's 11250/11251 still 179.61°/179.52° at
    pole 11258, the same ground-truth-checked values from build 61);
    **Cancel** leaves every UGW description completely untouched on all 3
    files; a bad typed point number live-updates to `no such point` with
    nothing applied for that row; **📍 pick** correctly hides/reveals the
    modal and fills the right field with the right id and a freshly
    computed angle; **Apply** with one row blanked leaves that UGW's
    description exactly `"UGW"` (no token added) while the other rows get
    their normal write — checked via the actual point descriptions after
    apply, not a return value; re-running Apply on the same (now-applied)
    state is **idempotent**, byte-identical both times, on all 3 files.
    Synthetic edge cases: a UGW with no pole anywhere in the file shows an
    empty/`no pole found nearby`/`skip` row (not a crash or a forced wrong
    pairing) and still accepts and correctly applies a manual override
    target typed by hand; a file with zero UGW points hud's a message and
    never opens the modal. Zero console errors in every scenario.
- **Build 70 — animated ring at the guy wire's own origin during a canvas
  pick:** the owner asked for a way to keep track of which UGW point a
  **📍** pick-on-canvas (build 69) is actually FOR while the review modal is
  hidden and the canvas is being panned/zoomed to find the right pole —
  nothing marked the origin point on screen during a pick. The app already
  had one ring-animation mechanism, `flash`/`drawFlash` (used by `⌖ Go to
  point`/`zoomToPoint`), but it's a one-shot ring that shrinks and fades out
  over a fixed 1200ms — wrong shape for this case, since finding the right
  pole can take much longer than 1200ms and the ring would vanish long
  before the owner's done looking.
  - Added a second, separate function, `drawUgwPickRing()`, that stays
    visible for the pick's ENTIRE duration instead of fading out once: it
    reads the currently-picking row's origin point straight off the
    existing `ugwPick`/`ugwReviewRows` state (both already tracked by build
    69 — no new global state needed) and draws a ring whose radius/opacity
    **loops** on a 900ms cycle (`(performance.now()%900)/900` → radius
    8→30px, fading out and restarting) via its own `requestAnimationFrame
    (draw)` chain — the same self-scheduling animation-loop pattern
    `drawFlash` already established, just repeating instead of terminating.
    It draws nothing once `ugwPick` is `null`, so the ring appears the
    instant `startUgwPick` runs (its existing trailing `draw()` call
    triggers the first frame) and disappears on its own the very next frame
    after `endUgwPick` clears `ugwPick` — on either a real target click or
    an Esc cancel — with no explicit start/stop bookkeeping added anywhere.
  - Wired into `draw2D()`/`draw3D()` immediately after the existing
    `drawFlash()` call in each, so it renders correctly in both plan view
    and 3D/orbit view like every other picking overlay in the app.
  - Verified through the real UI on the real Pascal job's 3 UGW points:
    starting a pick on UGW pt 11236 hides the modal, shows the crosshair
    cursor and hud hint, and a screenshot centered on the point shows a
    visible gold ring around it; a second screenshot ~300ms later shows the
    ring at a different radius/opacity, confirming it's genuinely animating
    frame to frame and not a static circle. Clicking a real different point
    (pt 11226) correctly completes the pick — fills that row's target
    field, reopens the modal, and the ring is gone in the next screenshot
    (`ugwPick===null`, no stray ring drawn); Escape mid-pick cancels the
    same way with the row's target left untouched. Re-ran the full
    regression sweep across all 5 real job files: figure counts unchanged
    (70/99/161/36/43), `collectSegments()`/`collectOffsetSegments()` still
    run with no error, every file's UGW review (Arundel included, which
    correctly has zero UGW points and never opens the modal) still
    opens/picks/cancels cleanly, re-applying is still idempotent, and zero
    console errors beyond the pre-existing, already-documented map-tile
    network block on any file.

## CPN / RPN — connect-to-point / recall-point-number (`parseDesc`/`buildLinework`/`figures`/`strokeFigure`, build 63, rendering fixed build 64, implicit-begin removed build 65)

- **Not the same thing as `addUgwCpn`'s `CPN` tag above** — that's a custom,
  descriptive text token the guy-wire tool invents (build 60-62), never
  parsed as linework. This section is the REAL vendor (Trimble/Carlson-
  style) line code the owner pointed out via screenshots + the vendor's own
  doc text, after asking "did we set up CPN code yet" and being told the
  real vendor meaning wasn't implemented. The owner explicitly said: leave
  `addUgwCpn` alone, build this instead. The two features share a name by
  coincidence — `addUgwCpn`'s tag is inert text; `CPN`/`RPN` below actually
  change a figure's drawn geometry.
- **Vendor semantics** (owner's pasted doc): `CPN<n>` — "connect to point
  number" — used when **beginning** a feature, connects the linework to a
  previously observed point `n` so you don't have to shoot a point on top
  of a point just for the sake of creating linework. `RPN<n>` — "recall
  point number" — the same idea, but used when **ending** a feature. In
  practice this means: draw ONE tie line from this specific point to point
  `n` — it says nothing about whether OTHER points sharing this point's
  figure code should be connected to each other at all.
- **Parsing:** `parseDesc` recognizes `CPN<n>`/`RPN<n>` (glued `CPN9124` or
  spaced `CPN 9124`, matching every other description-key token in this
  parser) and stores the referenced point NUMBER (a string, matching
  `p.id`) as `cpn`/`rpn` on that code's flags, unchanged since build 63.
- **Where the tie lives — build 65 rewrite:** `CPN`/`RPN` are tracked in a
  brand-new top-level global, `CONNECT` (declared alongside `CODES`), NOT
  inside `figures()`'s per-code run-building at all anymore. `buildLinework`
  (the same pass that already builds `CODES`) resolves every point's
  `cpn`/`rpn` target to a `PTS` index and pushes `{at,to,kind,code}` onto
  `CONNECT` — for EVERY point that carries the token, regardless of whether
  that point's own figure code ever has a `B` anywhere, ever forms a line,
  or is even in `CODES` at all. This is the key architectural change: a
  tie is now a fact about ONE point, computed completely independently of
  whether a "figure" exists for its code.
  - `figures()` is back to its exact pre-`CPN`-work shape for run-building
    (no `cpn`/`rpn` on the vertex object, no implicit-begin branch, the
    plain `if(f.begin){...}` / `if(!run)return;` gate, `buildLinework`'s
    "keep this code alive" check back to just `e.f.begin||e.f.cir`) — the
    ONLY addition is `r.links=CONNECT.filter(c=>r.verts.some(v=>v.i===
    c.at))` in the final `.map()` step: a **pure derived, read-only view**
    of the global list, scoped to whichever ties happen to originate from
    a vertex that's already part of this figure's real path (computed by
    the ordinary, unmodified begin/end rules). `r.links` is used only to
    decide what `inspectFig` displays — it plays no role in building or
    extending a run.
  - Drawing: `strokeFigure`'s own `f.links` loop (build 64, unchanged)
    still draws ties whose origin is part of a real figure. A new
    `drawConnectLinks(figs,proj)` draws every remaining `CONNECT` entry —
    the ones whose origin point ISN'T part of ANY figure (the whole point
    of this fix) — using a `Set` of every figured `PTS` index (built once
    from the SAME `figs` array `draw2D`/`draw3D` already computed for the
    `strokeFigure` loop, so `figures()` isn't recomputed a second time) to
    skip anything already drawn. Called right after the figures loop in
    both `draw2D` and `draw3D`.
  - The single-point inspector (`inspect()`) gained the same small
    **"Connect-to-point (CPN/RPN)"** section `inspectFig` already had
    (factored into a shared `connectTieHtml(i)` — a `TIE` badge, the linked
    point's own real current FBK line via `pointFbkLine`, and a **⌖** zoom
    button wired directly in `inspect()`, since `inspect()` doesn't share
    `inspectFig`'s delegated `.vb` handler) — this is now the ONLY place a
    lone tied node's connection is visible in the UI, since it never
    belongs to a figure `inspectFig` could show it under.
- **The bug this fixes — CPN's old implicit-begin swept an ENTIRE code's
  points into one line:** builds 63/64 mirrored the `CIR` implicit-begin
  precedent (build 40) — a `CPN`-flagged point with no run open for its
  code would open one right there, matching the vendor doc's framing
  ("CPN can be used when beginning a feature"). That was based on Dale's
  real `"RWLK3 CPN 5341"` case (point 5500, no `B` nearby) — but `CIR`'s
  version of this trick has a natural stopping point (it always auto-closes
  at exactly 3 vertices, since a circle is fixed-size); `CPN` has no such
  thing. Once an implicit-`CPN` run opens, NOTHING closes it except an
  explicit `E`/`CLS` — so it silently swallowed every LATER point sharing
  that same figure code, all the way to the next explicit `B` (or the end
  of the file), connecting them into one continuous line. The owner
  reported exactly this: a real figure code with **no `B` anywhere at all**
  (meant to stay individual, unconnected points/nodes — the app's own
  long-standing rule, "codes with no B stay points") where one point
  carried `CPN` to tie it to another line, and the fix wrongly connected
  ALL of that code's points into a single run instead of leaving the other
  points as plain nodes with just the one point getting its tie.
  - Fix: `CPN`'s implicit-begin is removed entirely — the whole point of
    build 65's `CONNECT`-list redesign above. A code with no `B` anywhere
    now behaves EXACTLY as it always did for every other code (stays plain
    points, `drawPt` draws each as a dot, never enters `figures()`'s output
    at all) — `CONNECT` doesn't care, and was never filtered by whether the
    code forms a figure to begin with.
  - `RPN` was never given implicit-begin/end power in the first place (no
    real job file on hand has ever used it), so this bug only ever applied
    to `CPN`.
- **Verified with a direct reproduction of the owner's report:** a
  synthetic 4-point figure code with no `B` anywhere (`600`/`601`/`602`/
  `603`, all just `"MISCL"` except `601`'s `"MISCL CPN500"` tying it to a
  separate real line) now correctly produces **zero figures** for `MISCL` —
  `figures()` returns nothing for that code at all, so all 4 points render
  as plain unconnected dots — while `CONNECT` still has exactly the one
  `601→500` tie, confirmed still rendering (via `drawConnectLinks`, since
  `601` belongs to no figure).
- **Re-verified against all 3 real job files:** Pascal unaffected (70
  figures, 0 `CONNECT` entries). Hamline's 2 real ties (Hamline's `CPN`
  usage always sits on points that ARE part of a genuine `B`-started
  `RWLK1` run) are completely unaffected — same 99 figures, same
  `RWLK1@700`/`RWLK1@825` `r.links`, drawn the same way via `strokeFigure`.
  Dale's figure count **drops from 162 back to 161** — matching the
  original, pre-any-`CPN`-work baseline — because point 5500 (the exact
  same "no `B` nearby" shape as the owner's report) no longer creates a
  phantom implicit figure; it's now correctly a lone node whose tie to
  point 5341 still renders via `drawConnectLinks` and still shows in its
  own single-point inspector. `RWLK4@597` (point 5502, which IS part of a
  real `B`-started run) is unaffected. Zero console errors on any file.
  Export safety (point 9124 still exports exactly once) and the `RPN`
  synthetic test were both re-confirmed unaffected by this change.

## BC..EC curve linework (`sampleCurve`/`sampleArcFit`, build 24-29, build 49)

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
    - **Build 34 fix — spurious double line when the BC point itself carried
      a curb code:** `strokeFigure`'s bc-branch had a leftover `activeSteps`
      variable that tracked whichever vertex's `steps` (the `H`/`V` cross-
      section offsets `expandCurb` attaches to the currently-active figure
      code) were most recently seen, and — **only inside the curve-sample
      loop, nowhere else** — nudged every sampled curve point sideways by
      `activeSteps[0].h` (and up/down by `.v`) if that list was non-empty.
      A BC point coded like `"RBCB B BC R624"` expands `R624` to its
      `CURB_BOC` steps (`H-0.5 V0.0 H-0.67 V-0.5 H-2.67 V-0.38`) attached to
      the still-active `RBCB` figure code, so `activeSteps[0]` was
      `{h:-0.5,v:0}` right as the curve started — every sample along the
      curve got silently shifted 0.5 ft sideways off the real shots, while
      the straight segments immediately before/after the curve (rendered via
      the plain `put(v.E,v.N,v.Z)` branch, which never consulted
      `activeSteps`) stayed at true position. The result: a curve that
      visibly ran parallel to, and offset from, its own straight lead-in/
      lead-out — the reported "two curbs, one from CAD, one from the FBK
      app" — and the arc no longer even passed through its own coded
      vertices (5520/5521/5522 in the reported job), contradicting the
      build-24-29 guarantee that the fitted arc always hits every real shot.
      Reproduced numerically against the reported job's real data (RBCB run
      5519 BC R624 → 5523 EC): the old code's curve samples sat exactly
      0.5 ft off the true point positions at every sample (matching R624's
      first `H` step precisely), while removing `activeSteps` entirely made
      every sample land exactly on the real coordinates again — confirmed
      sample-for-sample before applying the fix. `activeSteps` was always
      vestigial: curb cross-sections are correctly handled by two completely
      separate, already-correct systems — the explicit user-triggered
      `applyKnockdown()` (bakes a curb code's cross-section into real point
      coordinates) and the automatic `drawOffsets`/`curvedOffsetPts` green
      offset lane lines (build 27-29) — neither of which touches
      `strokeFigure`'s local `activeSteps` at all. Fix: deleted the
      `activeSteps` declaration, the `if(v.steps)activeSteps=v.steps;`
      tracking line, the nudge block inside the curve-sample `forEach`
      (curve samples now just `put(s.E,s.N,s.Z)` directly, same as every
      other vertex), and the now-dead `if(v.so)activeSteps=null;` resets in
      both the bc-branch and the plain-vertex branch. The base figure line
      now renders through raw/true point positions for curved sections
      exactly like it already did for straight ones — matching CAD.
    - **Build 35 fix — `circleFitLS` accepted a genuinely bad fit instead of
      falling back to the spline:** the owner reported build 34 didn't
      actually fix the double-line they were seeing on this same curve, and
      pointed at the real Civil3D drawing as the source of truth. Since
      `help.autodesk.com` is blocked from this sandbox, the owner ran
      Civil3D's own `LIST` command on their curb polyline and pasted the raw
      output — segment-by-segment length/radius/radius-point/course for
      every vertex. Matching those segments' end coordinates against the
      FBK's real shots confirmed every 2nd segment lands exactly on a real
      coded point (5520/5521/5522/5523), but Civil3D's polyline has an
      **extra vertex between every pair of real shots that isn't in the FBK
      data at all**, and the radii of these six segments (56.05, 13.84,
      9.44, 7.67, 1.34, 3.41 ft) swing wildly with no consistent design
      radius — a dead giveaway that Civil3D's own curve here isn't a single
      circular arc either; it's a smooth spline-like fit that got exported
      as a polyline with a short independent bulge per segment.
      `circleFitLS`'s validity check only ever caught the DEGENERATE cases
      (near-infinite radius from collinear points) — it never checked
      whether the fitted circle was actually a good match for real,
      messy/non-circular data like this. For this exact span, the
      least-squares circle came back "valid" (r≈8.14 ft) but individual
      shots deviated from it by up to **4.1 ft — literally half the
      radius**; forcing a per-segment arc through consecutive pairs at that
      fake shared design radius produced a curve that swung up to 1.04 ft
      off Civil3D's actual path in the middle of the span (verified against
      the real `LIST` output's un-shot intermediate vertices) — the visible
      "double line". `circleFitLS` now computes the max residual of every
      input point against the fitted circle and returns `null` (the
      existing `sampleCurve` fallback path) whenever that residual exceeds
      12% of the solved radius, so `sampleCurve` correctly drops to the
      cubic spline instead — which, on the same real data, tracks Civil3D's
      un-shot intermediate vertices to within 0.04-0.13 ft (an 8-25× better
      match) while still hitting every real shot exactly, same guarantee as
      before. Scanned every BC..EC sub-span in the owner's real job file
      (55 total) with this new threshold: only this one gets rejected — the
      other 54 genuinely circular curves fit essentially exactly (near-zero
      residual) and are unaffected, so this is a targeted fix for
      non-circular data, not a behavior change for real curves. Also
      verified against synthetic true circles (a 300 ft radius arc and a
      small 8 ft radius arc with ~0.01 ft noise) that the 12% threshold
      still accepts a genuine constant-radius curve without regression.
    - **Build 36 fix — the offset lane lines stopped curving on the same
      span:** the owner confirmed build 35's base-line fix worked (screenshot
      showed the orange RBCB line curving cleanly through the corner), but
      flagged that the green curb offset lane lines through that exact same
      corner were now going straight/faceted instead of following the
      curve. Cause: `curvedOffsetPts` (build 27/29) gets each lane segment's
      geometry from `arcSegmentsForSpan(baseP)` — the BASE line's own
      circle fit — and its existing `if(!segs){...}` branch (for "doesn't
      fit a circle") fell back to a **straight** vertex-to-vertex chord for
      that piece. That branch used to only fire for genuinely near-collinear
      spans (where a straight fallback is correct — there's no curve to
      draw). Since build 35 made `circleFitLS`/`arcSegmentsForSpan` also
      return `null` for a span that fits a circle badly (this exact
      non-circular curve), that same branch now also fires here — but this
      span very much has curvature, so chording it straight was wrong.
      Fixed by giving that branch the same fallback the base line itself
      already uses: run `sampleCurve` directly on the lane's own offset
      points (`opP`) — the same cubic spline `strokeFigure` falls back to —
      instead of a straight chord, only falling further back to straight
      points if that also fails (e.g. fewer than 2 points). Verified against
      the real job's 5519-5523 span with a synthetic offset lane: the old
      code produced 4 straight chord points (one per original vertex); the
      fixed code produces 67 smooth curve samples, matching the base line's
      own spline fallback in spirit and point count.
    - **Build 49 fix — a real compound curve with NO marker gets forced into
      ONE meaningless average radius:** the owner's screenshot showed a
      genuinely tangled/crossing mess between an `RBCB1` curb curve and an
      independently-coded `RWLK` walkway curve running alongside it. A full
      Civil3D `LIST` dump (its start point matched real shot 9754 to the
      hundredth of a foot, confirming it described this exact curve)
      showed `RBCB1`'s `BC..EC` span (9791→9809, 7 shots) actually covers
      TWO different curvature regimes — a tight ~30 ft curve through the
      first 4 shots, then a much flatter run (Civil3D radii up to 514 ft)
      through the last 3 — while `RWLK`'s OWN independently-coded
      `BC..EC` happens to end exactly at that regime change (point 9800)
      and gets a correspondingly tighter, more accurate ~31 ft fit for the
      same physical corner. `circleFitLS`'s single least-squares radius
      over `RBCB1`'s whole 7-point span came out to a compromise 51.4 ft
      that matches neither regime — putting its curve visibly out of step
      with `RWLK`'s better-localized curve over identical ground, which is
      what produced the crossing/tangled appearance.
    - This is exactly what `PCC`/`PRC` (build 29, above) exist to mark —
      except the owner confirmed **`PCC`/`PRC` are curve-engineering
      terms, not codes any crew ever actually types into a field book** —
      so there is no marker in real data to split on, and any fix has to
      be fully automatic. Two different automatic "does this span's
      curvature look internally consistent?" checks were tried — comparing
      each interior point's own local 3-point circumradius, and comparing
      a first-half-vs-second-half least-squares fit — and both were
      calibrated against every `BC..EC` span in both real job files (93
      spans). Neither threshold could separate this genuinely-bad span
      from several already-verified-good ones without also flagging them
      (e.g. previously-good spans showed local-radius ratios up to 5.6,
      well past this span's 2.87) — so no accept/reject threshold change
      was made; guessing at a split point the data itself doesn't mark is
      exactly the class of change build 40/47 already declined for a
      different reason (an unclosed run's implicit end), and the same
      caution applies here.
    - Fix: rather than deciding UP FRONT whether the WHOLE span needs
      splitting, `arcSegmentsForSpan` now gives every individual segment
      its own **locally-fitted radius** — each consecutive shot pair's
      circle now comes from a least-squares fit over a small window
      centered on it (that pair plus one shot on each side, clamped at the
      span's own ends: up to 4 points) instead of always reusing the one
      whole-span design radius. A real compound curve's true radius drifts
      continuously along the run as this window slides past it, with no
      marker needed to say where the "break" is; a genuinely
      constant-radius run keeps agreeing with itself window to window
      (every overlapping local fit lands close to the same radius, so
      nothing meaningfully changes for those). The whole-span `circleFitLS`
      call is still made first and still gates accept-vs-fall-back-to-
      spline exactly as before (build 35's 12% residual threshold,
      completely untouched) and still supplies the side-of-chord tie-break
      reference (`ref`) for every segment's `circleThroughChordR` call —
      this change only affects what RADIUS a segment reaches for once the
      span has already passed that unchanged gate.
    - Verified against the real Civil3D `LIST` ground truth for the exact
      reported span: the worst deviation of our curve from CAD's own
      un-shot intermediate vertices dropped from **0.60 ft** (old, one
      shared 51.4 ft radius) to **0.21 ft** (new, per-segment radii of
      30.9→29.6→31.3→45.1→80.8→84.3 ft — visibly tracking the real
      tight-to-flat progression along the run), and every other checked
      point improved too. Then re-rendered every `BC..EC` figure in BOTH
      real job files (58 curve figures total) old vs. new and
      Hausdorff-compared the sample clouds: the reported span changed by
      exactly the targeted 0.60 ft, 19 other spans shifted by small
      amounts (all ≤0.30 ft — spot-checked Dale's `RBCB2@1621`, a 4-point
      span whose overlapping 3-point windows shift smoothly 14.1→11.8→8.6
      ft, a plausible real local drift rather than a degenerate result),
      consistent with ordinary shot noise rather than a regression, and
      the remaining ~38 spans were unaffected. Total figure counts stayed
      exactly the same (99 Hamline, 161 Dale — no span gained or lost),
      and the curb offset lane rendering (`curvedOffsetPts`, which reads
      each segment's already-solved `{center,R}` and so inherits the new
      locally-varying radii for free, with no code change of its own)
      still renders every offset lane in both files without error. And
      confirmed visually in a real browser: `RBCB1` and `RWLK`'s two
      independently-coded curves over the same physical corner now track
      each other closely instead of visibly splaying apart and crossing.
    - **Build 50 fix — build 49's own local-window fit produced a tight
      self-crossing loop on a DIFFERENT curve:** the owner's very next
      message ("FIX THIS CURVED MESS") showed a real, different `RBCB`
      curve (points 9649-9658) rendering as a tangled loop instead of the
      clean curve their CAD shows — a genuine regression from build 49's
      own local-window radius fitting, shipped the same day.
    - Root cause: build 49's per-segment `circleFitLS` fits a least-squares
      circle over a small ~4-point window sliding along the span. That fit
      is numerically ill-conditioned when the real shots inside one window
      happen to sit unusually close together — three of this span's real
      shots (9655/9656/9657/9658) are packed within ~1-2 ft of each other.
      A Kåsa circle fit through near-coincident points can return a wildly
      tiny "radius" that still passes its OWN internal residual check (the
      points really do sit close to that absurd circle) while being
      nowhere near the run's actual curvature. Confirmed directly against
      the real data: this span's local windows came back with radii of
      **3.16, 1.43, 1.12 ft** against a whole-span design radius of
      **59.96 ft** — forcing per-segment arcs at those bogus tiny radii is
      exactly what drew the tight self-crossing loop the owner
      screenshotted.
    - First fix attempt: a per-segment sanity guard — reject one segment's
      local fit (falling that ONE segment back to the whole-span radius)
      whenever its ratio to the whole-span radius fell outside a band.
      Scanned every `BC..EC` span in both real job files to calibrate the
      band: every currently-good span's local/global ratio stayed within
      `[0.28,3.7]×`, so `[0.15,6]×` was picked as a safe margin with room
      on both sides. This did fix the loop.
    - But the owner then supplied a much richer, 30-segment Civil3D `LIST`
      dump — its start point matched this exact figure's real coordinates
      (N158865.06' / E558343.56') to the hundredth of a foot, confirming
      it describes this precise run — and that ground truth proved the
      per-segment-patch approach, while no longer looping, still wasn't a
      great match: this span isn't a compound curve with one bad segment,
      it's a genuinely **non-circular, spline-like** real path. The
      `LIST`'s own true sub-segment radii swing from 86.52 down to 0.76 up
      to 4388.91 ft within a handful of real shots — the same "short
      independent bulge per segment" signature build 35 first identified
      and already handles by falling back to the cubic spline. Direct
      nearest-point comparison against the `LIST`'s own un-shot
      intermediate vertices confirmed the plain spline fallback (already
      used elsewhere for non-circular spans) tracks this true path far
      better — **0.60 ft** max deviation — than forcing even a
      locally-patched circular arc through it — **1.41 ft** max deviation.
      Patching just the one flagged-bad segment isn't enough once the
      underlying data isn't circular at all; the other, still-"in-band"
      segments were themselves part of the same non-circular path.
    - Final fix: `arcSegmentsForSpan` now computes every segment's
      local-window ratio FIRST, in a separate pass, before building any
      arcs. If ANY segment's ratio falls outside the `[0.15,6]×` band, the
      function returns `null` for the WHOLE span (not just that one
      segment) — the same signal `sampleCurve` already uses to fall back
      to the spline for a span that fails the whole-span circularity gate,
      so an out-of-band local ratio now falls back the entire run to the
      spline instead of forcing part of it into a circle that doesn't fit.
      The whole-span `circleFitLS` accept/reject gate (build 35's
      12%-of-radius residual threshold) is completely untouched — this
      only adds a second, independent way a span can be rejected to the
      spline, and it only ever rejects further, never accepts a span the
      old gate would already have rejected.
    - Verified with a full before/after scan of every `BC..EC` span in
      both real job files (94 total, old build-49 logic vs. this fix):
      exactly **one** span changed — the reported 9649-9658 loop, now
      correctly returning `null` (spline fallback) — and every other span
      is completely unaffected, including the two closest-to-the-band
      cases on file that this fix could plausibly have caught by mistake:
      Hamline `RBCB@427` (local/global ratio 0.275, just inside the old
      `[0.28,3.7]` observed range) and Dale `RBCB@560` (ratio 3.711) —
      both still pass through with byte-identical radii to build 49.
      Confirmed the rendered base-line path for the fixed span is now
      strictly monotonic (E increases continuously through the entire
      9649-9658 window with no reversal) — the loop is gone. Confirmed
      `drawOffsets`/`curvedOffsetPts` (the green curb offset lane lines)
      still run end-to-end with no error now that this span's
      `arcSegmentsForSpan` returns `null` — it falls back to the existing
      build-27/36 spline-on-offset-points path, the same one any other
      non-circular span already uses.

## OC tangent-arc corner — offset lane lines (`tangentArcGeom`/`offsetTangentArc`, build 48)

- **`OC`/`POC`** rounds a corner between two straight tangent runs with a
  smooth arc that's tangent to both and passes through the coded `OC` point
  (`fitTangentArc`, unrelated to `BC..EC` — no design radius is fit here,
  the arc is fully determined by the two tangent lines plus the one point).
  This was always handled correctly for the base figure line, but
  `drawOffsets` (the green H/V curb cross-section lane lines) never had any
  `OC` handling at all — every `OC` corner fell through to the plain
  `offsetAt` mitered/extended corner math (build 28), correct for a real
  sharp corner but wrong for a smooth fillet, producing the same class of
  "offset lane doesn't track the base line's curve" complaint build 27/36
  already fixed for `BC..EC` spans.
- The owner's screenshot showed exactly this at a real `RBCB` corner (point
  9674, `"RBCB OC"`, between 9673 and 9675): the magenta base line curved
  smoothly through the corner while the green offset lanes on either side
  went sharp/faceted, with visible dashed miter-guide lines instead of a
  curve.
- Fix: extracted `fitTangentArc`'s internal solve into a shared
  `tangentArcGeom(B,d1,C,d2,OC)` returning the fitted arc's `center` and
  tangent points — `fitTangentArc` itself now just calls this and samples,
  same exact computation, confirmed byte-identical output for the base
  line. Then, since perpendicular-shifting a line tangent to a circle by a
  constant distance keeps it tangent to a **concentric** circle (radius
  R±that distance) — the same "parallel offset of a circle stays centered
  the same place" principle build 29 already used for `BC..EC` offset
  lanes — `offsetTangentArc(A,B,C,D,OC,Boff,Coff)` reuses the BASE arc's
  own solved `center` (not an independent re-fit) and finds where the
  already-offset tangent lines (`Boff`/`Coff`, the existing `offsetAt`
  points on either side of the corner) touch a circle centered there.
  Verified algebraically and numerically: both of the offset arc's tangent
  points come out at the exact same radius from the base center (to 4
  decimal places) — a real circle, not two mismatched arcs — equal to the
  base radius plus the lane's own `h` offset distance.
- `drawOffsets` tracks a new `ocAt` flag alongside `bcAt`/`ecAt`; hitting an
  `OC` vertex mid-lane skips straight to the smooth offset arc (same
  skip-the-OC-vertex indexing `strokeFigure`'s own base-line handling
  already uses — the OC vertex itself is never drawn as a lane point, the
  arc runs from the offset of the point before it to the offset of the
  point after) instead of the plain miter.
- Verified against both real `OC` corners in the Hamline job (points 9254
  and 9674) in a real browser: the green lane lines now curve smoothly and
  concentrically with the base line at both, no console errors. Purely
  additive — only fires when `ocAt[k]` is true with valid bounds (mirroring
  `strokeFigure`'s own `k>=2&&k<=len-3` guard) and both neighboring offset
  points exist, so every non-`OC` curb offset in the file renders exactly
  as before.

## SO (stop offset) — offset span boundaries (`offsetAt`/`spanAdj`, build 66, real gap fixed build 67, false-break regression fixed build 68)

- `SO` on a point stops the currently-active curb cross-section offset
  **after that point** (`parseDesc`: `else if(T==='SO'){if(cur)map[cur].so
  =true;}`) — it stops the auxiliary green offset lane/rib rendering only,
  never the base line itself, which keeps going through whatever real
  shots follow. A later point with its own fresh `H<v> V<v>` template
  restarts the offset from there.
- **The bug:** every offset point is placed by `offsetAt(all,k,h,v)`,
  which decides whether vertex `k` is a true interior corner (needing a
  2-line miter) purely from **physical array adjacency** — `k>0`/`k<n-1`,
  i.e. "does SOME neighboring vertex exist in this figure at all" — with
  no idea whether that neighbor's offset is part of the SAME continuous
  span. At an `SO` stop point the base line's NEXT vertex still physically
  exists (SO doesn't end the figure, just the offset), so the old code
  mitered the end-cap using that next segment anyway, even though no
  offset is drawn along it — and the base line is free to turn sharply
  right at that point (a curb corner, a driveway transition — exactly
  where a crew would naturally place `SO`), so the "miter" could aim
  wildly off from a proper perpendicular cap. The mirror-image bug hit the
  START of every offset run too: the very first offset point (right after
  `startK`, or right after a fresh restart following an earlier `SO`)
  mitered against the PRECEDING "dead" segment the same way.
- **Ground truth:** the owner's first-attached file (`TOPO ARUNDEL`) didn't
  match their screenshots at all — grepped it for the screenshots' point
  IDs and for literal `SO` tokens and found neither, so no code was
  touched until they supplied the correct file, `TOPO RAVOUX` (confirmed:
  contains every point ID from all 4 screenshots, and the real `SO`
  usage). Ravoux's `RDRC` figure has 5 real `SO` points (1097, 1101, 1115,
  1136, 1140), each riding along a driveway curb with real `H-0.5 V0`
  offset templates. At point 1140 (`"RDRC EC SO RBCB1 B H-0.5 V0"`), the
  real segment 1139→1140 turns **98.7°** into the real segment 1140→1141
  (a genuine corner in the shot data — 1141 just carries no offset,
  nothing wrong with the survey) — the old mitered corner at 1140 landed
  **0.58 ft** off a proper end-cap, more than the 0.5 ft offset distance
  itself. Rendered, this showed up as a spurious dashed diagonal spike
  jutting off the clean offset lane at every one of Ravoux's 5 real `SO`
  points and at the curve's own natural offset-start point (1082) —
  exactly the tangled mess in the owner's screenshots, next to their CAD
  reference showing a clean perpendicular end-cap tick at the same spot.
- **Fix:** `offsetAt(all,k,h,v,contPrev,contNext)` now takes two optional
  continuity flags saying whether the offset is ACTUALLY continuous into
  each neighbor (same active template, not stopped by `SO` in between) —
  omitting both keeps the old physical-adjacency-only behavior (so any
  future caller that doesn't track span continuity, e.g. a plain
  non-stepped figure, is unaffected). A new `spanAdj(per,k)` derives real
  continuity for free from the `per[]` "active template" array
  `drawOffsets`/`collectOffsetSegments` already build:
  `per[k-1]===per[k]` (object-reference equality) is true exactly when no
  restart/stop happened between them, since `active` is only ever
  reassigned at a fresh `stepsAt` entry — a restart always produces a
  distinct array instance even when its H/V values happen to match the
  previous template's (as they do throughout Ravoux's RDRC run), so this
  check can't be fooled by "same numbers, different template." Interior
  mitering now requires BOTH physical adjacency AND continuity on both
  sides; a one-sided boundary (start/end of a span) uses a plain
  single-segment perpendicular off whichever side IS continuous, falling
  back to whatever's physically there only for a fully isolated
  single-point offset (so `offsetAt` never crashes on a missing far
  neighbor at a span boundary — an early version of this fix threw
  exactly that on Hamline before the physical/continuity distinction was
  split apart correctly). Applied to all 3 places `offsetAt` is called:
  `drawOffsets`'s dashed cross-section ribs, its solid lane lines
  (including the BC..EC-curve and OC-tangent-arc tie-in points, which
  reuse the same per-k `op[]` array so they inherit the fix for free), and
  `collectOffsetSegments` (the OSNAP snap-segment rebuild, build 32/57).
- **Verified:** all 5 real job files (Pascal/Hamline/Dale/Ravoux/Arundel)
  load and redraw with unchanged figure counts (70/99/161/36/43) and zero
  console errors, including a direct call to `collectOffsetSegments()`/
  `collectSegments()` on each (OSNAP isn't exercised by a plain redraw).
  Numerically, the new offset at point 1140 lands exactly on the plain
  single-segment perpendicular (0.0 ft deviation, vs. 0.58 ft old). Direct
  before/after screenshots at all 4 of Ravoux's real `SO` points (1097,
  1101, 1115, 1136) and at the curve's own natural offset-start point
  (1082) each show the spurious dashed spike completely gone, replaced by
  a clean perpendicular end-cap tracking the base curve — matching the
  owner's CAD reference screenshots.
- **Build 67 fix — `SO` still didn't actually DISABLE the offset, it just
  got the corner angle right:** the owner tested build 66 and reported it
  in their own words: "when SO is applied it should disable the offset
  leaving that node and resume when the H/V callout is called later down
  the line" — implying a real, visible gap in the drawn line, not merely a
  corrected corner. Build 66 only fixed what angle `offsetAt` computes AT
  a boundary point — it never touched whether the LANE-LINE CONNECTING
  LOOP actually breaks the drawn path there. That loop (`drawOffsets`'s
  lane-line pass, and the matching one in `collectOffsetSegments`) decides
  `lineTo` (connect) vs. a fresh subpath purely from whether `op[k]` — the
  computed offset point — is non-`null`; it never checked whether `op[k-1]`
  and `op[k]` belong to the SAME active template. Ravoux's real `SO` usage
  always has the next `H/V` restart on the IMMEDIATELY FOLLOWING point
  (`"...SO"` then `"...H-0.5 V0"` right after — 1097→1098, 1136→1137) — so
  `op[]` never actually goes `null` in between, and the loop just drew one
  uninterrupted connected line straight through the boundary: the offset
  never visibly "disabled," it only got a correctly-angled corner at that
  point. Reproduced directly with a synthetic figure (`SO` on point 3, a
  fresh `H-0.5 V0` template on the very next point 4) — confirmed the old
  code (even with build 66's fix) drew one continuous unbroken green line
  from point 1 all the way to point 5, no visible break at 3 anywhere.
  - Fix: `drawOffsets`'s lane-line loop and `collectOffsetSegments` both
    now track a parallel `contPrev[]` array alongside `op[]` — the same
    `spanAdj(per,k).hasPrev` build 66 already computes for the corner
    math, just also kept around here instead of being discarded — and
    treat `!contPrev[k]` as a hard break (a fresh `moveTo` / `prev=null`)
    exactly like a `null` gap, even when `op[k-1]` and `op[k]` are both
    non-`null` and physically adjacent. "Disabled" now means an actual
    visual gap in the drawn line, not just a corrected angle at a corner
    that's still connected end-to-end.
  - Verified: the same synthetic repro now draws two genuinely separate
    green segments (points 1-2-3, and 4-5) with a real gap between them —
    confirmed at a normal zoom (visibly two disconnected pieces) and at a
    tight zoom on just the 4-5 segment (confirms that second piece renders
    correctly on its own — a real point-level check, not just "didn't
    crash"). Re-verified against the real Ravoux `RDRC` figure: a
    point-by-point `per`/`contPrev`/`op` dump for the `1096→1097→1098`
    transition confirms `contPrev` is `true` between 1096 and 1097 (same
    template — both still draw connected, correct, since `SO` includes its
    own point per the "stops AFTER this point" rule) and `false` at 1098
    (the fresh restart — correctly breaks). A tight screenshot centered on
    1096/1097 shows the green offset running continuously through both;
    a screenshot of the 1097→1098 base-line segment shows no offset at all
    alongside it (the real gap); a screenshot of 1098 onward shows a fresh
    offset lane starting there with its own clean perpendicular start-cap
    (build 66's fix, still intact). All 5 real job files re-verified after
    this change: figure counts still unchanged (70/99/161/36/43), zero
    console errors on load/draw/`collectOffsetSegments()`/`collectSegments()`;
    total offset-segment counts dropped slightly on every file (e.g. Ravoux
    134→102) — expected, since spurious connector segments across template
    boundaries are exactly what this fix removes, not a sign of any real
    offset line being lost (the base line, and every place `per[k]` is
    genuinely truthy, is completely untouched).
- **Build 68 fix — build 67's `contPrev` check was too strict, killing real
  curve offsets that had no `SO` anywhere near them:** the owner tested
  build 67 and reported "the curved corner stopped rendering the offset at
  curved section," with a screenshot of Dale's `RBCB@1485` curve (points
  6398-6403) — the green offset lane through that rounded corner was
  simply gone, base line unaffected. Cause: build 67's continuity check
  used **object-reference equality** (`per[k-1]===per[k]`) — but a
  curb-code shorthand like `R612`/`R006` re-**expands** to a brand-new
  steps array **every time it's re-stated** (`expandCurb` hands back a
  fresh array on each call), even when it's the exact same code repeated
  redundantly on consecutive points of the same curve with **no `SO`
  anywhere nearby**. Confirmed on the reported case: Dale's 6398
  (`"RBCB BC"`) → 6399 (`"RBCB R612"`) — 6399's `R612` re-declares the same
  curb template that was already active, but as a NEW array instance the
  old reference check couldn't recognize as "the same," so it read as a
  hard break even though nothing ever stopped the offset. A repo-wide scan
  (checking, for every `bcAt[k-1]` curve-start position, whether `cont[k]`
  was true) found this false-break pattern on **14 real curves across 4 of
  the 5 job files** (3 Hamline, 8 Dale — including the reported 6398/6399
  — 1 Ravoux, 1 Arundel) — a common, not isolated, real-data pattern.
  - Fix: replaced the reference-equality check with a real semantic one.
    A new shared `offsetPerCont(all,stepsAt,stopAt,startK)` builds `per[]`
    exactly as before, plus a parallel `cont[]` where `cont[k] = k>0 &&
    per[k-1]!=null && !stopAt[k-1]` — continuity into `k` depends ONLY on
    whether the PRIOR point actually carried an `SO` (`stopAt[k-1]`), never
    on whether `k` happens to restate its own `H/V`/curb-code template. A
    repeated-but-uninterrupted template is correctly continuous again
    (restoring pre-build-66 behavior for that case); a genuine `SO` still
    breaks the line exactly as build 67 intended — the two fixes are no
    longer in tension, since "was there really an `SO`" is now the only
    signal either one uses. `spanAdj(cont,k)` replaces the old
    `spanAdj(per,k)` (now reads `cont[k]`/`cont[k+1]` directly instead of
    comparing object identity); all 3 call sites (`drawOffsets`'s ribs and
    lane lines, `collectOffsetSegments`) now call `offsetPerCont` to get
    both `per` and `cont` in one pass.
  - Verified: the same repo-wide scan that found 14 false breaks now finds
    **zero** across all 5 files. Offset-segment counts are back at (or,
    for Ravoux, within 2 of) the original build-66 baseline — Pascal 385,
    Hamline 431, Dale 803, Arundel 181 (byte-identical to build 66); Ravoux
    132 vs. 134, the remaining 2-segment difference being the real `SO`
    breaks that are SUPPOSED to still be there. Figure counts unchanged
    (70/99/161/36/43), zero console errors. Re-ran build 67's own synthetic
    SO repro and the real Ravoux `1096→1097→1098` point-by-point check —
    both still show the correct genuine gap at the real `SO` boundary,
    confirming this fix narrowed build 67's trigger to what it was
    actually meant to catch, without undoing it. A direct screenshot of
    the reported Dale curve (6398-6403) now shows the full 3-lane `RBCB1`
    cross-section curving cleanly and continuously through the whole
    corner, matching its pre-regression appearance.

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

## Mobile UI pass (build 39)

- **Toolbar (`.bar`) horizontal scroll:** it's a single-row flex bar with no wrap.
  On a narrow phone viewport the row was wider than the screen with no way to
  reach the overflow — confirmed with a real headless-browser test at 390px
  width: `.bar`'s own bounding box was wider than the viewport (no scrollbar,
  no clipping) and buttons past ~373px were unclickable (Playwright's
  coordinate-based click landed on `.bar` itself, not the button, since that
  screen position wasn't really visible content). Fixed with
  `.bar{overflow-x:auto;...}` plus `.bar>*{flex-shrink:0}` (every direct child,
  including `.brand`, keeps its natural size instead of getting squished/
  wrapped into unreadable fragments) — the whole row now swipes/scrolls
  instead of overflowing invisibly. Verified every button (first and last)
  is reachable via `scrollIntoView`/swipe and actually clickable afterward.
- **Left tool column, and a real pre-existing bug it exposed:** `.tools` (the
  vertical SEL/MOVE/PAN/… icon column) is now `top:12px;bottom:12px` with its
  own `overflow-y:auto` instead of a fixed height, so it scrolls internally on
  a short viewport instead of tools running off-screen. The zoom **+/−**
  buttons used to be a SEPARATE absolutely-positioned block hardcoded to
  `top:430px` — with 10 tool buttons now (after build 38 added **CTR**), the
  tools column had grown tall enough that this fixed offset landed the zoom
  buttons ON TOP of the **MAP** button, hiding it (confirmed in a screenshot —
  MAP had visually vanished). Moved `zIn`/`zOut` to be plain trailing children
  of the SAME `.tools` flex column (with a small `margin-top` for grouping)
  instead of a second absolutely-positioned block, so this whole class of bug
  (a hardcoded pixel offset silently overlapping content as the tool list
  grows) can't recur — the column just gets one item taller/scrollable.
- **Inspector side panel — mobile drawer instead of vanishing:** below 840px
  the panel used to just `display:none` — since almost every editing action
  (viewing a point's fields, the figure/line editor, Review/edit FBK code)
  lives in that panel, this made the app effectively read-only-ish on a phone
  with zero visible feedback when you tapped a point. It's now a slide-in
  drawer (`#sidePanel`, `position:fixed;right:0` sliding in via `transform`)
  toggled by a new **☰ Inspector** toolbar button (`sideToggleBtn`, itself only
  shown below 840px), a **✕** close button in the panel header
  (`sideCloseBtn`), and a tap-to-close backdrop (`#sideScrim`). `openSideMobile()`
  — called from `inspect()`, `inspectFig()`, and `inspectMulti()`, guarded so
  it only fires on an actual selection (not the "click a point" placeholder
  state) — auto-opens the drawer the moment you select a point/figure/box-set
  on a narrow screen, so the existing selection flows didn't need to change
  at all; only the container around them gained show/hide behavior.
- **Modal width:** `.modal` was a fixed `300px` — changed to `width:min(300px,92vw)`
  (plus `max-height:90vh;overflow:auto`) so a dialog can't run wider than a
  narrow phone screen or taller than its viewport.
- **A real regression caught and fixed before pushing:** the new `#sideScrim`
  backdrop div sits, in the HTML, as a direct child of `.main` (the 2-column
  CSS Grid: `.stage` + `.side`) alongside `.stage`/`.side` — with no `display`
  rule of its own outside the mobile media query, it defaulted to
  `display:block` and was silently counted as a THIRD grid item. Grid
  auto-placement filled row 1 with `.stage` (col 1) and the invisible scrim
  (col 2), leaving no room for `.side` in that row, so it wrapped to row 2 —
  which visually shoved the entire desktop Inspector panel into a full-width
  band BELOW the canvas instead of docked on the right, even though every
  `getComputedStyle`/JS-level check (`display:flex`, `position:static`, no
  `.open` class) looked completely correct. Only comparing actual
  `getBoundingClientRect()` output against a real screenshot exposed it — a
  reminder that computed-style checks alone don't prove a layout is actually
  correct; a `display:none` element is invisible in a screenshot but still
  very much present to a Grid/Flexbox parent unless it's explicitly told not
  to be. Fixed with a base (non-media-query) `.sideScrim{display:none}` rule
  (and the same for `.sideClose`, the drawer's close button, which had the
  identical bug — visible by default on desktop with no base rule). Verified
  at 1400px (desktop: 2-column grid intact, no stray close button), 768px
  (tablet: drawer behavior, since it's under the 840px breakpoint), and 390px
  (phone: toolbar scroll + drawer both working) with real screenshots at each
  width, not just computed-style checks, specifically because of what this
  bug taught about the gap between the two.

## CIR doesn't need a B (build 40, `buildLinework`/`figures`, build 47)

- Every OTHER figure code needs an explicit `B` (begin) token somewhere to become
  a line at all — this is intentional and documented in the toolbar hint ("Lines
  need a B (begin) — codes with no B stay points"). **`CIR`/`CIRCLE` is the one
  exception**: it's inherently a fixed 3-point construct (a circle through
  exactly 3 shots), and in practice crews often shoot a small incidental circular
  feature (a manhole rim, a tree trunk) as 3 plain points with no B/E at all —
  just the shared code on all 3, and `CIR` on one of them.
- Before this fix, that pattern was silently dropped in one of two ways: (1) if
  the code had genuinely no `B` ANYWHERE in the whole file, `buildLinework`'s
  `if(!CODES[code].some(e=>e.f.begin))delete CODES[code]` deleted the code
  entirely before `figures()` ever ran (confirmed on the real job file: the
  `TRL` code has a real B for one run elsewhere, so it wasn't deleted, but a
  code with NO B anywhere would have been) — or (2) even when the code
  survived, `figures()`'s run-builder only ever starts a run at `f.begin`
  (`if(!run)return;` skips everything else), so a `CIR`-only cluster with no
  active run just never became part of any figure. Confirmed both failure
  modes on the real job file: `TRL`'s `6377 CIR / 6378 / 6379` cluster and
  `MISCL`'s `5605 CIR / 5606 / 5607` and `5608 CIR / 5609 / 5610` clusters
  were all completely invisible — never rendered, never exported as linework
  (though still present as plain shots, since that part of parsing is
  unaffected).
- Fix: `buildLinework` now keeps a code if it has a `begin` **or** a `cir`
  anywhere (`e.f.begin||e.f.cir`) — purely additive, never deletes a code the
  old rule would have kept. In `figures()`, a `cir`-flagged point with no run
  currently open implicitly starts a new run (flagged `implicitCir:true`),
  which then **auto-closes once it collects exactly 3 vertices** — regardless
  of any `E`/`CLS` token, since a circle's vertex count is always exactly 3
  by construction (this mirrors `strokeFigure`'s own `f.circle&&vs.length>=3`
  + `circle3(vs[0],vs[1],vs[2])`, which only ever look at the first 3 verts
  of a circle figure anyway). This only ever fires when `run` is null —
  a `CIR` token encountered while an explicit `B`-started run is still open
  (the normal case, e.g. a curb corner marked `CIR` mid-line) behaves exactly
  as before, just tagging that vertex for `f.circle` detection on the whole
  run, same as always.
- Verified against the real job file: `figures()` goes from 156 to 159 —
  exactly the 3 previously-invisible circles above, each now rendering as
  a proper 3-point circle (`f.circle===true`) — and every one of the other
  156 figures is byte-for-byte identical (same code, same vertex list, same
  order) to before the fix, confirmed via a full before/after diff, not just
  a spot check. A pre-existing, unrelated quirk in the same data was
  deliberately left alone: `MISCL`'s `5300 B...5304` run has no `E`/`CLS` of
  its own, so it stays open and incorrectly swallows a later, unrelated
  `5580 CIR/5581/5582` cluster into the same run — that's a "run never
  closes" problem, not a "CIR needs B" problem, and fixing it would mean
  guessing when an unclosed run should implicitly end, a materially
  different and riskier change than this one.
- **Build 47 fix — the "unclosed run swallows a later CIR cluster" problem
  build 40 deliberately left alone turned out to be a real, live bug, not
  just theoretical:** the owner's Hamline job showed a real manhole circle
  (`RCED` points 9572/9573/9574, right next to a labeled `UTS` point) not
  drawing at all — just a plain line running through where the circle
  should be. `RCED` in this file has a genuine long curb-edge line
  (`9488 B` ... `9583 E`, 6 real vertices) that happens to pass near **six
  separate** small manhole-rim `CIR` clusters coded with the SAME `RCED`
  figure code (`9095-97`, `9103-05`, `9180-82`, `9275-78`, `9417-19`, plus
  the reported `9542-44` and `9572-74`) — since that host run is still open
  (no `E`/`CLS` hit yet) by the time it reaches each `CIR` point, build 40's
  `!run&&f.cir` guard is false, so the implicit-3-point-circle path never
  fires; the `CIR` points just get appended as plain vertices into the host
  run, which then ALSO picks up `.circle=true` (`r.circle=...||
  verts.some(v=>v.cir)`) and renders one bogus circle through the host
  run's first 3 vertices only (nowhere near the actual manholes) instead of
  drawing the host line at all.
  - Fix: `figures()` now tracks a SEPARATE `cirRun` alongside the host
    `run`. Any `CIR`-flagged point that ISN'T also an explicit `B` on the
    same vertex pulls itself and the next 2 vertices OUT of the host run
    entirely (the host run is left untouched, effectively paused) into
    their own independent 3-point circle; once that circle collects exactly
    3 vertices it's pushed as its own figure, and the host run resumes
    exactly where it left off. This is different from just "close the host
    run and start a new one at the CIR point" (which would still lose
    whatever came after the last cluster if no fresh `B` ever appears
    before the real `E`) — the host run's identity and open/closed state
    are never touched by a `CIR` interruption at all.
  - The one combo deliberately left as-is: a vertex with `B` **and** `CIR`
    together (e.g. the real `"MISCL B CIR RWLK6 BC"` in the Dale job) still
    opens a normal explicit-begin run exactly as before — the new
    cir-pull-out branch only fires when `f.cir&&!f.begin`, so `f.begin`
    always wins on a shared vertex, matching the only real example of that
    exact combo on file.
  - Verified against both real jobs: Hamline's `RCED` now produces 9 correct
    figures instead of 1 wrong merged one — 7 standalone circles (the 6
    pre-existing ones plus the reported `9572-74`) all rendering as proper
    3-point circles, PLUS the host curb-edge line intact end-to-end
    (`9488→9524→9527→9528→9582→9583`, correctly skipping only the
    circle-cluster vertices) — confirmed in a real headless-browser
    screenshot that the 9572-74 circle now actually renders next to `UTS`.
    Dale's long-standing documented `MISCL@369` anomaly (called out in build
    40's own notes above, never fixed until now) is fixed as a natural
    consequence of the identical root cause: it now splits into
    `[5300,5301]` (a clean 2-vertex line, which as a side effect also makes
    its `"RT 6 RECT"` box finally render — see the RT/X/RECT section below)
    plus two correct standalone circles `[5302,5303,5304]` and
    `[5580,5581,5582]`. Total figure count: Dale goes from 159 to 161 (net
    +2, matching one wrong figure splitting into three correct ones), and
    every one of the other 150 non-`MISCL` figures is byte-for-byte
    identical to before — confirmed via a full figure-by-figure diff, not a
    spot check. Hamline's other 90+ figures (every code besides `RCED`) are
    likewise untouched.

## RT / X / RECT — right-turn, extend, rectangle (`parseDesc`/`strokeFigure`, build 42-46)

- Vendor (Trimble/Carlson-style) description-key codes for inserting computed
  vertices without shooting every corner:
  - **`X<value>`** (Extend) extends the *current* segment (prev→this point)
    straight through this point by `value` — positive extends further ahead,
    negative falls short of the point actually shot.
  - **`RT<value>`** (Right Turn) turns 90° off the current travel direction at
    this point and draws a perpendicular segment of `value` — positive jogs
    right (of travel), negative jogs left.
  - **`RECT<value>`** (Rectangle) closes an `RT` jog into a full closed
    rectangle: from the `RT` endpoint, turn another 90° (back parallel to the
    original segment) and close back to it — the two far corners are the
    *perpendicular offset* of both the current point and the previous one,
    connected back to the previous point and this one (`offsetAt`-style
    corner math, not a re-fit).
  - All three can carry the number either glued (`RT6`) or spaced (`RT 6`).
- **Build 42 fix — bare `RECT` (no value of its own) after `RT` was silently
  dropped:** the real, documented usage is `"CODE RT <d> RECT"` — `RT`
  establishes the jog distance, and a **bare** `RECT` (no number following it)
  means "close the rectangle at that same distance" — the vendor spec calls
  this "using the Rectangle code to complete the Right turn code, closing
  back to the starting segment as a perpendicular/perpendicular line
  intersection." `parseDesc` handled `RECT` exactly like `RT`/`X`: it always
  expected its OWN number (glued or spaced) and left `rect` at its default
  `null` if none ever came — since the closing `RECT` in real usage never has
  its own number (it's meant to reuse `RT`'s), `rect` silently stayed `null`
  forever and `strokeFigure`'s render logic (`if(v.rect!=null){...draw closed
  box...}else if(v.rt!=null){...draw one open jog point...}`) fell through to
  the single-dangling-tick path instead of the intended closed rectangle.
  Confirmed on the real job file's only `RT` occurrence (point 5301,
  `"MISCL RT 6 RECT"`): `rect` came back `null` before the fix, and the
  rendered shape was one perpendicular tick off the 5300→5301 segment with
  no closing side.
- Fix: `parseDesc` now flags `rectSeen=true` the moment a `RECT` token is
  seen (regardless of whether a value follows), and in a small post-pass
  after tokenizing the whole description, any code where `rectSeen` is true
  but `rect` is still `null` (no explicit value was ever given) defaults
  `rect` to that same code's `rt` value. This only fires when `RECT` truly
  had no number of its own — a standalone `"CODE RECT 5"` (no `RT` at all,
  or `RECT` given its own distinct value) is completely unaffected, since
  `rect` is already non-null in that case and the post-pass is a no-op.
  Verified against the real job file: point 5301 now resolves `rect=6`
  (matching `rt=6`) and renders as a full closed rectangle between points
  5300 and 5301, confirmed visually in a real browser at high zoom.
- **Build 43 fix — wrong turn direction on a CHAIN of consecutive `RT`s:**
  build 42's real example had exactly one `RT` on one point. A second real
  job (Hamline) showed the FAR more common usage: `"CODE RT <d>"` repeated
  on many consecutive real shots in a straight-ish run (e.g. a wall the crew
  couldn't shoot directly, corrected by a constant perpendicular offset on
  every point). The owner's screenshot of our render showed a lopsided
  zigzag; their CAD showed a clean repeating sawtooth. `strokeFigure`
  computed each jog's "incoming direction" as `vs[k]-vs[k-1]` — the vector
  between the two REAL vertices — which is only correct for the FIRST `RT`
  in a chain. For every `RT` after the first, the actual incoming segment
  is from the PRECEDING point's own jog endpoint (a synthetic point) back to
  this point — not from the real prior vertex, which the jog already carried
  the pen away from. The owner then supplied a Civil3D `LIST` dump of the
  real, correct BLD1 polyline (every segment's course/length), which let this
  be checked exactly: segment 6 in that dump (the "return" leg into point
  9633, course S18°42'49"W) plus 90° equals segment 7's course (the NEXT jog
  out of 9633, N71°17'11"W) to 5 decimal places — confirming the jog
  direction must derive from the return leg just drawn, not from a fresh
  vertex-to-vertex vector. Recomputing the old (vertex-to-vertex) direction
  for that same jog gives an azimuth ~70° off, which is exactly what produced
  the lopsided zigzag in the screenshot.
  - Fix: `strokeFigure` now tracks `lastE/lastN/lastZ` — the TRUE last-drawn
    pen position — updated after every `put()` call in the loop (a plain
    vertex, a `BC..EC` curve span's endpoint, an `OC` tangent arc's endpoint,
    and every `RT`/`X`/`RECT` synthetic point), and RT/X/RECT's "incoming
    direction" is computed from `lastE/lastN` to the current vertex, not from
    `vs[k-1]`. The two coincide for an isolated single `RT` (build 42's
    verified case — re-checked, byte-identical output after this change) and
    only diverge when a PRECEDING vertex had its own unclosed jog, which is
    exactly the chain case this fixes.
  - Verified two ways against the real Hamline job: (1) replayed the exact
    real point sequence (9627..9640, 7 consecutive `"BLD1 RT 9.52"` shots)
    through both the old and fixed logic and compared every resulting vertex
    against the owner's real Civil3D `LIST` dump — the fixed version matches
    every segment endpoint to within **0.008 ft**; the old logic was off by
    up to **11.5 ft**. (2) Re-verified the build-42 single-`RT`+`RECT` case
    (point 5301, different job) produces the identical closed rectangle as
    before — this change doesn't touch that path's numbers at all.
- **Build 44 fix — `RECT` only ever handled ONE `RT`/`X` value, silently
  dropping a whole documented feature:** the owner pointed at the actual
  Autodesk Civil3D vendor doc page for these codes (pasted in full, since
  `docs.autodesk.com`/`help.autodesk.com` are both blocked from this sandbox)
  and it gives its own worked example: `"BLD1 RT X10.1 5 -12.2 -5 -12.2"` —
  "Continues an active figure BLD1 to the current point, extends the current
  segment 10.1 units, and then draws perpendicular segments **for each
  value**." That's a **chain**: one `X` extend leg followed by *four more*
  perpendicular jog legs (`5`, `-12.2`, `-5`, `-12.2`), all off ONE point's
  description. `parseDesc`'s tokenizer only ever kept a single scalar
  `rt`/`x`/`rect` per code (`map[cur][key]=+rx[2]`, overwritten on repeat) and
  had no rule at all for a BARE number with no `RT`/`X`/`RECT` prefix — so
  every value after the first was silently discarded. Confirmed directly:
  parsing that exact doc sentence with the pre-build-44 code returned only
  `rt=5`; `X10.1`, `-12.2`, `-5`, and the second `-12.2` all vanished with no
  error. No real job file on hand happens to use a multi-value chain (both
  real `RT` examples — Dale point 5301 and the Hamline run — use exactly one
  value per point), so this was undetectable from job-file testing alone;
  it only surfaced once the actual vendor spec was read.
  - Fix, parsing: `rt`/`x` scalars replaced with a `jogs:[]` array. `RT`
    still opens the chain (glued or spaced), but now sets `inJog=true`, and
    while `inJog` is set, every subsequent **bare number** token (no letter
    prefix at all — previously matched nothing and vanished) is pushed as
    another `{t:'rt',v}` leg instead of being dropped; an `X<value>` token
    appearing mid-chain (exactly like the doc's own example) is pushed as a
    `{t:'x',v}` leg in the same array, in order. Any other real token (a new
    code word, `H`/`V`, `BC`, `RECT`, end of description, …) clears `inJog`,
    so chaining is strictly an `RT`-chain concept — a standalone `X<value>`
    with no `RT` still behaves exactly as before (one extend, not a chain).
    `rectSeen`'s post-pass now defaults a valueless closing `RECT` to the
    *last* `rt`-type leg in the chain (was: the single `rt` scalar — same
    result when there's only one, which is every real case on file).
  - Fix, rendering (`strokeFigure`): the old code special-cased exactly one
    `rt` value then one `x` value. It's now a loop over `v.jogs` starting
    from the real point (`pos=v`, `dir=`the segment actually just drawn,
    same `lastE/lastN` pen-tracking build 43 already verified): an `x` leg
    extends `pos` along the CURRENT `dir` by its value (direction unchanged);
    an `rt` leg turns `dir` 90° (sign of the value picks left/right, exactly
    build 43's already-proven turn formula) and moves `pos` along the new
    perpendicular. This is the same math as the build-43 cross-point chain,
    just applied to several synthetic legs off ONE point instead of several
    real points — no new formula, just no longer capped at one leg.
  - Fix, `RECT` closing a chain: the doc calls this "closing back to the
    starting segment as a perpendicular/perpendicular line intersection from
    the current figure line segment" — a real geometric intersection, not
    "reuse the same distance," which only happened to be equivalent for a
    single-leg chain (proven algebraically: with exactly one `rt` leg, the
    intersection of [a line through the chain's endpoint, parallel to the
    base segment] and [a line through the prior point, perpendicular to the
    base segment] reduces exactly to `prior + perp·rt` — the old formula).
    For a general chain the two lines aren't parallel-degenerate, so it's
    computed directly: project the chain's final endpoint onto the base
    segment's own perpendicular axis through the prior point (`d = dot(pos
    − prior, perp)`, `corner = prior + perp·d`) — closed-form equivalent of
    intersecting those two fixed lines, and it no longer depends on which
    leg types (extend vs. turn) built the chain, matching the doc's language
    that this is a computed intersection, not a re-specified distance.
  - Verified with zero regression by running the ACTUAL `index.html`
    `parseDesc`/`buildLinework`/`figures`/`strokeFigure` (not a standalone
    reimplementation) against both real jobs end-to-end: point 5301's
    `"MISCL RT 6 RECT"` still produces the byte-identical closed rectangle
    off points 5300/5301, and the Hamline `BLD1` 9627–9640 chain still
    produces the identical previously-`LIST`-verified sawtooth coordinates,
    both through the live parse→figures→render pipeline. Then verified the
    new chain support itself: parsing the doc's own example now keeps all 5
    legs (`x10.1, rt5, rt-12.2, rt-5, rt-12.2`, none dropped), and a
    synthetic multi-leg-chain + a standalone `RT 6 RECT` figure both
    rendered correctly (clean closed box for the simple case, a sensible
    zigzag with a closing notch for the chain) in a real headless browser
    with no console errors.
  - **Unrelated pre-existing issue found, NOT touched:** point 5301's figure
    in the real Dale job (`MISCL@369`) is the same run build 40's notes
    already flag as never closing (`5300 B...5304` has no `E`/`CLS`) and
    swallowing a later `5580 CIR/5581/5582` cluster into one run — that
    merged run also picks up `.circle=true` (since ANY vertex in it, 5302,
    carries a `CIR` flag) and `strokeFigure`'s circle branch draws a full
    circle through the run's first 3 vertices and returns immediately,
    before ever reaching the RT/RECT jog code. So in the live app, THIS
    SPECIFIC real figure renders as a circle, not a rectangle, regardless of
    the RT/RECT fix — a separate, already-documented, deliberately-untouched
    bug (fixing it means guessing when an unclosed run should implicitly
    end, per build 40's own notes). Confirmed the RT/RECT code itself is
    correct by testing it in isolation (a standalone 2-vertex figure built
    from those same real points' real coordinates, bypassing the unrelated
    merge) — see verification above.
    **Update, build 47:** this is now actually fixed, as a side effect of
    the "CIR doesn't need a B" section's build-47 fix (`figures()` pulling a
    `CIR` cluster fully out of whatever host run it interrupts, instead of
    the host run swallowing it) — `MISCL@369` now correctly splits into its
    own clean 2-vertex `[5300,5301]` line (so this `"RT 6 RECT"` box finally
    renders as intended) plus two separate proper circles. See the CIR
    section above for the full writeup; not re-verified twice here.
- **Build 45 fix — bare `RECT` closing a plain 3-shot L with NO `RT` at all:**
  the owner sent a CAD screenshot (a clean closed rectangle box around a
  circle) next to the app's own render of the SAME area (an open dead-ending
  line, no box) as proof build 44 still wasn't right. The actual figure:
  `"RCED B"` (9878) → `"RCED"` (9879) → `"RCED E RECT"` (9880) — **three real
  corner shots, no `RT` anywhere in the whole figure**. Checked the real
  coordinates: the angle between segment 9878→9879 and segment 9879→9880 is
  88.7° and the two side lengths are nearly equal (4.417 ft / 4.434 ft) —
  this is a genuine field survey pattern crews use for a small rectangular
  feature (a curb box, a pad corner): shoot 3 of the 4 actual corners, then
  `RECT` (with no number at all — there's no distance to give, the box's
  size is already fully determined by the 3 real shots) closes the missing
  4th corner and the loop. This is a DIFFERENT, and in practice probably far
  more common, usage than build 42-44's "`RT <d> ... RECT`" case — no
  distance value ever appears in the description at all.
  - Build 44's fix only widened the trigger to `v.jogs.length||v.rect!=null`
    — with zero `rt`/`x` legs and no explicit/inherited `rect` value (nothing
    to default from — there's no `rt` leg anywhere to borrow a distance
    from), that condition is `false` and the entire `RECT` was silently a
    no-op, exactly reproducing the owner's screenshot (open line, no box).
  - Fix: `parseDesc`'s post-pass now sets a new flag `closeL:true` when
    `rectSeen` is true, `rect` is still `null`, AND `jogs` is completely
    empty (no `rt` to borrow a distance from, no `x` either) — i.e. `RECT`
    appeared totally bare with nothing before it to build a jog from.
    `strokeFigure` closes this case by computing the missing 4th corner
    directly from the plain geometry of the run's own last 3 real vertices
    (`vs[k-2]`=p1, the tracked prior pen position=p2, current=p3): a
    rectangle's (or any parallelogram's) 4th corner is always
    `p1 + (p3 − p2)` — the standard "complete the parallelogram" vector sum,
    needing no assumed distance or angle at all, just the 3 points already
    shot. This is a THIRD, mutually exclusive `RECT` branch alongside the
    existing two (`v.jogs.length` → close a chain per build 44;
    `v.rect!=null` → old standalone jog+close per build 42): `closeL` only
    ever fires when there's truly nothing else to go on.
  - Verified: the real 9878/9879/9880 data produces a 4th corner
    (558582.661, 158864.092) whose four side vectors are exact negations of
    their opposite sides (a true closed parallelogram/rectangle, not an
    approximation), and a real headless-browser screenshot of this exact
    figure in the live app now shows the identical closed box — with the
    nearby `MISCL` circle (9881/9882/9883, a separate figure) sitting inside
    it — matching the owner's Civil3D screenshot shape-for-shape. Re-ran
    both of build 44's regression cases (Dale `5300/5301` `"RT 6 RECT"`,
    Hamline `BLD1` `RT`-chain) through the same real pipeline afterward:
    byte-identical output, confirming `closeL` is additive and never fires
    on either existing case (both still have non-empty `jogs`, so the new
    branch is skipped for them).
- **Build 46 fix — build 45's own closing side drew a spurious diagonal:**
  the owner confirmed the box now closes but flagged a straight diagonal
  line cutting across it (a screenshot showed the line running from `9878`
  directly to `9880`, splitting the box in two). Build 45's `closeL` branch
  ended with `put(corner);put(p1);put(v)` — that trailing `put(v)` was meant
  to leave the pen "back on the real current point" for continuity, copying
  the pattern the OTHER two `RECT` branches already use (`v.jogs.length` and
  `v.rect!=null` both end the same way: `put(corner);put(prior);put(v)`).
  But in those two branches that final leg retraces `prior→v` — the plain
  base segment that was ALREADY drawn just before entering the branch, so
  it's an overlap, not a new line. `closeL`'s retrace used `p1` (`vs[k-2]`,
  two vertices back), not `prior` — the original path was the L-shape
  `p1→prior→v`, which never contained a direct `p1→v` chord, so
  `put(p1);put(v)` drew a brand-new straight diagonal across the box that
  had no reason to exist.
  - Fix: dropped the trailing `put(v.E,v.N,v.Z)` — the path now simply
    stops at `p1` after the closing corner (`9878→9879→9880→corner→9878`,
    4 sides, no 5th line), while still setting `lastE/lastN/lastZ=v` so any
    vertex after this one (not present in real data, but for consistency)
    still computes its own incoming direction from the real point, not from
    `p1`.
  - Verified: the real 9878/9879/9880 put-sequence now ends exactly at the
    closing corner point with no trailing segment, and a real headless-
    browser screenshot of the same figure shows the closed box with no
    diagonal — matching the owner's Civil3D screenshot exactly. The other
    two `RECT` branches were re-checked and don't share this bug (their
    retrace target is genuinely the immediately-prior vertex, so it only
    ever re-draws an existing line).

## Point at circle center (`startCircleCtrPick`, build 38, ⊙ CTR toolbar button)

- Places a new point at the **circumcircle center** of 3 points — for a manhole,
  catch basin, or any feature shot as 3 points around its rim rather than at its
  actual center.
- Click the **⊙ CTR** tool, then either **click 3 points** on the canvas (highlighted
  gold with a 1/2/3 order marker as you go), or **click an existing CIR-coded line**
  (a figure with a `CIR`/`CIRCLE` token — see the toolbar hint / `f.circle` in
  `figures()`) to use that line's own first 3 vertices instead of picking manually.
  **Esc** cancels a pick in progress.
- `circle3(p1,p2,p3)` (already used by `strokeFigure`'s `f.circle` branch) computes
  the center — collinear points return `null` and the tool just reports "collinear —
  no circle" with no dialog, rather than crashing or silently producing a nonsense
  center.
- **Elevation prompt:** reuses the same `zpickScrim` chooser as the apparent-
  intersection snap (`openZPick`, build 32), via a new `openAvgZPick(avg,hint,onDone)`
  that shows a single "average of 3 points" option plus the existing custom-Z field —
  `circle3` already computes that average (`(p1.Z+p2.Z+p3.Z)/3`), so this is just a
  confirm-or-override step. (Hardened `openZPick` itself to always set its own hint
  text, since the two now share the same dialog markup and a stale hint from one
  flow must never leak into the other.)
- **Code/description prompt:** a small dialog (`circleCtrScrim`) shows the computed
  N/E/Z read-only and asks for a code/description — this point doesn't belong to any
  existing figure's linework, so (unlike `insertPointOnLine`/`insertCogoPoint`) it
  gets **whatever code the user types**, not a figure's code.
- **File position — "after the 3rd point":** the new point is tagged
  `posAfter: <PTS index of the 3rd point picked>` (or the CIR line's 3rd vertex).
  `exportFBK` step 2c (new, runs before the main line-assembly loop so `nezBefore`
  is fully populated first) resolves that anchor's *current* `srcLine` and emits the
  new point as an `NEZ` record via `nezBefore[anchorSrcLine+1]` — immediately after
  the anchor's own line, the same "insert extra lines before line L" hook build 31's
  `PRISM` bracketing and the added-point logic (step 2b) already use. If the anchor
  itself has no valid position (deleted, or itself a synthetic/inserted point with no
  real `srcLine`), the point safely falls through to the existing step-3b safety net
  (dumped as a plain `NEZ` at the very end) instead of being lost.
- Verified end-to-end against the real job file: picking real points 5519/5520/5521
  computed a center, average-Z, and produced a point whose exported `NEZ` line landed
  on the line immediately following point 5521's own line; the CIR-line shortcut
  (picking figure `MISCL@369`, `.circle=true`, 8 vertices) correctly used its own
  first 3 vertices instead of requiring 3 manual clicks; 3 synthetic collinear points
  correctly showed "collinear — no circle" with no new point created and no dialog.

## Add Point (COGO) canvas pick + CAD snap (`startCogoPick`/`snapPoint`)

- The **Add Point (COGO)** dialog has a **📍 Pick on canvas (snap)** button. It
  hides the dialog, lets you click the drawing, and fills N/E/Z from the click.
- Basic CAD object snap (`snapPoint`, 2D only) in priority order: **endpoint**
  (any point/vertex), **apparent intersection** of two lines (lines are extended
  until they cross — the headline request), **midpoint**, then **nearest** on a
  segment. Z is interpolated along the segment (W2S is affine, so the screen-space
  parameter equals the world parameter); apparent-intersection Z is the average of
  the two lines' Z at the crossing.
- A live osnap marker is drawn under the cursor (▢ endpoint, ○ intersection,
  △ midpoint, ⋈ nearest — build 56 changed intersection from an X/cross to a
  circle per the owner's request; endpoint/midpoint already matched). No snap
  in range → free pick (N/E only, Z left for the user). **Esc** cancels and
  reopens the dialog. Both the figure linework **and the curb cross-section
  offset lane lines** are snapped (`collectOffsetSegments` rebuilds the
  offsets as world segments using the same math as `drawOffsets`).
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
  **Superseded by build 57's OSNAP toolbox, below** — `insertSnapOn` is
  gone, replaced by `snapEnabled.intersection`.
- **Build 57 — shared OSNAP toolbox (`#snapBox`, `snapEnabled`, `syncSnapBox`):**
  the owner asked for a way to check/toggle which snap types are active, and
  for the same capability on insert-on-line, which until now only had the
  single build-32/33 intersection checkbox above. One `let snapEnabled=
  {endpoint,intersection,midpoint,nearest}` (all `true` by default) now
  gates BOTH `snapPoint()` (COGO) and `pickSegmentForInsert()` (insert-on-
  line) — each function tries its 4 stages in the same priority order
  (endpoint > intersection > midpoint > nearest), skipping any stage whose
  `snapEnabled` flag is off, and stopping the whole cascade (returning
  `null`) if `nearest` is off and nothing higher-priority matched either.
  `pickSegmentForInsert` gained two stages it never had: an **endpoint**
  snap (lands exactly on one of the clicked figure's own vertices) and a
  **midpoint** snap (lands exactly on one of its segments' midpoints) —
  both scoped to that figure's own segments only, since an inserted point
  has to stay on the line being edited; the existing intersection-crossing
  logic (build 32/33) is unchanged, just now reads `snapEnabled.intersection`
  instead of the old standalone `insertSnapOn`.
  - A floating panel (`#snapBox`, bottom-right of the canvas, CSS class
    `.snapbox`) shows a checkbox per type and appears whenever a
    snap-driven pick is actually live — `cogoPick` truthy, or `insertPt`
    truthy and 2D — via `syncSnapBox()`, called on every `draw()` so it
    never goes stale. Whichever type is engaged right now under the cursor
    (`cogoSnap.type` or the new `insertSnap.type`, tracked the same way
    `cogoSnap` always was — insert-on-line gets a live hover preview via
    `drawSnapMarker` for the first time, it previously only computed a
    landing on click) gets a green `.active` highlight on its checkbox row.
  - **A real bug found and fixed:** the box is an ordinary DOM element
    sitting on top of the canvas, so with no `pointer-events` handling it
    silently swallowed mouse events anywhere its own footprint overlapped
    the canvas — confirmed directly against a real Dale job figure whose
    segment midpoint happened to fall exactly under the toolbox's own
    `midpoint` row: every mouse event there stopped reaching `#cv`
    entirely (`pickSegmentForInsert` never even got called, confirmed by
    monkeypatching it and seeing zero invocations). Fixed with
    `.snapbox{pointer-events:none}` plus `.snapbox label{pointer-events:
    auto}` — the box's empty background/padding lets clicks pass straight
    through to the canvas underneath, while the checkbox rows themselves
    stay clickable. This is the same tradeoff every other floating overlay
    in the app (`.legend`, `.tools`) already makes just by existing on top
    of the canvas; picking a target away from the toolbox's own corner
    confirmed the underlying snap logic is unaffected.
  - Insert-on-line's side-panel UI lost the standalone `insertSnapChk`
    checkbox (superseded) — its hint text now just points at the shared
    on-canvas toolbox.
  - Verified through the REAL UI (actual button clicks, not poked state)
    on both real job files: Add Point (COGO) → Pick on canvas shows the
    toolbox and correctly highlights `endpoint` beside a real point;
    opening a figure → ⊕ Click line to insert point shows the toolbox and,
    at real segment locations, correctly resolves `intersection` → (with
    intersection off) `nearest` → (with nearest off too) `null`, no crash
    — the same cascade COGO already used. A 25-figure × 2-file
    insert-on-line sweep and a 40-point × 2-file COGO-pick sweep produced
    zero console errors beyond the pre-existing, already-documented
    `ERR_CONNECTION_RESET` from blocked map-tile fetches.

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

## 3D orbit navigation — pivot retargeting, zoom-about-cursor, middle-mouse pan (`retargetOrbitPivot`/`zoomOrbit`, build 80)

- The owner: orbiting is hard to control when there's a large distance
  between points (a real job site spans hundreds of feet), and asked for the
  mouse **middle button** to actually be put to use. Three real bugs, all in
  the same area of the pointer-handling code, combined to cause this:
  1. **The orbit pivot (`orbit.cx/cy/cz`) was set once by `fit()`/`⌖ Go to
     point` and then never moved again** until you called `fit()` again.
     Rotation genuinely happens *around* that fixed world point — so once
     you'd zoomed into a corner of a large site far from the pivot, even a
     tiny mouse drag swept that corner across a huge arc on screen (the
     farther a point sits from the pivot, and the more you've zoomed in
     — i.e. the larger `orbit.s` — the more its screen position moves for a
     given rotation). That's the literal mechanism behind "hard to orbit
     with a large distance between points."
  2. **Every zoom (wheel, or the +/− buttons) silently re-centered the
     pivot to the exact middle of the screen** via `refreshOrbitPivot()`
     (`orbit.ox=w/2-center[0]`, discarding whatever `orbit.ox/oy` pan
     offset was already there). So panning over to a distant part of the
     site with shift-drag, then scrolling to zoom in on it, would snap the
     view straight back to being centered on the old pivot — undoing the
     pan you'd just done and forcing you to redo it, over and over.
  3. **Middle-mouse-button drag was a dead no-op in 3D.** Its `pointerdown`
     handler ran BEFORE the `is3D` check and always stored `view.x/y` as
     the drag anchor — but the 3D projection (`P3`) never reads `view.x/y`
     at all (it uses `orbit.ox/oy`), so nothing visibly moved during the
     drag; then on release, `if(drag.pan&&is3D)refreshOrbitPivot()` would
     even snap the view back to center on the pivot, an unrelated jump on
     top of the button already doing nothing useful.
- **Fix 1 — retarget the pivot at the start of every orbit drag
  (`retargetOrbitPivot(sx,sy,pt)`):** unless Shift is held (Shift-drag is
  still a plain pan, untouched), `pointerdown`'s `is3D` branch now calls
  this before starting the drag. If a real point is under the cursor (the
  same `pick()` already used to select it for the inspector), that point's
  own `E,N,Z` becomes the new pivot. Otherwise the cursor is unprojected
  onto the **horizontal plane at the pivot's own current elevation**
  (inverting just the rotation step of `P3`, assuming `z1=0`: `x1=(sx-w/2-
  orbit.ox)/orbit.s`, `y1=-(sy-h/2-orbit.oy)/(orbit.s·sin(el))`, then
  `e=x1·cos(az)-y1·sin(az)`, `n=x1·sin(az)+y1·cos(az)` — the rotation
  matrix `P3` applies is orthonormal, so its inverse is just its
  transpose). Either way, since the new pivot's own projection is trivially
  `(w/2+ox, h/2+oy)` (its own `e,n,u` are all zero by construction), setting
  `orbit.ox=sx-w/2` and `orbit.oy=sy-h/2` lands it exactly under the cursor
  with **zero visual jump** at the moment of retarget — confirmed
  algebraically and numerically. Every orbit drag now rotates around
  whatever you actually clicked or pointed at, near or far from the site's
  overall centroid — **⊡ Fit** (or `F`) still resets to the whole-model
  pivot on demand, unchanged.
- **Fix 2 — zoom about the cursor instead of snapping to the pivot
  (`zoomOrbit(f,sx,sy)`):** replaces the old `orbit.s*=f;
  refreshOrbitPivot()` pattern in both the wheel handler (about the cursor)
  and the `zIn`/`zOut` buttons (about the viewport center, `w/2,h/2`).
  Since only `orbit.s` changes (rotation is untouched), the projected
  screen offsets of any fixed world content scale linearly with `orbit.s`
  around the current `ox,oy` — so `dx=sx-w/2-orbit.ox` (and `dy`) computed
  BEFORE the scale change, then `orbit.ox=sx-w/2-dx*f` (same for `oy`)
  AFTER it, keeps whatever's under the cursor pinned to that exact screen
  position through the zoom — the same principle as the 2D wheel handler's
  existing `view.x=sx-wx*view.s`, just derived for the oblique 3D affine
  form instead of `S2W`'s true inverse. This is a strict improvement over
  the old recenter-on-pivot behavior: it can only keep the view where you
  already had it (or center it, for the toolbar buttons), never yank it
  back to some other point.
  `refreshOrbitPivot()` itself is now dead code (nothing called it besides
  the wheel handler, the zoom buttons, and the middle-mouse-pan cleanup
  below, all three replaced) and was deleted rather than left unused.
- **Fix 3 — middle-mouse-button drag actually pans the 3D view:** the
  `pointerdown` middle-button branch now checks `is3D` and stores
  `orbit.ox/oy` as the drag anchor when true (`view.x/y` otherwise,
  unchanged for 2D); the matching `pointermove` handler for `drag.pan` now
  branches the same way, updating `orbit.ox/oy` during the drag instead of
  the unused `view.x/y`. The `endInteract` cleanup that used to call
  `refreshOrbitPivot()` after a middle-mouse pan (undoing the very pan that
  had — before this fix — not even visibly happened) is gone; nothing needs
  to run after a pan that already updated the right variables live.
  `e.preventDefault()` was added to the middle-button `pointerdown` branch
  too — without it, the browser's own native middle-click autoscroll cursor
  was starting at the same time as our drag and competing with it, which
  is itself part of why "using the middle button" felt broken.
- The `#orbHint` text (both its static HTML default and `setMode`'s dynamic
  version) and the 3D inspector note were updated to mention that orbiting
  re-centers on click and that middle-drag pans, alongside the existing
  shift-drag pan.
- **Verified two ways.** First, a standalone reimplementation of the
  exact projection/retarget/zoom formulas (`P3`, `retargetOrbitPivot`,
  `zoomOrbit`) confirmed numerically: retargeting onto a real point causes
  **zero** screen movement of that point; a 0.3 rad rotation immediately
  after retargeting leaves the (now-pivot) point's screen position
  completely unmoved, since it IS the pivot (rotating around a point
  doesn't move that point); retargeting onto empty ground (no point picked)
  correctly re-projects back to the exact cursor pixel; and `zoomOrbit`
  keeps a world point's screen position fixed to sub-millipixel precision
  through a 1.8× scale change. Second, and more importantly, this was
  re-verified **end-to-end through the real, running `index.html`** in a
  real headless browser (Chromium via Playwright) — no synthetic
  reimplementation this time — using synthetic point data spanning a large
  area (since this repo has no sample `.fbk` job file checked in to load a
  real one from): switching to 3D and dragging to orbit starting exactly on
  a real point snapped `orbit.cx/cy/cz` to that point's exact real
  coordinates with **zero** visual jump (the point's own `P3()` screen
  position was byte-identical before and after retarget), and the
  subsequent drag moved `az`/`el` by exactly the drag-distance formula
  (`0.008`/`0.006` rad/px, matching the pre-existing, unchanged rotation
  math); a middle-mouse-button drag panned `orbit.ox/oy` by **exactly** the
  mouse's own screen-space delta (previously a complete no-op — confirmed
  broken on the pre-build-80 code path before fixing it); and a real mouse
  wheel event over a specific point changed `orbit.s` by the expected
  ×1.12 factor while leaving that point's screen position unchanged to
  within a fraction of a pixel (a small floating-point/DPR rounding
  residual, not a formula error). Also confirmed the inline script still
  parses (`node --check`) and that ordinary 2D pan/zoom/orbit-tool-select
  behavior is untouched (the 2D code paths in every changed function are
  the pre-existing `else` branches, unmodified).

## 3D view editing — Inspector unlocked (`inspect`/`inspectMulti`, build 83)

- The owner: "WHEN IN VIEW 3D AND SEL PION OR LINE MAKE ITT THE I CAN EDIT
  IN THAT VIEW" — 3D orbit mode should let you edit a selected point or
  line right there, not force a trip back to a 2D tool first.
- **What was actually gating edits, and why most of it had no real reason
  to:** `inspect()` (the single-point Inspector) rendered every field —
  `fDesc`/`eId`/`eN`/`eE`/`eZ` for a control/coded-NEZ point, plus
  `eHA`/`eSD`/`eZA`/`eRod` for a shot point — with `${is3D?'disabled':''}`
  baked into the HTML string, and swapped the entire Apply/Delete button
  group for a dead-end `<div class="warnbox">3D inspect mode — switch to a
  2D tool to edit.</div>` whenever `is3D` was true; `inspectMulti()` did the
  identical swap for its Delete/Restore/Clear buttons. None of this
  reflected a real technical constraint — `applyPointEdit(p)`,
  `toggleDel(p)`, and `multiDelete(bool)` (the actual functions that write
  to point data) never read `is3D` anywhere in their own bodies; they just
  take a point object (or the current `selSet`) and mutate it, identically
  regardless of which view triggered the call. The `disabled`/`warnbox`
  gating was purely a UI decision layered on top of already view-agnostic
  logic, not something the underlying edit machinery required.
- **Checked `inspectFig()` (the figure/line editor) before touching
  anything, since it's the OTHER half of "point or line":** it turned out
  to already be fully editable in 3D with zero gating anywhere — vertex
  reorder (▲▼), remove (✕), per-vertex code edits, the "render as NEZ"
  checkbox, zoom-to-point (⌖), and Street View (📷) all already worked
  identically in both views, since `inspectFig` was never written with an
  `is3D` check at all. So the real scope of this request was narrower than
  it first read: only the single-point Inspector and the multi-select
  panel needed unlocking, not the figure editor.
- **Fix:** removed every `${is3D?'disabled':''}` from both branches of
  `inspect()` (the `p.kind==='ctrl'` branch and the plain shot-point
  branch) — `fDesc`, `eId`, `eN`, `eE`, `eZ`, `eHA`, `eSD`, `eZA`, `eRod`
  are now always plain, always-enabled inputs regardless of view. Replaced
  the `${is3D?warnbox:...}` ternary in both branches with the Apply/Delete
  `chgrp` rendering unconditionally, and folded the old warning into the
  trailing note instead of blocking the action entirely — the control-
  point branch's note now reads `Edits republish this NEZ record on export
  (coords, code & point #).${is3D?' Editable here in 3D too — dragging to
  move a point still needs a 2D tool.':''}` (the shot-point branch's
  equivalent note got the same treatment). Removed the `if(!is3D){...}`
  wrapper that had gated wiring `$('applyEdit').onclick`, the
  Enter-key-submits-on-any-field handler, and `$('delBtn').onclick` — all
  three now always run. `inspectMulti()` got the same treatment: the
  `${is3D?warnbox:...}` ternary around its Delete/Restore/Clear buttons is
  gone (always rendered), and the `if(!is3D){...}` wrapper around wiring
  `$('mDel')`/`$('mRestore')`/`$('mClear')` was removed so those three
  always attach their handlers.
- **What deliberately stays 2D-only, and why — not an oversight:**
  1. **Dragging a point to a new position** — this is driven by 2D screen-
     to-world math (`S2W`) with live object-snap under the cursor; the 3D
     oblique projection (`P3`) has no such inverse (the same limitation
     build 30's own zoom-window fix and build 80's orbit-pivot math both
     already had to work around with screen-space-only formulas), so there
     is no way to know where in 3D world space a screen drag should land a
     point without inventing an assumption the app has no basis for.
  2. **The three canvas-click "insert a brand-new point" flows** — Insert
     point on line (`pickSegmentForInsert`), Add Point (COGO) → Pick on
     canvas (`snapPoint`), and ⊙ CTR circle-center picking
     (`startCircleCtrPick`) — all three depend on the same 2D-only object-
     snap primitives (`snapPoint`/`collectSegments`/`collectOffsetSegments`,
     explicitly documented elsewhere in this file as 2D-only, e.g. under
     "Add Point (COGO) canvas pick + CAD snap") for locating an endpoint/
     intersection/midpoint/nearest snap target. These already correctly
     don't render their trigger buttons in 3D (per those sections' own
     `!is3D` guards) — this build doesn't change that, since a canvas-
     click-driven pick still has nowhere valid to resolve to in the oblique
     3D projection.
  - Both of these are the exact same "no world-space inverse for the
    oblique 3D projection" limitation build 30 (Zoom window in 3D) already
    documented and designed around — this build doesn't touch either of
    them, it only unlocks the part of editing that never actually needed
    canvas geometry at all: typing a new value into a field and applying it
    is a plain textbox-to-object write (`applyPointEdit`), the same
    operation in either view.
- **Help surfaces updated so nothing still describes the old restriction:**
  the Inspector's own empty-state note (shown before anything is selected)
  changed from "3D orbits the survey by elevation — inspect only; switch
  back to a 2D tool to edit." to "**3D** orbits the survey by elevation —
  click a point or line to edit its fields right here in the Inspector,
  same as 2D; only dragging to move a point or clicking to insert a new one
  still need a 2D tool. Orbiting re-centers on whatever you click..."; the
  Help modal's **Getting Started** tab 3D bullet dropped "for inspection
  only (no editing)" and gained "Clicking a point or line opens the same
  editable Inspector/figure editor as 2D — only dragging to move a point,
  and clicking to insert a brand-new one, still need a 2D tool."; and
  `HELP_CANVAS_TOOLS`'s `'⟲ 3D'` row was reworded to `'3D orbit view (O) —
  click a point or line to edit it right there, same as 2D; see Getting
  Started for the orbit/pan/zoom controls.'` — confirmed via a full-file
  grep that no "inspect only" / "3D inspect mode" / "switch to a 2D tool"
  text remains anywhere in `index.html` after these edits.
- **Verified two ways in a real headless browser, both against the actual
  live `index.html` code paths, not a reimplementation:**
  1. **Poked-state sweep** — with `is3D=true` and a real point selected,
     confirmed every field's `.disabled` property reads `false` for both a
     control point and a shot point (`fDesc`/`eN`/`eHA`/`eRod` spot-checked
     directly), the Apply/Delete buttons exist with no `warnbox` present;
     editing `#fDesc` and clicking the real `#applyEdit` button actually
     changed the underlying `PTS[i].desc` (verified `"RBCB B"` →
     `"RBCB B RENAMED"`); editing `#eE` and applying it changed
     `PTS[i].E` to the typed value on a real control point; clicking the
     real `#delBtn` flipped `p.deleted` to `true`, and clicking it again
     (now reading "Restore") flipped it back to `false`; confirmed
     `inspectFig`'s own vertex-reorder button is present and enabled in 3D
     (proving the figure editor needed no changes, consistent with the
     investigation above); and a real click on the multi-select panel's
     Delete button in 3D actually deleted the expected count (2) of
     selected points. Zero console errors.
  2. **Real-UI, real-click sweep** (`test_3dedit4.js`) — rather than poking
     `is3D`/`sel` directly, this test clicked the real `#tOrbit` toolbar
     button to actually enter 3D through the UI, computed a target point's
     current on-screen pixel via the app's own live `P3(E,N,Z)` projection
     (not a guess at screen coordinates), and drove real
     `page.mouse.move()`/`.down()`/`.up()` events at that exact pixel — a
     single `page.mouse.click()` had proven unreliable for this canvas's
     pointer handlers in earlier build-80 testing (selection silently
     never happened), so the same move/down/up sequence already proven
     reliable there was reused. Confirmed the real click actually selected
     the target point (`sel` changed to the right index) with the real
     `#fDesc` input now present and enabled; typed a new value into it via
     `page.fill()`, clicked the real `#applyEdit` button, and confirmed
     `PTS[i].desc` updated to the typed text; then clicked the real
     `#delBtn` and confirmed `PTS[i].deleted` flipped to `true` — all
     through actual DOM interaction, immediately after the same test had
     already proven the identical edit flow works through the real UI in
     2D on a different point in the same run, showing the two views now
     behave identically for this purpose. Zero console errors.

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
- **Zoom to point (build 41):** each vertex row's button group has a **⌖**
  button (alongside ▲▼ reorder / ✕ remove) that calls the new `zoomToPoint(i)`
  — pans the view to center that point, zooms in (`view.s=Math.max(view.s,6)`
  in 2D, re-centers `orbit.ox/oy` in 3D), and plays the same gold flash-ring
  animation (`flash`/`drawFlash`) as the toolbar's **⌖ Go to point**. Unlike
  Go to point, it does **not** call `inspect()`/change `sel`/`selFig` — you
  stay on the figure's vertex list instead of getting bounced to the
  single-point inspector, since the point being useful here is jumping the
  *canvas* to a vertex while still mid-edit on the line, not inspecting that
  one point in isolation. `gotoPoint()` (the toolbar button/`G` key) was
  refactored to call the same `zoomToPoint(i)` internally instead of
  duplicating the pan/zoom/flash math — one implementation, two entry points.

## Street View (build 51-53) — embedded panorama with the line's points overlaid

- A **📷 Street View** button gets you a real-world, ground-level view of the
  linework, to eyeball it against reality — the point-in-the-field equivalent
  of the app's existing "compare against a Civil3D `LIST` dump" workflow, but
  for looking at the actual curb/curve instead of a CAD drawing. Two entry
  points, unchanged since build 51: the single-point inspector (`inspect()`)
  gets a **📷 Street View** button (`svOpenForPoint(i)`); every vertex row in
  the figure/line editor (`inspectFig()`) gets a small **📷** button next to
  the existing **⌖** zoom button.
- **Builds 51-52 (superseded by 53, kept here for history):** without a
  Google Maps API key, this opened Google's own Maps *website* in a new/
  reused browser tab at the point's lat/lon (a plain deep-link URL, no key
  needed) — build 52 added Walk/Prev/Next controls to step through a whole
  line's vertices, re-navigating one shared tab instead of spawning a new
  one per click (see the git history for the `noopener`-drop fix that made
  tab-reuse actually work, and the ratio/heading verification from build 51
  — both still apply to the coordinate/heading math below, unchanged).
- **Build 53 — the owner supplied a real Google Maps JavaScript API key, so
  Street View is now a live, embedded, interactive panorama right in the
  app**, not a tab-opening link — a proper Street View panorama in a modal
  (`#svScrim`/`#svPanoDiv`), with **every point of the line overlaid as a
  numbered marker directly on the panorama** (a `Marker`'s `.map` set to a
  `StreetViewPanorama` instead of a plain `Map` — a real, documented
  capability of the classic `Marker` class, whose `map` property type is
  `Map|StreetViewPanorama|null`, and it renders anchored at street level in
  the pano). **Correction, build 59:** this section originally cited
  Google's own `streetview-overlays` sample as the source for that
  technique — that citation was wrong; see build 59 below for what that
  sample actually shows and what changed as a result (obtaining the
  panorama itself, not the marker-overlay technique, which is unaffected).
  This is a strict upgrade, not an alternate
  mode — the old tab-opening `openStreetView` is gone (the embedded panorama
  needs the same `surveyToLL` coordinate transform anyway and is simply
  better once a key exists), but `streetViewURL` itself lives on as an
  automatic fallback: if the panorama never loads (bad/quota'd key, no
  network), `openSvModal` swaps the modal's content for a plain
  `streetViewURL` link the user can open in a new tab instead of a dead,
  permanently-loading modal.
  - **No keyless path exists for this API** (unlike the deep-link URL
    builds 51/52 used) — `google.maps.StreetViewPanorama` only loads via
    `<script src="https://maps.googleapis.com/maps/api/js?key=...">`, a
    real Google Cloud Maps JavaScript API key with billing enabled. The key
    is embedded directly in `index.html`'s closing `<script async
    src=".../js?key=AIzaSy...">` tag — this is normal/expected for this API
    (Maps JS keys are meant to be restricted by **HTTP referrer**, not kept
    secret; they're visible in every page's source by design). If you
    (the owner) ever rotate this key, that's the one line to update.
  - **Core pieces:** `ensureGMaps(cb)` polls (every 150ms, up to ~22s) until
    `google.maps.StreetViewPanorama` exists before doing anything with it —
    handles the async script tag's load race with the user clicking a
    Street View button before it's ready. `svLatLng(p)` wraps `surveyToLL`
    in a `google.maps.LatLng`. `svShowMarkers(vs)` clears any previous
    markers and drops one numbered marker per vertex of the CURRENT line
    onto the panorama. `svGoto(idx)` moves the live panorama's position +
    heading (`setPosition`/`setPov`, reusing the same `headingAt` compass
    math from build 51) and updates the `pt <id> · <k>/<n>` label and the
    modal's own Prev/Next `disabled` state at both ends. `openSvModal(vs,
    idx)` is the one entry point both `svOpenForPoint` (single-point
    inspector, a 1-vertex "line") and the figure inspector's **📷 Walk line
    in Street View** button / per-vertex **📷** buttons call — always
    passing the relevant line's own vertex list, so Prev/Next in the modal
    step through that same line's real vertex order.
  - **A real bug found and fixed along the way:** clicking the modal's
    Prev/Next before the async Maps script had actually finished loading
    threw `Cannot read properties of null (reading 'setPosition')` —
    `svPano` (the panorama object) only gets created inside `ensureGMaps`'s
    callback, so a click landing before that resolved called `svGoto` on a
    still-`null` panorama. Fixed two ways: `svGoto` now no-ops entirely if
    `svPano` isn't ready yet (`if(!svPano||!svCtx)return;`), and
    `openSvModal` explicitly disables both nav buttons the moment the modal
    opens (before `ensureGMaps` even starts polling), only re-enabling them
    once `svGoto` actually runs for the first time — so the loading state is
    also visually obvious (`"Loading Street View…"` placeholder text stays
    in `#svPanoDiv` until the panorama constructor replaces it), not just
    silently unresponsive.
  - **A real, disclosed verification gap:** this sandbox's own network
    policy blocks outbound connections to Google's domains entirely —
    confirmed directly via the agent-proxy's own status endpoint, which
    logged repeated `403 policy denial` (on `www.google.com`,
    `android.clients.google.com`, `redirector.gvt1.com`) and
    `tunnel closed (code 1006)` failures specifically against
    `maps.googleapis.com` and `accounts.google.com` while testing this
    build — a plain `curl` to the bare `maps.api.js` URL had returned 200
    (misleadingly, since that's a different, simpler connection than what
    Chromium's full page-load actually triggers). Per this sandbox's own
    "don't retry policy denials" rule, live end-to-end verification of the
    ACTUAL panorama imagery + marker rendering was not possible from here.
    Everything that WAS reachable from this sandbox was verified: the
    inline script still parses; the modal opens and closes cleanly from
    both entry points with no stray DOM/state left over; Prev/Next/Close
    never throw, including the premature-click race above; and a full
    sweep clicking **every** Street View entry point (the figure-level Walk
    button plus every per-vertex 📷 button) across the first 30 figures of
    BOTH real job files — 241 clicks on Hamline, 215 on Dale — produced
    zero console errors. **The owner still needs to confirm, in a real
    browser with actual internet access, that the panorama image and
    numbered point markers actually render and that Prev/Next visibly move
    the view** — that part of this build is unverified by me.
  - The one part of this THAT WAS fully end-to-end verifiable despite the
    blocked network is the fallback path itself, since `ensureGMaps` giving
    up after ~22s is exactly what this sandbox's Google block triggers on
    every attempt: waited it out for real and confirmed `openSvModal` swaps
    in the exact right `streetViewURL` fallback link (same lat/lon/heading
    the old build-51/52 tab-opener would have used) with zero errors. This
    surfaced a real, separate layout bug: the fallback message and link
    landed on the SAME visual line, `<br>` ignored — `#svPanoDiv` is a flex
    container (`display:flex`, for centering the "Loading…" placeholder),
    and a `<br>` between two DIRECT flex-item children doesn't force a line
    break the way it does in normal block flow. Fixed by wrapping the
    fallback content in its own nested block `<div>` (a single flex item,
    behaving as ordinary block content internally) instead of two bare
    text/`<br>`/`<a>` nodes as direct flex children — confirmed fixed with
    a real screenshot, message and link now stack on separate lines.
  - **A second caveat for local testing specifically:** if the API key is
    restricted to specific HTTP referrers (the standard/recommended setup)
    and you test by double-clicking `index.html` locally, it will likely
    fail to load — a `file://` page sends no `Referer` header at all, so it
    can't match any referrer restriction. Local testing needs either a
    temporary unrestricted (or `file://`-inclusive, if Google's console
    supports that) key, or serving the page from an actual domain the key's
    restriction allows.
  - **Build 54 fix — inverted panorama colors:** the owner's first real
    (non-sandboxed) test of build 53 confirmed the panorama and markers DO
    render, but the photo's colors came back inverted — a negative — while
    nothing else in the app looked wrong. That asymmetry (only the
    panorama, not the rest of an otherwise-normal page) points at Chrome's
    own "Force Dark Mode for Web Content" heuristic (or a Dark-Reader-style
    extension doing the same thing): it tries to auto-darken pages for
    users who want dark mode everywhere, and it recognizes plain `<img>`
    photos well enough to leave them alone, but a Maps `StreetViewPanorama`
    renders its imagery through WebGL/canvas, which that heuristic can't
    reliably identify as "already a photo" — so it inverts it like it would
    invert a plain white background, while the rest of our page (ordinary
    HTML/CSS) gets recolored correctly and looks fine. Fixed by adding
    `color-scheme:light;forced-color-adjust:none` directly to `#svPanoDiv` —
    both properties tell the browser this element is deliberately
    light-themed content that its automatic dark-mode/forced-colors
    machinery shouldn't touch. Verified via computed style in a real
    headless browser that both properties land as set with no console
    errors (the sandbox's Google-domain block still prevented seeing the
    actual before/after photo, so the owner should confirm the panorama
    now renders in true color).
  - **Marker alignment — still open, intentionally not touched yet:** the
    owner also reported the markers don't line up well with the real curb.
    Deliberately not guessing at a fix here without seeing it first — this
    could be a real bug in our coordinate math, OR it could be ordinary
    Street View camera-vs-curb parallax (the panorama photo is taken from
    wherever Google's imagery car actually drove down the street, which is
    essentially never the exact curb line a marker sits on a few feet away
    — a well-known, unavoidable characteristic of Street View, not
    something fixable in our code). Waiting on a screenshot before touching
    `svLatLng`/`svShowMarkers`/the `surveyToLL` transform.
  - **Build 58 — ↗ New tab button:** after the owner found a Dark Reader
    regression report (`darkreader/darkreader#14919`) confirming that
    extension can independently invert Street View/Maps imagery it's
    supposed to leave alone — a bug in the extension itself, separate from
    and not fixable by anything in build 54's `color-scheme`/
    `forced-color-adjust` fix, which only targets Chrome's own native
    forced-dark-mode heuristic — the modal header got a small **↗ New tab**
    button next to Close. It opens the real Google Maps site (in a fresh
    tab, `noopener`) at the CURRENT point (`svCtx.idx`, tracked by Prev/
    Next) via the same `streetViewURL`/`headingAt` deep-link math builds
    51/52 used before the embedded panorama existed — that code was never
    removed, just relegated to the build-53 no-panorama fallback, and now
    has a second, always-available entry point. Since `svCtx` is set
    synchronously in `openSvModal` before the async Maps script even starts
    loading, this button works immediately, even if the embedded panorama
    never loads at all (e.g. this sandbox's own Google-domain block).
    Verified via a real headless-browser test on both real job files:
    opened a mid-line vertex and a plain control point through the actual
    UI, intercepted `window.open`, confirmed the URL/target/`noopener`
    exactly match `streetViewURL`/`headingAt` computed independently for
    that same point — zero console errors.
  - **Build 59 — panorama now obtained via `map.getStreetView()`, matching
    Google's real sample:** the owner pointed at the actual
    `streetview-overlays` example on `developers.google.com` to double-check
    our marker-overlay approach against. `developers.google.com` is blocked
    from this sandbox exactly like `maps.googleapis.com`, but the identical
    sample source lives in the public `googlemaps/js-samples` GitHub repo
    (`samples/streetview-overlays/index.ts`) and IS fetchable — reading the
    real, current file there showed it does something different from what
    this section (and build 53's original writeup) claimed: it places
    markers on a plain `google.maps.Map`, then toggles a **separate**
    Street View panorama obtained via `map.getStreetView()` visible/
    invisible over that same div — it never assigns a marker's `.map` to a
    panorama at all. Copying that literally would have dropped every
    vertex marker from the panorama (a `Map`'s own markers don't appear
    once its panorama takes over the div) — exactly the opposite of what
    this feature exists for, so a straight copy was rejected. Fix instead
    adopts the ONE piece of that sample that's genuinely an improvement —
    obtaining the panorama via `new google.maps.Map($('svPanoDiv'),
    {center,zoom,streetViewControl:false})` → `.getStreetView()` →
    `.setOptions({...})` → `.setVisible(true)`, in place of build 53's
    direct `new google.maps.StreetViewPanorama(...)` (a construction this
    sample never uses) — while leaving the marker-overlay piece completely
    untouched: `svShowMarkers` still does `new google.maps.Marker({...,
    map:svPano})`, unchanged since build 53. `svPano` caching (`if(!svPano)`
    guards the whole Map/getStreetView setup) is unchanged, so the second
    and later modal opens still just reuse it. Verified structurally with a
    mocked `google.maps` (`Marker`/`Map`/`Panorama` faked, `StreetViewPanorama`
    rigged to throw if ever called directly): the real call order on first
    open is `Map ctor → getStreetView → pano.setOptions → pano.setVisible
    (true) → one Marker({map:pano}) per vertex → pano.setPosition/setPov`,
    with the direct-constructor path never invoked; Prev/Next still only
    calls `setPosition`/`setPov` on the cached pano; the build-58 New-tab
    button is unaffected; opening the modal again for a different figure
    correctly skips rebuilding the Map and reuses the cached panorama — all
    confirmed on both real job files, zero console errors. The genuine,
    real-browser rendering of markers directly on a `StreetViewPanorama`
    (a documented Marker-class capability, independent of this specific
    sample) is still unverified from this sandbox, same standing caveat as
    build 53 — this fix only changes how the panorama itself is obtained.
  - **Build 72 (🍇 GRAPE) — UNVERIFIED, on its own branch
    (`claude/streetview-color-test`), NOT merged to main:** the owner pasted
    a third-party ("AI-generated") suggested fix for the inverted-colors
    issue, claiming `index.html`'s script was truncated and needed a
    restored `openCogoDialog`/`handleCogoInsert` block, plus dropping
    `color-scheme:light;forced-color-adjust:none` off `#svPanoDiv` in favor
    of a `filter:none` rule. Checked both claims against the real file
    before touching anything: the script is NOT truncated (`node --check`
    passes, and `openCogoDialog`/`insertCogoPoint` already exist, fully
    implemented, further down the same file — including the B/E-token-move
    logic on the figure's endpoint this pasted snippet's `handleCogoInsert`
    doesn't do at all, a real functional regression had it been pasted in
    verbatim) — so that whole "restore the missing code" premise was
    rejected outright, and the JS block was NOT applied. Also declined to
    remove `color-scheme`/`forced-color-adjust` from `#svPanoDiv`, since
    that's the exact property build 54 already verified (via computed
    style in a real headless browser) stops Chrome's own forced-dark-mode
    heuristic from inverting the panorama — removing it would undo a
    confirmed fix on the strength of an unverified suggestion.
  - The one piece worth actually trying: **adding** (not replacing)
    `filter:none!important` to `#svPanoDiv`, alongside the existing
    `color-scheme`/`forced-color-adjust` properties — a low-risk, purely
    additive CSS change that can't regress anything already working, in
    case some other browser/extension path inverts via a CSS `filter`
    rather than the forced-dark-mode heuristic build 54 already covers.
    Put on its own branch specifically because it's UNTESTED: this
    sandbox's own network policy blocks Google's domains entirely (the
    same standing limitation documented under build 53/58 above), so
    there is still no way to visually confirm from here whether this
    changes anything — a separate branch means it can't accidentally reach
    `main` before the owner has actually looked at it in a real browser.
    **If the owner still sees inverted colors after pulling this branch,
    check with any Dark Reader / forced-dark-mode browser extension
    disabled for the page first** — build 58 already traced a real, linked
    upstream bug (`darkreader/darkreader#14919`) in that exact extension
    independently inverting Street View/Maps imagery, which no CSS on our
    side can fix. Only merge this branch into `claude/street-view-linework`/
    `main` once the owner confirms in their own browser that it actually
    helps — do not merge on the strength of this write-up alone.
  - **Build 73 (🍓 STRAWBERRY) — still UNVERIFIED, same branch
    (`claude/streetview-color-test`), still NOT merged to main:** the
    owner asked specifically to try a **pre-invert** on `#svPanoDiv`
    instead — the standard workaround for content that's getting
    color-inverted by something outside our control (a browser's forced-
    dark heuristic, or a dark-mode extension in "filter" mode): apply our
    OWN `invert(1)` (plus `hue-rotate(180deg)`, needed alongside `invert()`
    to land back on the original hue rather than a color-rotated version —
    the same pairing Dark Reader's own "Filter" mode and most manual
    dark-mode counter-invert tricks use) to the panorama's container, so
    that if something else inverts it a second time on top, the two
    cancel out and the photo reads correctly again. Replaced build 72's
    `filter:none!important` (a no-op once nothing else is inverting)
    with `filter:invert(1) hue-rotate(180deg)` on `#svPanoDiv` — still
    additive to, not a removal of, the build-54 `color-scheme`/
    `forced-color-adjust` properties, which stay untouched.
  - **Real tradeoff to flag, not hidden in the diff:** this is a genuine
    double-edged change, unlike build 72's inert `filter:none`. If
    something really is externally inverting the panorama, this should
    cancel it back to normal. But if the owner's browser ISN'T inverting
    it (build 54 alone already fixed it, or their setup never triggered
    the issue at all), this filter would make the photo wrong on its own
    — visibly inverted where it wasn't before. There's no way to tell
    which case applies from this sandbox (still blocked from Google's
    domains, so the actual panorama pixels are unverifiable from here
    either way) — this is exactly why it's a separate, unmerged branch:
    the owner needs to look at it in a real browser and report back
    whether colors are now correct, still off, or newly wrong, before
    any of this lands on `main`.
  - Verified only what's checkable without seeing Google's servers: the
    inline script still parses (`node --check`), the computed
    `filter:invert(1) hue-rotate(180deg)` lands on `#svPanoDiv` exactly as
    written, and a redraw of all 3 original real job files (figure counts
    70/99/161, unchanged) produces zero console errors beyond the
    pre-existing, already-documented map-tile network block.
  - **Build 74 (🍒 CHERRY) — replaces build 73's speculative pre-invert,
    still on `claude/streetview-color-test` only, still NOT merged:** the
    owner uploaded a fix a DIFFERENT AI had produced against this same
    repo (`index_streetview_color_fixed.html`) and asked to check whether
    it actually resolves the color issue. Diffed it directly against the
    real file first (`diff`, not a description) — unlike the earlier
    pasted third-party suggestion (declined, see the build-72 entry
    above), this one turned out to be a small, real, purely-additive CSS
    diff with no fabricated/duplicated JS and nothing removed: ~20 new
    lines of stylesheet plus a few extra inline properties on `#svPanoDiv`
    itself, everything else byte-identical.
  - **What it does differently from build 72/73's attempts:** rather than
    a blind `filter:none` (build 72) or a blind pre-invert (build 73), it
    neutralizes filter/blend-mode effects on `#svPanoDiv` **and everything
    Google's own JS mounts inside it** — its `.gm-style` wrapper, any
    `canvas`, any `img` — via a new stylesheet block
    (`#svPanoDiv,#svPanoDiv *{filter:none!important;mix-blend-mode:
    normal!important;forced-color-adjust:none!important}` plus a
    `.gm-style`/`canvas`/`img`-specific rule with the same properties),
    and adds `isolation:isolate` to give `#svPanoDiv` its own stacking
    context — relevant because a `mix-blend-mode`-based "smart invert"
    (some dark-mode implementations apply `mix-blend-mode:difference`
    against a full-page overlay, a mechanism build 54's `color-scheme`/
    `forced-color-adjust` fix was never aimed at, since that only covers
    Chrome's own forced-dark heuristic) can't composite through an
    isolated stacking context the same way. Also upgrades
    `color-scheme:light` to **`color-scheme:light only`** — the `only`
    keyword is a stronger signal per spec, telling the browser never to
    render this element as dark even under forced-colors, not just
    "prefer light."
  - **One piece of the uploaded fix deliberately NOT kept:** it also set
    `background:#fff!important` on `#svPanoDiv`. Checked what that does to
    the "Loading Street View…" placeholder and the no-panorama fallback
    link — both use `color:var(--mut)` (`#8a99b8`, a medium blue-gray)
    inline on the div, chosen for contrast against the div's own dark
    `#0a1426` background; forcing white would leave that same gray text
    sitting on white with materially worse contrast for as long as the
    placeholder/fallback is showing (which, per build 53, can be the
    ~22s `ensureGMaps` timeout or longer on a bad connection — not just a
    one-frame flash). Not needed for the actual anti-inversion mechanism
    either (`filter`/`mix-blend-mode`/`isolation` are unrelated to the
    container's own background color) — so it was dropped, keeping the
    original `#0a1426` background, confirmed via computed style
    (`backgroundColor: rgb(10,20,38)`, i.e. `#0a1426`, unchanged) and a
    real screenshot showing the loading placeholder still reads clearly.
  - **Real tradeoff, still disclosed honestly:** this REPLACES build 73's
    filter (a live `google.maps.Map`/panorama mount will now render with
    whatever colors Google's own imagery actually has, no correction
    applied) rather than layering on top of it — the two are mutually
    exclusive (one resets to neutral, the other actively inverts) so only
    one can be live at a time, and this one was judged the more
    defensible bet: it targets the SPECIFIC DOM structure Google Maps
    actually mounts (`.gm-style`, `canvas`, `img`) instead of guessing at
    a blanket transform, and it can only help or do nothing — unlike
    build 73's pre-invert, it has no failure mode where it makes a
    correctly-rendering photo wrong. Still fundamentally unverifiable
    from this sandbox (same standing Google-domain network block as every
    Street View build since 53) — needs the owner to check in a real
    browser before merging anywhere.
  - Verified everything checkable without live Google imagery: `node
    --check` on the extracted script; the computed style on `#svPanoDiv`
    shows every targeted property landing exactly as written
    (`color-scheme:"light only"`, `filter:"none"`, `mix-blend-mode:
    "normal"`, `isolation:"isolate"`, background unchanged at `#0a1426`)
    across all 3 original real job files, unchanged figure counts
    (70/99/161), zero new console errors; and a real-UI open of the
    Street View modal (via `svOpenForPoint`) on a real point shows the
    modal, header, New tab/Close buttons, and the (still-loading, since
    this sandbox can't reach Google) placeholder all rendering normally
    with the expected dark background and readable placeholder text.
  - **Build 75 (🥝 KIWI) — real regression found in build 74, fixed, still
    on `claude/streetview-color-test` only, still NOT merged:** the owner
    pulled build 74 into a real browser and confirmed the colors ARE
    fixed, but reported a new problem: orbiting/panning inside the live
    Street View panorama makes it go black. Build 74's stylesheet had two
    rules touching every descendant of `#svPanoDiv`, not just the
    container: `#svPanoDiv,#svPanoDiv *{filter:none!important;
    mix-blend-mode:normal!important;forced-color-adjust:none!important}`
    and a second rule forcing the same on `.gm-style`/`canvas`/`img`
    specifically, plus `opacity:1`. That `mix-blend-mode:normal!important`
    landing on EVERY element inside the live panorama — including
    whatever internal layers Google's own renderer uses to cross-fade or
    stitch newly-loading tiles together as the view moves — is almost
    certainly what broke it: a panorama tile mid-load/mid-blend needs its
    OWN blend mode (screen/lighten/whatever Google's renderer actually
    uses for that transition) to composite correctly, and a page-level
    `!important` rule reaching into Google's own DOM and force-resetting
    it to `normal` on every element would show up exactly as described —
    fine once everything's settled, black while new tiles are actively
    loading/blending during a pan or orbit.
  - **The actual fix only ever needed to touch the CONTAINER, never its
    descendants:** `isolation:isolate` on `#svPanoDiv` alone is what
    blocks an ancestor's blend-mode-based invert trick from compositing
    through in the first place (it gives the element its own stacking
    context, so nothing outside that subtree can blend against anything
    inside it) — forcing `mix-blend-mode:normal`/`opacity:1` on every
    descendant was never necessary to achieve that, and is exactly what
    broke Google's own tile compositing. Removed BOTH build-74 rules
    entirely (`#svPanoDiv,#svPanoDiv *{...}` and the `.gm-style`/`canvas`/
    `img`-specific one) and replaced them with a single container-only
    rule: `#svPanoDiv{color-scheme:light only!important;isolation:isolate;
    filter:none!important;forced-color-adjust:none!important}` — no `*`
    selector, no `mix-blend-mode` anywhere, nothing targeting anything
    inside `#svPanoDiv` at all. Also dropped the matching
    `mix-blend-mode:normal!important` build 74 had added to `#svPanoDiv`'s
    own inline style (the container's inline style still keeps
    `filter:none!important`/`isolation:isolate` — only the blend-mode
    piece was removed, everywhere).
  - Verified the fix actually stops touching descendants: appended a
    synthetic child `<div>` inside `#svPanoDiv` with its own
    `mix-blend-mode:screen` set directly, then read its COMPUTED style —
    it correctly comes back `screen`, not forced to `normal`, confirming
    nothing in our CSS reaches into the panorama's own DOM anymore, while
    the container itself still shows the intended `filter:"none"`,
    `isolation:"isolate"`, `color-scheme:"light only"`. Re-ran across all
    3 original real job files: figure counts unchanged (70/99/161), zero
    new console errors, and a real-UI open of the Street View modal still
    renders normally (modal, header, buttons, placeholder). Still can't
    verify the ACTUAL live-panorama pan/orbit behavior from this sandbox
    (same standing Google-domain block) — the owner needs to confirm in
    their own browser that orbiting no longer goes black before this
    merges anywhere.
  - **Build 76 (🍑 PEACH) — build 75 overcorrected, real color regression
    reported, fixed narrower, still on `claude/streetview-color-test`
    only, still NOT merged:** the owner pulled build 75 and reported the
    inversion is BACK. That's a genuinely useful data point, not just
    "still broken": it means build 74's descendant-level reset wasn't
    purely redundant with the container's `isolation:isolate` after all —
    something (a browser/extension "smart invert" heuristic) applies its
    own counter-invert filter **directly to the panorama's own `<canvas>`/
    `<img>` leaf elements**, not as a blend coming from OUTSIDE
    `#svPanoDiv`. `isolation:isolate` on the container only blocks an
    ANCESTOR's blend-mode effect from compositing INTO the isolated
    subtree from outside it — it does nothing to stop an effect applied
    directly to an element that's already inside that subtree, which is
    exactly what build 75 left unguarded once it removed every
    descendant-targeting rule.
  - **The real distinction build 74 never made:** build 74's mistake
    wasn't resetting `canvas`/`img` — that part was doing real work and
    build 75 was wrong to remove it. The mistake was resetting `.gm-style`
    and, worse, EVERY `.gm-style>div` and EVERY `#svPanoDiv *` alongside
    it — the plain wrapper `<div>` layers Google's own renderer uses to
    cross-fade/stitch tiles together while panning, which is what
    actually broke orbiting. Fix: put back a `filter`/`mix-blend-mode`
    reset scoped ONLY to `#svPanoDiv canvas,#svPanoDiv img` — the two leaf
    element types that actually render pixels and are the plausible
    target of a per-element counter-invert heuristic — while leaving every
    generic `<div>` (`.gm-style` included) completely untouched, so
    nothing in Google's own tile-blending layers gets interfered with.
    The container-level rule from build 75 (`isolation:isolate;
    filter:none!important;forced-color-adjust:none!important;
    color-scheme:light only!important`) is unchanged — this build only
    adds back the narrower leaf-element rule.
  - Verified the split holds exactly as intended: appended 3 synthetic
    elements inside `#svPanoDiv` — a plain `<div>` with its own
    `mix-blend-mode:screen` (simulating a Google tile-wrapper layer), and
    a `<canvas>`/`<img>` each with an injected `mix-blend-mode:screen` AND
    `filter:invert(1)` (simulating a counter-invert landing directly on
    them) — then read all 3 back via computed style. The plain `<div>`
    correctly KEEPS `mix-blend-mode:screen` untouched (confirms orbiting
    stays fixed); the `<canvas>` and `<img>` both correctly come back
    `filter:"none"`/`mix-blend-mode:"normal"` (confirms the counter-invert
    gets cancelled). Container-level properties unchanged from build 75.
    Re-ran across all 3 original real job files: figure counts unchanged
    (70/99/161), zero new console errors, Street View modal still opens
    normally through the real UI. Still fundamentally unverifiable from
    this sandbox (same standing Google-domain block) — needs the owner to
    confirm BOTH things at once in a real browser (correct colors AND
    smooth orbiting) before this merges anywhere.
  - **Build 77 (🍍 PINEAPPLE) — a pattern finally emerged across 3 real
    reports, still on `claude/streetview-color-test` only, still NOT
    merged:** the owner pulled build 76 and reported it worked briefly,
    then the viewer went black specifically when the numbered markers
    appeared — a THIRD distinct trigger (not orbit this time) for the same
    "goes black" symptom. Lined up all 3 real-browser reports so far:
    - Build 74 (reset `canvas`+`img`+every wrapper `<div>`) → black on
      **orbit**.
    - Build 75 (reset **nothing**, container only) → color regression,
      but **never** went black.
    - Build 76 (reset `canvas`+`img` only, no `<div>`s) → black on
      **markers appearing**.
    The one thing every black-out build has in common is resetting
    `<canvas>`; the one build that never touched `<canvas>` never went
    black either, regardless of what else was reset. That's the real
    signal, not "orbit" vs "markers" specifically — both are just
    different moments Google's own script re-touches the live panorama's
    rendering state (a fresh tile reload on pan, mounting overlay DOM for
    markers), and apparently BOTH moments involve Google legitimately
    restyling its own `<canvas>` — which our `!important` reset was
    fighting either way, with the black-out surfacing at whichever moment
    happened to trigger it first in each build.
  - **Working theory, now better-supported:** Street View likely still
    uses (at least in part) a classic DOM `<img>`-tile-mosaic rendering
    path, not purely WebGL-canvas — so `<img>` is plausibly where the
    real counter-invert actually lands, and `<canvas>` was never needed
    for the color fix at all; it's a separate element Google's own script
    manages for its own purposes at exactly the moments that were going
    black. Fix: dropped `canvas` from the reset selector entirely — now
    only `#svPanoDiv img{filter:none!important;mix-blend-mode:
    normal!important}`, leaving BOTH `<canvas>` and every wrapper `<div>`
    completely untouched (previously only `<div>` was spared).
  - Verified with the same synthetic-element technique as build 76, one
    step further: a plain `<div>` AND a `<canvas>`, each given their own
    injected `filter:invert(1)`/`mix-blend-mode:screen`, BOTH now survive
    completely untouched (computed style still reads back `invert(1)`/
    `screen` on both) — confirming nothing in our CSS reaches `<canvas>`
    anymore, not even indirectly; only a synthetic `<img>` with the same
    injected properties gets correctly reset to `filter:"none"`/
    `mix-blend-mode:"normal"`. Figure counts unchanged (70/99/161) across
    all 3 real job files, zero new console errors, Street View modal still
    opens normally. **This is now the 4th CSS-only iteration and still
    unverifiable from this sandbox** — if this build still goes black at
    some interaction, the useful next piece of information isn't another
    guess, it's the actual browser console output at the moment it turns
    black (any error Google's own script throws) and which extensions are
    active, since blind CSS iteration is reaching the point of diminishing
    returns without that.
- **THE REAL ROOT CAUSE, FINALLY FOUND — builds 72-77's whole CSS chase
  was solving the wrong problem.** The owner pulled the actual browser
  console output at last, and it contains the real answer, buried under
  a harmless `google.maps.Marker` deprecation warning (noise, not the
  cause — that API still works fine, just discouraged in favor of
  `AdvancedMarkerElement`):
  ```
  You must enable Billing on the Google Cloud Project at
  https://console.cloud.google.com/project/_/billing/enable
  ```
  This is a hard failure from Google's Maps JS API itself: **the API
  key's Google Cloud project has no billing account enabled**, so the
  Street View service can't actually load/render properly at all. This
  is not a CSS bug, was never a CSS bug, and no CSS on our side can fix
  it — it's an account-level setting on Google's side, outside the
  codebase entirely.
- **This retroactively explains every symptom chased across builds
  72-77:** without billing enabled, the panorama service degrades or
  errors out, and whatever broken/fallback rendering state results from
  that is inherently unstable — which of our CSS filter/blend-mode
  tweaks happened to be active at the time could easily make that
  already-broken output LOOK inverted one moment and black the next,
  purely as a side effect, without any of it ever being a genuine
  "correct colors vs. broken rendering" tradeoff in the first place. The
  entire build 72→77 sequence (`filter:none`, then `invert()`, then
  neutralize-everything, then narrow to canvas+img, then drop canvas,
  then owner reports colors reverted) was pattern-matching against a
  moving target that was never going to converge, because the actual
  cause was never in scope for a CSS fix to begin with.
- **The fix is entirely outside this repo:** the owner needs to enable
  billing on the Google Cloud project tied to the Street View API key
  (`console.cloud.google.com` → select the project → enable billing —
  Google Maps includes a monthly free credit, so light use like this
  typically stays free, but a payment method has to be on file
  regardless of usage level for the API to function past its free
  trial/dev-mode restrictions).
- **Next step, deliberately NOT another CSS push:** once billing is
  enabled, the owner should retest Street View on the CLEAN, pre-chase
  baseline — `claude/street-view-linework` (build 71, before any of
  builds 72-77's filter/mix-blend-mode changes) — to see the real,
  unmodified behavior with a properly-functioning API. If it renders
  correctly on its own with billing enabled and zero CSS hacks, every
  build on `claude/streetview-color-test` (72-77) was solving a phantom
  and should be discarded rather than merged — there is no reason to
  carry speculative, already-proven-unstable CSS overrides for a
  problem billing alone resolves. If something is still genuinely wrong
  once billing is confirmed enabled, THAT would be the first real signal
  worth chasing, since it would no longer be confounded by an API
  that's failing to load in the first place.
- **Build 78 — independent invert overlay, instead of a 5th round of direct
  CSS on `#svPanoDiv`:** the owner asked to add a color-inverting filter
  "on top, independent from the app" rather than resume touching
  `#svPanoDiv`'s own properties. Builds 74-77 all set `filter`/
  `mix-blend-mode` directly on `#svPanoDiv` or its descendants (`canvas`/
  `img`), and every one of those attempts risked fighting Google's own
  dynamic style updates on those SAME elements (the orbit/marker black-out
  regressions build 75-77 chased) — even though the root cause turned out
  to be billing, not CSS, the underlying risk of touching Google-managed
  elements directly is real and worth avoiding regardless.
  - `#svPanoDiv` is now wrapped in `#svPanoWrap` (`position:relative`), and
    a brand-new sibling `<div id="svInvertOverlay">` — never a child of
    `#svPanoDiv`, never touching anything inside it — sits absolutely
    positioned over it (`inset:0`) with `mix-blend-mode:difference` against
    a white `background`. Blending white in `difference` mode against
    whatever's underneath produces a full color inversion of everything
    the overlay covers, achieved entirely by the overlay's OWN properties —
    zero properties are set on `#svPanoDiv` or any element Google's script
    manages. `pointer-events:none` on the overlay means it never blocks
    dragging/clicking to look around inside the actual panorama.
  - Because it's a sibling, not a child, it's immune to BOTH ways
    `#svPanoDiv`'s content changes: `new google.maps.Map($('svPanoDiv'),...)`
    mounting the panorama, and the no-key/no-network fallback path's
    `$('svPanoDiv').innerHTML=...` swap — neither can wipe out or interact
    with the overlay, since it was never inside `#svPanoDiv` to begin with.
  - A new **Invert colors** checkbox (`#svInvertChk`) in the Street View
    modal's header toggles `svInvertOn` (a plain global, default `true` per
    the owner's request) and calls `syncSvInvertOverlay()`, which just
    toggles the overlay's `.on` class (`display:block`/`none`) and the
    checkbox's `checked` state to match. `openSvModal` calls
    `syncSvInvertOverlay()` every time it opens, so the toggle's state
    (which persists across opens/closes for the session, same pattern as
    `labelShow`/`snapEnabled`) is always reflected correctly the moment the
    modal shows, regardless of which point/line it's opened for.
  - All of build 74-77's direct `filter`/`mix-blend-mode` resets on
    `#svPanoDiv img` are removed — the CSS comment block above `#svPanoDiv`
    now explains why. Build 54's `color-scheme:light only`/
    `forced-color-adjust:none` on `#svPanoDiv` itself is kept exactly as-is
    — that's a real, separately-confirmed fix for a genuinely different
    problem (Chrome's forced-dark-mode heuristic misreading the panorama's
    canvas as needing auto-inversion), not part of the builds-74-77 chase,
    and not something this overlay approach has any reason to touch.
  - Verified end-to-end through the real UI in a real headless browser (the
    actual `openSvModal` call path, real DOM clicks on `#svInvertChk`, not
    poked state): overlay/wrapper/checkbox all present; opening the modal
    syncs the overlay to visible (`display:block`, computed
    `mix-blend-mode:difference`, white background) and the checkbox to
    checked (default ON); a real click un-checks both the checkbox and the
    overlay's `on` class; a second real click re-checks both; closing and
    reopening the modal for a different point preserves the ON state
    (confirming the session-persistent toggle); `#svPanoDiv`'s own computed
    style now shows plain unforced browser defaults (`filter:"none"`,
    `mix-blend-mode:"normal"`) alongside the still-intact `color-scheme:
    "light only"`; script parses (`node --check`); zero console errors
    beyond the pre-existing, already-documented Google-domain network
    block that every Street View section in this project already discloses
    (this sandbox still can't load the real Maps JS script or reach
    `cbk0.google.com`, so the actual live panorama imagery — whether the
    invert genuinely looks right now, and whether it's even still needed
    post-billing-fix — is unverified from here, same standing caveat as
    every build since 51).
  - **Still on `claude/streetview-color-test` only, still not merged.** The
    owner should test this with billing now enabled (per the section
    above) and decide: if Street View already renders correctly with the
    invert toggled OFF, this whole branch (72-78) may no longer be needed
    at all and the clean `claude/street-view-linework` baseline (build 71)
    is probably the better one to keep using; if the invert genuinely still
    helps, this build at least makes it a deliberate, safe, independent
    toggle instead of another guess baked directly into Google's own
    elements.
- **Build 79 — the overlay follows the panorama into real (native)
  fullscreen:** the owner confirmed build 78's overlay works, then clicked
  Google's own native fullscreen control on the panorama and asked for the
  invert to keep applying there too. The real browser Fullscreen API only
  ever paints DESCENDANTS of the element `requestFullscreen()` was called
  on — build 78's overlay is deliberately a SIBLING of `#svPanoDiv` (so it
  can't fight Google's own style updates on that element), which means
  once the panorama actually goes fullscreen, the overlay — sitting
  outside that subtree — stops being painted at all, even though its own
  `.on`/display state never changed.
  - `svSyncOverlayFullscreen()`, wired to `fullscreenchange` (and the
    `webkit`-prefixed variant), checks `document.fullscreenElement`
    against `#svPanoDiv` three ways — equal to it, a descendant of it, or
    an ancestor containing it — since Google's own fullscreen control
    could plausibly target `#svPanoDiv` itself or some internal wrapper it
    creates in/around it, and this doesn't need to know which. When the
    browser is fullscreen on any of those, the overlay is reparented
    directly INTO the fullscreen element (`appendChild`, safely a no-op if
    already there) and switched to `position:fixed` (so `inset:0` covers
    the real fullscreen viewport rather than `#svPanoWrap`'s now-irrelevant
    box) with a max z-index so it stacks above whatever Google renders
    there. Leaving fullscreen reparents it straight back into
    `#svPanoWrap` at `position:absolute` — build 78's exact baseline.
    `pointer-events:none` is unchanged, so the overlay never blocks the
    native exit-fullscreen control.
  - **Verification is split, honestly:** this sandbox's headless Chromium
    can't reliably fire a REAL `requestFullscreen()` without a genuine
    user gesture the automated test can't produce, so `svSyncOverlayFullscreen`
    itself was tested directly against a mocked `document.fullscreenElement`
    (`Object.defineProperty`) — confirming the function's own logic is
    correct in all 3 fullscreen-target cases (on `#svPanoDiv` itself, on a
    synthetic descendant simulating an internal Google wrapper, and back
    to normal on exit), and that the Invert-colors checkbox still toggles
    correctly afterward. What's NOT verified from here is whether the
    browser's real `fullscreenchange` event actually fires at the right
    moment when the owner clicks Google's real fullscreen button — that
    needs a real browser to confirm.

## Point marker symbols (`drawPtSymbol`, build 55)

- The 2D canvas draws every point as a small colored dot (`drawPt`) — control
  points gold, shots blue/green, selected gold-and-bigger, deleted a red X.
  That tells you the point's *state* at a glance but nothing about its
  *feature type* without opening the inspector. `drawPtSymbol(p,x,y,r)` adds
  a small outline shape drawn AROUND that same dot (the dot stays visible in
  the center — this is an addition, not a replacement) so common feature
  families are readable straight off the canvas:
  - **☐ Square** — any point carrying a real curb code in its description.
    Reuses the exact same token scan `applyKnockdown` already uses to find a
    curb code (`(p.desc||'').toUpperCase().split(/\s+/).some(t=>CURB_BOC[t]||
    CURB_FL[t])`) — so "has a curb code" means the same thing here as it does
    everywhere else in the app, no separate/duplicate definition to drift out
    of sync. A point whose curb code has already been baked into H/V tokens
    by Knockdown no longer matches (the literal code string is gone from the
    description at that point) — consistent with how `applyKnockdown` itself
    treats that case.
  - **△ Triangle** — a figure code (the description's first whitespace token)
    starting with the letter `C` — e.g. `CP` (control point), `CHK`
    (checkpoint), `CIP`, `CNL` in the real job files on hand.
  - **🌲 Tree emoji** — the two tree codes `TCTR`/`TDTR` specifically (an
    exact match, not just "starts with T").
  - Checked in that order (tree → square → triangle) since tree is the most
    specific match (an exact code, not a prefix or token-membership test);
    in practice a point only ever matches one of the three anyway, since
    curb codes and the sample `C`-prefixed codes on file don't overlap.
- Wired into `drawPt` behind the SAME visibility gate the point-ID label
  already uses (`p.kind==='ctrl'||view.s>3||hot`) — symbols only show at a
  reasonable zoom level (or for control points / the hot/selected point),
  so a zoomed-out full-file overview doesn't turn into visual noise, exactly
  matching how the existing ID labels already declutter themselves.
- Legend (`#legend`, top-right of the canvas) gets three new rows matching
  the on-canvas colors — a square-outline swatch, a CSS-border-triangle
  swatch, and the tree emoji itself — so the symbols are self-explanatory
  without needing to ask what they mean.
- Verified in a real headless browser against both real job files: zoomed
  screenshots of a real `TCTR` point (9089, Hamline), a real `CP` control
  point (point 1, Hamline), and a real curb point (`"RBCB EC L824"`, point
  9231, Hamline) each show exactly the right symbol, correctly centered, not
  obscuring the dot underneath. A full sweep classifying every non-deleted
  point in both files into exactly one bucket found sane, non-zero counts
  for all three categories on both files (Hamline: 33 tree / 5 square / 59
  triangle / 869 none out of 966; Dale: 38 tree / 46 square / 53 triangle /
  1586 none out of 1723), and forcing a full canvas redraw at `view.s=1`
  (well past the zoom threshold, so every symbol actually draws) produced
  zero console errors on either file.

## Point label toolbox (`pointLabelText`/`labelShow`/`labelSize`, build 71, 🏷 Labels button)

- Before this, a point's on-canvas text label was hardcoded to exactly one
  field, picked purely by point kind: a control point always showed its
  **code** (`p.desc.split(' ')[0]`), every other point always showed its
  **point number** — fixed 10px font, no way to see a shot's code or
  elevation on the canvas without opening the inspector, and no way to
  resize the text.
- **🏷 Labels** (top toolbar) toggles a small floating panel (`#labelBox`,
  reuses the `.snapbox` OSNAP-toolbox CSS for consistent styling, an
  additional `.labelbox` rule repositions it bottom-left — `left:64px`
  clears the tool column, `bottom:44px` clears the hud text row — so it
  never collides with either) with three independent checkboxes —
  **Point #**, **Code**, **Elevation** — plus a **Size** range slider
  (7-20px, live readout).
- `pointLabelText(p)` builds the label string from whichever of
  `labelShow.num`/`.code`/`.elev` are checked, space-joined in that fixed
  order (e.g. Code+Elevation with Point # off on a real `UGW` point reads
  `"UGW 229.00"`; all three reads `"11236 UGW 229.00"`), returning `''`
  when every box is off — the caller skips the `fillText` call entirely on
  an empty string, so unchecking everything draws no label at all rather
  than an empty string artifact.
- One shared function drives **both** the 2D (`drawPt`) and 3D (`draw3D`'s
  point-painter loop) label draws — both were switched from their old
  hardcoded `ctx.font='600 10px ...'` + single-field `fillText` to
  `pointLabelText(p)` + the `labelSize` variable
  (`` `600 ${labelSize}px ui-monospace,monospace` ``) — so the toolbox
  controls what's on screen in plan view and orbit view identically, one
  set of checkboxes for both.
- **Default state reproduces the old look almost exactly:**
  `labelShow={num:true,code:false,elev:false}`, `labelSize=10` — plain
  point numbers at 10px, same as every non-control-point always showed
  before this build, so nothing changes for anyone who never opens the
  toolbox. The one deliberate behavior change: a **control point** now
  also defaults to showing its number instead of its code (previously
  code-only for control points specifically) — tick **Code** back on to
  get the old control-point look, since the whole point of this feature is
  no longer hardcoding a different field per point kind; every checkbox
  now applies uniformly to every point.
- Verified through the real UI on the real Pascal job file: toggling **🏷
  Labels** shows/hides the panel; a zoomed screenshot at the default state
  matches the pre-existing plain-point-number look; ticking Code+Elevation
  (Point # off) shows `"UGW 229.00"` next to point 11236 — confirmed both
  via a direct `pointLabelText()` call and a real rendered screenshot;
  ticking all three shows `"11236 UGW 229.00"`; dragging the size slider
  to 18px visibly enlarges every on-screen label and updates the panel's
  own readout; unchecking all three produces an empty string and draws
  nothing. Re-ran the full regression sweep across all 5 real job files
  cycling every checkbox combination (num-only / code-only / elev-only /
  all-three / none) through both `draw2D()` and `draw3D()`: figure counts
  unchanged (70/99/161/36/43), zero console errors beyond the
  pre-existing, already-documented map-tile network block on any file.

## Help & Reference modal (`openHelp`/`renderHelpTables`/`curbCardsHTML`, build 81, ❓ Help button)

- The owner asked for a help menu covering how to use the app, what each
  tool does, and a list of the curb data — this had never existed; the only
  documentation was scattered across button `title=` attributes, the
  inspector's `.note` div, and this file (which the owner never sees inside
  the app itself).
- **`#helpBtn`**, top toolbar — deliberately **never `disabled`**, unlike
  almost every other toolbar button (Fit/Export/Knockdown/etc. all require a
  file loaded first) — so a brand-new user can open Help before loading
  anything at all.
- **4 tabs** (`.helpTab`/`.helpPane`, toggled by `setHelpTab(name)` — sets
  `.on` on the matching button/pane, plain CSS `display:none` otherwise, no
  framework):
  - **Getting Started** — the load/import → inspect/edit → bulk-tool
    (Knockdown/UGW→CPN) → export workflow, plus a short rundown of the 2D/
    3D/MAP/Labels view controls (including build 80's orbit-pivot-retargets-
    on-click and middle-drag-pans behavior, so this doesn't go stale the
    next time orbit navigation changes — update this tab alongside any
    future 3D nav change).
  - **Tools** — 4 tables built at open-time by `renderHelpTables()` from 4
    plain arrays (`HELP_TOOLBAR`, `HELP_CANVAS_TOOLS`, `HELP_KEYS`, plus the
    hardcoded mouse/touch table): the top toolbar's buttons, the left
    canvas-tool column's buttons, every keyboard shortcut the app's own
    `keydown` handlers actually implement (`v/m/p/z/o/i/c/a/f/g`, Ctrl+Z/Y,
    Del/Backspace, Esc), and mouse/touch gestures (left/middle/shift-drag,
    wheel, pinch, Del, Esc). These arrays are hand-written summaries of
    behavior that already exists elsewhere in the code (button `title=`
    text, the `keydown` handlers, the `.note`/`#orbHint` text) — **keep them
    in sync**: if a shortcut or tool's behavior changes, update its row here
    too, the same discipline this file's other sections already expect.
  - **Description-Key Codes** (`HELP_CODES`) — one row per line code this
    app parses (`B`/`E`/`CLS`, `BC..EC`, `PCC`/`PRC`, `OC`, `CIR`, `H<v>
    V<v>`, `SO`, `RT<v>`, `X<v>`, `RECT<v>`, `CPN<n>`/`RPN<n>`, `REF`,
    `PRISM<v>`) — summarizing the behavior already fully documented in this
    file's own dedicated sections (BC..EC curve linework, OC tangent-arc,
    SO stop-offset, RT/X/RECT, CPN/RPN, Knockdown's REF workflow, Rod
    height's PRISM bracketing) so a user doesn't have to dig through this
    whole file to find the one line they need.
  - **Curb Database** — the actual reason this needed live data instead of
    a written table: `curbCardsHTML(db,kd)` reads the app's real
    `CURB_BOC`/`CURB_FL` objects directly (`Object.keys(db).sort().map(...)`)
    and renders one card per code showing its real `H`/`V` step string
    exactly as `expandCurb` would consume it — so this list **cannot drift
    out of sync** with what Knockdown actually does, the way a hand-typed
    second copy of the database eventually would once someone edits
    `CURB_BOC`/`CURB_FL` and forgets the docs. Back-of-curb cards also show
    a `KD <value>` badge when that code has a `CURB_KD` knockdown-reveal
    entry (12 of the 70 codes). `#helpCurbSearch` live-filters the cards by
    code substring (case-insensitive) via plain `style.display` toggling —
    no rebuild, just show/hide. `renderCurbData()` only builds the ~140
    cards once (`helpCurbBuilt` guard), not on every modal open, since the
    underlying data never changes at runtime.
- **Styling** reuses the exact same `.scrim`/`.modal` pattern every other
  dialog in the app already uses (`Go to point`, `Add Point (COGO)`, the
  FBK code editor, etc.) — a new `.modal.help` width variant
  (`min(860px,94vw)`) and a small set of `.helpTab`/`.helpPane`/`.helpTbl`/
  `.curbCard` rules, nothing structurally new. Closes via **✕**
  (`#helpCloseBtn`), a backdrop click (`$('helpScrim').onclick`, the same
  "click === the scrim element itself" pattern every other modal uses), or
  **Esc**.
- **A real interaction bug caught before shipping:** the app's main
  `keydown` handler maps bare letters to tool switches (`o`→3D orbit,
  `v`→SEL, etc.) whenever focus isn't in an `<input>` — the Help modal has
  no inputs except the curb search box, so pressing a letter key while
  reading the Tools tab (e.g. actually typing "O" while looking at the "O =
  3D orbit" row) would have silently switched the canvas's tool/view
  underneath the modal. Fixed by adding `$('helpScrim').classList.contains
  ('show')` to the same early-return guard the Go-to-point modal
  (`$('scrim')`) already used, and adding a dedicated `Escape` check (before
  that guard, so Esc still closes Help even though the guard would
  otherwise swallow it) that calls `closeHelp()`. Undo/redo (`Ctrl+Z`/
  `Ctrl+Y`) are deliberately NOT blocked while Help is open — same as every
  other modal — since undoing/redoing the underlying point data doesn't
  interact with the modal at all.
- Verified end-to-end through the real UI in a real headless browser: the
  button is clickable with zero points loaded (`PTS.length===0`, confirming
  it's genuinely never `disabled`); opening it shows the modal with
  **Getting Started** active by default; switching to **Tools** renders 14
  toolbar rows / 11 canvas-tool rows / 14 keyboard-shortcut rows; **Codes**
  renders 15 rows; **Curb Database** renders exactly 70 BOC cards and 70 FL
  cards, with exactly 12 BOC cards carrying a `KD` badge — all 3 counts
  independently cross-checked against a regex key-count over the raw
  `CURB_BOC`/`CURB_FL`/`CURB_KD` object-literal source, not just re-reading
  the same JS object the app itself uses; typing `624` into the curb search
  box narrows the 70 BOC cards to the 2 real matches (`L624`/`R624`) and
  clearing the box restores all 70; **Esc** and a backdrop click both close
  the modal; reopening it and pressing **O** leaves the app's `mode`
  variable at its pre-open value (confirmed it does NOT switch to `'orbit'`
  the way it would with the modal closed); and a full synthetic
  load→edit→`buildLinework()` cycle performed around an open/close of the
  Help modal produced the correct figure count with zero console errors
  beyond the pre-existing, already-documented map-tile network block.

## Project layout

- Single-file app: `index.html` (HTML + CSS + JS inline).
- Curb template databases live both inline in `index.html` (`CURB_BOC`,
  `CURB_FL`, `CURB_KD`) and as text files in `data/`.

## Workflow

- Develop on branch `claude/ecstatic-mendel-4ngsu9`; owner also wants pushes
  reflected on `main`. Keep the two in sync.
- Verify inline script parses before pushing (e.g. extract `<script>` and
  `new Function(...)` it with node).
