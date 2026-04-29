import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7

    TYPE_SPELL = 0x2
    TYPE_MONSTER = 0x1
    TYPE_EFFECT = 0x20
    TYPE_QUICKPLAY = 0x10000

    spell_entries = [
        (922100091, "Repairs in Jamir", TYPE_SPELL),
        (922100092, "Bond of Brotherhood", TYPE_SPELL | TYPE_QUICKPLAY),
        (922100093, "Pegasus Comet", TYPE_SPELL),
        (922100094, "Nebula Storm", TYPE_SPELL | TYPE_QUICKPLAY),
    ]

    monster_entries = [
        # id, name, atk, def, level, race, attribute
        (922100095, "Cassios' Intervention", 1800, 2500, 4, 1, 1),
        (922100096, "Marin - Guide of the Apprentice", 1400, 1600, 4, 1, 8),
        (922100097, "Shaina - Paralyzing Cobra", 1600, 1400, 4, 1, 16),
        (922100098, "Mitsumasa Kido - Legacy of the Foundation", 0, 0, 1, 1, 1),
        (922100100, "Tatsumi - Guardian of the Mansion", 1000, 1000, 3, 1, 1),
    ]

    for cid, name, typ in spell_entries:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, SET_SAINT, typ, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    for cid, name, atk, defe, level, race, attr in monster_entries:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, SET_SAINT, TYPE_MONSTER | TYPE_EFFECT, atk, defe, level, race, attr, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated cards 091-098 and 100 (099 missing).")


if __name__ == "__main__":
    main()

