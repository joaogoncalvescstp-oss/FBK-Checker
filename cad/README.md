# CurbStep.lsp — step off curb lines in AutoCAD / Civil 3D

One AutoLISP file with the curb database **built in** — nothing else to copy.

## Setup
`APPLOAD` → pick `cad/CurbStep.lsp` (add it to the *Startup Suite* to load every session).

## Use — `CURBSTEP`
1. **Popup window**: choose the database (Back of curb / Flow line / Standard /
   Knockdown) and click a curb type (`R624`, `L612`, `RPARK`…). Type in *Filter*
   to narrow the list. The right side shows every offset line (H offset, V elevation).
   Options: cross-section ribs on/off, max chord length on arcs.
2. **Select the base line**: line, polyline, 3D polyline, arc, spline,
   Civil 3D **feature line** or **alignment**.
3. **Pick the side** to offset toward (the gutter / outermost-line side).
4. Select the next base line with the same curb type, or press Enter to finish.
   One `U` undoes the whole run.

Result: one 3D polyline per H/V step on layers `CURB-<code>-L1`, `-L2`, … with real
elevations (base Z + V), and cross-section ribs on `CURB-<code>-XS`. Alignments have
no elevation, so you're asked for a base elevation. In Civil 3D, run
`CREATEFEATURELINES` on the results if you want feature lines.

`CURBSTEPLIST` prints a database to the text window.

## Rules (same as the FBK Checker app)
- Every H/V pair is one line: **H = offset from the base line** (not cumulative),
  **V = elevation difference from the base line's Z**.
- The picked side sets the direction of the step with the largest |H|; every other
  step keeps its sign relative to it (so flow-line codes with a back-of-curb step
  behind the base line still come out right).
- Corners are mitered/extended (like CAD `OFFSETGAPTYPE=0`); arcs are sampled into
  short chords.

## Changing the database
Edit `data/*_db.txt`, then run `python3 cad/embed_db.py` — it rewrites the
DATABASE block at the bottom of `CurbStep.lsp`.
