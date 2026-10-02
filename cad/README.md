# CurbStep.lsp — step off curb lines in AutoCAD / Civil 3D from the FBK curb database

AutoLISP is used because it runs inside plain AutoCAD **and** Civil 3D with
nothing to install or compile — just `APPLOAD`.

## Setup
1. `APPLOAD` → pick `cad/CurbStep.lsp` (add it to the *Startup Suite* to load every session).
2. First run asks for the database folder — pick any file in this repo's `data/`
   folder (e.g. `back-of-curb_db.txt`). The folder is remembered.

## Use
`CURBSTEP`
1. Database: **Boc** (back of curb), **Flowline**, **Std**, or **Knockdown**.
2. Curb code: `R624`, `L612`, `RPARK`… (`?` lists them). You can also type a raw
   template like `H-0.5 V0 H-0.67 V-0.5`.
3. Ribs (cross-section lines at each vertex) Yes/No, max arc chord length.
4. Select the base line(s): LWPOLYLINE, 3D polyline, LINE, ARC, SPLINE…
5. If it came out on the wrong side (line drawn the other direction), answer
   **Yes** to *Flip to other side?*.

Result: one 3D polyline per H/V step on layer `CURB-<code>-L1`, `-L2`, … with real
elevations (base Z + V), plus ribs on `CURB-<code>-XS`. In Civil 3D, run
`CREATEFEATURELINES` on them if you want feature lines.

`CURBSTEPLIST` lists a database. `CURBSTEPDB` re-picks the folder.

## Rules (same as the FBK Checker app)
- Every H/V pair is one line: **H = offset from the base line** (not cumulative),
  **V = elevation difference from the base line's Z**.
- **+H = right** of the line's drawing direction, **−H = left**.
- Corners are mitered/extended (like CAD `OFFSETGAPTYPE=0`); arcs are sampled
  into short chords.
- Editing the `data/*_db.txt` files changes what CURBSTEP draws — no code change needed.
