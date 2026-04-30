import sqlite3


def main() -> None:
    start = 922100000
    end = 922100171

    con = sqlite3.connect("expansions/cards-unofficial.cdb")
    cur = con.cursor()

    cur.execute("SELECT COUNT(*) FROM datas WHERE id BETWEEN ? AND ?", (start, end))
    datas_before = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM texts WHERE id BETWEEN ? AND ?", (start, end))
    texts_before = cur.fetchone()[0]

    cur.execute("DELETE FROM datas WHERE id BETWEEN ? AND ?", (start, end))
    datas_deleted = cur.rowcount
    cur.execute("DELETE FROM texts WHERE id BETWEEN ? AND ?", (start, end))
    texts_deleted = cur.rowcount

    con.commit()

    cur.execute("SELECT COUNT(*) FROM datas WHERE id BETWEEN ? AND ?", (start, end))
    datas_after = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM texts WHERE id BETWEEN ? AND ?", (start, end))
    texts_after = cur.fetchone()[0]

    con.close()

    print(f"datas_before: {datas_before}")
    print(f"texts_before: {texts_before}")
    print(f"datas_deleted: {datas_deleted}")
    print(f"texts_deleted: {texts_deleted}")
    print(f"datas_after: {datas_after}")
    print(f"texts_after: {texts_after}")


if __name__ == "__main__":
    main()

