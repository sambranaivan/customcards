import os
import re
import shutil
import sqlite3
import sys
import json
import urllib.parse
import urllib.request
import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from PIL import Image


REPO_ROOT = Path(r"c:\ProjectIgnis")
DB_PATH = REPO_ROOT / "sets" / "sets.sqlite3"

CARDMAKER_DIR = REPO_ROOT / "tools" / "CardMaker"
CARDMAKER_OUT = CARDMAKER_DIR / "output"
CARDMAKER_ART_DIR = CARDMAKER_DIR / "img" / "cardimages"

ART_DIR = REPO_ROOT / "sets" / "saint_seiya" / "pics"
OUT_DIR = REPO_ROOT / "sets" / "saint_seiya" / "pics" / "cardmaker"

DEFAULT_ART_NAME = "_blank.png"

GOOGLE_CSE_API_KEY_ENV = "AIzaSyBbXGfW-VNEDJGCsBR017PKhjUroxtuxbo"
GOOGLE_CSE_CX_ENV = "173bc80dbc49b4ca2"
GOOGLE_CSE_RIGHTS_ENV = "GOOGLE_CSE_RIGHTS"
GOOGLE_CSE_DEFAULT_RIGHTS = "cc_publicdomain|cc_attribute|cc_sharealike|cc_noncommercial"


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

def _google_cse_credentials() -> tuple[Optional[str], Optional[str]]:
    return (os.environ.get(GOOGLE_CSE_API_KEY_ENV), os.environ.get(GOOGLE_CSE_CX_ENV))


def _try_fetch_art_with_google_cse(*, query: str, out_png_path: Path) -> bool:
    api_key, cx = _google_cse_credentials()
    if not api_key or not cx:
        return False

    rights = os.environ.get(GOOGLE_CSE_RIGHTS_ENV, GOOGLE_CSE_DEFAULT_RIGHTS)
    params = {
        "key": api_key,
        "cx": cx,
        "q": query,
        "searchType": "image",
        "num": 1,
        "safe": "active",
        "imgType": "photo",
    }
    if rights:
        params["rights"] = rights

    url = "https://www.googleapis.com/customsearch/v1?" + urllib.parse.urlencode(params)
    with urllib.request.urlopen(url, timeout=30) as resp:
        payload = json.loads(resp.read().decode("utf-8"))

    items = payload.get("items") or []
    if not items:
        return False

    img_url = items[0].get("link")
    if not img_url:
        return False

    tmp = out_png_path.with_suffix(".download")
    with urllib.request.urlopen(img_url, timeout=30) as r:
        tmp.write_bytes(r.read())

    try:
        im = Image.open(tmp).convert("RGBA")
        im.save(out_png_path)
    finally:
        try:
            tmp.unlink(missing_ok=True)
        except Exception:
            pass

    return out_png_path.exists()


def _cardmaker_attribute(attr: Optional[str], card_type: str) -> str:
    if card_type == "Spell":
        return "Spell"
    if card_type == "Trap":
        return "Trap"
    if not attr:
        return "Empty"
    return attr.strip().lower().capitalize()  # LIGHT -> Light


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


def _source_art_filename(card_id: int) -> str:
    return f"{card_id}.png"


def _ensure_art_available(card_id: int, *, title: str) -> str:
    src = ART_DIR / _source_art_filename(card_id)
    if src.exists():
        dst = CARDMAKER_ART_DIR / src.name
        if not dst.exists():
            shutil.copyfile(src, dst)
        return src.name

    # If it's missing, try to fetch a reasonable placeholder via Google Custom Search API.
    # Requires env vars: GOOGLE_CSE_API_KEY and GOOGLE_CSE_CX.
    ART_DIR.mkdir(parents=True, exist_ok=True)
    if _try_fetch_art_with_google_cse(query=f"{title} Saint Seiya", out_png_path=src):
        dst = CARDMAKER_ART_DIR / src.name
        if not dst.exists():
            shutil.copyfile(src, dst)
        return src.name

    return DEFAULT_ART_NAME


def _expected_output_filename(title: str) -> str:
    file_name = _title_sanitize.sub("", title).replace(" ", "_") + ".png"
    return file_name


def _fetch_cards(conn: sqlite3.Connection) -> list[CardRow]:
    rows = conn.execute(
        """
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
        WHERE archetypes_json LIKE '%saint-seiya%'
        ORDER BY card_id
        """
    ).fetchall()

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
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--fetch-missing-art",
        action="store_true",
        help="If a card is missing sets/saint_seiya/pics/{card_id}.png, fetch it via Google CSE and save it.",
    )
    parser.add_argument(
        "--regenerate",
        action="store_true",
        help="Regenerate cardmaker outputs even if they already exist.",
    )
    args = parser.parse_args()

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    _ensure_default_art()

    conn = sqlite3.connect(DB_PATH)
    cards = _fetch_cards(conn)
    conn.close()

    # CardMaker uses relative paths; run from its folder.
    os.chdir(CARDMAKER_DIR)
    if str(CARDMAKER_DIR) not in sys.path:
        sys.path.insert(0, str(CARDMAKER_DIR))

    from modules.CardConstructor import CardConstructor  # type: ignore

    generated = 0
    skipped_existing = 0
    errors = 0
    fetched_art = 0

    for row in cards:
        out_path = OUT_DIR / f"{row.card_id}.png"
        if out_path.exists() and not args.regenerate:
            skipped_existing += 1
            # Still allow downloading missing art, even if we skip rendering.
            if args.fetch_missing_art:
                before = (ART_DIR / _source_art_filename(row.card_id)).exists()
                _ensure_art_available(row.card_id, title=row.name_en)
                after = (ART_DIR / _source_art_filename(row.card_id)).exists()
                if not before and after:
                    fetched_art += 1
            continue

        if args.fetch_missing_art:
            before = (ART_DIR / _source_art_filename(row.card_id)).exists()
            image_card = _ensure_art_available(row.card_id, title=row.name_en)
            after = (ART_DIR / _source_art_filename(row.card_id)).exists()
            if not before and after:
                fetched_art += 1
        else:
            image_card = _ensure_art_available(row.card_id, title=row.name_en)
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
            print(f"ERROR card_id={row.card_id} title={row.name_en!r} expected_output_missing={produced}")
            continue

        shutil.copyfile(produced, out_path)
        generated += 1

    print(
        f"cards={len(cards)} fetched_art={fetched_art} generated={generated} skipped_existing={skipped_existing} errors={errors} out_dir={OUT_DIR}"
    )


if __name__ == "__main__":
    main()

