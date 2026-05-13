"""Export `bronze_saints.md` from `expansions/saint-seiya.cdb` (datas + texts)."""
from __future__ import annotations

import sqlite3
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CDB = REPO / "expansions" / "saint-seiya.cdb"
OUT = Path(__file__).resolve().parent / "bronze_saints.md"

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


def is_spell(tb: int) -> bool:
    return (tb & TYPE_SPELL) != 0


def is_trap(tb: int) -> bool:
    return (tb & TYPE_TRAP) != 0


def spell_subtype(tb: int) -> str:
    if tb & TYPE_QUICKPLAY:
        return "Quick-Play Spell"
    if tb & TYPE_CONTINUOUS:
        return "Continuous Spell"
    if tb & TYPE_EQUIP:
        return "Equip Spell"
    if tb & TYPE_FIELD:
        return "Field Spell"
    if tb & TYPE_RITUAL:
        return "Ritual Spell"
    if is_trap(tb) and (tb & TYPE_COUNTER):
        return "Counter Trap"
    if is_trap(tb) and (tb & TYPE_CONTINUOUS):
        return "Continuous Trap"
    if is_trap(tb):
        return "Normal Trap"
    return "Normal Spell"


def card_type_line(tb: int) -> str:
    if is_spell(tb) or is_trap(tb):
        return spell_subtype(tb)
    parts = []
    if tb & TYPE_NORMAL:
        parts.append("Normal")
    elif tb & TYPE_EFFECT:
        parts.append("Effect")
    parts.append("Monster")
    return " ".join(parts)


def level_val(tb: int, lvl_bits: int) -> int:
    if tb & TYPE_LINK:
        return (lvl_bits >> 24) & 0xFF
    return lvl_bits & 0xFF


def main() -> None:
    conn = sqlite3.connect(CDB)
    conn.row_factory = sqlite3.Row
    ids = list(range(922100000, 922100012)) + list(range(922100041, 922100051))
    q = f"""
    SELECT d.id, d.type, d.attribute, d.race, d.level, d.atk, d.def, t.name, t.desc
    FROM datas d JOIN texts t ON d.id = t.id
    WHERE d.id IN ({",".join(str(i) for i in ids)})
    ORDER BY d.id
    """
    rows = list(conn.execute(q))
    conn.close()

    lines: list[str] = []
    lines.append("# Bronze Saints (source of truth)")
    lines.append("")
    lines.append(
        "This document replaces overlapping content from "
        "`saint_cards_effects.md` (Bronze Saints + Bronze Cloth sections) and "
        "`reviews/fix bronze cloth.md`. **Authoritative data:** "
        "`expansions/saint-seiya.cdb` (`datas` + `texts`) and "
        "`script/unofficial/c{card_id}.lua`."
    )
    lines.append("")
    lines.append(
        "Older markdown used names like `Saint - Seiya of Pegasus` and "
        "outdated Equip Spell lines (hand discard to search; Standby re-equip). "
        "The game database uses **`Bronze Saint - …`** naming and the "
        "implemented GY effects on Bronze Cloth cards."
    )
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Bronze Saint monsters")
    lines.append("")

    for r in rows:
        cid = int(r["id"])
        if cid > 922100009:
            continue
        _emit_card(lines, r)

    lines.append("---")
    lines.append("")
    lines.append("## Cloth support (same core set)")
    lines.append("")

    for r in rows:
        cid = int(r["id"])
        if not (922100010 <= cid <= 922100011):
            continue
        _emit_card(lines, r)

    lines.append("---")
    lines.append("")
    lines.append("## Bronze Cloth (Equip Spells)")
    lines.append("")

    for r in rows:
        cid = int(r["id"])
        if not (922100041 <= cid <= 922100050):
            continue
        _emit_card(lines, r)

    lines.append("---")
    lines.append("")
    lines.append("## Regenerating from the database")
    lines.append("")
    lines.append(
        "From the repo root: "
        "`python sets/saint_seiya/export_bronze_saints_md_from_cdb.py` "
        "(overwrites this file from `expansions/saint-seiya.cdb`). "
        "After changing card text in the `.cdb`, re-run that script; "
        "Lua behavior is not validated automatically."
    )

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT.relative_to(REPO)}")


def _emit_card(lines: list[str], r: sqlite3.Row) -> None:
    tb = int(r["type"])
    ab = int(r["attribute"])
    race = RACE_MAP.get(int(r["race"]) or 0, "Warrior")
    name = r["name"]
    desc = (r["desc"] or "").strip()
    cid = int(r["id"])
    lua = f"script/unofficial/c{cid}.lua"

    lines.append(f"### {name}")
    lines.append(f"- **Card ID**: `{cid}`")
    lines.append(f"- **Lua**: `{lua}`")
    lines.append(f"- **Card type**: {card_type_line(tb)}")
    if not (is_spell(tb) or is_trap(tb)):
        lines.append(f"- **Attribute**: {ATTRIBUTE_MAP.get(ab or 0, '?')}")
        lines.append(f"- **Monster type**: {race}")
        lv = level_val(tb, int(r["level"] or 0))
        lines.append(f"- **Level**: {lv}")
        lines.append(f"- **ATK / DEF**: {int(r['atk'] or 0)} / {int(r['def'] or 0)}")
    lines.append("")
    lines.append("```text")
    lines.append(desc)
    lines.append("```")
    lines.append("")


if __name__ == "__main__":
    main()
