import sqlite3


def main() -> None:
    db = "c:/ProjectIgnis/sets/sets.sqlite3"
    con = sqlite3.connect(db)
    cur = con.cursor()

    cur.execute(
        """
        SELECT name, sql
        FROM sqlite_master
        WHERE type IN ('table','view')
          AND name NOT LIKE 'sqlite_%'
        ORDER BY name
        """
    )
    rows = cur.fetchall()
    print(f"OBJECTS {len(rows)}")
    for name, sql in rows:
        print(f"\n-- {name} --")
        print(sql or "")

    con.close()


if __name__ == "__main__":
    main()

