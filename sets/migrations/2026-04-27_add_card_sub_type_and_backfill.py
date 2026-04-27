import re
import sqlite3
from pathlib import Path


DB_PATH = Path(r"c:\ProjectIgnis\sets\sets.sqlite3")

# Matches: "Imported from foo.md (Effect Monster)." -> "Effect Monster"
SUBTYPE_RE = re.compile(r"\((?P<sub>[^()]+?)\)\.\s*$")


def _column_exists(conn: sqlite3.Connection, table: str, col: str) -> bool:
    cols = [r[1] for r in conn.execute(f"PRAGMA table_info({table})").fetchall()]
    return col in cols


def main() -> None:
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys=ON")
    cur = conn.cursor()

    if not _column_exists(conn, "cards", "card_sub_type"):
        cur.execute("ALTER TABLE cards ADD COLUMN card_sub_type TEXT")

    rows = cur.execute(
        """
        SELECT card_id, updated_notes
        FROM cards
        WHERE card_sub_type IS NULL
          AND updated_notes IS NOT NULL
          AND updated_notes LIKE '%(%'
        """
    ).fetchall()

    updated = 0
    for card_id, notes in rows:
        m = SUBTYPE_RE.search(notes or "")
        if not m:
            continue
        sub = m.group("sub").strip()
        if not sub:
            continue
        cur.execute("UPDATE cards SET card_sub_type=? WHERE card_id=?", (sub, card_id))
        updated += 1

    conn.commit()

    total_with_sub = cur.execute(
        "SELECT COUNT(*) FROM cards WHERE card_sub_type IS NOT NULL"
    ).fetchone()[0]
    total = cur.execute("SELECT COUNT(*) FROM cards").fetchone()[0]

    print(f"added_column=true backfilled={updated} with_subtype={total_with_sub}/{total}")
    conn.close()


if __name__ == "__main__":
    main()

