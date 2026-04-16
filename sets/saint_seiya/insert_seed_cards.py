import sqlite3


DB_PATH = r"c:\ProjectIgnis\sets\saint_seiya\effects.sqlite3"


def effect_exists(conn: sqlite3.Connection, *, card_id: int, effect_text: str, language: str, is_psct: int) -> bool:
    row = conn.execute(
        """
        SELECT 1
        FROM card_effects
        WHERE card_id = ?
          AND effect_text = ?
          AND language = ?
          AND is_psct = ?
        LIMIT 1
        """,
        (card_id, effect_text, language, is_psct),
    ).fetchone()
    return row is not None


def main() -> None:
    cards = [
        {
            "name": "Hilda de Polaris - Representante de Odín",
            "archetypes": '["odin"]',
            "card_type": "Monster",
            "level": 4,
            "attribute": "WATER",
            "race": "Spellcaster",
            "atk": 1500,
            "def": 1500,
            "notes": "User-provided Spanish concept; stored PSCT in English.",
            "effects": [
                {
                    "effect_text": (
                        "If this card is Normal or Special Summoned: You can add 1 "
                        "\"Palace of Valhalla\" or 1 \"Nibelungo Ring\" from your Deck to your hand.\n"
                        "You can only use this effect of \"Hilda de Polaris - Representante de Odín\" once per turn.\n"
                        "\n"
                        "Once per turn: You can reveal your opponent's hand, then place 1 Frost Counter on 1 card in their hand."
                    ),
                    "language": "en",
                    "is_psct": 1,
                    "source": "chat/psct",
                    "tags_json": '["search","counters","hand-reveal"]',
                }
            ],
        },
        {
            "name": "Flare (Freya) - La Esperanza de Asgard",
            "archetypes": '["odin"]',
            "card_type": "Monster",
            "level": 3,
            "attribute": "LIGHT",
            "race": "Spellcaster",
            "atk": 0,
            "def": 2000,
            "notes": "User-provided Spanish concept; stored PSCT in English.",
            "effects": [
                {
                    "effect_text": (
                        "Once per turn: You can Tribute this card; remove all Frost Counters from the field, and if you do, "
                        "draw 1 card for each counter removed."
                    ),
                    "language": "en",
                    "is_psct": 1,
                    "source": "chat/psct",
                    "tags_json": '["draw","tribute","counters"]',
                }
            ],
        },
    ]

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys=ON")

    for c in cards:
        conn.execute(
            """
            INSERT INTO cards (name, archetypes, card_type, level, attribute, race, atk, def, notes, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, strftime('%Y-%m-%dT%H:%M:%fZ','now'))
            ON CONFLICT(name) DO UPDATE SET
              archetypes=excluded.archetypes,
              card_type=excluded.card_type,
              level=excluded.level,
              attribute=excluded.attribute,
              race=excluded.race,
              atk=excluded.atk,
              def=excluded.def,
              notes=excluded.notes,
              updated_at=strftime('%Y-%m-%dT%H:%M:%fZ','now')
            """,
            (
                c["name"],
                c["archetypes"],
                c["card_type"],
                c["level"],
                c["attribute"],
                c["race"],
                c["atk"],
                c["def"],
                c["notes"],
            ),
        )
        card_id = conn.execute("SELECT id FROM cards WHERE name=?", (c["name"],)).fetchone()[0]

        for e in c["effects"]:
            if not effect_exists(
                conn,
                card_id=card_id,
                effect_text=e["effect_text"],
                language=e["language"],
                is_psct=e["is_psct"],
            ):
                conn.execute(
                    """
                    INSERT INTO card_effects (card_id, effect_text, language, is_psct, source, tags_json)
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    (
                        card_id,
                        e["effect_text"],
                        e["language"],
                        e["is_psct"],
                        e.get("source"),
                        e.get("tags_json"),
                    ),
                )

    conn.commit()

    rows = conn.execute(
        """
        SELECT c.id, c.name, COUNT(e.id) AS effects_count
        FROM cards c
        LEFT JOIN card_effects e ON e.card_id=c.id
        WHERE c.name IN (?, ?)
        GROUP BY c.id, c.name
        ORDER BY c.id
        """,
        (cards[0]["name"], cards[1]["name"]),
    ).fetchall()

    for row in rows:
        print(row)

    conn.close()


if __name__ == "__main__":
    main()

