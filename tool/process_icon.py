"""Post-process AI app icon → logo.png + transparent foreground."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image

SIZE = 1024
ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / "assets" / "logo.png"
FOREGROUND = ROOT / "assets" / "icon_foreground.png"


def _load_square(path: Path) -> Image.Image:
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    side = min(w, h)
    left = (w - side) // 2
    top = (h - side) // 2
    img = img.crop((left, top, left + side, top + side))
    return img.resize((SIZE, SIZE), Image.Resampling.LANCZOS)


def _transparent_foreground(src: Image.Image) -> Image.Image:
    """Remove dark background; keep emblem for adaptive icon."""
    px = src.load()
    out = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    opx = out.load()

    for y in range(SIZE):
        for x in range(SIZE):
            r, g, b, a = px[x, y]
            lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
            # Distance from center — keep more of center glow
            cx = cy = SIZE / 2
            dist = math.hypot(x - cx, y - cy) / (SIZE * 0.5)
            threshold = 22 + dist * 14
            if lum > threshold or (r > 28 and g > 45 and b > 70):
                opx[x, y] = (r, g, b, a)
            elif lum > 12 and b > r and b > g:
                # faint blue glow
                alpha = int(min(255, (lum - 8) * 18))
                opx[x, y] = (r, g, b, alpha)
            else:
                opx[x, y] = (0, 0, 0, 0)
    return out


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"Missing source icon: {SRC}")
    icon = _load_square(SRC)
    icon.save(LOGO, format="PNG", optimize=True)
    fg = _transparent_foreground(icon)
    fg.save(FOREGROUND, format="PNG", optimize=True)
    print(f"Saved {LOGO}")
    print(f"Saved {FOREGROUND}")


if __name__ == "__main__":
    main()
