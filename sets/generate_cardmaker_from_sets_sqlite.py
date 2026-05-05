"""
Read an EDOPro/ProjectIgnis .cdb (datas/texts) and render Yu-Gi-Oh! card images with tools/CardMaker.

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
DEFAULT_CDB_PATH = REPO_ROOT / "expansions" / "saint-seiya.cdb"
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
    type_bits: int
    attribute_bits: int
    level_bits: int
    race_bits: int
    atk: Optional[int]
    defe: Optional[int]
    effect_text_en: Optional[str]


TYPE_MONSTER = 0x1
TYPE_SPELL = 0x2
TYPE_TRAP = 0x4
TYPE_NORMAL = 0x10
TYPE_EFFECT = 0x20
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
    0x01: "Earth",
    0x02: "Water",
    0x04: "Fire",
    0x08: "Wind",
    0x10: "Light",
    0x20: "Dark",
    0x40: "Divine",
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


def _ensure_default_art() -> None:
    CARDMAKER_ART_DIR.mkdir(parents=True, exist_ok=True)
    p = CARDMAKER_ART_DIR / DEFAULT_ART_NAME
    if p.exists():
        return
    img = Image.new("RGBA", (512, 512), (255, 255, 255, 255))
    img.save(p)


def _is_spell(type_bits: int) -> bool:
    return (type_bits & TYPE_SPELL) != 0


def _is_trap(type_bits: int) -> bool:
    return (type_bits & TYPE_TRAP) != 0


def _cardmaker_attribute(type_bits: int, attribute_bits: int) -> str:
    if _is_spell(type_bits):
        return "Spell"
    if _is_trap(type_bits):
        return "Trap"
    return ATTRIBUTE_MAP.get(int(attribute_bits) or 0, "Empty")


def _cardmaker_template(type_bits: int) -> str:
    if _is_spell(type_bits):
        return "spell"
    if _is_trap(type_bits):
        return "trap"
    if (type_bits & TYPE_LINK) != 0:
        return "link"
    if (type_bits & TYPE_XYZ) != 0:
        return "xyz"
    if (type_bits & TYPE_SYNCHRO) != 0:
        return "synchro"
    if (type_bits & TYPE_FUSION) != 0:
        return "fusion"
    if (type_bits & TYPE_RITUAL) != 0:
        return "ritual"
    if (type_bits & TYPE_NORMAL) != 0:
        return "normal"
    return "effect"


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
    # Include keywords CardConstructor expects for header icon selection.
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


def _level_value(row: CardRow) -> int:
    # ygopro/edopro packs link/rank/level into datas.level bits:
    # - Level/Rank: low 8 bits
    # - Link rating: bits 24..31
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

    out: list[CardRow] = []
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
        out.append(
            CardRow(
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
    parser.add_argument(
        "--cdb",
        type=str,
        default=str(DEFAULT_CDB_PATH),
        help="Path to .cdb (sqlite) with datas/texts tables. Default: expansions/saint-seiya.cdb",
    )
    args = parser.parse_args()

    cdb_path = Path(args.cdb)
    if not cdb_path.is_file():
        raise SystemExit(f"Database not found: {cdb_path}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    CARDMAKER_OUT.mkdir(parents=True, exist_ok=True)
    _ensure_default_art()

    conn = sqlite3.connect(str(cdb_path))
    cards = _fetch_cards(conn, card_id=args.card_id)
    conn.close()

    if args.card_id is not None and not cards:
        raise SystemExit(f"No card with card_id={args.card_id} in {cdb_path}")

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
            "card": _cardmaker_template(row.type_bits).upper(),
            "image_card": image_card,
            "Title": row.name_en,
            "attribute": _cardmaker_attribute(row.type_bits, row.attribute_bits),
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
