import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_SILVER_SAINT = 0x1DA
    SET_GOLD_SAINT = 0x1DB
    SET_ENVOY = 0x1DD
    SET_GHOST_SAINT = 0x1DF

    TYPE_MONSTER = 0x1
    TYPE_EFFECT = 0x20

    setcode_envoy_silver_saint = SET_SAINT | (SET_SILVER_SAINT << 16) | (SET_ENVOY << 32)
    setcode_envoy_only = SET_ENVOY
    setcode_envoy_silver_only = SET_SILVER_SAINT | (SET_ENVOY << 16)
    setcode_ghost = SET_SAINT | (SET_ENVOY << 16) | (SET_GHOST_SAINT << 32)
    setcode_envoy_gold = SET_SAINT | (SET_GOLD_SAINT << 16) | (SET_ENVOY << 32)

    entries = [
        # id, name, atk, def, level, race, attr, setcode
        (922100121, "Silver Saint - Cepheus Daidalos, Envoy of the Pope", 2400, 2400, 6, 1, 16, setcode_envoy_silver_saint),
        (922100122, "Ghost Saint - Geist, Envoy of the Pope", 1400, 1400, 4, 1, 32, setcode_ghost),
        (922100123, "Ghost Saint - Astaroth, Envoy of the Pope", 1200, 800, 3, 8, 32, setcode_ghost),
        (922100124, "Ghost Saint - Iguana, Envoy of the Pope", 800, 400, 2, 8192, 1, setcode_ghost),
        (922100125, "Cassios, Envoy of the Pope", 1800, 1400, 4, 1, 1, setcode_envoy_only),
        (922100126, "Shiva of Peacock, Envoy of the Pope", 1700, 1600, 5, 1, 16, setcode_envoy_only),
        (922100127, "Agora of Lotus, Envoy of the Pope", 1800, 1500, 5, 2, 32, setcode_envoy_only),
        (922100128, "Docrates, Envoy of the Pope", 2400, 1600, 6, 1, 1, setcode_envoy_silver_only),
        (922100129, "Jango of the Boomerang, Envoy of the Pope", 1800, 1200, 5, 1, 8, setcode_envoy_silver_only),
        (922100130, "Gold Saint - Deathmask of Cancer, Envoy of the Pope", 2900, 2500, 8, 1, 32, setcode_envoy_gold),
    ]

    for cid, name, atk, defe, level, race, attr, setcode in entries:
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
    print("Inserted/updated 10 cards (121-130).")


if __name__ == "__main__":
    main()

