import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_BLACK_SAINT = 0x1E1
    SET_FRAGMENT = 0x1E2

    TYPE_MONSTER = 0x1
    TYPE_EFFECT = 0x20
    TYPE_EQUIP = 0x40002  # Spell + Equip

    setcode_black = SET_SAINT | (SET_BLACK_SAINT << 16)
    setcode_fragment = SET_FRAGMENT | (SET_SAINT << 16)

    monsters = [
        (922100151, "Black Saint - Dark Dragon", 1600, 1700, 4, 1, 32),
        (922100152, "Black Saint - Dark Cygnus", 1500, 1300, 4, 1, 32),
        (922100153, "Black Saint - Dark Andromeda", 1400, 1900, 4, 1, 32),
        (922100154, "Black Saint - Dark Phoenix", 1700, 1000, 4, 1, 32),
    ]

    equips = [
        (922100155, "Fragment of Sagittarius - Helmet"),
        (922100156, "Fragment of Sagittarius - Chestplate"),
        (922100157, "Fragment of Sagittarius - Skirt"),
        (922100158, "Fragment of Sagittarius - Left Arm"),
        (922100159, "Fragment of Sagittarius - Right Arm"),
        (922100160, "Fragment of Sagittarius - Right Leg"),
    ]

    for cid, name, atk, defe, level, race, attr in monsters:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode_black, TYPE_MONSTER | TYPE_EFFECT, atk, defe, level, race, attr, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    for cid, name in equips:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode_fragment, TYPE_EQUIP, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated 10 cards (151-160).")


if __name__ == "__main__":
    main()

