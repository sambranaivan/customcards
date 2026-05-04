"""
Read sets/sets.sqlite3 and render Yu-Gi-Oh! card images with tools/CardMaker.

Artwork: repo api_output/{card_id}.png if present; otherwise a blank white
512x512 placeholder (_blank.png) in CardMaker img/cardimages/.

CLI: full run, or --card-id ID for a single card (always overwrites output).
"""

from __future__ import annotations

import os
import re
import shutil
import sqlite3
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[1]
DB_PATH = REPO_ROOT / "sets" / "sets.sqlite3"
API_OUTPUT_DIR = REPO_ROOT / "api_output"

CARDMAKER_DIR = REPO_ROOT / "tools" / "CardMaker"
CARDMAKER_OUT = CARDMAKER_DIR / "output"
CARDMAKER_ART_DIR = CARDMAKER_DIR / "img" / "cardimages"

OUT_DIR = REPO_ROOT / "sets" / "cardmaker_output"

DEFAULT_ART_NAME = "_blank.png"

_title_sanitize = re.compile(r"[^a-zA-Z0-9 | ]*")


@dataclass(frozen=True)
class CardRow:
    card_id: int
    name_en: str
    card_type: str
    card_sub_type: Optional[str]
    attribute: Optional[str]
    level: Optional[int]
    rank: Optional[int]
    link: Optional[int]
    race: Optional[str]
    atk: Optional[int]
    defe: Optional[int]
    effect_text_en: Optional[str]


def _ensure_default_art() -> None:
    CARDMAKER_ART_DIR.mkdir(parents=True, exist_ok=True)
    p = CARDMAKER_ART_DIR / DEFAULT_ART_NAME
    if p.exists():
        return
    img = Image.new("RGBA", (512, 512), (255, 255, 255, 255))
    img.save(p)


def _cardmaker_attribute(attr: Optional[str], card_type: str) -> str:
    if card_type == "Spell":
        return "Spell"
    if card_type == "Trap":
        return "Trap"
    if not attr:
        return "Empty"
    return attr.strip().lower().capitalize()


def _cardmaker_template(card_type: str, sub_type: Optional[str]) -> str:
    if card_type == "Spell":
        return "spell"
    if card_type == "Trap":
        return "trap"
    s = (sub_type or "").lower()
    if "synchro" in s:
        return "synchro"
    if "xyz" in s:
        return "xyz"
    if "link" in s:
        return "link"
    if "fusion" in s:
        return "fusion"
    if "ritual" in s:
        return "ritual"
    if "normal" in s:
        return "normal"
    return "effect"


def _sub_kind_for_type_field(sub_type: Optional[str]) -> str:
    s = (sub_type or "").lower()
    for k in ("synchro", "xyz", "link", "fusion", "ritual", "normal", "effect"):
        if k in s:
            return k.capitalize()
    return (sub_type or "Effect").strip()


def _type_field(row: CardRow) -> str:
    if row.card_type in ("Spell", "Trap"):
        return (row.card_sub_type or row.card_type).strip()
    race = (row.race or "Warrior").strip()
    return f"{race}/{_sub_kind_for_type_field(row.card_sub_type)}"


def _level_value(row: CardRow) -> int:
    return int(row.level or row.rank or row.link or 0)


def _atk_def(row: CardRow) -> tuple[str, str]:
    if row.card_type in ("Spell", "Trap"):
        return ("0", "0")
    return (str(row.atk or 0), str(row.defe or 0))


def _desc(row: CardRow) -> str:
    return (row.effect_text_en or "").strip()


def _image_filename_for_card(card_id: int) -> str:
    api_png = API_OUTPUT_DIR / f"{card_id}.png"
    if api_png.is_file():
        dst = CARDMAKER_ART_DIR / f"{card_id}.png"
        shutil.copyfile(api_png, dst)
        return f"{card_id}.png"
    return DEFAULT_ART_NAME


def _expected_output_filename(title: str) -> str:
    return _title_sanitize.sub("", title).replace(" ", "_") + ".png"


def _fetch_cards(conn: sqlite3.Connection, card_id: Optional[int] = None) -> list[CardRow]:
    base_sql = """
        SELECT
          card_id,
          COALESCE(name_en, '') AS name_en,
          card_type,
          card_sub_type,
          attribute,
          level, rank, link,
          race,
          atk, def,
          effect_text_en
        FROM cards
    """
    if card_id is not None:
        rows = conn.execute(base_sql + " WHERE card_id = ? ORDER BY card_id", (card_id,)).fetchall()
    else:
        rows = conn.execute(base_sql + " ORDER BY card_id").fetchall()

    out: list[CardRow] = []
    for (
        card_id,
        name_en,
        card_type,
        card_sub_type,
        attribute,
        level,
        rank,
        link,
        race,
        atk,
        defe,
        effect_text_en,
    ) in rows:
        out.append(
            CardRow(
                card_id=int(card_id),
                name_en=str(name_en),
                card_type=str(card_type),
                card_sub_type=str(card_sub_type) if card_sub_type is not None else None,
                attribute=str(attribute) if attribute is not None else None,
                level=int(level) if level is not None else None,
                rank=int(rank) if rank is not None else None,
                link=int(link) if link is not None else None,
                race=str(race) if race is not None else None,
                atk=int(atk) if atk is not None else None,
                defe=int(defe) if defe is not None else None,
                effect_text_en=str(effect_text_en) if effect_text_en is not None else None,
            )
        )
    return out


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--regenerate",
        action="store_true",
        help="Regenerate outputs even if sets/cardmaker_output/{id}.png exists.",
    )
    parser.add_argument(
        "--card-id",
        type=int,
        default=None,
        metavar="ID",
        help="Process only this card_id (always regenerates that file). Ignores bulk skip logic.",
    )
    args = parser.parse_args()

    if not DB_PATH.is_file():
        raise SystemExit(f"Database not found: {DB_PATH}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    CARDMAKER_OUT.mkdir(parents=True, exist_ok=True)
    _ensure_default_art()

    conn = sqlite3.connect(DB_PATH)
    cards = _fetch_cards(conn, card_id=args.card_id)
    conn.close()

    if args.card_id is not None and not cards:
        raise SystemExit(f"No card with card_id={args.card_id} in {DB_PATH}")

    os.chdir(CARDMAKER_DIR)
    if str(CARDMAKER_DIR) not in sys.path:
        sys.path.insert(0, str(CARDMAKER_DIR))

    from modules.CardConstructor import CardConstructor  # type: ignore

    generated = 0
    skipped_existing = 0
    errors = 0
    used_api = 0
    used_blank = 0

    force_one = args.card_id is not None

    for row in cards:
        out_path = OUT_DIR / f"{row.card_id}.png"
        if out_path.exists() and not args.regenerate and not force_one:
            skipped_existing += 1
            continue

        image_card = _image_filename_for_card(row.card_id)
        if image_card == DEFAULT_ART_NAME:
            used_blank += 1
        else:
            used_api += 1

        atk_s, def_s = _atk_def(row)

        json_card = {
            "card": _cardmaker_template(row.card_type, row.card_sub_type).upper(),
            "image_card": image_card,
            "Title": row.name_en,
            "attribute": _cardmaker_attribute(row.attribute, row.card_type),
            "Level": _level_value(row),
            "Type": _type_field(row),
            "Descripton": _desc(row),
            "Atk": atk_s,
            "Def": def_s,
        }

        try:
            c = CardConstructor(json_card)
            c.generateCard()
        except Exception as e:
            errors += 1
            print(f"ERROR card_id={row.card_id} title={row.name_en!r} err={e}")
            continue

        expected_name = _expected_output_filename(row.name_en)
        produced = CARDMAKER_OUT / expected_name
        if not produced.exists():
            errors += 1
            print(
                f"ERROR card_id={row.card_id} title={row.name_en!r} expected_output_missing={produced}"
            )
            continue

        shutil.copyfile(produced, out_path)
        generated += 1

    print(
        f"cards={len(cards)} generated={generated} skipped_existing={skipped_existing} "
        f"art_from_api={used_api} art_blank={used_blank} errors={errors} out_dir={OUT_DIR}"
    )


if __name__ == "__main__":
    main()
