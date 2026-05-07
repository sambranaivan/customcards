import shutil
import sqlite3
import sys
from pathlib import Path


DEFAULT_DBS = [
    Path("expansions/saint-seiya.cdb"),
    Path("sets/sets.sqlite3"),
]


ID_MIN = 922100000
ID_MAX = 922199999
OLD = "Saint - "
NEW = "Bronze Saint - "
DOUBLE = "Bronze Bronze Saint - "


def backup_path(db_path: Path) -> Path:
    return db_path.with_suffix(db_path.suffix + ".bak")


def ensure_backup(db_path: Path) -> None:
    bak = backup_path(db_path)
    if not bak.exists():
        shutil.copy2(db_path, bak)
        print(f"Backup created: {bak}")
    else:
        print(f"Backup exists: {bak}")


def update_table_texts(con: sqlite3.Connection) -> int:
    cur = con.cursor()
    cols = [r[1] for r in cur.execute("pragma table_info(texts)")]
    # ProjectIgnis .cdb usually has `texts.desc`
    text_cols = [c for c in ("desc", "str2", "str3", "str4") if c in cols]
    if not text_cols:
        return 0

    total = 0
    for col in text_cols:
        cur.execute(
            f"""
            update texts
               set {col} = replace({col}, ?, ?)
             where id between ? and ?
               and {col} like ?
               and {col} not like ?
            """,
            (OLD, NEW, ID_MIN, ID_MAX, f"%{OLD}%", f"%{NEW}%"),
        )
        total += max(cur.rowcount, 0)
        print(f"Updated texts.{col}: {cur.rowcount}")
    return total


def update_table_cards(con: sqlite3.Connection) -> int:
    cur = con.cursor()
    cols = [r[1] for r in cur.execute("pragma table_info(cards)")]
    text_cols = [c for c in ("effect_text_en", "effect_text_es", "name_en", "name_es") if c in cols]
    if not text_cols:
        return 0

    total = 0
    for col in text_cols:
        cur.execute(
            f"""
            update cards
               set {col} = replace({col}, ?, ?)
             where card_id between ? and ?
               and {col} like ?
               and {col} not like ?
            """,
            (OLD, NEW, ID_MIN, ID_MAX, f"%{OLD}%", f"%{NEW}%"),
        )
        total += max(cur.rowcount, 0)
        print(f"Updated cards.{col}: {cur.rowcount}")

    # Cleanup if an earlier run created double-prefix names.
    if "name_en" in cols:
        cur.execute(
            """
            update cards
               set name_en = replace(name_en, ?, ?)
             where card_id between ? and ?
               and name_en like ?
            """,
            (DOUBLE, NEW, ID_MIN, ID_MAX, f"{DOUBLE}%"),
        )
        if cur.rowcount:
            print("Fixed cards.name_en double-prefix rows:", cur.rowcount)
    return total


def run_one(db_path: Path) -> None:
    if not db_path.exists():
        print(f"Skipping missing DB: {db_path}")
        return

    ensure_backup(db_path)

    con = sqlite3.connect(db_path)
    try:
        cur = con.cursor()
        tables = [r[0] for r in cur.execute("select name from sqlite_master where type='table' order by name")]
        print(f"Tables in {db_path}:", tables)

        changed = 0
        if "texts" in tables:
            changed += update_table_texts(con)
        if "cards" in tables:
            changed += update_table_cards(con)

        con.commit()
        print(f"Total updated in {db_path}: {changed}")

        # Quick verification counts (post)
        if "texts" in tables and "desc" in [r[1] for r in cur.execute("pragma table_info(texts)")]:
            cnt = cur.execute(
                "select count(*) from texts where id between ? and ? and desc like ? and desc not like ?",
                (ID_MIN, ID_MAX, f"%{OLD}%", f"%{NEW}%"),
            ).fetchone()[0]
            print(f"Remaining unconverted '{OLD}' in texts.desc:", cnt)
        if "cards" in tables and "effect_text_en" in [r[1] for r in cur.execute("pragma table_info(cards)")]:
            cnt = cur.execute(
                "select count(*) from cards where card_id between ? and ? and effect_text_en like ? and effect_text_en not like ?",
                (ID_MIN, ID_MAX, f"%{OLD}%", f"%{NEW}%"),
            ).fetchone()[0]
            print(f"Remaining unconverted '{OLD}' in cards.effect_text_en:", cnt)
    finally:
        con.close()


def main() -> None:
    args = [Path(a) for a in sys.argv[1:]]
    dbs = args if args else DEFAULT_DBS
    for db in dbs:
        run_one(db)


if __name__ == "__main__":
    main()

