"""
Generate social-media images per card_id using existing sources.

Inputs (must already exist):
- Background art:   api_output/{card_id}.png
- Rendered card:    sets/cardmaker_output/{card_id}.png (rendered by an independent process)

Output:
- sets/instagram_output/{card_id}.png

Composition:
- Background: artwork resized/cropped to square, blended with a blurred version at 50%.
- Foreground: card image centered with a soft shadow.
"""

from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from PIL import Image, ImageChops, ImageFilter, ImageOps

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CDB_PATH = REPO_ROOT / "expansions" / "saint-seiya.cdb"

API_OUTPUT_DIR = REPO_ROOT / "api_output"
CARD_RENDER_DIR = REPO_ROOT / "sets" / "cardmaker_output"
INSTAGRAM_OUT_DIR = REPO_ROOT / "sets" / "instagram_output"

DEFAULT_CANVAS_SIZE = 1080  # square (Instagram-friendly)


@dataclass(frozen=True)
class CardIdRow:
    card_id: int


def _fetch_card_ids(conn: sqlite3.Connection, card_id: Optional[int] = None) -> list[CardIdRow]:
    base_sql = "SELECT d.id FROM datas d"
    if card_id is not None:
        rows = conn.execute(base_sql + " WHERE d.id = ? ORDER BY d.id", (card_id,)).fetchall()
    else:
        rows = conn.execute(base_sql + " ORDER BY d.id").fetchall()
    return [CardIdRow(card_id=int(cid)) for (cid,) in rows]


def _load_rgba(path: Path) -> Image.Image:
    img = Image.open(path)
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    return img


def _make_background(art: Image.Image, size: int) -> Image.Image:
    canvas = ImageOps.fit(art, (size, size), method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
    blurred = canvas.filter(ImageFilter.GaussianBlur(radius=max(2, size * 0.02)))
    # "blur 50%" as a blend between original and blurred.
    return Image.blend(canvas, blurred, 0.5)


def _make_shadow(alpha: Image.Image, blur_radius: int) -> Image.Image:
    # alpha must be single-channel (L). Builds a soft shadow mask.
    shadow = alpha.filter(ImageFilter.GaussianBlur(radius=blur_radius))
    # Slightly deepen the shadow (non-linear)
    shadow = ImageChops.multiply(shadow, shadow)
    return shadow


def _composite_one(card_id: int, canvas_size: int, card_render_dir: Path) -> tuple[Optional[Image.Image], str]:
    art_path = API_OUTPUT_DIR / f"{card_id}.png"
    card_path = card_render_dir / f"{card_id}.png"

    if not card_path.is_file():
        return (None, f"missing_card_render={card_path}")

    if art_path.is_file():
        art = _load_rgba(art_path)
    else:
        # Fallback to a neutral background if art is missing.
        art = Image.new("RGBA", (512, 512), (245, 245, 245, 255))

    card = _load_rgba(card_path)

    bg = _make_background(art, canvas_size)
    out = bg.copy()

    # Fit the card to a comfortable portion of the canvas.
    max_w = int(canvas_size * 0.78)
    max_h = int(canvas_size * 0.88)
    card_fit = ImageOps.contain(card, (max_w, max_h), method=Image.Resampling.LANCZOS)

    x = (canvas_size - card_fit.width) // 2
    y = (canvas_size - card_fit.height) // 2

    # Soft shadow behind the card.
    alpha = card_fit.getchannel("A")
    shadow_mask = _make_shadow(alpha, blur_radius=max(2, canvas_size // 60))
    shadow_layer = Image.new("RGBA", (card_fit.width, card_fit.height), (0, 0, 0, 150))
    shadow = Image.new("RGBA", (card_fit.width, card_fit.height), (0, 0, 0, 0))
    shadow.paste(shadow_layer, (0, 0), shadow_mask)

    shadow_offset = (int(canvas_size * 0.01), int(canvas_size * 0.012))
    out.alpha_composite(shadow, (x + shadow_offset[0], y + shadow_offset[1]))
    out.alpha_composite(card_fit, (x, y))

    return (out, "ok")


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--regenerate",
        action="store_true",
        help="Regenerate outputs even if sets/instagram_output/{id}.png exists.",
    )
    parser.add_argument(
        "--card-id",
        type=int,
        default=None,
        metavar="ID",
        help="Process only this card_id (always regenerates that file). Ignores bulk skip logic.",
    )
    parser.add_argument(
        "--cdb",
        type=str,
        default=str(DEFAULT_CDB_PATH),
        help="Path to .cdb (sqlite) with datas table. Default: expansions/saint-seiya.cdb",
    )
    parser.add_argument(
        "--size",
        type=int,
        default=DEFAULT_CANVAS_SIZE,
        help="Square canvas size in pixels (default: 1080).",
    )
    parser.add_argument(
        "--card-dir",
        type=str,
        default=str(CARD_RENDER_DIR),
        help="Directory containing rendered cards named {card_id}.png. Default: sets/cardmaker_output",
    )
    args = parser.parse_args()

    cdb_path = Path(args.cdb)
    if not cdb_path.is_file():
        raise SystemExit(f"Database not found: {cdb_path}")

    if args.size < 256:
        raise SystemExit("--size must be >= 256")

    INSTAGRAM_OUT_DIR.mkdir(parents=True, exist_ok=True)
    card_dir = Path(args.card_dir)
    if not card_dir.is_dir():
        raise SystemExit(f"--card-dir is not a directory: {card_dir}")

    conn = sqlite3.connect(str(cdb_path))
    cards = _fetch_card_ids(conn, card_id=args.card_id)
    conn.close()

    if args.card_id is not None and not cards:
        raise SystemExit(f"No card with card_id={args.card_id} in {cdb_path}")

    generated = 0
    skipped_existing = 0
    errors = 0
    missing_art = 0

    force_one = args.card_id is not None

    for row in cards:
        out_path = INSTAGRAM_OUT_DIR / f"{row.card_id}.png"
        if out_path.exists() and not args.regenerate and not force_one:
            skipped_existing += 1
            continue

        composed, msg = _composite_one(row.card_id, canvas_size=int(args.size), card_render_dir=card_dir)
        if composed is None:
            errors += 1
            print(f"ERROR card_id={row.card_id} {msg}")
            continue

        if not (API_OUTPUT_DIR / f"{row.card_id}.png").is_file():
            missing_art += 1

        composed.save(out_path)
        generated += 1

    print(
        f"cards={len(cards)} generated={generated} skipped_existing={skipped_existing} "
        f"missing_art_used_fallback={missing_art} errors={errors} out_dir={INSTAGRAM_OUT_DIR}"
    )


if __name__ == "__main__":
    main()

