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

## Project layout

- Single-file app: `index.html` (HTML + CSS + JS inline).
- Curb template databases live both inline in `index.html` (`CURB_BOC`,
  `CURB_FL`, `CURB_KD`) and as text files in `data/`.

## Workflow

- Develop on branch `claude/ecstatic-mendel-4ngsu9`; owner also wants pushes
  reflected on `main`. Keep the two in sync.
- Verify inline script parses before pushing (e.g. extract `<script>` and
  `new Function(...)` it with node).
