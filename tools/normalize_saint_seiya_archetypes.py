import json
import re
import sqlite3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = ROOT / "script" / "unofficial"
SAINT_SEIYA_CDB = ROOT / "expansions" / "saint-seiya.cdb"
SETS_DB = ROOT / "sets" / "sets.sqlite3"


# Low-16 setcode constants from script/archetype_setcode_constants.lua
SETCODE_BY_TAG: dict[str, int] = {
    "saint": 0x1D7,
    "Saint": 0x1D7,
    "saint-seiya": 0x1D7,  # umbrella
    "cloth": 0x1D8,
    "Cloth": 0x1D8,
    "Bronze Cloth": 0x1EC,
    "Silver Cloth": 0x1EB,
    "Bronze Saint": 0x1D9,
    "Silver Saint": 0x1DA,
    "Gold Saint": 0x1DB,
    "Gold Cloth": 0x1DC,
    "Envoy of the Pope": 0x1DD,
    "Pope's Mandate": 0x1DE,
    "Ghost Saint": 0x1DF,
    "Steel Saint": 0x1E0,
    "Black Saint": 0x1E1,
    "God Warrior": 0x1E3,
    "Poseidon": 0x1E4,
    "Marine General": 0x1E5,
    "Pillar": 0x1E6,
    "Hades": 0x1E7,
    "Specter": 0x1E8,
    "Renegade Saint": 0x1E9,
    "Meta": 0x1EA,
}


SETCODE_PRIORITY: list[int] = [
    0x1D7,  # SAINT umbrella
    0x1D8,  # CLOTH
    0x1EC,  # BRONZE_CLOTH
    0x1D9,  # BRONZE_SAINT
    0x1DA,  # SILVER_SAINT
    0x1DB,  # GOLD_SAINT
    0x1DC,  # GOLD_CLOTH
    0x1EB,  # SILVER_CLOTH
    0x1DD,  # ENVOY
    0x1DE,  # POPES_MANDATE
    0x1DF,  # GHOST_SAINT
    0x1E0,  # STEEL_SAINT
    0x1E1,  # BLACK_SAINT
    0x1E3,  # GOD_WARRIOR
    0x1E4,  # POSEIDON
    0x1E5,  # MARINE_GENERAL
    0x1E6,  # PILLAR
    0x1E7,  # HADES
    0x1E8,  # SPECTER
    0x1E9,  # RENEGADE_SAINT
    0x1EA,  # META
]


def parse_lua_archetypes(path: Path) -> tuple[int, list[str]] | None:
    txt = path.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"--\s*ID:\s*(\d+)", txt)
    if not m:
        return None
    cid = int(m.group(1))

    arch: list[str] = []
    in_arch = False
    saw_archetypes_header = False
    for line in txt.splitlines():
        if re.match(r"^--\s*Archetypes\s*:\s*$", line):
            saw_archetypes_header = True
            in_arch = True
            continue
        if in_arch:
            if re.match(r"^--\s*Effect\s*\(EN\)\s*:\s*$", line):
                break
            mm = re.match(r"^--\s*-\s*(.+?)\s*$", line)
            if mm:
                arch.append(mm.group(1))

    if not saw_archetypes_header:
        return None
    return cid, arch


def encode_setcode(segments: list[int]) -> int:
    code = 0
    for idx, sc in enumerate(segments[:4]):
        code |= (sc & 0xFFFF) << (16 * idx)
    return code


def desired_setcode_segments(archetype_tags: list[str]) -> list[int]:
    seg = set()
    for a in archetype_tags:
        if a in SETCODE_BY_TAG:
            seg.add(SETCODE_BY_TAG[a])
        else:
            al = a.strip().lower()
            if al in SETCODE_BY_TAG:
                seg.add(SETCODE_BY_TAG[al])

    ordered = [x for x in SETCODE_PRIORITY if x in seg]
    for x in sorted(seg):
        if x not in ordered:
            ordered.append(x)
    return ordered


def main() -> None:
    wanted: dict[int, tuple[list[str], list[int]]] = {}
    for p in SCRIPTS_DIR.glob("c922100*.lua"):
        parsed = parse_lua_archetypes(p)
        if not parsed:
            continue
        cid, tags = parsed
        segs = desired_setcode_segments(tags)
        if segs:
            wanted[cid] = (tags, segs)
        elif not tags:
            # Explicit `-- Archetypes:` with no `-- - …` lines → setcode 0 (e.g. civilian / non-series monster).
            wanted[cid] = ([], [])

    # 1) Normalize expansions/saint-seiya.cdb datas.setcode
    con = sqlite3.connect(str(SAINT_SEIYA_CDB))
    cur = con.cursor()
    changed = 0
    for cid, (_tags, segs) in wanted.items():
        row = cur.execute("SELECT setcode FROM datas WHERE id=?", (cid,)).fetchone()
        if not row:
            continue
        old = row[0] or 0
        new = encode_setcode(segs)
        if new != old:
            cur.execute("UPDATE datas SET setcode=? WHERE id=?", (new, cid))
            changed += 1
    con.commit()
    con.close()
    print("saint-seiya.cdb setcode normalized changed", changed)

    # 2) Normalize sets/sets.sqlite3 cards.archetypes_json to match lua header tags
    managed = set(SETCODE_BY_TAG.keys()) | {k.lower() for k in SETCODE_BY_TAG.keys()}

    con = sqlite3.connect(str(SETS_DB))
    cur = con.cursor()
    updated_arch = 0
    updated_sc = 0
    for cid, (tags, segs) in wanted.items():
        row = cur.execute("SELECT archetypes_json, setcodes_json FROM cards WHERE card_id=?", (cid,)).fetchone()
        if not row:
            continue
        aj, sj = row[0], row[1]
        try:
            arr = json.loads(aj) if aj else []
        except Exception:
            arr = []

        existing = set(arr)
        kept = {t for t in existing if t not in managed}
        new_arr = sorted(kept | set(tags))

        want_sc = json.dumps(segs, ensure_ascii=False)
        sc_changed = sj != want_sc
        aj_changed = new_arr != arr
        if sc_changed:
            updated_sc += 1
        if aj_changed:
            updated_arch += 1
        if sc_changed or aj_changed:
            reason = "archetype+setcodes" if sc_changed and aj_changed else ("setcodes-json" if sc_changed else "archetype-fix")
            notes = (
                "setcodes from lua Archetypes map; archetypes_json from lua header."
                if sc_changed and aj_changed
                else (
                    "Packed setcode segments from lua Archetypes + SETCODE_BY_TAG."
                    if sc_changed
                    else "Normalized archetypes_json to match lua Archetypes header."
                )
            )
            cur.execute(
                """
                UPDATE cards SET archetypes_json=?, setcodes_json=?,
                updated_ts=strftime('%Y-%m-%dT%H:%M:%fZ','now'), updated_reason=?, updated_notes=?
                WHERE card_id=?
                """,
                (
                    json.dumps(new_arr, ensure_ascii=False),
                    want_sc,
                    reason,
                    notes,
                    cid,
                ),
            )
    con.commit()
    con.close()
    print("sets.sqlite3 setcodes_json rows updated", updated_sc)
    print("sets.sqlite3 archetypes_json normalized updated", updated_arch)


if __name__ == "__main__":
    main()

