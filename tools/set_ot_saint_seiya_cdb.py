import argparse
import sqlite3


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default="expansions/saint-seiya.cdb")
    ap.add_argument("--start", type=int, default=922100000)
    ap.add_argument("--end", type=int, default=922100171)
    ap.add_argument("--ot", type=int, default=3)
    args = ap.parse_args()

    con = sqlite3.connect(args.db)
    cur = con.cursor()
    cur.execute("SELECT ot, COUNT(*) FROM datas WHERE id BETWEEN ? AND ? GROUP BY ot ORDER BY ot", (args.start, args.end))
    before = cur.fetchall()

    cur.execute("UPDATE datas SET ot=? WHERE id BETWEEN ? AND ?", (args.ot, args.start, args.end))
    changed = cur.rowcount
    con.commit()

    cur.execute("SELECT ot, COUNT(*) FROM datas WHERE id BETWEEN ? AND ? GROUP BY ot ORDER BY ot", (args.start, args.end))
    after = cur.fetchall()
    con.close()

    print("before_ot_counts", before)
    print("rows_updated", changed)
    print("after_ot_counts", after)


if __name__ == "__main__":
    main()

