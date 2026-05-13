import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_POPES_MANDATE = 0x1DE
    SET_STEEL_SAINT = 0x1E0
    SET_BLACK_SAINT = 0x1E1

    TYPE_MONSTER = 0x1
    TYPE_EFFECT = 0x20
    TYPE_SPELL = 0x2
    TYPE_TRAP = 0x4
    TYPE_QUICKPLAY = 0x10000
    TYPE_CONTINUOUS = 0x20000
    TYPE_COUNTER = 0x100000

    setcode_mandate = SET_POPES_MANDATE
    setcode_steel = SET_SAINT | (SET_STEEL_SAINT << 16)
    setcode_black = SET_SAINT | (SET_BLACK_SAINT << 16)

    traps_spells = [
        (922100141, "Pope's Mandate - Silence the Rebels", TYPE_TRAP | TYPE_CONTINUOUS, setcode_mandate),
        (922100142, "Pope's Mandate - Absolute Verdict", TYPE_TRAP | TYPE_COUNTER, setcode_mandate),
        (922100146, "Steel Assistance System", TYPE_SPELL | TYPE_QUICKPLAY, SET_STEEL_SAINT),
        (922100147, "Interception Protocol", TYPE_TRAP | TYPE_COUNTER, SET_STEEL_SAINT),
    ]

    monsters = [
        # id, name, atk, def, level, race, attr, setcode
        (922100143, "Steel Saint - Sho of Sky Armor", 1200, 1200, 4, 32, 8, setcode_steel),
        (922100144, "Steel Saint - Daichi of Land Armor", 1400, 1800, 4, 32, 1, setcode_steel),
        (922100145, "Steel Saint - Ushio of Marine Armor", 1300, 1500, 4, 32, 2, setcode_steel),
        (922100148, "Black Saint - Ikki, Leader of Death Queen Island", 2400, 1800, 6, 1, 32, setcode_black),
        (922100149, "Black Saint - Jango, Commander of the Shadow", 1700, 1000, 4, 1, 32, setcode_black),
        (922100150, "Black Saint - Dark Pegasus", 1800, 1100, 4, 1, 32, setcode_black),
    ]

    for cid, name, typ, setcode in traps_spells:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode, typ, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    for cid, name, atk, defe, level, race, attr, setcode in monsters:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode, TYPE_MONSTER | TYPE_EFFECT, atk, defe, level, race, attr, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated 10 cards (141-150).")


if __name__ == "__main__":
    main()

