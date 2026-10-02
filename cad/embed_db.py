#!/usr/bin/env python3
"""Embed data/*_db.txt into cad/CurbStep.lsp (between the <<DB-BEGIN>>/<<DB-END>> markers).

Run after editing any curb database file:   python3 cad/embed_db.py
"""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LSP = os.path.join(ROOT, 'cad', 'CurbStep.lsp')
DBS = [  # (key, label, file)
    ('Boc', 'Back of curb (RBCB)', 'back-of-curb_db.txt'),
    ('Flowline', 'Flow line (RCFL)', 'flow-line_db.txt'),
    ('Std', 'Standard curb', 'std-curb_db.txt'),
    ('Knockdown', 'Knockdown curb', 'knock-down-curb_db.txt'),
]
HV = re.compile(r'^[HV]-?\d*\.?\d+$', re.I)

def rows(path):
    out, seen = [], set()
    for line in open(path, encoding='utf-8'):
        if ',' not in line:
            continue
        code, tmpl = (x.strip() for x in line.split(',', 1))
        tmpl = ' '.join(tmpl.split())
        # skip non-template rows (e.g. the knockdown reveal list "L612,0.06")
        if not code or not tmpl or not all(HV.match(t) for t in tmpl.split()):
            continue
        code = code.upper()
        if code in seen:
            continue
        seen.add(code)
        out.append((code, tmpl))
    return out

def q(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'

lines = ['(setq *cs-db*', "  '("]
for key, label, fn in DBS:
    r = rows(os.path.join(ROOT, 'data', fn))
    lines.append(f'    ({q(key)} {q(label)}')
    lines.append('     (')
    for code, tmpl in r:
        lines.append(f'      ({q(code)} . {q(tmpl)})')
    lines.append('     ))')
    print(f'{key}: {len(r)} codes')
lines.append('   ))')

src = open(LSP, encoding='utf-8').read()
a = src.index(';;; <<DB-BEGIN>>') + len(';;; <<DB-BEGIN>>')
b = src.index(';;; <<DB-END>>')
src = src[:a] + '\n' + '\n'.join(lines) + '\n' + src[b:]
open(LSP, 'w', encoding='utf-8', newline='\r\n' if '\r\n' in src else '\n').write(src)
