import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_SILVER_SAINT = 0x1DA
    SET_ENVOY = 0x1DD

    TYPE_MONSTER = 0x1
    TYPE_EFFECT = 0x20

    setcode_envoy_silver = SET_SAINT | (SET_SILVER_SAINT << 16) | (SET_ENVOY << 32)

    entries = [
        # id, name, atk, def, level, attr
        (922100111, "Silver Saint - Hound Asterion, Envoy of the Pope", 2400, 2000, 6, 16),
        (922100112, "Silver Saint - Whale Moses, Envoy of the Pope", 2500, 2200, 6, 2),
        (922100113, "Silver Saint - Centaurus Babel, Envoy of the Pope", 2300, 2100, 6, 8),
        (922100114, "Silver Saint - Crow Jamian, Envoy of the Pope", 2400, 1800, 6, 32),
        (922100115, "Silver Saint - Cerberus Dante, Envoy of the Pope", 2500, 2300, 6, 32),
        (922100116, "Silver Saint - Auriga Capella, Envoy of the Pope", 2600, 1900, 6, 16),
        (922100117, "Silver Saint - Canis Major Sirius, Envoy of the Pope", 2500, 2100, 6, 1),
        (922100118, "Silver Saint - Musca Dio, Envoy of the Pope", 2200, 2200, 6, 32),
        (922100119, "Silver Saint - Heracles Algethi, Envoy of the Pope", 2700, 2000, 7, 1),
        (922100120, "Silver Saint - Sagitta Ptolemy, Envoy of the Pope", 2300, 1700, 6, 16),
    ]

    for cid, name, atk, defe, level, attr in entries:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode_envoy_silver, TYPE_MONSTER | TYPE_EFFECT, atk, defe, level, 1, attr, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated 10 cards (111-120).")


if __name__ == "__main__":
    main()

