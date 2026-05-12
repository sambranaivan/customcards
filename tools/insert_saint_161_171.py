import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_BLACK_SAINT = 0x1E1
    SET_FRAGMENT = 0x1E2

    TYPE_MONSTER = 0x1
    TYPE_EFFECT = 0x20
    TYPE_SPELL = 0x2
    TYPE_TRAP = 0x4
    TYPE_EQUIP = 0x40002
    TYPE_FIELD = 0x80002
    TYPE_CONTINUOUS = 0x20000
    TYPE_QUICKPLAY = 0x10000
    TYPE_COUNTER = 0x100000

    setcode_black = SET_SAINT | (SET_BLACK_SAINT << 16)
    setcode_fragment = SET_FRAGMENT | (SET_SAINT << 16)

    entries = [
        # 161 equip
        ("equip", 922100161, "Fragment of Sagittarius - Left Leg", TYPE_EQUIP, setcode_fragment, 0, 0, 0, 0, 0),
        # 162 monster
        ("mon", 922100162, "Desecrated Sagittarius - Reassembled Gold Cloth", TYPE_MONSTER | TYPE_EFFECT, (SET_BLACK_SAINT << 16) | SET_SAINT, 3000, 2500, 8, 1, 32),
        # 163 field
        ("spell", 922100163, "Death Queen Island", TYPE_SPELL | TYPE_FIELD, SET_SAINT, 0, 0, 0, 0, 0),
        ("spell", 922100164, "The Stolen Gold Cloth", TYPE_SPELL, SET_SAINT, 0, 0, 0, 0, 0),
        ("trap", 922100165, "Desecrated Sagittarius - The Heist", TYPE_TRAP | TYPE_COUNTER, SET_SAINT, 0, 0, 0, 0, 0),
        ("trap", 922100166, "Oath of the Shadow", TYPE_TRAP | TYPE_CONTINUOUS, SET_SAINT, 0, 0, 0, 0, 0),
        ("mon", 922100167, "Saint - Seiya, Cosmos of His Companions", TYPE_MONSTER | TYPE_EFFECT, SET_SAINT, 2600, 1900, 7, 1, 16),
        ("mon", 922100168, "Esmeralda, Light of Death Queen Island", TYPE_MONSTER | TYPE_EFFECT, SET_SAINT, 400, 1200, 2, 2, 16),
        ("mon", 922100169, "Guilty, Master of Hell", TYPE_MONSTER | TYPE_EFFECT, SET_SAINT, 2100, 1500, 5, 1, 32),
        ("spell", 922100170, "Esmeralda's Last Will", TYPE_SPELL | TYPE_QUICKPLAY, SET_SAINT, 0, 0, 0, 0, 0),
        ("spell", 922100171, "Guilty's Cruel Trial", TYPE_SPELL | TYPE_CONTINUOUS, SET_SAINT, 0, 0, 0, 0, 0),
    ]

    for kind, cid, name, typ, setcode, atk, defe, level, race, attr in entries:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode, typ, atk, defe, level, race, attr, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated 11 cards (161-171).")


if __name__ == "__main__":
    main()

