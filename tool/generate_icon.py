"""
One-off script: generates the app launcher icon (a book + spark mark on the
app's indigo brand color) consumed by flutter_launcher_icons.
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw

OUT_DIR = Path(r"C:\Users\aderm\Dev\waec_wizzard\assets\icon")
SIZE = 1024
INDIGO = (61, 90, 241, 255)   # 0xFF3D5AF1, matches AppTheme.seed
WHITE = (255, 255, 255, 255)
GOLD = (255, 196, 66, 255)


def draw_book(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: float, color):
    """An open book made of two trapezoid 'pages' meeting at a spine."""
    w = int(280 * scale)
    h = int(190 * scale)
    spine_x = cx
    top_y = cy - h // 2
    bottom_y = cy + h // 2
    lift = int(28 * scale)  # outer corners lift up slightly for a page-curl feel

    left_page = [
        (spine_x, top_y),
        (spine_x - w, top_y - lift),
        (spine_x - w, bottom_y - lift),
        (spine_x, bottom_y),
    ]
    right_page = [
        (spine_x, top_y),
        (spine_x + w, top_y - lift),
        (spine_x + w, bottom_y - lift),
        (spine_x, bottom_y),
    ]
    draw.polygon(left_page, fill=color)
    draw.polygon(right_page, fill=color)

    # spine line
    draw.line([(spine_x, top_y - 4 * scale), (spine_x, bottom_y + 4 * scale)], fill=INDIGO, width=max(2, int(10 * scale)))


def draw_star(draw: ImageDraw.ImageDraw, cx: int, cy: int, r_outer: float, color):
    points = []
    for i in range(10):
        angle = math.pi / 2 + i * math.pi / 5
        r = r_outer if i % 2 == 0 else r_outer * 0.42
        points.append((cx + r * math.cos(angle), cy - r * math.sin(angle)))
    draw.polygon(points, fill=color)


def make_icon(with_background: bool) -> Image.Image:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if with_background:
        draw.rounded_rectangle([0, 0, SIZE, SIZE], radius=SIZE // 5, fill=INDIGO)

    cx, cy = SIZE // 2, int(SIZE * 0.56)
    draw_book(draw, cx, cy, scale=1.0, color=WHITE)
    draw_star(draw, int(SIZE * 0.665), int(SIZE * 0.30), r_outer=SIZE * 0.085, color=GOLD)

    return img


def make_adaptive_foreground() -> Image.Image:
    # Android adaptive icons need generous padding (safe zone ~66% of canvas).
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = SIZE // 2, int(SIZE * 0.53)
    draw_book(draw, cx, cy, scale=0.62, color=WHITE)
    draw_star(draw, int(SIZE * 0.62), int(SIZE * 0.335), r_outer=SIZE * 0.055, color=GOLD)
    return img


if __name__ == "__main__":
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    make_icon(with_background=True).save(OUT_DIR / "icon.png")
    make_adaptive_foreground().save(OUT_DIR / "icon_foreground.png")
    print("Wrote", OUT_DIR / "icon.png")
    print("Wrote", OUT_DIR / "icon_foreground.png")
