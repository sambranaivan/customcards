"""Audit texts.str1-str16 in saint-seiya.cdb for cards in WindBot Black/Bronze decks."""
from __future__ import annotations

import re
import sqlite3
from pathlib import Path

ROOT = Path(r"c:\ProjectIgnis")
DB = ROOT / "expansions" / "saint-seiya.cdb"
SCRIPT_DIR = ROOT / "script" / "unofficial"
DECKS = [
    ROOT / "WindBot" / "Decks" / "AI_SaintSeiyaBlackSaints.ydk",
    ROOT / "WindBot" / "Decks" / "AI_SaintSeiyaBronzeOnly.ydk",
]

STRINGID_RE = re.compile(r"aux\.Stringid\s*\(\s*(?:id|s\.id)\s*,\s*(\d+)\s*\)")


def load_deck_ids(path: Path) -> set[int]:
    ids: set[int] = set()
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("!"):
            continue
        if line.isdigit():
            ids.add(int(line))
    return ids


def lua_stringids(card_id: int) -> set[int]:
    path = SCRIPT_DIR / f"c{card_id}.lua"
    if not path.exists():
        return set()
    text = path.read_text(encoding="utf-8", errors="replace")
    return {int(m) for m in STRINGID_RE.findall(text)}


def main() -> None:
    all_ids: set[int] = set()
    for deck in DECKS:
        all_ids |= load_deck_ids(deck)

    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    missing: list[tuple[int, str, int, str]] = []
    no_lua: list[int] = []
    no_row: list[int] = []

    for cid in sorted(all_ids):
        row = conn.execute(
            "SELECT name, str1,str2,str3,str4,str5,str6,str7,str8,"
            "str9,str10,str11,str12,str13,str14,str15,str16 FROM texts WHERE id=?",
            (cid,),
        ).fetchone()
        if row is None:
            no_row.append(cid)
            continue
        sids = lua_stringids(cid)
        if not sids and not (SCRIPT_DIR / f"c{cid}.lua").exists():
            no_lua.append(cid)
        name = row["name"] or f"id={cid}"
        for sid in sorted(sids):
            col = f"str{sid + 1}"
            val = row[col] or ""
            if not val.strip():
                missing.append((cid, name, sid, col))

    conn.close()

    print(f"Deck cards (unique): {len(all_ids)}")
    print(f"Not in CDB: {len(no_row)}")
    if no_row:
        print("  ", no_row)
    print(f"No lua script: {len(no_lua)}")
    print(f"Missing str for Stringid used in lua: {len(missing)}\n")

    cur = None
    for cid, name, sid, col in missing:
        if cid != cur:
            cur = cid
            print(f"\n{cid} {name}")
        print(f"  Stringid {sid} -> {col} EMPTY")

    if not missing and not no_row:
        print("All required str fields are populated.")


if __name__ == "__main__":
    main()
