from __future__ import annotations

import sqlite3
from pathlib import Path


def main() -> None:
    repo = Path(__file__).resolve().parents[1]
    cdb = repo / "expansions" / "saint-seiya.cdb"
    print("cdb:", cdb)
    print("exists:", cdb.exists())
    conn = sqlite3.connect(str(cdb))
    cur = conn.cursor()
    tables = cur.execute(
        "select name from sqlite_master where type='table' order by name"
    ).fetchall()
    print("tables:", tables)
    for t in ("datas", "texts"):
        try:
            cols = cur.execute(f"pragma table_info({t})").fetchall()
        except sqlite3.OperationalError as e:
            print(f"{t} pragma error:", e)
            continue
        print(f"{t} cols:", cols)

    try:
        sample = cur.execute(
            """
            select
              d.id,
              t.name,
              d.type,
              d.atk,
              d.def,
              d.level,
              d.race,
              d.attribute,
              t.desc
            from datas d
            join texts t on t.id = d.id
            order by d.id
            limit 1
            """
        ).fetchone()
        print("sample:", sample)
    except sqlite3.OperationalError as e:
        print("sample query error:", e)

    conn.close()


if __name__ == "__main__":
    main()

