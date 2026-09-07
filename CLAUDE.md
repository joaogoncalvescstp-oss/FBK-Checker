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
  - Suggested next fruits to rotate through:
    🍇 GRAPE, 🍊 ORANGE, 🍓 STRAWBERRY, 🍒 CHERRY.

## Knockdown behavior (⚙ button → `applyKnockdown()`)

- **RBCB** (rod on back of curb) → uses the **Back-of-Curb DB** (`CURB_BOC`).
  - A point with its own curb code gets that code's std cross-section (overrides REF).
  - A point with no code derives the reveal from the nearest **REF** point's Z
    difference. **REF is a back-of-curb-only workflow.**
- **RCFL** (rod on flow line) → gets the std **Flow-Line DB** (`CURB_FL`)
  cross-section (full reveal), but **only at points that carry their OWN curb
  code** in the description. A flow-line point with no code is left untouched —
  it does NOT inherit the last-seen code or a default. **Do NOT use REF for RCFL.**

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
  app**, not a tab-opening link — a proper `google.maps.StreetViewPanorama`
  in a modal (`#svScrim`/`#svPanoDiv`), with **every point of the line
  overlaid as a numbered marker directly on the panorama** (per Google's own
  "Overlays within Street View" docs: a `Marker`'s `.map` can be set to a
  `StreetViewPanorama` instead of a plain `Map`, and it renders anchored at
  street level in the pano). This is a strict upgrade, not an alternate
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

## Project layout

- Single-file app: `index.html` (HTML + CSS + JS inline).
- Curb template databases live both inline in `index.html` (`CURB_BOC`,
  `CURB_FL`, `CURB_KD`) and as text files in `data/`.

## Workflow

- Develop on branch `claude/ecstatic-mendel-4ngsu9`; owner also wants pushes
  reflected on `main`. Keep the two in sync.
- Verify inline script parses before pushing (e.g. extract `<script>` and
  `new Function(...)` it with node).
