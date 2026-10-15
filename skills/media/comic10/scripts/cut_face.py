#!/usr/bin/env python3
# Cut a face out of a photo as a magazine-style paper cutout (white border, transparent outside).
#   usage: cut_face.py SRC.jpg OUT.png PREVIEW.jpg 'x1,y1 x2,y2 ...'   (polygon around the head, in source pixels)
# Trace the polygon clockwise from the top of the hair: hair, forehead, nose, chin, jaw, ear, back of the head.
# Leave the neck out. Then Read PREVIEW.jpg (cutout on green, 2x) and adjust points until it reads clean.
# Run with the papercut venv: ~/.local/share/papercut-explainer/tools-venv/bin/python -I cut_face.py ...
import sys
from PIL import Image, ImageDraw, ImageFilter
if len(sys.argv) != 5: sys.exit("usage: cut_face.py SRC.jpg OUT.png PREVIEW.jpg 'x1,y1 x2,y2 ...'")
src, out, prev, poly = sys.argv[1:5]
P = [tuple(float(v) for v in p.split(',')) for p in poly.split()]
im = Image.open(src).convert('RGBA')
m = Image.new('L', im.size, 0); ImageDraw.Draw(m).polygon(P, fill=255)
m = m.filter(ImageFilter.GaussianBlur(0.8))
face = im.copy(); face.putalpha(m)
bb = m.getbbox(); pad = 26
if not bb: sys.exit('empty polygon: check the points')
face = face.crop((bb[0] - pad, bb[1] - pad, bb[2] + pad, bb[3] + pad))
border = face.split()[3].filter(ImageFilter.MaxFilter(19)).filter(ImageFilter.GaussianBlur(1))
base = Image.new('RGBA', face.size, (246, 244, 238, 0)); base.putalpha(border)
res = Image.alpha_composite(base, face); res.save(out)
pv = Image.new('RGBA', res.size, (40, 90, 60, 255)); pv.alpha_composite(res)
pv.convert('RGB').resize((res.width * 2, res.height * 2)).save(prev)
print(res.size)
