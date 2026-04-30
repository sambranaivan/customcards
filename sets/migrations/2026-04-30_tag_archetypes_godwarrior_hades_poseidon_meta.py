import json
import sqlite3
from pathlib import Path


DB_PATH = Path(r"c:\ProjectIgnis\sets\sets.sqlite3")


def _load_tags(archetypes_json: str | None) -> list[str]:
    if not archetypes_json:
        return []
    try:
        v = json.loads(archetypes_json)
        return v if isinstance(v, list) else []
    except Exception:
        return []


def _add_tag_if_missing(conn: sqlite3.Connection, *, where_sql: str, where_args: tuple, tag: str) -> tuple[int, int]:
    cur = conn.cursor()
    rows = cur.execute(
        f"SELECT card_id, archetypes_json FROM cards WHERE {where_sql}",
        where_args,
    ).fetchall()

    matched = len(rows)
    updated = 0
    for card_id, archetypes_json in rows:
        tags = _load_tags(archetypes_json)
        if tag in tags:
            continue
        tags.append(tag)
        tags = sorted(set(tags))
        cur.execute(
            "UPDATE cards SET archetypes_json=? WHERE card_id=?",
            (json.dumps(tags, ensure_ascii=False), card_id),
        )
        updated += 1

    return matched, updated


def _count_tag(conn: sqlite3.Connection, tag: str) -> int:
    return conn.execute(
        "SELECT COUNT(*) FROM cards WHERE archetypes_json LIKE ?",
        (f'%"{tag}"%',),
    ).fetchone()[0]


def main() -> None:
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys=ON")

    rules: list[tuple[str, tuple, str]] = []

    # By file source (most reliable for Meta staples)
    rules.append(("updated_source_ref LIKE ?", ("%meta_card_effect.md",), "Meta"))

    # God Warriors
    rules.append(("LOWER(name_en) LIKE ?", ("%god warrior%",), "God Warrior"))
    rules.append(("LOWER(name_en) LIKE ?", ("%palace of valhalla%",), "God Warrior"))
    rules.append(("LOWER(name_en) LIKE ?", ("%odin%",), "God Warrior"))

    # Hades / Specter
    rules.append(("LOWER(name_en) LIKE ?", ("%specter%",), "Specter"))
    rules.append(("LOWER(name_en) LIKE ?", ("%hades%",), "Hades"))
    rules.append(("LOWER(name_en) LIKE ?", ("%underworld%",), "Hades"))
    rules.append(("LOWER(name_en) LIKE ?", ("%renegade saint%",), "Renegade Saint"))

    # Poseidon / Pillars / Marine Generals
    rules.append(("LOWER(name_en) LIKE ?", ("%poseidon%",), "Poseidon"))
    rules.append(("LOWER(name_en) LIKE ?", ("%pillar%",), "Pillar"))
    rules.append(("LOWER(name_en) LIKE ?", ("%marine general%",), "Marine General"))

    total_updated = 0
    per_rule: list[tuple[str, int, int]] = []

    for where_sql, where_args, tag in rules:
        matched, updated = _add_tag_if_missing(conn, where_sql=where_sql, where_args=where_args, tag=tag)
        per_rule.append((tag, matched, updated))
        total_updated += updated

    conn.commit()

    print(f"total_updated={total_updated}")
    for tag, matched, updated in per_rule:
        print(f"{tag}: matched={matched} updated={updated} total_with_tag={_count_tag(conn, tag)}")

    conn.close()


if __name__ == "__main__":
    main()

