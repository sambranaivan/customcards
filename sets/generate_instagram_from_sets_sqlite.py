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

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CDB_PATH = REPO_ROOT / "expansions" / "saint-seiya.cdb"

API_OUTPUT_DIR = REPO_ROOT / "api_output"
CARD_RENDER_DIR = REPO_ROOT / "sets" / "cardmaker_output"
INSTAGRAM_OUT_DIR = REPO_ROOT / "sets" / "instagram_output"
INSTAGRAM_SHEET_OUT_DIR = REPO_ROOT / "sets" / "instagram_output_sheet"

DEFAULT_CANVAS_SIZE = 1080  # square (Instagram-friendly)
DEFAULT_SHEET_SIZE = (1080, 1350)  # 4:5 portrait (Instagram feed)
DEFAULT_CENTER_SIZE = (1080, 1350)  # 4:5 portrait (Instagram feed)


@dataclass(frozen=True)
class CardIdRow:
    card_id: int


@dataclass(frozen=True)
class CardRow:
    card_id: int
    name_en: str
    type_bits: int
    attribute_bits: int
    level_bits: int
    race_bits: int
    atk: Optional[int]
    defe: Optional[int]
    effect_text_en: Optional[str]


# Minimal type decoding (copied from sets/generate_cardmaker_from_sets_sqlite.py)
TYPE_SPELL = 0x2
TYPE_TRAP = 0x4
TYPE_NORMAL = 0x10
TYPE_FUSION = 0x40
TYPE_RITUAL = 0x80
TYPE_SYNCHRO = 0x2000
TYPE_QUICKPLAY = 0x10000
TYPE_CONTINUOUS = 0x20000
TYPE_EQUIP = 0x40000
TYPE_FIELD = 0x80000
TYPE_COUNTER = 0x100000
TYPE_XYZ = 0x800000
TYPE_LINK = 0x4000000

ATTRIBUTE_MAP = {
    0x01: "EARTH",
    0x02: "WATER",
    0x04: "FIRE",
    0x08: "WIND",
    0x10: "LIGHT",
    0x20: "DARK",
    0x40: "DIVINE",
}

RACE_MAP = {
    0x1: "Warrior",
    0x2: "Spellcaster",
    0x4: "Fairy",
    0x8: "Fiend",
    0x10: "Zombie",
    0x20: "Machine",
    0x40: "Aqua",
    0x80: "Pyro",
    0x100: "Rock",
    0x200: "Winged Beast",
    0x400: "Plant",
    0x800: "Insect",
    0x1000: "Thunder",
    0x2000: "Dragon",
    0x4000: "Beast",
    0x8000: "Beast-Warrior",
    0x10000: "Dinosaur",
    0x20000: "Fish",
    0x40000: "Sea Serpent",
    0x80000: "Reptile",
    0x100000: "Psychic",
    0x200000: "Divine-Beast",
    0x400000: "Wyrm",
    0x800000: "Cyberse",
}


def _is_spell(type_bits: int) -> bool:
    return (type_bits & TYPE_SPELL) != 0


def _is_trap(type_bits: int) -> bool:
    return (type_bits & TYPE_TRAP) != 0


def _monster_kind_for_type_field(type_bits: int) -> str:
    if (type_bits & TYPE_LINK) != 0:
        return "Link"
    if (type_bits & TYPE_XYZ) != 0:
        return "Xyz"
    if (type_bits & TYPE_SYNCHRO) != 0:
        return "Synchro"
    if (type_bits & TYPE_FUSION) != 0:
        return "Fusion"
    if (type_bits & TYPE_RITUAL) != 0:
        return "Ritual"
    if (type_bits & TYPE_NORMAL) != 0:
        return "Normal"
    return "Effect"


def _spell_trap_type_field(type_bits: int) -> str:
    base = "Trap" if _is_trap(type_bits) else "Spell"
    if (type_bits & TYPE_QUICKPLAY) != 0:
        return f"Quick-Play {base}"
    if (type_bits & TYPE_CONTINUOUS) != 0:
        return f"Continuous {base}"
    if (type_bits & TYPE_EQUIP) != 0:
        return f"Equip {base}"
    if (type_bits & TYPE_FIELD) != 0:
        return f"Field {base}"
    if (type_bits & TYPE_RITUAL) != 0:
        return f"Ritual {base}"
    if base == "Trap" and (type_bits & TYPE_COUNTER) != 0:
        return "Counter Trap"
    return f"{base}"


def _type_field(row: CardRow) -> str:
    if _is_spell(row.type_bits) or _is_trap(row.type_bits):
        return _spell_trap_type_field(row.type_bits)
    race = RACE_MAP.get(int(row.race_bits) or 0, "Warrior")
    return f"{race}/{_monster_kind_for_type_field(row.type_bits)}"


def _attribute_field(row: CardRow) -> str:
    if _is_spell(row.type_bits):
        return "SPELL"
    if _is_trap(row.type_bits):
        return "TRAP"
    return ATTRIBUTE_MAP.get(int(row.attribute_bits) or 0, "EMPTY")


def _level_value(row: CardRow) -> int:
    lvl = int(row.level_bits) if row.level_bits is not None else 0
    if (row.type_bits & TYPE_LINK) != 0:
        return (lvl >> 24) & 0xFF
    return lvl & 0xFF


def _atk_def(row: CardRow) -> tuple[str, str]:
    if _is_spell(row.type_bits) or _is_trap(row.type_bits):
        return ("0", "0")
    return (str(row.atk or 0), str(row.defe or 0))


def _desc(row: CardRow) -> str:
    return (row.effect_text_en or "").strip()


def _fetch_card_ids(conn: sqlite3.Connection, card_id: Optional[int] = None) -> list[CardIdRow]:
    base_sql = "SELECT d.id FROM datas d"
    if card_id is not None:
        rows = conn.execute(base_sql + " WHERE d.id = ? ORDER BY d.id", (card_id,)).fetchall()
    else:
        rows = conn.execute(base_sql + " ORDER BY d.id").fetchall()
    return [CardIdRow(card_id=int(cid)) for (cid,) in rows]


def _fetch_cards(conn: sqlite3.Connection, card_id: Optional[int] = None) -> dict[int, CardRow]:
    base_sql = """
        SELECT
          d.id,
          COALESCE(t.name, '') AS name_en,
          d.type,
          d.attribute,
          d.level,
          d.race,
          d.atk,
          d.def,
          t.desc
        FROM datas d
        JOIN texts t ON t.id = d.id
    """
    if card_id is not None:
        rows = conn.execute(base_sql + " WHERE d.id = ? ORDER BY d.id", (card_id,)).fetchall()
    else:
        rows = conn.execute(base_sql + " ORDER BY d.id").fetchall()

    out: dict[int, CardRow] = {}
    for (
        cid,
        name_en,
        type_bits,
        attribute_bits,
        level_bits,
        race_bits,
        atk,
        defe,
        effect_text_en,
    ) in rows:
        row = CardRow(
            card_id=int(cid),
            name_en=str(name_en),
            type_bits=int(type_bits or 0),
            attribute_bits=int(attribute_bits or 0),
            level_bits=int(level_bits or 0),
            race_bits=int(race_bits or 0),
            atk=int(atk) if atk is not None else None,
            defe=int(defe) if defe is not None else None,
            effect_text_en=str(effect_text_en) if effect_text_en is not None else None,
        )
        out[row.card_id] = row
    return out


def _load_rgba(path: Path) -> Image.Image:
    img = Image.open(path)
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    return img


def _make_background(art: Image.Image, width: int, height: int, *, blur_factor: float) -> Image.Image:
    canvas = ImageOps.fit(art, (width, height), method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
    blur_base = max(width, height)
    blurred = canvas.filter(ImageFilter.GaussianBlur(radius=max(2, blur_base * blur_factor)))
    # "blur 50%" as a blend between original and blurred.
    return Image.blend(canvas, blurred, 0.5)


def _make_shadow(alpha: Image.Image, blur_radius: int) -> Image.Image:
    # alpha must be single-channel (L). Builds a soft shadow mask.
    shadow = alpha.filter(ImageFilter.GaussianBlur(radius=blur_radius))
    # Slightly deepen the shadow (non-linear)
    shadow = ImageChops.multiply(shadow, shadow)
    return shadow


def _get_font(size: int, *, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    # Pillow typically bundles DejaVu; fallback to default if missing.
    candidates = ["DejaVuSans-Bold.ttf", "DejaVuSans.ttf"] if bold else ["DejaVuSans.ttf", "DejaVuSans-Bold.ttf"]
    for name in candidates:
        try:
            return ImageFont.truetype(name, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def _wrap_text(text: str, draw: ImageDraw.ImageDraw, font: ImageFont.ImageFont, max_width: int) -> list[str]:
    words = (text or "").replace("\r\n", "\n").replace("\r", "\n").split()
    if not words:
        return []
    lines: list[str] = []
    cur: list[str] = []
    for w in words:
        trial = (" ".join(cur + [w])).strip()
        bbox = draw.textbbox((0, 0), trial, font=font)
        if bbox[2] <= max_width or not cur:
            cur.append(w)
        else:
            lines.append(" ".join(cur))
            cur = [w]
    if cur:
        lines.append(" ".join(cur))
    return lines


def _measure_text_height(draw: ImageDraw.ImageDraw, lines: list[str], font: ImageFont.ImageFont, line_gap: int) -> int:
    if not lines:
        return 0
    bbox = draw.textbbox((0, 0), "Ag", font=font)
    line_h = (bbox[3] - bbox[1]) + line_gap
    return line_h * len(lines)


def _fit_fonts_for_panel(
    draw: ImageDraw.ImageDraw,
    *,
    width: int,
    height: int,
    pad: int,
    title: str,
    meta: str,
    effect_label: str,
    effect_text: str,
) -> tuple[ImageFont.ImageFont, ImageFont.ImageFont, ImageFont.ImageFont, ImageFont.ImageFont, list[str]]:
    """
    Fit title/meta/label/body into a fixed-size panel without cropping by shrinking fonts.
    Returns (title_font, meta_font, label_font, body_font, wrapped_body_lines).
    """
    max_text_w = max(10, width - pad * 2)
    avail_h = max(10, height - pad * 2)

    base = max(width, height)
    # Start large and shrink until it fits.
    title_size = max(16, base // 18)
    meta_size = max(12, base // 26)
    label_size = max(12, base // 28)
    body_size = max(11, base // 30)

    line_gap = max(2, base // 260)
    sep_gap = max(8, base // 90)

    for _ in range(60):
        title_font = _get_font(size=title_size, bold=True)
        meta_font = _get_font(size=meta_size, bold=False)
        label_font = _get_font(size=label_size, bold=True)
        body_font = _get_font(size=body_size, bold=False)

        # Wrap title too (rare but possible).
        title_lines = _wrap_text(title, draw, title_font, max_text_w)
        meta_lines = _wrap_text(meta, draw, meta_font, max_text_w)
        body_lines = _wrap_text(effect_text, draw, body_font, max_text_w)

        needed = 0
        needed += _measure_text_height(draw, title_lines, title_font, line_gap)
        needed += sep_gap
        needed += _measure_text_height(draw, meta_lines, meta_font, line_gap)
        needed += sep_gap
        needed += _measure_text_height(draw, [effect_label], label_font, line_gap)
        needed += max(4, line_gap)
        needed += _measure_text_height(draw, body_lines, body_font, line_gap)

        if needed <= avail_h:
            return (title_font, meta_font, label_font, body_font, body_lines)

        # Prefer shrinking body first (to ensure full effect text fits).
        if body_size > 10:
            body_size -= 1
            continue
        if meta_size > 11:
            meta_size -= 1
            continue
        if title_size > 14:
            title_size -= 1
            continue
        if label_size > 11:
            label_size -= 1
            continue

        # Can't shrink further; return the smallest and let wrapping do the rest.
        return (title_font, meta_font, label_font, body_font, body_lines)

    return (
        _get_font(size=title_size, bold=True),
        _get_font(size=meta_size, bold=False),
        _get_font(size=label_size, bold=True),
        _get_font(size=body_size, bold=False),
        _wrap_text(effect_text, draw, _get_font(size=body_size, bold=False), max_text_w),
    )


def _composite_center(
    card_id: int, canvas_w: int, canvas_h: int, card_render_dir: Path, *, blur_factor: float
) -> tuple[Optional[Image.Image], str]:
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

    bg = _make_background(art, canvas_w, canvas_h, blur_factor=blur_factor)
    out = bg.copy()

    # Fit the card to a comfortable portion of the canvas.
    base = max(canvas_w, canvas_h)
    max_w = int(canvas_w * 0.78)
    max_h = int(canvas_h * 0.82)
    card_fit = ImageOps.contain(card, (max_w, max_h), method=Image.Resampling.LANCZOS)

    x = (canvas_w - card_fit.width) // 2
    y = (canvas_h - card_fit.height) // 2

    # Soft shadow behind the card.
    alpha = card_fit.getchannel("A")
    shadow_mask = _make_shadow(alpha, blur_radius=max(2, base // 60))
    shadow_layer = Image.new("RGBA", (card_fit.width, card_fit.height), (0, 0, 0, 150))
    shadow = Image.new("RGBA", (card_fit.width, card_fit.height), (0, 0, 0, 0))
    shadow.paste(shadow_layer, (0, 0), shadow_mask)

    shadow_offset = (int(canvas_w * 0.01), int(canvas_h * 0.012))
    out.alpha_composite(shadow, (x + shadow_offset[0], y + shadow_offset[1]))
    out.alpha_composite(card_fit, (x, y))

    return (out, "ok")


def _composite_sheet(
    card_id: int,
    canvas_w: int,
    canvas_h: int,
    card_render_dir: Path,
    card_db: dict[int, CardRow],
    *,
    blur_factor: float,
) -> tuple[Optional[Image.Image], str]:
    art_path = API_OUTPUT_DIR / f"{card_id}.png"
    card_path = card_render_dir / f"{card_id}.png"

    if not card_path.is_file():
        return (None, f"missing_card_render={card_path}")

    if art_path.is_file():
        art = _load_rgba(art_path)
    else:
        art = Image.new("RGBA", (512, 512), (245, 245, 245, 255))

    row = card_db.get(card_id)
    if row is None:
        return (None, "missing_db_row")

    bg = _make_background(art, canvas_w, canvas_h, blur_factor=blur_factor)
    out = bg.copy()

    # Layout regions
    margin = int(canvas_w * 0.06)
    gap = int(canvas_w * 0.04)
    header_h = int(canvas_h * 0.18)
    usable_w = canvas_w - margin * 2 - gap
    # Make the text box exactly the same size as the card render by giving each half equal width.
    left_w = usable_w // 2
    right_w = usable_w - left_w
    top = margin + header_h
    bottom = canvas_h - margin

    # Card render on the left
    card = _load_rgba(card_path)
    card_fit = ImageOps.contain(card, (left_w, bottom - top), method=Image.Resampling.LANCZOS)
    card_x = margin + (left_w - card_fit.width) // 2
    card_y = top + ((bottom - top) - card_fit.height) // 2
    alpha = card_fit.getchannel("A")
    shadow_mask = _make_shadow(alpha, blur_radius=max(2, max(canvas_w, canvas_h) // 70))
    shadow_layer = Image.new("RGBA", (card_fit.width, card_fit.height), (0, 0, 0, 150))
    shadow = Image.new("RGBA", (card_fit.width, card_fit.height), (0, 0, 0, 0))
    shadow.paste(shadow_layer, (0, 0), shadow_mask)
    out.alpha_composite(shadow, (card_x + int(canvas_w * 0.008), card_y + int(canvas_h * 0.01)))
    out.alpha_composite(card_fit, (card_x, card_y))

    # Info panel on the right
    panel_x0 = margin + left_w + gap
    # Same size as the rendered card (per request).
    panel_w = int(card_fit.width)
    panel_h = int(card_fit.height)
    panel_y0 = card_y

    # Keep it visually aligned even if the "right region" is wider than card_fit.
    panel_x0 = panel_x0 + (right_w - panel_w) // 2

    panel = Image.new("RGBA", (panel_w, panel_h), (0, 0, 0, 0))
    pd = ImageDraw.Draw(panel)

    # Rounded rect: black background + white text.
    radius = max(12, int(max(canvas_w, canvas_h) * 0.02))
    panel_fill = (0, 0, 0, 215)
    panel_outline = (255, 255, 255, 55)
    pd.rounded_rectangle(
        (0, 0, panel.width - 1, panel.height - 1),
        radius=radius,
        fill=panel_fill,
        outline=panel_outline,
        width=max(2, max(canvas_w, canvas_h) // 360),
    )

    pad = int(panel.width * 0.06)
    x = pad
    y = pad

    # Title
    title = row.name_en.strip() or str(card_id)
    # Meta line (stats)
    lvl = _level_value(row)
    atk_s, def_s = _atk_def(row)
    meta = f"{_attribute_field(row)} • {_type_field(row)}"
    if not (_is_spell(row.type_bits) or _is_trap(row.type_bits)):
        meta = f"{meta} • LV {lvl} • ATK {atk_s} / DEF {def_s}"

    desc = _desc(row)
    if not desc:
        desc = "(No text)"

    title_font, meta_font, label_font, body_font, body_lines = _fit_fonts_for_panel(
        pd,
        width=panel.width,
        height=panel.height,
        pad=pad,
        title=title,
        meta=meta,
        effect_label="Effect",
        effect_text=desc,
    )

    white = (245, 245, 245, 255)
    soft_white = (220, 220, 220, 255)
    sep = (255, 255, 255, 35)
    max_text_w = panel.width - pad * 2

    # Title (wrapped)
    title_lines = _wrap_text(title, pd, title_font, max_text_w)
    line_gap = max(2, max(panel.width, panel.height) // 260)
    title_bbox = pd.textbbox((0, 0), "Ag", font=title_font)
    title_line_h = (title_bbox[3] - title_bbox[1]) + line_gap
    for tl in title_lines:
        pd.text((x, y), tl, font=title_font, fill=white)
        y += title_line_h

    y += max(8, max(panel.width, panel.height) // 110)

    # Meta (wrapped)
    meta_lines = _wrap_text(meta, pd, meta_font, max_text_w)
    meta_bbox = pd.textbbox((0, 0), "Ag", font=meta_font)
    meta_line_h = (meta_bbox[3] - meta_bbox[1]) + line_gap
    for ml in meta_lines:
        pd.text((x, y), ml, font=meta_font, fill=soft_white)
        y += meta_line_h

    y += max(10, max(panel.width, panel.height) // 95)
    pd.line((x, y, panel.width - pad, y), fill=sep, width=max(1, max(panel.width, panel.height) // 520))
    y += max(10, max(panel.width, panel.height) // 95)

    pd.text((x, y), "Effect", font=label_font, fill=white)
    y = pd.textbbox((x, y), "Effect", font=label_font)[3] + max(6, max(panel.width, panel.height) // 180)

    body_bbox = pd.textbbox((0, 0), "Ag", font=body_font)
    body_line_h = (body_bbox[3] - body_bbox[1]) + line_gap
    for bl in body_lines:
        pd.text((x, y), bl, font=body_font, fill=white)
        y += body_line_h

    out.alpha_composite(panel, (int(panel_x0), int(panel_y0)))
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
        default=None,
        help="(Legacy) If set, uses a square canvas of this size (overrides --center-width/--center-height).",
    )
    parser.add_argument(
        "--center-width",
        type=int,
        default=DEFAULT_CENTER_SIZE[0],
        help="Center variant canvas width (default: 1080).",
    )
    parser.add_argument(
        "--center-height",
        type=int,
        default=DEFAULT_CENTER_SIZE[1],
        help="Center variant canvas height (default: 1350).",
    )
    parser.add_argument(
        "--sheet-width",
        type=int,
        default=DEFAULT_SHEET_SIZE[0],
        help="Sheet variant canvas width (default: 1080).",
    )
    parser.add_argument(
        "--sheet-height",
        type=int,
        default=DEFAULT_SHEET_SIZE[1],
        help="Sheet variant canvas height (default: 1350).",
    )
    parser.add_argument(
        "--card-dir",
        type=str,
        default=str(CARD_RENDER_DIR),
        help="Directory containing rendered cards named {card_id}.png. Default: sets/cardmaker_output",
    )
    parser.add_argument(
        "--variant",
        type=str,
        default="center",
        choices=["center", "sheet"],
        help="Output layout variant: center (card centered) or sheet (card left + info panel).",
    )
    parser.add_argument(
        "--blur",
        type=float,
        default=0.04,
        help="Background blur factor (radius = max(width,height)*blur). Default: 0.04 (strong).",
    )
    args = parser.parse_args()

    cdb_path = Path(args.cdb)
    if not cdb_path.is_file():
        raise SystemExit(f"Database not found: {cdb_path}")

    if args.size is not None and args.size < 256:
        raise SystemExit("--size must be >= 256")
    if args.blur <= 0:
        raise SystemExit("--blur must be > 0")
    if args.center_width < 256 or args.center_height < 256:
        raise SystemExit("--center-width/--center-height must be >= 256")
    if args.sheet_width < 256 or args.sheet_height < 256:
        raise SystemExit("--sheet-width/--sheet-height must be >= 256")

    INSTAGRAM_OUT_DIR.mkdir(parents=True, exist_ok=True)
    INSTAGRAM_SHEET_OUT_DIR.mkdir(parents=True, exist_ok=True)
    card_dir = Path(args.card_dir)
    if not card_dir.is_dir():
        raise SystemExit(f"--card-dir is not a directory: {card_dir}")

    conn = sqlite3.connect(str(cdb_path))
    cards = _fetch_card_ids(conn, card_id=args.card_id)
    card_db = _fetch_cards(conn, card_id=args.card_id if args.variant == "sheet" else None)
    conn.close()

    if args.card_id is not None and not cards:
        raise SystemExit(f"No card with card_id={args.card_id} in {cdb_path}")

    generated = 0
    skipped_existing = 0
    errors = 0
    missing_art = 0

    force_one = args.card_id is not None

    for row in cards:
        out_dir = INSTAGRAM_SHEET_OUT_DIR if args.variant == "sheet" else INSTAGRAM_OUT_DIR
        out_path = out_dir / f"{row.card_id}.png"
        if out_path.exists() and not args.regenerate and not force_one:
            skipped_existing += 1
            continue

        if args.variant == "sheet":
            composed, msg = _composite_sheet(
                row.card_id,
                canvas_w=int(args.sheet_width),
                canvas_h=int(args.sheet_height),
                card_render_dir=card_dir,
                card_db=card_db,
                blur_factor=float(args.blur),
            )
        else:
            if args.size is not None:
                cw = ch = int(args.size)
            else:
                cw = int(args.center_width)
                ch = int(args.center_height)
            composed, msg = _composite_center(
                row.card_id, canvas_w=cw, canvas_h=ch, card_render_dir=card_dir, blur_factor=float(args.blur)
            )
        if composed is None:
            errors += 1
            print(f"ERROR card_id={row.card_id} {msg}")
            continue

        if not (API_OUTPUT_DIR / f"{row.card_id}.png").is_file():
            missing_art += 1

        composed.save(out_path)
        generated += 1

    final_out_dir = INSTAGRAM_SHEET_OUT_DIR if args.variant == "sheet" else INSTAGRAM_OUT_DIR
    print(
        f"cards={len(cards)} generated={generated} skipped_existing={skipped_existing} "
        f"missing_art_used_fallback={missing_art} errors={errors} out_dir={final_out_dir}"
    )


if __name__ == "__main__":
    main()

