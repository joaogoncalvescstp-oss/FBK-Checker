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
    | 72 | 🍇 GRAPE | **NEW BRANCH `claude/streetview-pointcloud` (off `main`, not merged) — EXPERIMENTAL ☁ Point Cloud (Street View).** The owner linked 3 real openFrameworks addons (`wearenocomputer/ofxGSVImageStitcher`/`ofxGSVDepthmap`/`ofxGSVPointCloud` on GitHub, from their own "Creating Point Clouds with Google Street View" writeup) and asked to try the technique. Cloned and read all 3 (their Medium article itself is blocked from this sandbox, same as every Google domain, but GitHub isn't) — they use an UNDOCUMENTED, keyless Google endpoint (`cbk0.google.com/cbk`) that serves raw panorama tiles AND a compact binary depth map (a handful of 3D planes + a per-pixel plane index), completely separate from and NOT gated by the official Maps JS API key/billing this app's embedded Street View panorama needs. Reimplemented the technique in plain JS (`decodeDepthMap`/`depthAt`/`fetchPanoCanvas`/`buildStreetViewPointCloud`) — see the dedicated section below for the full writeup, including exactly what was and wasn't verifiable from this sandbox. The core binary-format/math WAS verified byte-for-byte against a real depth_map value captured in the reference C++ source (Node cross-check + a real-browser cross-check via `DecompressionStream('deflate')`, both exact matches); the actual network path (CORS on the depth-metadata fetch and the tile-pixel canvas read) could NOT be verified end-to-end (this sandbox can't reach any Google domain) but fails with a clear hud message rather than hanging or crashing, confirmed by deliberately triggering the real failure through the real UI. Heading/orientation relative to true survey north is explicitly disclosed as unverified (best-effort yaw parsing, falls back to no rotation). New `☁ Point Cloud (experimental)` button in the single-point inspector (both control-point and shot-point panels); 3D-view-only overlay via `drawStreetViewPointCloud`, never added to `PTS`/export. Full regression sweep across all 5 real job files: figure counts unchanged (70/99/161/36/43), zero new console errors. |
  - Suggested next fruits to rotate through:
    🍓 STRAWBERRY, 🍒 CHERRY,
    🥝 KIWI, 🍑 PEACH.

## Knockdown behavior (⚙ button → `applyKnockdown()`)

- **RBCB** (rod on back of curb) → uses the **Back-of-Curb DB** (`CURB_BOC`).
  - A point with its own curb code gets that code's std cross-section (overrides REF).
  - A point with no code derives the reveal from the nearest **REF** point's Z
    difference. **REF is a back-of-curb-only workflow.**
- **RCFL** (rod on flow line) → gets the std **Flow-Line DB** (`CURB_FL`)
  cross-section (full reveal), but **only at points that carry their OWN curb
  code** in the description. A flow-line point with no code is left untouched —
  it does NOT inherit the last-seen code or a default. **Do NOT use REF for RCFL.**

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

## ☁ Street View point cloud — EXPERIMENTAL (`decodeDepthMap`/`depthAt`/`buildStreetViewPointCloud`, build 72, branch `claude/streetview-pointcloud` off `main`, NOT merged)

- **Not the embedded panorama above.** This is a completely separate feature,
  on its own branch off `main` (not `claude/street-view-linework`), that
  reconstructs a real, colored 3D point cloud from a single Street View
  panorama — a different kind of thing entirely from walking/viewing the
  panorama.
- **Where the idea came from:** the owner linked three real GitHub repos —
  `wearenocomputer/ofxGSVImageStitcher`, `ofxGSVDepthmap`, `ofxGSVPointCloud`
  — openFrameworks (C++) addons built by a real person, from their own
  Medium writeup ("Creating Point Clouds with Google Street View"). The
  Medium article itself is blocked from this sandbox (`medium.com` is on the
  same domain-block list as every Google property), but GitHub is not — all
  3 repos were cloned (read-only, via `add_repo`) and their actual source
  read directly, not guessed at from a description.
- **The technique, as implemented in the reference C++ and ported here:**
  Google's own web Street View client loads two things from an
  **undocumented, keyless internal endpoint** (`cbk0.google.com/cbk`) that
  has nothing to do with the official Maps JavaScript API key/billing this
  app's embedded panorama (above) needs:
  1. `?output=xml&ll=<lat>,<lon>&dm=1` — panorama metadata (`pano_id`) plus
     a **binary depth map**: a small set of 3D planes (`{x,y,z,d}` — a
     normal vector + distance) and a per-pixel byte index saying which
     plane (if any) that pixel belongs to, base64-encoded (URL-safe, `-`/`_`
     not `+`/`/`) and zlib-compressed.
  2. `?output=tile&panoid=<id>&zoom=<z>&x=<x>&y=<y>` — raw 512×512 JPEG
     tiles of the panorama's own equirectangular color imagery.
  For each depth-map pixel, its `(x,y)` position converts to a viewing
  direction in spherical coordinates (`theta`/`phi` from normalized pixel
  position, then to a unit vector `(sinφcosθ, sinφsinθ, cosφ)` — `z` is
  "up"), and ray-casting that direction against its assigned plane
  (`t = |d / (v·planeNormal)|`) recovers a real-world distance in meters.
  Multiply the direction by that distance and you have a real 3D point;
  color comes from the same pixel position in the (separately fetched)
  panorama image. One panorama → thousands of real, colored 3D points, with
  **no official API key or billing involved in this path at all**.
- **JS reimplementation, not a straight port** (the reference is C++/
  openFrameworks, this app is a single-file browser page):
  - `urlSafeB64ToBytes`/`inflateZlib` — decode + zlib-inflate the depth
    blob. **No external library added**: the browser's native
    `DecompressionStream('deflate')` handles zlib's RFC1950 format
    directly (the exact same format C++ zlib's `uncompress()` reads) —
    confirmed byte-identical to Node's own `zlib.inflateSync` on the same
    real compressed data (see verification below), so this avoids adding
    a `pako`-style dependency the project has never needed before.
  - `decodeDepthMap` — parses the 8-byte header (`headersize`,
    `numberofplanes`, `width`, `height`, `offset` — all little-endian,
    `headersize`/`offset` both must read `8`), the `width×height` byte
    plane-index array, then `numberofplanes×16` bytes of `{x,y,z,d}`
    float32 planes (plane 0 reserved as "no plane"/infinite, matching the
    reference).
  - `depthAt(dm,x,y)` — the exact spherical-direction + ray-plane math
    above, one pixel at a time.
  - `fetchPanoCanvas(panoId,zoom,outW,outH)` — stitches whatever raw tiles
    load (a single failed tile leaves a gap, not a hard failure) into one
    canvas, then resizes it down to the depth map's own `width×height` —
    unlike the reference's hardcoded `512×256` resize target, this uses
    whatever dimensions the ACTUAL parsed depth-map header reports, so it
    isn't tied to one specific panorama's resolution. Resizing (not just
    stitching) is what makes color and depth trivially index-aligned:
    `pix[(y*width+x)*4]` and `depthAt(dm,x,y)` read the exact same pixel
    grid, no separate UV math needed for color. The same horizontal mirror
    the reference applies when stitching tiles (`translate`+`scale(-1,1)`,
    to match the depth decode's own x-flip) is applied here during the
    resize step instead, with identical net effect.
  - `buildStreetViewPointCloud(anchorIdx)` — the orchestration: `surveyToLL`
    (already used for the embedded panorama and the MAP background) gets
    lat/lon for the anchor point; fetch metadata → parse XML (`DOMParser`,
    no library) → decode depth map → fetch+build the color canvas → for
    every depth-map pixel with a real (non-zero, <150m) depth, convert to a
    3D point, convert meters→feet via `RC.FT` (the same US-survey-foot
    constant `surveyToLL` itself already uses, so this stays consistent
    with the rest of the app's unit handling), and offset from the anchor
    point's own `E/N/Z` — never written to `PTS`, never exported, purely a
    rendering-time overlay (`svPointCloud`, a plain array of `{E,N,Z,r,g,b}`
    plus which point it's anchored to).
  - `drawStreetViewPointCloud(proj)` — draws each point as a small
    solid-colored square using its own captured photo color, 3D-view-only
    (`is3D` gated, wired into `draw3D()` right before the survey points'
    own painter loop, so real survey points stay drawn on top and
    clickable). New **☁ Point Cloud (experimental)** button in the
    single-point inspector (both the control-point and shot-point panels,
    next to the existing 📷 Street View button) toggles building/clearing
    it for whichever point is selected; the button's own label flips to
    "☁ Clear point cloud" once one exists for that point, refreshing
    automatically the moment the async build actually finishes (not just on
    click) so it never shows a stale label. Cleared automatically on a
    fresh file load, same as other transient per-session state.
- **What was actually verified, and how — the honest split, since this
  sandbox cannot reach any Google domain (same standing block documented
  throughout every Street View section above):**
  - **The binary format + math — verified byte-for-byte against REAL
    captured Google data, not synthetic test data.** The reference
    `ofxGSVDepthmap` demo's own source has a real `depth_map` value
    hardcoded in it (a real Google response, captured by its author) —
    extracted that exact string (regex, not retyped by hand — a
    3600+-character blob is exactly the kind of thing transcription errors
    hide in) and ran it through: (1) a standalone Node script replicating
    the exact decode: URL-safe base64 → `zlib.inflateSync` → header/plane
    parse → ray-plane depth math. Result: header parses cleanly
    (`headersize=8, offset=8`), **81 real planes**, **512×256** depth map,
    plane-index array exactly `512×256` bytes, **total bytes consumed
    exactly equals the decompressed length with zero leftover** (the
    single strongest signal the byte-offset math is exactly right, not
    approximately right), depths ranging **2.90m–198.8m** — physically sane
    for a street-level panorama (nothing negative, nothing absurdly huge).
    (2) The SAME real compressed bytes run through a real headless
    Chromium's native `DecompressionStream('deflate')` — **byte-identical**
    output to Node's zlib, confirming the no-external-library choice is
    safe. (3) The app's OWN real `decodeDepthMap`/`depthAt` functions
    (not a reimplementation for testing — the actual shipped code) run
    against that same real base64 string inside a real headless browser
    with the real `index.html` loaded: **exact match** on every stat
    (512×256, 81 planes, 92587 non-zero-depth pixels, min/max depth to 6
    decimal places) — this is the strongest verification available without
    live network access, and it passed cleanly on the first real test.
  - **The network path — genuinely NOT verifiable from here, disclosed
    rather than assumed.** Whether `cbk0.google.com` sends CORS headers
    permitting a `fetch()` from an arbitrary page origin, and whether its
    tile server sends CORS headers letting a `crossOrigin='anonymous'`
    `<img>` avoid tainting the canvas on `getImageData` — both unknown from
    this sandbox, and this is exactly the kind of assumption build 53's
    "should work, can't verify" writeup already got proven wrong once by
    real testing (see the color-inversion saga in the sections above) — so
    it's stated plainly here as unverified, not glossed over. What WAS
    confirmed: triggering the REAL failure through the REAL UI (clicking
    the actual `#svPcBtn` button on a real point, in a real headless
    browser, where the fetch genuinely fails against this sandbox's own
    network block) resolves cleanly — `svPointCloud` stays `null`,
    `svPcBusy` correctly resets to `false` (not stuck busy forever),
    the hud shows `"point cloud failed: Failed to fetch"`, and the button
    label correctly reverts — confirming the failure path itself is solid
    even though the success path (real Google data actually arriving)
    couldn't be exercised. If it fails with a CORS error specifically in
    the owner's real browser (as opposed to succeeding, or failing for a
    different reason), that would need a genuinely different approach — a
    small same-origin proxy, most likely — since no page-side JS trick gets
    around a server that simply doesn't send CORS headers.
  - **Heading/orientation is the one open, explicitly-unverified piece.**
    Google's local frame (`depthAt`'s `vx,vy,vz`) has no confirmed
    correspondence to true survey north from here — the reference C++ code
    never parses or applies any yaw correction at all (it just displays the
    cloud in the panorama's own unrotated local frame), and no FULL example
    depth-map XML response (as opposed to just the isolated `depth_map`
    value quoted in the demo source) was available to confirm this legacy
    format's yaw attribute name/path. `parseYawDeg` tries a couple of
    plausible attribute names (`pano_yaw_deg` under `data_properties` or
    `projection_properties`) and applies a horizontal rotation if found,
    but falls back to **no rotation** (an arbitrary, unverified heading) if
    not — and the hud message after a successful build says explicitly
    which case applied (`"heading unknown, orientation unverified"` vs. a
    plain success message), so this is never silently wrong.
- **Full regression sweep** across all 5 real job files (Pascal/Hamline/
  Dale/Ravoux/Arundel): figure counts unchanged (70/99/161/36/43), zero new
  console errors beyond the pre-existing, already-documented map-tile
  network block on any file — this feature is purely additive and doesn't
  touch any existing rendering/parsing path.
- **Deliberately on its own branch off `main`** (not merged, and not on
  `claude/street-view-linework` either) — this is a genuinely new,
  substantial, unverified-in-the-one-way-that-matters-most feature, exactly
  the kind of thing this project's own recent history (the Street View
  color-inversion chase above) shows shouldn't be merged on the strength of
  sandbox-only testing alone. The owner needs to actually click **☁ Point
  Cloud** on a real point in a real browser and report what happens —
  success (and how the heading looks), a CORS error specifically, or
  something else — before this goes anywhere near `main`.

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

## Project layout

- Single-file app: `index.html` (HTML + CSS + JS inline).
- Curb template databases live both inline in `index.html` (`CURB_BOC`,
  `CURB_FL`, `CURB_KD`) and as text files in `data/`.

## Workflow

- Develop on branch `claude/ecstatic-mendel-4ngsu9`; owner also wants pushes
  reflected on `main`. Keep the two in sync.
- Verify inline script parses before pushing (e.g. extract `<script>` and
  `new Function(...)` it with node).
