#!/usr/bin/env python3
"""Generate the CodeShikhi launcher icon (1024x1024).

Figma logo/mark: solid orange (#F97316) rounded square, a white bold ">"
chevron centered-left, plus a thin white vertical caret bar to its right.
Drawn with PIL polygons — no photo, no external font.
"""
from PIL import Image, ImageDraw

SIZE = 1024
RADIUS = 228
ORANGE = (0xF9, 0x73, 0x16, 255)
WHITE = (255, 255, 255, 255)

img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# Rounded-square background.
d.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=RADIUS, fill=ORANGE)

# Chevron ">" — bold, centered-left. Tip at x=620, arms at x=380.
# Stroke thickness ~110, vertical span 300..724 (center 512).
cx_tip, cx_base = 640, 380
cy, half_span, thick = 512, 212, 112
# Upper arm: polygon from (base, cy-half_span) to (tip, cy).
d.polygon([
    (cx_base, cy - half_span),
    (cx_tip, cy - thick // 2),
    (cx_tip, cy + thick // 2),
    (cx_base, cy + half_span),
    (cx_base + 8, cy + half_span - thick),
    (cx_tip - thick, cy),
    (cx_base + 8, cy - half_span + thick),
], fill=WHITE)

# Caret bar to the right of the chevron.
bar_x0, bar_w = 700, 64
bar_y0, bar_y1 = cy - half_span, cy + half_span
d.rounded_rectangle([bar_x0, bar_y0, bar_x0 + bar_w, bar_y1],
                    radius=bar_w // 2, fill=WHITE)

img.save("assets/icon/icon.png", "PNG")
print("wrote assets/icon/icon.png", img.size)
