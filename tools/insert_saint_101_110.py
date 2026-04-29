import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_SILVER_SAINT = 0x1DA
    SET_ENVOY = 0x1DD

    TYPE_TRAP = 0x4
    TYPE_COUNTER = 0x100000
    TYPE_MONSTER = 0x1
    TYPE_EFFECT = 0x20

    counter_traps = [
        (922100101, "Crystal Wall"),
        (922100102, "Circular Defense"),
        (922100103, "The Pope's Verdict"),
        (922100104, "The Miracle of the Saints"),
    ]

    # Pope Ares (not tagged as Envoy in comment block)
    pope_ares = (922100105, "Pope Ares - Voice of the Sanctuary", 1000, 1800, 4, 2, 32)

    # Envoys: Saint + Silver Saint + Envoy
    setcode_envoy_silver = SET_SAINT | (SET_SILVER_SAINT << 16) | (SET_ENVOY << 32)
    envoys = [
        (922100106, "Silver Saint - Marin of Eagle, Envoy of the Pope", 2200, 1400, 6, 1, 8),
        (922100107, "Silver Saint - Shaina of Ophiuchus, Envoy of the Pope", 2400, 1200, 6, 1, 16),
        (922100108, "Silver Saint - Algol of Perseus, Envoy of the Pope", 2300, 1800, 6, 1, 1),
        (922100109, "Silver Saint - Misty of Lacerta, Envoy of the Pope", 2000, 2500, 6, 1, 2),
        (922100110, "Silver Saint - Orphee of Lyra, Envoy of the Pope", 2700, 2000, 7, 1, 16),
    ]

    for cid, name in counter_traps:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, SET_SAINT, TYPE_TRAP | TYPE_COUNTER, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    cid, name, atk, defe, level, race, attr = pope_ares
    c.execute(
        "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        (cid, 4, 0, SET_SAINT, TYPE_MONSTER | TYPE_EFFECT, atk, defe, level, race, attr, 0),
    )
    c.execute(
        "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
    )

    for cid, name, atk, defe, level, race, attr in envoys:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode_envoy_silver, TYPE_MONSTER | TYPE_EFFECT, atk, defe, level, race, attr, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated 10 cards (101-110).")


if __name__ == "__main__":
    main()

