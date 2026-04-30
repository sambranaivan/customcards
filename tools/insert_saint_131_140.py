import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_GOLD_SAINT = 0x1DB
    SET_ENVOY = 0x1DD
    SET_POPES_MANDATE = 0x1DE

    TYPE_MONSTER = 0x1
    TYPE_EFFECT = 0x20
    TYPE_SPELL = 0x2
    TYPE_QUICKPLAY = 0x10000
    TYPE_CONTINUOUS = 0x20000

    setcode_envoy_gold = SET_SAINT | (SET_GOLD_SAINT << 16) | (SET_ENVOY << 32)
    setcode_mandate = SET_POPES_MANDATE | (SET_SAINT << 16)

    monsters = [
        # id, name, atk, def, level, race, attr, setcode
        (922100131, "Gold Saint - Aphrodite of Pisces, Envoy of the Pope", 2700, 2700, 8, 1, 32, setcode_envoy_gold),
        (922100132, "Gold Saint - Shura of Capricorn, Envoy of the Pope", 2800, 2100, 8, 1, 1, setcode_envoy_gold),
        (922100133, "Gold Saint - Camus of Aquarius, Envoy of the Pope", 2700, 2600, 8, 1, 2, setcode_envoy_gold),
        (922100134, "Gold Saint - Aiolia of Leo, Envoy of the Pope", 2800, 2000, 8, 4, 16, setcode_envoy_gold),
        (922100135, "Pope Ares - Usurper of the Sanctuary", 3200, 2800, 10, 2, 32, SET_SAINT),
        (922100136, "Gold Saint - Saga of Gemini, Envoy of the Pope", 3200, 2800, 10, 1, 32, setcode_envoy_gold),
    ]

    spells = [
        (922100137, "Pope's Mandate - Chain of Command", TYPE_SPELL | TYPE_CONTINUOUS),
        (922100138, "Pope's Guard", TYPE_SPELL | TYPE_QUICKPLAY),
        (922100139, "Pope's Mandate - Extermination Order", TYPE_SPELL),
        (922100140, "Pope's Mandate - Sanctuary Judgment", TYPE_SPELL | TYPE_QUICKPLAY),
    ]

    for cid, name, atk, defe, level, race, attr, setcode in monsters:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode, TYPE_MONSTER | TYPE_EFFECT, atk, defe, level, race, attr, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    for cid, name, typ in spells:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode_mandate, typ, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated 10 cards (131-140).")


if __name__ == "__main__":
    main()

