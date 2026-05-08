import sqlite3
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CDB = REPO_ROOT / "expansions" / "saint-seiya.cdb"
GEN_SCRIPT = REPO_ROOT / "sets" / "generate_cardmaker_from_sets_sqlite.py"


TYPE_SPELL = 0x2
TYPE_EQUIP = 0x40000


def _is_equip_spell(type_bits: int) -> bool:
    return (type_bits & TYPE_SPELL) != 0 and (type_bits & TYPE_EQUIP) != 0


def _find_bronze_cloth_ids(cdb_path: Path) -> list[int]:
    con = sqlite3.connect(str(cdb_path))
    try:
        cur = con.cursor()
        rows = cur.execute(
            """
            select d.id, d.type, t.name, t.desc
              from datas d
              join texts t on t.id = d.id
             where d.id between 922100000 and 922199999
             order by d.id
            """
        ).fetchall()
    finally:
        con.close()

    equip_rows = []
    for cid, type_bits, name, desc in rows:
        if _is_equip_spell(int(type_bits or 0)):
            equip_rows.append((int(cid), str(name or ""), str(desc or "")))

    # Primary match: name contains "Bronze Cloth"
    ids = [cid for cid, name, _ in equip_rows if "Bronze Cloth" in name]
    if ids:
        return ids

    # Fallback: name contains "Cloth" and description mentions a Bronze Saint.
    ids = [
        cid
        for cid, name, desc in equip_rows
        if "Cloth" in name and "Bronze Saint -" in desc
    ]
    return ids


def main() -> None:
    cdb_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_CDB
    if not cdb_path.is_file():
        raise SystemExit(f"Database not found: {cdb_path}")
    if not GEN_SCRIPT.is_file():
        raise SystemExit(f"Generator not found: {GEN_SCRIPT}")

    ids = _find_bronze_cloth_ids(cdb_path)
    if not ids:
        raise SystemExit("No Bronze Cloth equip cards found to regenerate.")

    print(f"Bronze Cloth equip cards to regenerate: {len(ids)}")
    print("IDs:", ids)

    for cid in ids:
        cmd = [
            sys.executable,
            str(GEN_SCRIPT),
            "--cdb",
            str(cdb_path),
            "--card-id",
            str(cid),
        ]
        print("Running:", " ".join(cmd))
        subprocess.check_call(cmd, cwd=str(REPO_ROOT))


if __name__ == "__main__":
    main()

