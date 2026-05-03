import re
import sqlite3
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = ROOT / "script" / "unofficial"
DB_PATH = ROOT / "expansions" / "saint-seiya.cdb"


# Must match constants in script/archetype_setcode_constants.lua
SET_SAINT = 0x1D7
SET_GOD_WARRIOR = 0x1E3
SET_POSEIDON = 0x1E4
SET_MARINE_GENERAL = 0x1E5
SET_PILLAR = 0x1E6
SET_HADES = 0x1E7
SET_SPECTER = 0x1E8
SET_RENEGADE_SAINT = 0x1E9
SET_META = 0x1EA


ARCH_TO_SET = {
    # comment tag -> setcode constant
    "saint": SET_SAINT,
    # Treat 'saint-seiya' as the umbrella archetype -> SET_SAINT
    "saint-seiya": SET_SAINT,
    "God Warrior": SET_GOD_WARRIOR,
    "Poseidon": SET_POSEIDON,
    "Marine General": SET_MARINE_GENERAL,
    "Pillar": SET_PILLAR,
    "Hades": SET_HADES,
    "Specter": SET_SPECTER,
    "Renegade Saint": SET_RENEGADE_SAINT,
    "Meta": SET_META,
}


TYPE_MAP = {
    "Monster / Effect Monster": 33,
    "Monster / Effect Monster / Tuner": 4129,
    "Monster / Fusion Monster": 97,
    "Spell / Normal Spell": 2,
    "Spell / Quick-Play Spell": 65538,
    "Spell / Continuous Spell": 131074,
    "Spell / Equip Spell": 262146,
    "Spell / Field Spell": 524290,
    "Trap / Normal Trap": 4,
    "Trap / Continuous Trap": 131076,
    "Trap / Counter Trap": 1048580,
}


RACE_MAP = {
    "Warrior": 0x1,
    "Spellcaster": 0x2,
    "Fairy": 0x4,
    "Fiend": 0x8,
    "Zombie": 0x10,
    "Machine": 0x20,
    "Aqua": 0x40,
    "Pyro": 0x80,
    "Rock": 0x100,
    "Winged Beast": 0x200,
    "Plant": 0x400,
    "Insect": 0x800,
    "Thunder": 0x1000,
    "Dragon": 0x2000,
    "Beast": 0x4000,
    "Beast-Warrior": 0x8000,
    "Dinosaur": 0x10000,
    "Fish": 0x20000,
    "Sea Serpent": 0x40000,
    "Reptile": 0x80000,
    "Psychic": 0x100000,
    "Divine-Beast": 0x200000,
    "Creator God": 0x400000,
    "Wyrm": 0x800000,
    "Cyberse": 0x1000000,
    "Illusion": 0x2000000,
}


ATTRIBUTE_MAP = {
    "EARTH": 0x01,
    "WATER": 0x02,
    "FIRE": 0x04,
    "WIND": 0x08,
    "LIGHT": 0x10,
    "DARK": 0x20,
    "DIVINE": 0x40,
}


@dataclass(frozen=True)
class Card:
    cid: int
    name: str
    type_line: str
    desc: str
    setcode: int
    typ: int
    atk: int
    defe: int
    level: int
    race: int
    attribute: int
    ot: int = 3
    alias: int = 0
    category: int = 0


def norm(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def extract_block(script_text: str) -> str:
    m = re.search(r"--\[\=\=\[\s*\n([\s\S]*?)\n--\]\=\=\]", norm(script_text))
    if not m:
        raise ValueError("missing [==[ block ]==]")
    return m.group(1)


def kv(block: str, key: str) -> str | None:
    m = re.search(rf"^--\s*{re.escape(key)}\s*:\s*(.+?)\s*$", block, flags=re.MULTILINE)
    return m.group(1).strip() if m else None


def list_archetypes(block: str) -> list[str]:
    m = re.search(r"^--\s*Archetypes\s*:\s*$", block, flags=re.MULTILINE)
    if not m:
        return []
    out: list[str] = []
    for line in block[m.end() :].splitlines():
        if re.match(r"^--\s*Effect\s*\(EN\):\s*$", line):
            break
        mm = re.match(r"^--\s*-\s*(.+?)\s*$", line)
        if mm:
            out.append(mm.group(1))
    return out


def extract_effect_en(block: str) -> str:
    m = re.search(r"^--\s*Effect\s*\(EN\):\s*$", block, flags=re.MULTILINE)
    if not m:
        raise ValueError("missing Effect (EN) header")
    lines: list[str] = []
    for line in block[m.end() :].splitlines():
        if line == "":
            continue
        if not line.strip().startswith("--"):
            break
        content = line.lstrip()[2:]
        if content.startswith(" "):
            content = content[1:]
        lines.append(content.rstrip())
    eff = "\n".join(lines).strip()
    if not eff:
        raise ValueError("empty Effect (EN)")
    return eff


def encode_setcode(archetypes: list[str]) -> int:
    # Unique, stable ordering: keep first as base, additional as 16-bit shifts.
    # Always include umbrella SET_SAINT if 'saint-seiya' is present.
    mapped: list[int] = []
    for a in archetypes:
        if a not in ARCH_TO_SET:
            raise KeyError(f"unknown archetype: {a}")
        mapped.append(ARCH_TO_SET[a])
    # If the card only has saint-seiya, we still map it to SET_SAINT via table.
    uniq: list[int] = []
    for x in mapped:
        if x not in uniq:
            uniq.append(x)
    if not uniq:
        uniq = [SET_SAINT]
    code = 0
    for idx, sc in enumerate(uniq[:4]):
        code |= sc << (16 * idx)
    return code


def parse_card(path: Path) -> Card:
    text = path.read_text(encoding="utf-8", errors="replace")
    block = extract_block(text)

    cid_s = kv(block, "ID")
    if not cid_s or not cid_s.isdigit():
        raise ValueError(f"{path.name}: invalid ID")
    cid = int(cid_s)

    type_line = kv(block, "Type") or ""
    if type_line not in TYPE_MAP:
        raise ValueError(f"{path.name}: unknown type line: {type_line!r}")
    typ = TYPE_MAP[type_line]

    name = text.splitlines()[0].lstrip("-").strip() if text.splitlines() else path.stem
    arch = list_archetypes(block)
    desc = extract_effect_en(block)
    setcode = encode_setcode(arch)

    # defaults
    atk = 0
    defe = 0
    level = 0
    race = 0
    attribute = 0

    if typ & 0x1:  # monster bit
        lvl_s = kv(block, "Level")
        if lvl_s and lvl_s.isdigit():
            level = int(lvl_s)
        atkdef_s = kv(block, "ATK/DEF")
        if atkdef_s:
            m = re.match(r"(\d+)\s*/\s*(\d+)", atkdef_s)
            if m:
                atk = int(m.group(1))
                defe = int(m.group(2))
        race_s = kv(block, "Race")
        if race_s:
            if race_s not in RACE_MAP:
                raise ValueError(f"{path.name}: unknown race {race_s!r}")
            race = RACE_MAP[race_s]
        attr_s = kv(block, "Attribute")
        if attr_s:
            if attr_s not in ATTRIBUTE_MAP:
                raise ValueError(f"{path.name}: unknown attribute {attr_s!r}")
            attribute = ATTRIBUTE_MAP[attr_s]

    return Card(
        cid=cid,
        name=name,
        type_line=type_line,
        desc=desc,
        setcode=setcode,
        typ=typ,
        atk=atk,
        defe=defe,
        level=level,
        race=race,
        attribute=attribute,
    )


def ensure_schema(conn: sqlite3.Connection) -> None:
    cur = conn.cursor()
    cur.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('datas','texts')"
    )
    have = {r[0] for r in cur.fetchall()}
    missing = {"datas", "texts"} - have
    if missing:
        raise RuntimeError(f"{DB_PATH} missing tables: {sorted(missing)}")


def upsert(conn: sqlite3.Connection, cards: list[Card]) -> None:
    cur = conn.cursor()
    for c in cards:
        cur.execute(
            """
            INSERT OR REPLACE INTO datas
              (id, ot, alias, setcode, type, atk, def, level, race, attribute, category)
            VALUES
              (?,  ?,  ?,     ?,      ?,    ?,   ?,   ?,     ?,    ?,         ?)
            """,
            (
                c.cid,
                c.ot,
                c.alias,
                c.setcode,
                c.typ,
                c.atk,
                c.defe,
                c.level,
                c.race,
                c.attribute,
                c.category,
            ),
        )
        cur.execute(
            """
            INSERT OR REPLACE INTO texts
              (id, name, desc, str1, str2, str3, str4, str5, str6, str7, str8, str9, str10, str11, str12, str13, str14, str15, str16)
            VALUES
              (?,  ?,    ?,   '',   '',   '',   '',   '',   '',   '',   '',   '',   '',    '',    '',    '',    '',    '',    '')
            """,
            (c.cid, c.name, c.desc),
        )


def main() -> None:
    start, end = 922100172, 922100302
    cards: list[Card] = []
    for cid in range(start, end + 1):
        path = SCRIPTS_DIR / f"c{cid}.lua"
        cards.append(parse_card(path))

    conn = sqlite3.connect(str(DB_PATH))
    try:
        ensure_schema(conn)
        upsert(conn, cards)
        conn.commit()
    finally:
        conn.close()

    print(f"upserted: {len(cards)} into {DB_PATH}")


if __name__ == "__main__":
    main()

