import json
import sqlite3
from pathlib import Path


DB_PATH = Path(r"c:\ProjectIgnis\sets\sets.sqlite3")

RULES: list[tuple[str, str]] = [
    ("black saint", "Black Saint"),
    ("fragment of sagittarius", "Fragment of Sagittarius"),
]


def _load_tags(archetypes_json: str | None) -> list[str]:
    if not archetypes_json:
        return []
    try:
        v = json.loads(archetypes_json)
        return v if isinstance(v, list) else []
    except Exception:
        return []


def main() -> None:
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    total_updated = 0
    per_rule: list[tuple[str, int, int]] = []

    for needle, tag in RULES:
        rows = cur.execute(
            """
            SELECT card_id, archetypes_json
            FROM cards
            WHERE name_en IS NOT NULL
              AND LOWER(name_en) LIKE ?
            """,
            (f"%{needle}%",),
        ).fetchall()

        updated = 0
        for card_id, archetypes_json in rows:
            tags = _load_tags(archetypes_json)
            if tag in tags:
                continue
            tags.append(tag)
            tags = sorted(set(tags))
            cur.execute(
                "UPDATE cards SET archetypes_json = ? WHERE card_id = ?",
                (json.dumps(tags, ensure_ascii=False), card_id),
            )
            updated += 1

        per_rule.append((tag, len(rows), updated))
        total_updated += updated

    conn.commit()

    totals = {}
    for _needle, tag in RULES:
        totals[tag] = cur.execute(
            "SELECT COUNT(*) FROM cards WHERE archetypes_json LIKE ?",
            (f'%"{tag}"%',),
        ).fetchone()[0]

    print(f"total_updated={total_updated}")
    for tag, matched, updated in per_rule:
        print(f"{tag}: matched={matched} updated={updated} total_with_tag={totals[tag]}")

    conn.close()


if __name__ == "__main__":
    main()

