import shutil
import sqlite3
import sys
from pathlib import Path


def main() -> None:
    db_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("expansions/saint-seiya.cdb")
    if not db_path.exists():
        raise SystemExit(f"DB not found: {db_path}")

    backup = db_path.with_suffix(db_path.suffix + ".bak")
    if not backup.exists():
        shutil.copy2(db_path, backup)
        print(f"Backup created: {backup}")
    else:
        print(f"Backup exists: {backup}")

    con = sqlite3.connect(db_path)
    try:
        cur = con.cursor()

        tables = [r[0] for r in cur.execute("select name from sqlite_master where type='table' order by name")]
        print("Tables:", tables)

        # ProjectIgnis .cdb typically stores card names in texts.name,
        # while sets/sets.sqlite3 in this repo uses cards.name.
        if "texts" in tables:
            table = "texts"
            name_col = "name"
            id_col = "id"
        elif "cards" in tables:
            table = "cards"
            id_col = "card_id"
            cols = [r[1] for r in cur.execute("pragma table_info(cards)")]
            print("cards columns:", cols)
            name_cols = [c for c in ("name_en", "name_es") if c in cols]
            if not name_cols:
                raise SystemExit("No supported name columns found in 'cards' (expected name_en/name_es); aborting.")
        else:
            raise SystemExit("Expected table 'texts' or 'cards' not found; aborting.")

        if table == "texts":
            name_cols = [name_col]  # type: ignore[name-defined]

        for col in name_cols:
            before_cnt = cur.execute(f"select count(*) from {table} where {col} like 'Saint - %'").fetchone()[0]
            print(f"Rows matching \"Saint - %\" in {table}.{col} (before):", before_cnt)

            sample_before = cur.execute(
                f"select {id_col}, {col} from {table} where {col} like 'Saint - %' order by {id_col} limit 20"
            ).fetchall()
            if sample_before:
                print(f"Sample before ({col}):")
                for cid, name in sample_before:
                    print(f"  {cid}: {name}")

        # Replace only the leading 'Saint - ' prefix.
        changed_total = 0
        for col in name_cols:
            cur.execute(
                f"""
                update {table}
                   set {col} = 'Bronze Saint - ' || substr({col}, length('Saint - ') + 1)
                 where {col} like 'Saint - %'
                """
            )
            changed_total += max(cur.rowcount, 0)
        con.commit()
        print("Updated rows (total across columns):", changed_total)

        for col in name_cols:
            after_cnt = cur.execute(f"select count(*) from {table} where {col} like 'Saint - %'").fetchone()[0]
            print(f"Rows matching \"Saint - %\" in {table}.{col} (after):", after_cnt)

            sample_after = cur.execute(
                f"select {id_col}, {col} from {table} where {col} like 'Bronze Saint - %' order by {id_col} limit 20"
            ).fetchall()
            if sample_after:
                print(f"Sample after ({col}):")
                for cid, name in sample_after:
                    print(f"  {cid}: {name}")
    finally:
        con.close()


if __name__ == "__main__":
    main()

