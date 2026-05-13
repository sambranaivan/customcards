"""
One-shot migration: remove SET_SAINT (0x1D7) from datas.setcode unless
the card name contains 'saint' (case-insensitive) or id is in TREATED_SAINT_IDS.

Recompacts remaining 16-bit segments toward low bits, then prepends SET_SAINT
when required. Updates texts.desc for treated-as cards.

Usage (from repo root):
    python tools/migrate_saint_setcode_by_name.py
"""
from __future__ import annotations

import re
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DB_PATH = ROOT / "expansions" / "saint-seiya.cdb"

SET_SAINT = 0x1D7
TREATED_SAINT_IDS = frozenset({922100184})
TREATED_PREFIX = '(This card is always treated as a "Saint" card.)\n'

ID_LO, ID_HI = 922100000, 922100302


def has_segment(setcode: int, value: int) -> bool:
    s = setcode
    while s:
        if (s & 0xFFFF) == value:
            return True
        s >>= 16
    return False


def remove_segment_and_compact(setcode: int, remove: int = SET_SAINT) -> int:
    """Drop all 16-bit segments equal to `remove`, preserve order of others, max 4 slots."""
    segments: list[int] = []
    s = setcode
    while s:
        seg = s & 0xFFFF
        s >>= 16
        if seg != 0 and seg != remove:
            segments.append(seg)
    out = 0
    for i, seg in enumerate(segments[:4]):
        out |= seg << (16 * i)
    return out


def should_include_set_saint(card_id: int, name: str) -> bool:
    if card_id in TREATED_SAINT_IDS:
        return True
    return bool(re.search(r"saint", name, re.I))


def compute_setcode(card_id: int, name: str, old_setcode: int) -> int:
    base = remove_segment_and_compact(old_setcode, SET_SAINT)
    if not should_include_set_saint(card_id, name):
        return base
    if has_segment(base, SET_SAINT):
        return base
    # Prepend SET_SAINT (matches existing convention: SAINT in low 16 bits)
    segments: list[int] = []
    s = base
    while s:
        segments.append(s & 0xFFFF)
        s >>= 16
    merged = [SET_SAINT] + [x for x in segments if x != SET_SAINT]
    merged = merged[:4]
    out = 0
    for i, seg in enumerate(merged):
        out |= seg << (16 * i)
    return out


def maybe_treated_desc(card_id: int, desc: str | None) -> str | None:
    if card_id not in TREATED_SAINT_IDS:
        return None
    if not desc:
        return TREATED_PREFIX.rstrip()
    if "always treated as" in desc.lower() and "saint" in desc.lower():
        return None
    return TREATED_PREFIX + desc


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    conn = sqlite3.connect(str(DB_PATH))
    cur = conn.cursor()
    rows = cur.execute(
        """
        SELECT d.id, t.name, d.setcode, IFNULL(t.desc, '')
        FROM datas d
        JOIN texts t ON t.id = d.id
        WHERE d.id BETWEEN ? AND ?
        ORDER BY d.id
        """,
        (ID_LO, ID_HI),
    ).fetchall()

    sc_updates = 0
    desc_updates = 0
    unchanged = 0

    for cid, name, old_sc, desc in rows:
        new_sc = compute_setcode(cid, name, old_sc)
        new_desc = maybe_treated_desc(cid, desc)

        if new_sc != old_sc:
            cur.execute("UPDATE datas SET setcode=? WHERE id=?", (new_sc, cid))
            sc_updates += 1
        elif new_desc is None:
            unchanged += 1

        if new_desc is not None:
            cur.execute("UPDATE texts SET desc=? WHERE id=?", (new_desc, cid))
            desc_updates += 1

    conn.commit()
    conn.close()

    print(f"setcode rows changed: {sc_updates}")
    print(f"desc rows changed: {desc_updates}")
    print(f"setcode unchanged: {unchanged}")


if __name__ == "__main__":
    main()
