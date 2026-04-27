import sqlite3
from pathlib import Path


DB_PATH = Path(r"c:\ProjectIgnis\sets\sets.sqlite3")


def main() -> None:
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    cur.execute(
        """
        UPDATE cards
        SET archetypes_json = REPLACE(archetypes_json, '"bronze"', '"Bronze Saint"')
        WHERE archetypes_json LIKE '%"bronze"%'
        """
    )
    bronze = cur.rowcount

    cur.execute(
        """
        UPDATE cards
        SET archetypes_json = REPLACE(archetypes_json, '"silver"', '"Silver Saint"')
        WHERE archetypes_json LIKE '%"silver"%'
        """
    )
    silver = cur.rowcount

    cur.execute(
        """
        UPDATE cards
        SET archetypes_json = REPLACE(archetypes_json, '"gold"', '"Gold Saint"')
        WHERE archetypes_json LIKE '%"gold"%'
        """
    )
    gold = cur.rowcount

    conn.commit()

    rows = cur.execute(
        "SELECT archetypes_json, COUNT(*) FROM cards GROUP BY archetypes_json ORDER BY COUNT(*) DESC LIMIT 10"
    ).fetchall()
    print(f"updated bronze={bronze} silver={silver} gold={gold}")
    print(rows)

    conn.close()


if __name__ == "__main__":
    main()

