"""Render the word icons: ink ground, Anton caps in paper, red full-stop.

Usage: python make_icons.py <Anton font file> <output folder>

The font is Anton (SIL Open Font License 1.1), for example Anton-Regular.ttf
from Google Fonts; a woff2 file works too. Needs Python packages
Pillow and fonttools (with brotli for woff2):

    pip install pillow fonttools brotli

Writes one 512x512 <app>.png per entry of ICONS into the output folder
(icons/ in this repository).
"""
import os
import sys
import tempfile
from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw, ImageFont

INK = "#16130d"
PAPER = "#f2ead9"
RED = "#d5482a"
SIZE = 512
MAX_W = 0.78 * SIZE      # widest line
MAX_H = 0.62 * SIZE      # whole block
GAP = 0.06               # line gap as a share of the font size
MIN_FONT = 20            # smaller than this is not an icon worth shipping

ICONS = {
    "scanbutler": ["SCAN", "BUTLER"],
    "tdld": ["TDLD"],
    "cf-managed-network-endpoint": ["CF", "ENDPOINT"],
    "ucg-config-backup": ["UCG", "BACKUP"],
    "wol-relay-container": ["WOL", "RELAY"],
    "panacontrol": ["PANA", "CONTROL"],
    "buybutler": ["BUY", "BUTLER"],
}


def block(ttf, lines, size):
    font = ImageFont.truetype(ttf, size)
    # The stop hangs after the last line; measure it as part of that line.
    texts = lines[:-1] + [lines[-1] + "."]
    boxes = [font.getbbox(t) for t in texts]
    cap = font.getbbox("H")
    line_h = cap[3] - cap[1]
    width = max(b[2] - b[0] for b in boxes)
    height = len(lines) * line_h + (len(lines) - 1) * GAP * size
    return font, texts, boxes, cap, line_h, width, height


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src, out = sys.argv[1:]
    # PIL reads TrueType; convert a woff2 file in a private temporary folder.
    with tempfile.TemporaryDirectory() as tmp:
        ttf = os.path.join(tmp, "anton.ttf")
        f = TTFont(src)
        f.flavor = None
        f.save(ttf)
        render(ttf, out)


def render(ttf, out):
    for name, lines in ICONS.items():
        size = 150  # cap, so short names don't outshout the rest
        while True:
            font, texts, boxes, cap, line_h, w, h = block(ttf, lines, size)
            if w <= MAX_W and h <= MAX_H:
                break
            size -= 2
            if size < MIN_FONT:
                sys.exit(f"{name}: {' / '.join(lines)} does not fit at font size {MIN_FONT}")
        img = Image.new("RGB", (SIZE, SIZE), INK)
        d = ImageDraw.Draw(img)
        y = (SIZE - h) / 2 - cap[1]
        for i, (t, b) in enumerate(zip(texts, boxes)):
            x = (SIZE - (b[2] - b[0])) / 2 - b[0]
            if i == len(texts) - 1:
                word = t[:-1]
                d.text((x, y), word, font=font, fill=PAPER)
                d.text((x + font.getlength(word), y), ".", font=font, fill=RED)
            else:
                d.text((x, y), t, font=font, fill=PAPER)
            y += line_h + GAP * size
        img.save(f"{out}/{name}.png", optimize=True)
        print(name, size)


if __name__ == "__main__":
    main()
