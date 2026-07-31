"""Generate Digital Safe app icon — premium vault emblem, 1024x1024."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / "assets" / "logo.png"
FOREGROUND = ROOT / "assets" / "icon_foreground.png"

# Brand palette (matches AppColors)
BG_DEEP = (10, 22, 40)          # #0A1628
BG_MID = (17, 29, 50)             # #111D32
BG_GLOW = (30, 64, 120)           # soft center glow
BLUE_DARK = (29, 78, 216)         # #1D4ED8
BLUE_MID = (59, 130, 246)         # #3B82F6
BLUE_LIGHT = (96, 165, 250)       # #60A5FA
CYAN = (56, 189, 248)             # #38BDF8
WHITE = (255, 255, 255)
GOLD = (251, 191, 36)             # accent ring highlight


def _lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def _lerp_rgb(c1: tuple[int, ...], c2: tuple[int, ...], t: float) -> tuple[int, int, int]:
    return (
        int(_lerp(c1[0], c2[0], t)),
        int(_lerp(c1[1], c2[1], t)),
        int(_lerp(c1[2], c2[2], t)),
    )


def _radial_background() -> Image.Image:
    img = Image.new("RGBA", (SIZE, SIZE))
    px = img.load()
    cx = cy = SIZE / 2
    max_r = SIZE * 0.72
    for y in range(SIZE):
        for x in range(SIZE):
            d = min(math.hypot(x - cx, y - cy) / max_r, 1.0)
            # Deep corners, luminous center
            base = _lerp_rgb(BG_DEEP, BG_MID, d * 0.55)
            glow = _lerp_rgb(base, BG_GLOW, max(0.0, 1.0 - d * 1.35) ** 1.6)
            px[x, y] = (*glow, 255)
    return img


def _vertical_gradient_mask(w: int, h: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGBA", (w, h))
    px = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        color = _lerp_rgb(top, bottom, t)
        for x in range(w):
            px[x, y] = (*color, 255)
    return img


def _shield_points(cx: float, cy: float, w: float, h: float) -> list[tuple[float, float]]:
    """Classic vault shield — rounded shoulders, pointed base."""
    return [
        (cx, cy - h * 0.54),
        (cx + w * 0.12, cy - h * 0.50),
        (cx + w * 0.50, cy - h * 0.28),
        (cx + w * 0.50, cy + h * 0.08),
        (cx + w * 0.38, cy + h * 0.38),
        (cx, cy + h * 0.54),
        (cx - w * 0.38, cy + h * 0.38),
        (cx - w * 0.50, cy + h * 0.08),
        (cx - w * 0.50, cy - h * 0.28),
        (cx - w * 0.12, cy - h * 0.50),
    ]


def _draw_emblem(draw_target: Image.Image, cx: float, cy: float, scale: float = 1.0) -> None:
    """Draw vault shield + closed lock onto an RGBA canvas."""
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)

    sw, sh = 320 * scale, 360 * scale
    shield = _shield_points(cx, cy - 8 * scale, sw, sh)

    # Soft drop shadow
    shadow_pts = [(x + 6 * scale, y + 12 * scale) for x, y in shield]
    d.polygon(shadow_pts, fill=(0, 0, 0, 90))

    # Shield body with gradient via clipped overlay
    shield_mask = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(shield_mask).polygon(shield, fill=255)
    grad = _vertical_gradient_mask(SIZE, SIZE, BLUE_LIGHT, BLUE_DARK)
    body = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    body.paste(grad, (0, 0), shield_mask)
    layer.alpha_composite(body)

    # Inner bevel ring
    inner = _shield_points(cx, cy - 8 * scale, sw * 0.88, sh * 0.88)
    d.polygon(inner, outline=(255, 255, 255, 55), width=max(2, int(3 * scale)))

    # Top-left gloss
    gloss = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(gloss)
    gloss_pts = _shield_points(cx - 18 * scale, cy - 42 * scale, sw * 0.55, sh * 0.42)
    gd.polygon(gloss_pts, fill=(255, 255, 255, 38))
    gloss = gloss.filter(ImageFilter.GaussianBlur(6))
    layer.alpha_composite(gloss)

    # Decorative orbit rings
    ring_r = 205 * scale
    ring = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring)
    bbox = [cx - ring_r, cy - ring_r - 10 * scale, cx + ring_r, cy + ring_r - 10 * scale]
    rd.arc(bbox, start=250, end=110, fill=(*CYAN, 220), width=max(6, int(8 * scale)))
    rd.arc(bbox, start=70, end=190, fill=(*BLUE_LIGHT, 90), width=max(4, int(5 * scale)))
    inner_bbox = [cx - ring_r + 18 * scale, cy - ring_r + 8 * scale, cx + ring_r - 18 * scale, cy + ring_r - 22 * scale]
    rd.arc(inner_bbox, start=200, end=340, fill=(255, 255, 255, 45), width=max(2, int(3 * scale)))
    ring = ring.filter(ImageFilter.GaussianBlur(1.5))
    layer.alpha_composite(ring)

    # --- Closed lock (centered on shield) ---
    lx, ly = cx, cy + 28 * scale
    lock = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ld = ImageDraw.Draw(lock)

    shackle_w = 52 * scale
    shackle_h = 44 * scale
    shackle_t = max(10, int(14 * scale))
    # Closed shackle — full arc connected to body
    sh_bbox = [lx - shackle_w, ly - shackle_h, lx + shackle_w, ly + shackle_t]
    ld.arc(sh_bbox, start=180, end=0, fill=(*WHITE, 255), width=shackle_t)
    ld.rectangle(
        [lx - shackle_w, ly - 2 * scale, lx - shackle_w + shackle_t, ly + shackle_t * 0.4],
        fill=(*WHITE, 255),
    )
    ld.rectangle(
        [lx + shackle_w - shackle_t, ly - 2 * scale, lx + shackle_w, ly + shackle_t * 0.4],
        fill=(*WHITE, 255),
    )

    bw, bh = 118 * scale, 92 * scale
    bx, by = lx - bw / 2, ly + 2 * scale
    ld.rounded_rectangle(
        [bx + 4 * scale, by + 6 * scale, bx + bw + 4 * scale, by + bh + 6 * scale],
        radius=int(20 * scale),
        fill=(0, 0, 0, 70),
    )
    ld.rounded_rectangle([bx, by, bx + bw, by + bh], radius=int(20 * scale), fill=(*WHITE, 255))

    # Keyhole with cyan accent
    kh_y = by + bh * 0.36
    kh_r = 14 * scale
    ld.ellipse([lx - kh_r, kh_y - kh_r, lx + kh_r, kh_y + kh_r], fill=(*BLUE_MID, 255))
    ld.rounded_rectangle(
        [lx - 6 * scale, kh_y, lx + 6 * scale, kh_y + 26 * scale],
        radius=int(3 * scale),
        fill=(*BLUE_MID, 255),
    )
    ld.ellipse(
        [lx - 5 * scale, kh_y - 2 * scale, lx + 5 * scale, kh_y + 8 * scale],
        fill=(*CYAN, 255),
    )

    # Gold security dot
    dot_r = 5 * scale
    ld.ellipse(
        [lx - dot_r, by + bh - 18 * scale - dot_r, lx + dot_r, by + bh - 18 * scale + dot_r],
        fill=(*GOLD, 255),
    )

    layer.alpha_composite(lock)
    draw_target.alpha_composite(layer)


def _ambient_glow() -> Image.Image:
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(glow)
    cx, cy = SIZE / 2, SIZE / 2
    d.ellipse([cx - 420, cy - 420, cx + 420, cy + 420], fill=(*CYAN, 38))
    d.ellipse([cx - 260, cy - 260, cx + 260, cy + 260], fill=(*BLUE_MID, 55))
    return glow.filter(ImageFilter.GaussianBlur(28))


def render_full_icon() -> Image.Image:
    canvas = _radial_background()
    canvas.alpha_composite(_ambient_glow())
    _draw_emblem(canvas, SIZE / 2, SIZE / 2 + 6, scale=1.0)

    # Subtle vignette
    vignette = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vignette)
    cx, cy = SIZE / 2, SIZE / 2
    for i in range(6):
        alpha = 8 + i * 6
        pad = i * 18
        vd.ellipse([pad, pad, SIZE - pad, SIZE - pad], outline=(0, 0, 0, alpha), width=14)
    vignette = vignette.filter(ImageFilter.GaussianBlur(10))
    canvas.alpha_composite(vignette)
    return canvas


def render_foreground() -> Image.Image:
    """Transparent background; emblem scaled for Android adaptive safe zone (~66%)."""
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    _draw_emblem(canvas, SIZE / 2, SIZE / 2 + 8, scale=0.82)
    return canvas


def main() -> None:
    LOGO.parent.mkdir(parents=True, exist_ok=True)
    full = render_full_icon()
    fg = render_foreground()
    full.save(LOGO, format="PNG", optimize=True)
    fg.save(FOREGROUND, format="PNG", optimize=True)
    print(f"Saved {LOGO} ({SIZE}x{SIZE})")
    print(f"Saved {FOREGROUND} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
