import json
import sqlite3
from pathlib import Path


DB_PATH = Path(r"c:\ProjectIgnis\sets\sets.sqlite3")
TAG = "Envoy of the Pope"


def main() -> None:
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    rows = cur.execute(
        """
        SELECT card_id, name_en, archetypes_json
        FROM cards
        WHERE name_en IS NOT NULL
          AND LOWER(name_en) LIKE '%envoy of the pope%'
        """,
    ).fetchall()

    updated = 0
    for card_id, name_en, archetypes_json in rows:
        if archetypes_json:
            try:
                tags = json.loads(archetypes_json)
                if not isinstance(tags, list):
                    tags = []
            except Exception:
                tags = []
        else:
            tags = []

        if TAG not in tags:
            tags.append(TAG)
            tags = sorted(set(tags))
            cur.execute(
                "UPDATE cards SET archetypes_json = ? WHERE card_id = ?",
                (json.dumps(tags, ensure_ascii=False), card_id),
            )
            updated += 1

    conn.commit()

    total_envoy = cur.execute(
        "SELECT COUNT(*) FROM cards WHERE archetypes_json LIKE '%\"Envoy of the Pope\"%'"
    ).fetchone()[0]

    print(f"matched={len(rows)} updated={updated} total_with_tag={total_envoy}")
    conn.close()


if __name__ == "__main__":
    main()

