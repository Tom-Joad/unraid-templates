"""Render the word icons: ink ground, Anton caps in paper, red full-stop."""
import sys
from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw, ImageFont

INK = "#16130d"
PAPER = "#f2ead9"
RED = "#d5482a"
SIZE = 512
MAX_W = 0.78 * SIZE      # widest line
MAX_H = 0.62 * SIZE      # whole block
GAP = 0.06               # line gap as a share of the font size

ICONS = {
    "scanbutler": ["SCAN", "BUTLER"],
    "tdld": ["TDLD"],
    "cf-managed-network-endpoint": ["CF", "ENDPOINT"],
    "ucg-config-backup": ["UCG", "BACKUP"],
    "wol-relay-container": ["WOL", "RELAY"],
}

src, out = sys.argv[1], sys.argv[2]
f = TTFont(src)
f.flavor = None
f.save("/tmp/anton.ttf")


def block(lines, size):
    font = ImageFont.truetype("/tmp/anton.ttf", size)
    # The stop hangs after the last line; measure it as part of that line.
    texts = lines[:-1] + [lines[-1] + "."]
    boxes = [font.getbbox(t) for t in texts]
    cap = font.getbbox("H")
    line_h = cap[3] - cap[1]
    width = max(b[2] - b[0] for b in boxes)
    height = len(lines) * line_h + (len(lines) - 1) * GAP * size
    return font, texts, boxes, cap, line_h, width, height


for name, lines in ICONS.items():
    size = 150  # cap, so short names don't outshout the rest
    while True:
        font, texts, boxes, cap, line_h, w, h = block(lines, size)
        if w <= MAX_W and h <= MAX_H:
            break
        size -= 2
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
