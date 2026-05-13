"""Export `black_saints.md` from `expansions/saint-seiya.cdb` (datas + texts)."""
from __future__ import annotations

import sqlite3
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CDB = REPO / "expansions" / "saint-seiya.cdb"
LUA_DIR = REPO / "script" / "unofficial"
OUT = Path(__file__).resolve().parent / "black_saints.md"

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


def lua_reference_block(card_id: int) -> str | None:
    path = LUA_DIR / f"c{card_id}.lua"
    if not path.is_file():
        return None
    raw = path.read_text(encoding="utf-8", errors="replace")
    if "--[==[" not in raw or "--]==]" not in raw:
        return None
    inner = raw.split("--[==[", 1)[1].split("--]==]", 1)[0].strip("\n")
    out: list[str] = []
    for line in inner.splitlines():
        if line.startswith("--"):
            out.append(line[2:].lstrip())
        else:
            out.append(line)
    body = "\n".join(out).strip()
    return body or None


def main() -> None:
    id_lo, id_hi = 922100148, 922100171
    conn = sqlite3.connect(CDB)
    conn.row_factory = sqlite3.Row
    q = f"""
    SELECT d.id, d.type, d.attribute, d.race, d.level, d.atk, d.def, t.name, t.desc
    FROM datas d JOIN texts t ON d.id = t.id
    WHERE d.id BETWEEN ? AND ?
    ORDER BY d.id
    """
    rows = list(conn.execute(q, (id_lo, id_hi)))
    conn.close()
    by_id = {int(r["id"]): r for r in rows}

    lines: list[str] = []
    lines.append("# Black Saints (source of truth)")
    lines.append("")
    lines.append(
        "PSCT and stats match **`expansions/saint-seiya.cdb`** (`datas` + `texts`). "
        "Each card lists its Lua path (`script/unofficial/c` + *id* + `.lua`) and a **Lua reference** "
        "block parsed from the `--[==[ ... ]==]` header in that script (documentation only; "
        "if it disagrees with the box text, trust the database and the registered effects in Lua)."
    )
    lines.append("")
    lines.append(
        "For design drafts and cards not yet in this ID range, see **`black_saints_effects.md`**."
    )
    lines.append("")
    lines.append("---")
    lines.append("")

    sections: list[tuple[str, list[int]]] = [
        ("## Black Saint monsters", list(range(922100148, 922100155))),
        ("## Fragments of Sagittarius (Equip Spells)", list(range(922100155, 922100162))),
        ("## Boss monster", [922100162]),
        ("## Spells and Traps", list(range(922100163, 922100167))),
        ("## Crossover and lore support", list(range(922100167, 922100172))),
    ]

    for heading, id_list in sections:
        lines.append(heading)
        lines.append("")
        for cid in id_list:
            r = by_id.get(cid)
            if r is None:
                lines.append(f"_(Missing row for `{cid}` in database.)_")
                lines.append("")
                continue
            _emit_card(lines, r)
        lines.append("---")
        lines.append("")

    lines.append("## Regenerating from the database")
    lines.append("")
    lines.append(
        "From the repo root: `python sets/saint_seiya/export_black_saints_md_from_cdb.py` "
        "(overwrites this file from `expansions/saint-seiya.cdb`)."
    )

    OUT.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(f"Wrote {OUT.relative_to(REPO)}")


def _emit_card(lines: list[str], r: sqlite3.Row) -> None:
    tb = int(r["type"])
    ab = int(r["attribute"])
    race = RACE_MAP.get(int(r["race"]) or 0, "Warrior")
    name = r["name"]
    desc = (r["desc"] or "").strip()
    cid = int(r["id"])
    lua_rel = f"script/unofficial/c{cid}.lua"

    lines.append(f"### {name}")
    lines.append(f"- **Card ID**: `{cid}`")
    lines.append(f"- **Lua**: `{lua_rel}`")
    lines.append(f"- **Card type**: {card_type_line(tb)}")
    if not (is_spell(tb) or is_trap(tb)):
        lines.append(f"- **Attribute**: {ATTRIBUTE_MAP.get(ab or 0, '?')}")
        lines.append(f"- **Monster type**: {race}")
        lv = level_val(tb, int(r["level"] or 0))
        lines.append(f"- **Level**: {lv}")
        lines.append(f"- **ATK / DEF**: {int(r['atk'] or 0)} / {int(r['def'] or 0)}")
    lines.append("")
    lua_ref = lua_reference_block(cid)
    if lua_ref:
        lines.append("**Lua reference** (header block in script):")
        lines.append("")
        lines.append("```text")
        lines.append(lua_ref)
        lines.append("```")
        lines.append("")
    lines.append("**Card text** (`texts.desc`):")
    lines.append("")
    lines.append("```text")
    lines.append(desc)
    lines.append("```")
    lines.append("")


if __name__ == "__main__":
    main()
