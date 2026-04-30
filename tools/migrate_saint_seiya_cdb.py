import os
import sqlite3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "expansions" / "cards-unofficial.cdb"
DST = ROOT / "expansions" / "saint-seiya.cdb"

START_ID = 922100000
END_ID = 922100171


def get_create_sql(cur: sqlite3.Cursor, table: str) -> str:
    cur.execute(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name=?",
        (table,),
    )
    row = cur.fetchone()
    if not row or not row[0]:
        raise RuntimeError(f"Could not find CREATE TABLE for {table!r} in source DB")
    return row[0]


def copy_table(
    src_cur: sqlite3.Cursor,
    dst_cur: sqlite3.Cursor,
    table: str,
    columns: list[str],
) -> int:
    cols = ", ".join(columns)
    qmarks = ", ".join(["?"] * len(columns))
    src_cur.execute(
        f"SELECT {cols} FROM {table} WHERE id BETWEEN ? AND ? ORDER BY id",
        (START_ID, END_ID),
    )
    rows = src_cur.fetchall()
    dst_cur.executemany(
        f"INSERT INTO {table} ({cols}) VALUES ({qmarks})",
        rows,
    )
    return len(rows)


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"Source DB not found: {SRC}")

    if DST.exists():
        DST.unlink()

    src = sqlite3.connect(str(SRC))
    dst = sqlite3.connect(str(DST))
    try:
        src_cur = src.cursor()
        dst_cur = dst.cursor()

        # Create tables (datas/texts) with identical schema
        for table in ("datas", "texts"):
            create_sql = get_create_sql(src_cur, table)
            dst_cur.execute(create_sql)

        # Copy rows
        datas_cols = [
            "id",
            "ot",
            "alias",
            "setcode",
            "type",
            "atk",
            "def",
            "level",
            "race",
            "attribute",
            "category",
        ]
        texts_cols = [
            "id",
            "name",
            "desc",
            "str1",
            "str2",
            "str3",
            "str4",
            "str5",
            "str6",
            "str7",
            "str8",
            "str9",
            "str10",
            "str11",
            "str12",
            "str13",
            "str14",
            "str15",
            "str16",
        ]

        datas_n = copy_table(src_cur, dst_cur, "datas", datas_cols)
        texts_n = copy_table(src_cur, dst_cur, "texts", texts_cols)

        dst.commit()

        # Audit destination completeness within range
        ids = list(range(START_ID, END_ID + 1))
        dst_cur.execute(
            "SELECT id FROM datas WHERE id BETWEEN ? AND ? ORDER BY id",
            (START_ID, END_ID),
        )
        datas_ids = {r[0] for r in dst_cur.fetchall()}
        dst_cur.execute(
            "SELECT id FROM texts WHERE id BETWEEN ? AND ? ORDER BY id",
            (START_ID, END_ID),
        )
        texts_ids = {r[0] for r in dst_cur.fetchall()}

        missing_datas = [i for i in ids if i not in datas_ids]
        missing_texts = [i for i in ids if i not in texts_ids]

        print(f"created: {DST}")
        print(f"copied datas: {datas_n}")
        print(f"copied texts: {texts_n}")
        print(f"missing_datas: {len(missing_datas)}")
        if missing_datas:
            print(missing_datas)
        print(f"missing_texts: {len(missing_texts)}")
        if missing_texts:
            print(missing_texts)
    finally:
        src.close()
        dst.close()


if __name__ == "__main__":
    main()

